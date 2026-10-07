#requires -Version 5.1
# Loading this file never changes game settings.
Set-StrictMode -Version 2.0
$script:GearsToolDirectory = $PSScriptRoot
. (Join-Path $PSScriptRoot 'GameProfile.ps1')

function Get-GearsLanguageCatalog {
    $text = @(
        @('ko','한국어'), @('en','영어'), @('ja','일본어'),
        @('fr','프랑스어'), @('de','독일어'), @('it','이탈리아어'),
        @('es-ES','스페인어 (스페인)'), @('es-419','스페인어 (중남미)'),
        @('pt-BR','포르투갈어 (브라질)'), @('pt-PT','포르투갈어 (포르투갈)'),
        @('zh-Hans','중국어 간체'), @('zh-Hant','중국어 번체'),
        @('ar','아랍어'), @('cs','체코어'), @('fi','핀란드어'), @('hu','헝가리어'),
        @('nb','노르웨이어'), @('nl','네덜란드어'), @('pl','폴란드어'),
        @('ru','러시아어'), @('sv','스웨덴어'), @('tr','튀르키예어')
    ) | ForEach-Object { [pscustomobject]@{Code=$_[0]; Name=$_[1]} }
    $voice = @(
        @('en','영어','English(US)',23), @('ko','한국어','Korean',27),
        @('ja','일본어','Japanese',33), @('fr','프랑스어','French(France)',24),
        @('de','독일어','German',25), @('it','이탈리아어','Italian',26),
        @('es-ES','스페인어 (스페인)','Spanish(Spain)',31),
        @('es-419','스페인어 (중남미)','Spanish(Mexico)',30),
        @('pt-BR','포르투갈어 (브라질)','Portuguese(Brazil)',29)
    ) | ForEach-Object { [pscustomobject]@{Code=$_[0];Name=$_[1];Bank=$_[2];Chunk=[int]$_[3]} }
    [pscustomobject]@{Text=@($text); Voice=@($voice)}
}

function Find-GearsConfigDirectory {
    $path = Join-Path $env:LOCALAPPDATA 'Microsoft\Gears of War E-Day\WinGDK\6BE41AB5\Saved\Config\WinGDK'
    if (Test-Path -LiteralPath $path -PathType Container) { return [IO.Path]::GetFullPath($path) }
    throw '게임 설정 폴더를 찾지 못했습니다. 게임을 한 번 실행한 뒤 종료하거나 설정 폴더를 직접 선택하세요.'
}

function Resolve-GearsConfigDirectory {
    param([Parameter(Mandatory)][string]$ConfigDirectory)
    $item = Get-Item -LiteralPath $ConfigDirectory -ErrorAction Stop
    if (-not $item.PSIsContainer) { throw '설정 폴더를 지정하세요.' }
    if (-not (Test-Path -LiteralPath (Join-Path $item.FullName 'GameUserSettings.ini') -PathType Leaf)) {
        throw 'GameUserSettings.ini가 있는 실제 설정 폴더를 선택하세요.'
    }
    $item.FullName.TrimEnd('\','/')
}

function Get-GearsDigest {
    param([byte[]]$Bytes)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-GearsStorage {
    param([string]$ConfigDirectory)
    $id = (Get-GearsDigest ([Text.Encoding]::UTF8.GetBytes($ConfigDirectory.ToLowerInvariant()))).Substring(0,20)
    $directory = Join-Path (Join-Path $script:GearsToolDirectory 'backups') $id
    [pscustomobject]@{ Directory=$directory; StatePath=(Join-Path $directory 'active.json'); Id=$id }
}

function Read-GearsFile {
    param([string]$Path)
    if (-not [IO.File]::Exists($Path)) {
        return [pscustomobject]@{ Exists=$false; Bytes=[byte[]]@(); Text=''; Encoding=[Text.UTF8Encoding]::new($false,$true); Attributes=[int][IO.FileAttributes]::Archive }
    }
    $bytes = [IO.File]::ReadAllBytes($Path)
    $offset=0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
        $encoding=[Text.UTF8Encoding]::new($true,$true); $offset=3
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 255 -and $bytes[1] -eq 254) {
        $encoding=[Text.UnicodeEncoding]::new($false,$true,$true); $offset=2
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 254 -and $bytes[1] -eq 255) {
        $encoding=[Text.UnicodeEncoding]::new($true,$true,$true); $offset=2
    } else { $encoding=[Text.UTF8Encoding]::new($false,$true) }
    try { $text=$encoding.GetString($bytes,$offset,$bytes.Length-$offset) }
    catch { throw "설정 파일의 문자 인코딩을 안전하게 읽을 수 없습니다: $Path" }
    [pscustomobject]@{Exists=$true;Bytes=$bytes;Text=$text;Encoding=$encoding;Attributes=[int][IO.File]::GetAttributes($Path)}
}

function ConvertTo-GearsBytes {
    param([string]$Text, [Text.Encoding]$Encoding)
    [byte[]]$bytes = @($Encoding.GetPreamble()) + @($Encoding.GetBytes($Text))
    return ,$bytes
}

function Get-GearsRules {
    @(
        [pscustomobject]@{File='Game.ini';Section='/Script/AkAudio.AkSettings';Keys=@('UnrealCultureToWwiseCulture')},
        [pscustomobject]@{File='GameUserSettings.ini';Section='Internationalization';Keys=@('Culture','Language','Locale')}
    )
}

function Edit-GearsIni {
    param([AllowEmptyString()][string]$Text,[string]$Section,[string[]]$Keys,[string[]]$NewLines=@())
    $crlf=([string][char]13)+[char]10
    $newline = if ($Text.Contains($crlf)) { $crlf } elseif ($Text.Contains([string][char]10)) { [string][char]10 } else { $crlf }
    $lines = [regex]::Split($Text, '\r\n|\n|\r')
    $out = [Collections.Generic.List[string]]::new()
    $removed = [Collections.Generic.List[string]]::new()
    $inside=$false; $insertAt=-1; $sectionIndex=-1
    $keyPattern='^\s*[+.!-]?(?:' + (($Keys | ForEach-Object {[regex]::Escape($_)}) -join '|') + ')\s*='
    for ($i=0; $i -lt $lines.Length; $i++) {
        $line=$lines[$i]
        if ($line -match '^\s*\[([^\]]+)\]\s*(?:[;#].*)?$') {
            if ($inside) { $insertAt=$out.Count }
            $inside=($Matches[1] -ieq $Section)
            if ($inside) { $sectionIndex=$out.Count }
            $out.Add($line)
            continue
        }
        if ($inside -and $line -match $keyPattern) {
            $removed.Add($line)
            $value=$line.Substring($line.IndexOf('=')+1)
            $plain=[regex]::Replace($value, '"(?:\\.|[^"\\])*"', '')
            $depth=([regex]::Matches($plain,'\(')).Count-([regex]::Matches($plain,'\)')).Count
            while (($depth -gt 0 -or $line.TrimEnd().EndsWith('\')) -and $i+1 -lt $lines.Length) {
                $i++; $line=$lines[$i]
                if ($line -match '^\s*\[') { throw '언어 설정이 여러 줄에 걸쳐 있지만 끝이 잘못되어 있습니다. 파일을 확인하세요.' }
                $removed.Add($line)
                $plain=[regex]::Replace($line, '"(?:\\.|[^"\\])*"', '')
                $depth+=([regex]::Matches($plain,'\(')).Count-([regex]::Matches($plain,'\)')).Count
            }
            if ($depth -gt 0) { throw '언어 설정의 괄호가 닫히지 않았습니다.' }
            continue
        }
        $out.Add($line)
    }
    if ($inside) { $insertAt=$out.Count }
    if ($NewLines.Count -gt 0) {
        if ($sectionIndex -lt 0) {
            if ($out.Count -gt 0 -and $out[$out.Count-1] -ne '') { $out.Add('') }
            $out.Add("[$Section]")
            $insertAt=$out.Count
        }
        if ($sectionIndex -ge 0) { $insertAt=$sectionIndex+1 }
        $out.InsertRange($insertAt, [string[]]$NewLines)
    }
    if ($NewLines.Count -eq 0) {
        for ($i=$out.Count-1; $i -ge 0; $i--) {
            if ($out[$i] -match '^\s*\[([^\]]+)\]\s*$' -and $Matches[1] -ieq $Section) {
                $end=$i+1
                while ($end -lt $out.Count -and $out[$end] -notmatch '^\s*\[') { $end++ }
                $nonempty=$false
                for ($j=$i+1; $j -lt $end; $j++) { if ($out[$j].Trim().Length -gt 0) { $nonempty=$true } }
                if (-not $nonempty) { $out.RemoveRange($i,$end-$i) }
            }
        }
    }
    $result=($out -join $newline)
    if ($result.Length -gt 0 -and -not $result.EndsWith($newline)) { $result+=$newline }
    [pscustomobject]@{Text=$result;Removed=@($removed.ToArray())}
}

function Get-GearsSelection {
    param([Parameter(Mandatory)][string]$VoiceLanguage,[string]$TextLanguage='')
    $catalog=Get-GearsLanguageCatalog
    $voice=@($catalog.Voice | Where-Object Code -EQ $VoiceLanguage)
    if ($voice.Count -ne 1) { throw '설정된 음성 언어를 확인하지 못했습니다. 게임에서 음성용 언어를 먼저 선택하세요.' }
    $text=$null
    if ($TextLanguage) {
        $matches=@($catalog.Text | Where-Object Code -EQ $TextLanguage)
        if ($matches.Count -ne 1) { throw '자막·메뉴 언어를 선택하세요.' }
        $text=$matches[0]
    }
    $cultures=@($catalog.Text.Code) + @('en-US','en-GB','ko-KR','ja-JP','fr-FR','de-DE','it-IT','es','es-MX','zh-CN','zh-TW','zh-HK','ar-SA','cs-CZ','fi-FI','hu-HU','nb-NO','nl-NL','pl-PL','ru-RU','sv-SE','tr-TR')
    $cultures=@($cultures | Select-Object -Unique)
    $pairs=@($cultures | ForEach-Object { '("' + $_ + '","' + $voice[0].Bank + '")' })
    $cultureLines=@()
    if ($text) {
        # Saved/Config is a flattened array, not a DefaultGame.ini command stream.
        # UE 5.5 ConfigContext loads SavedLayer with bHandleSymbolCommands=false.
        # Prefixes such as + and ! become literal keys and GetArray cannot see them.
        $cultureLines=@($cultures | ForEach-Object { 'CultureMappings="' + $_ + ';' + $text.Code + '"' })
    }
    [pscustomobject]@{
        Text=$text;Voice=$voice[0]
        AudioLine=('UnrealCultureToWwiseCulture=(' + ($pairs -join ',') + ')')
        CultureLines=$cultureLines
    }
}

function Get-GearsVoiceStatus {
    param([Parameter(Mandatory)][string]$ConfigDirectory)
    $dir=Resolve-GearsConfigDirectory $ConfigDirectory
    $catalog=Get-GearsLanguageCatalog
    $profile=Get-GearsGameProfileLanguage -ConfigDirectory $dir
    $file=Read-GearsFile (Join-Path $dir 'Game.ini')
    $lines=(Edit-GearsIni $file.Text '/Script/AkAudio.AkSettings' @('UnrealCultureToWwiseCulture')).Removed
    $pairs=[regex]::Matches(($lines -join ' '), '\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)')
    $banks=@($pairs | ForEach-Object {$_.Groups[2].Value} | Select-Object -Unique)
    $bank=''
    if ($banks.Count -eq 1) { $bank=$banks[0] }
    elseif ($profile.Known) {
        $matching=@($pairs | Where-Object { $_.Groups[1].Value -ceq $profile.Language })
        if ($matching.Count -gt 0) { $bank=$matching[$matching.Count-1].Groups[2].Value }
    }
    $voice=@()
    if ($bank) { $voice=@($catalog.Voice | Where-Object Bank -CEQ $bank) }
    elseif ($profile.Known -and $pairs.Count -eq 0) {
        $voice=@($catalog.Voice | Where-Object Code -CEQ $profile.Language)
        if ($voice.Count -eq 0 -and $profile.Language -in @('ar','cs','fi','hu','nb','nl','pl','pt-PT','ru','sv','tr')) {
            $voice=@($catalog.Voice | Where-Object Code -EQ 'en')
        }
    }
    if ($voice.Count -ne 1) {
        return [pscustomobject]@{Known=$false;Language='';Bank='';Summary='설정된 음성 언어를 확인하지 못했습니다. 게임에서 음성용 언어를 먼저 선택하세요.'}
    }
    [pscustomobject]@{
        Known=$true;Language=$voice[0].Code;Bank=$voice[0].Bank
        Summary=("설정된 음성 언어: $($voice[0].Name). 실제 재생 언어를 감지하는 표시는 아닙니다.")
    }
}

function Get-GearsPreview {
    param([Parameter(Mandatory)][string]$ConfigDirectory,[Parameter(Mandatory)][string]$TextLanguage)
    $voice=Get-GearsVoiceStatus $ConfigDirectory
    if (-not $voice.Known) { throw $voice.Summary }
    $selection=Get-GearsSelection -VoiceLanguage $voice.Language -TextLanguage $TextLanguage
    (@('Game.ini (적용 후 읽기 전용)','[Internationalization]') + $selection.CultureLines +
        @('','[/Script/AkAudio.AkSettings]',$selection.AudioLine)) -join [Environment]::NewLine
}

function Get-GearsVoicePackStatus {
    param([string]$VoiceLanguage)
    $voice=@((Get-GearsLanguageCatalog).Voice | Where-Object Code -EQ $VoiceLanguage)
    if ($voice.Count -ne 1) { return [pscustomobject]@{Available=$false;Summary='음성 언어를 선택하세요.'} }
    $paks=Join-Path (Split-Path $script:GearsToolDirectory -Parent) 'Content\FairlightConcept\Content\Paks'
    $missing=@()
    foreach ($extension in @('utoc','ucas')) {
        $path=Join-Path $paks ("pakchunk{0}-WinGDK.{1}" -f $voice[0].Chunk,$extension)
        if (-not [IO.File]::Exists($path) -or (Get-Item -LiteralPath $path).Length -eq 0) { $missing+=$extension }
    }
    if ($missing.Count -gt 0) {
        return [pscustomobject]@{Available=$false;Summary=($voice[0].Name + ' 기본 음성 파일이 비어 있거나 없습니다. 게임 설정 > 시스템에서 이 언어팩 설치를 100% 완료하세요.')}
    }
    [pscustomobject]@{Available=$true;Summary=($voice[0].Name + ' 기본 음성 파일을 확인했습니다. 모드별 추가 설치·게임 내 활성화 여부는 게임에서 확인하세요.')}
}

function Read-GearsState {
    param($Storage,[string]$ConfigDirectory)
    if (-not [IO.File]::Exists($Storage.StatePath)) { return $null }
    $state=Get-Content -LiteralPath $Storage.StatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($state.Version -notin @(1,2,3) -or $state.ConfigDirectory -ine $ConfigDirectory -or $state.BaselineId -notmatch '^[a-zA-Z0-9_-]+$') {
        throw '백업 정보의 경로 또는 버전이 일치하지 않습니다. backups 폴더를 확인하세요.'
    }
    $state
}

function Get-GearsSetupStatus {
    param([Parameter(Mandatory)][string]$ConfigDirectory)
    $profile=Get-GearsGameProfileLanguage -ConfigDirectory $ConfigDirectory
    $summary=$profile.Summary + [Environment]::NewLine + '자막·메뉴 언어는 게임의 시스템 > 언어 선택에서 바꿉니다. 변경 후 게임을 재시작하세요.'
    [pscustomobject]@{Known=$profile.Known;Language=$profile.Language;Summary=$summary}
}

function Get-GearsStatus {
    param([string]$ConfigDirectory)
    $dir=Resolve-GearsConfigDirectory $ConfigDirectory
    $storage=Get-GearsStorage $dir
    $state=Read-GearsState $storage $dir
    $voice=Get-GearsVoiceStatus $dir
    $textCode=''
    $summary=$voice.Summary
    if ($null -eq $state) {
        # A portable copy can inspect/reset overrides without the old backup folder.
        $file=Read-GearsFile (Join-Path $dir 'Game.ini')
        $textEntries=(Edit-GearsIni $file.Text 'Internationalization' @('CultureMappings')).Removed
        $audioEntries=(Edit-GearsIni $file.Text '/Script/AkAudio.AkSettings' @('UnrealCultureToWwiseCulture')).Removed
        $active=($textEntries.Count -gt 0 -or $audioEntries.Count -gt 0)
        $targets=@($textEntries | ForEach-Object {
            if ($_ -match '^\s*[+.!-]?CultureMappings\s*=\s*"[^";]+;([^";]+)"\s*$') { $Matches[1] }
        } | Select-Object -Unique)
        if ($targets.Count -eq 1 -and $targets[0] -in @((Get-GearsLanguageCatalog).Text.Code)) {
            $textCode=$targets[0]
        } elseif ($textEntries.Count -eq 0) {
            $profile=Get-GearsGameProfileLanguage -ConfigDirectory $dir
            if ($profile.Known) { $textCode=$profile.Language }
        }
        if ($active) {
            $summary += [Environment]::NewLine + '언어 재정의가 있지만 이 도구의 적용 기록은 없습니다. 게임 언어 따르기로 해제할 수 있습니다.'
        } else {
            $summary += [Environment]::NewLine + '별도 자막·음성 매핑이 없습니다. 게임에서 선택한 언어를 따릅니다.'
        }
        return [pscustomobject]@{Active=$active;TextLanguage=$textCode;VoiceLanguage=$voice.Language;Summary=$summary}
    }
    if ($state.Version -eq 3) {
        $textCode=$state.TextLanguage
        $selection=Get-GearsSelection -VoiceLanguage $state.VoiceLanguage -TextLanguage $textCode
        $file=Read-GearsFile (Join-Path $dir 'Game.ini')
        $entries=(Edit-GearsIni $file.Text 'Internationalization' @('CultureMappings')).Removed
        $summary += [Environment]::NewLine + "선택한 자막·메뉴 언어: $($selection.Text.Name)"
        if (($entries -join '\n') -ceq ($selection.CultureLines -join '\n')) {
            $summary += [Environment]::NewLine + '텍스트 매핑 파일이 선택한 값과 일치합니다. 게임을 재시작해 실제 표시를 확인하세요.'
        } elseif (@($entries | Where-Object { $_ -match '^\s*[+!]CultureMappings\s*=' }).Count -gt 0) {
            $summary += [Environment]::NewLine + '이전 버전의 자막 저장 형식 오류가 남아 있습니다. 게임 종료 후 적용을 다시 누르세요.'
        } else { $summary += [Environment]::NewLine + '텍스트 매핑이 변경되었습니다. 원하는 언어를 다시 적용하세요.' }
    } else {
        $summary += [Environment]::NewLine + '이전 버전 설정이 있습니다. 자막·메뉴 언어를 선택한 뒤 적용하세요.'
    }
    if ($state.Version -eq 1) {
        $summary += [Environment]::NewLine + '이전 버전의 시작 언어 항목은 다음 적용 때 정리하며, 게임 안에서 고른 언어는 유지됩니다.'
    }
    [pscustomobject]@{Active=$true;TextLanguage=$textCode;VoiceLanguage=$voice.Language;Summary=$summary}
}

function Write-GearsBytes {
    param([string]$Path,[byte[]]$Bytes,[int]$Attributes)
    $temp=$Path + '.GearsLanguage-' + [guid]::NewGuid().ToString('N') + '.tmp'
    $oldAttributes=$null
    try {
        [IO.File]::WriteAllBytes($temp,$Bytes)
        if ([IO.File]::Exists($Path)) {
            $oldAttributes=[IO.File]::GetAttributes($Path)
            [IO.File]::SetAttributes($Path, ($oldAttributes -band (-bnot [IO.FileAttributes]::ReadOnly)))
            [IO.File]::Replace($temp,$Path,[System.Management.Automation.Language.NullString]::Value)
        } else { [IO.File]::Move($temp,$Path) }
        [IO.File]::SetAttributes($Path,[IO.FileAttributes]$Attributes)
    } catch {
        if ($null -ne $oldAttributes -and [IO.File]::Exists($Path)) { [IO.File]::SetAttributes($Path,$oldAttributes) }
        throw
    } finally {
        if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) }
    }
}

function Remove-GearsOwnedFile {
    param([string]$Path)
    # Only fixed configuration filenames; never recursive.
    if ([IO.File]::Exists($Path)) {
        $attributes=[IO.File]::GetAttributes($Path)
        [IO.File]::SetAttributes($Path,($attributes -band (-bnot [IO.FileAttributes]::ReadOnly)))
        [IO.File]::Delete($Path)
    }
}

function New-GearsSnapshot {
    param([string]$ConfigDirectory,$Storage,[string]$Action,[string[]]$FileNames=@('Game.ini','GameUserSettings.ini'))
    $id=[DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '_' + [guid]::NewGuid().ToString('N').Substring(0,8)
    $directory=Join-Path $Storage.Directory $id
    [void][IO.Directory]::CreateDirectory($directory)
    $files=@()
    foreach ($rule in @(Get-GearsRules | Where-Object { $_.File -in $FileNames })) {
        $file=Read-GearsFile (Join-Path $ConfigDirectory $rule.File)
        $files += [pscustomobject]@{Name=$rule.File;Exists=$file.Exists;Attributes=$file.Attributes;Data=[Convert]::ToBase64String($file.Bytes)}
    }
    $snapshot=[pscustomobject]@{Version=1;Id=$id;Action=$Action;ConfigDirectory=$ConfigDirectory;Files=$files}
    $json=$snapshot | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText((Join-Path $directory 'snapshot.json'),$json,[Text.UTF8Encoding]::new($true))
    [pscustomobject]@{Id=$id;Directory=$directory;Snapshot=$snapshot}
}

function Restore-GearsSnapshot {
    param($Snapshot,[string]$ConfigDirectory)
    foreach ($file in $Snapshot.Files) {
        if ($file.Name -notin @('Game.ini','GameUserSettings.ini')) { throw '백업 파일 이름이 올바르지 않습니다.' }
        $path=Join-Path $ConfigDirectory $file.Name
        if ($file.Exists) { Write-GearsBytes $path ([Convert]::FromBase64String($file.Data)) ([int]$file.Attributes) }
        else { Remove-GearsOwnedFile $path }
    }
}

function Assert-GearsStopped {
    if (Get-Process -Name GoWEDay -ErrorAction SilentlyContinue) {
        throw '게임이 실행 중입니다. 게임을 완전히 종료한 뒤 다시 적용하거나 복원하세요.'
    }
}

function New-GearsRestoreOperation {
    param([string]$ConfigDirectory,$Rule,$Baseline,[string]$AppliedHash,[switch]$RestoreTextMappings)
    $path=Join-Path $ConfigDirectory $Rule.File
    $current=Read-GearsFile $path
    $original=@($Baseline.Files | Where-Object Name -EQ $Rule.File)
    if ($original.Count -ne 1) { throw '원본 백업에 필요한 파일 정보가 없습니다.' }
    $original=$original[0]
    $originalBytes=[Convert]::FromBase64String($original.Data)
    $stream=[IO.MemoryStream]::new($originalBytes,$false)
    $reader=[IO.StreamReader]::new($stream,[Text.UTF8Encoding]::new($false,$true),$true)
    try { $originalText=$reader.ReadToEnd() } finally { $reader.Dispose();$stream.Dispose() }

    $oldOwned=Edit-GearsIni $originalText $Rule.Section $Rule.Keys
    $currentOutside=Edit-GearsIni $current.Text $Rule.Section $Rule.Keys
    $originalOutside=$oldOwned
    if ($RestoreTextMappings -and $Rule.File -eq 'Game.ini') {
        $currentOutside=Edit-GearsIni $currentOutside.Text 'Internationalization' @('CultureMappings')
        $originalOutside=Edit-GearsIni $originalOutside.Text 'Internationalization' @('CultureMappings')
    }
    # Latest-applied hash alone is insufficient: an unrelated edit can predate a
    # re-apply. Restore exact bytes only when all non-owned content still matches.
    if ($currentOutside.Text.Trim() -ceq $originalOutside.Text.Trim()) {
        $bytes=$originalBytes; $attributes=[int]$original.Attributes; $delete=-not $original.Exists
    } else {
        $edited=Edit-GearsIni $current.Text $Rule.Section $Rule.Keys $oldOwned.Removed
        if ($RestoreTextMappings -and $Rule.File -eq 'Game.ini') {
            $originalCulture=(Edit-GearsIni $originalText 'Internationalization' @('CultureMappings')).Removed
            $edited=Edit-GearsIni $edited.Text 'Internationalization' @('CultureMappings') $originalCulture
        }
        $bytes=ConvertTo-GearsBytes $edited.Text $current.Encoding
        $attributes=($current.Attributes -band (-bnot [int][IO.FileAttributes]::ReadOnly)) -bor
            ([int]$original.Attributes -band [int][IO.FileAttributes]::ReadOnly)
        $delete=(-not $original.Exists -and [string]::IsNullOrWhiteSpace($edited.Text))
    }
    [pscustomobject]@{Path=$path;Name=$Rule.File;Bytes=$bytes;Attributes=$attributes;Delete=$delete}
}

function Get-GearsDefaultOperations {
    param([string]$ConfigDirectory)
    # Explicit reset of language overrides only. No original backup is required.
    foreach ($rule in @(Get-GearsRules)) {
        $path=Join-Path $ConfigDirectory $rule.File
        $current=Read-GearsFile $path
        if (-not $current.Exists) { continue }
        $edited=Edit-GearsIni $current.Text $rule.Section $rule.Keys
        $removed=$edited.Removed.Count
        if ($rule.File -eq 'Game.ini') {
            $edited=Edit-GearsIni $edited.Text 'Internationalization' @('CultureMappings')
            $removed+=$edited.Removed.Count
        }
        if ($removed -eq 0) { continue }
        [pscustomobject]@{
            Path=$path;Name=$rule.File
            Bytes=(ConvertTo-GearsBytes $edited.Text $current.Encoding)
            Attributes=($current.Attributes -band (-bnot [int][IO.FileAttributes]::ReadOnly))
            Delete=[string]::IsNullOrWhiteSpace($edited.Text)
        }
    }
}

function Invoke-GearsChange {
    param([string]$ConfigDirectory,[string]$TextLanguage,[switch]$Restore,[switch]$UseGameLanguage)
    $dir=Resolve-GearsConfigDirectory $ConfigDirectory
    $storage=Get-GearsStorage $dir
    $mutex=[Threading.Mutex]::new($false,('Local\GearsLanguageSelector_' + $storage.Id))
    $locked=$false
    try {
        try { $locked=$mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $locked=$true }
        if (-not $locked) { throw '다른 언어 선택기가 설정을 변경 중입니다. 잠시 후 다시 시도하세요.' }
        Assert-GearsStopped
        $state=if ($UseGameLanguage) { $null } else { Read-GearsState $storage $dir }
        if ($Restore -and $null -eq $state) { throw '이 선택기로 적용한 설정이 없어 복원할 내용이 없습니다.' }
        $legacy=($null -ne $state -and $state.Version -eq 1)
        $operations=@()
        if ($Restore -or $legacy) {
            $baselinePath=Join-Path (Join-Path $storage.Directory $state.BaselineId) 'snapshot.json'
            $baseline=Get-Content -LiteralPath $baselinePath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($baseline.ConfigDirectory -ine $dir -or $baseline.Version -ne 1) { throw '원본 백업의 설정 경로가 일치하지 않습니다.' }
        }
        if ($UseGameLanguage) {
            $operations=@(Get-GearsDefaultOperations -ConfigDirectory $dir)
            if ($operations.Count -eq 0 -and -not [IO.File]::Exists($storage.StatePath)) {
                return [pscustomobject]@{BackupDirectory='';Message='해제할 언어 재정의가 없습니다. 게임에서 선택한 언어를 따릅니다.'}
            }
        } elseif ($Restore) {
            foreach ($rule in @(Get-GearsRules)) {
                if ($rule.File -eq 'GameUserSettings.ini' -and -not $legacy) { continue }
                $operations += New-GearsRestoreOperation $dir $rule $baseline $state.AppliedHashes.($rule.File) -RestoreTextMappings:($state.Version -eq 3)
            }
        } else {
            $voice=Get-GearsVoiceStatus $dir
            if (-not $voice.Known) { throw $voice.Summary }
            $selection=Get-GearsSelection -VoiceLanguage $voice.Language -TextLanguage $TextLanguage
            if (-not $selection.Text) { throw '자막·메뉴 언어를 선택하세요.' }
            $path=Join-Path $dir 'Game.ini'
            $current=Read-GearsFile $path
            $edited=Edit-GearsIni $current.Text '/Script/AkAudio.AkSettings' @('UnrealCultureToWwiseCulture') @($selection.AudioLine)
            $edited=Edit-GearsIni $edited.Text 'Internationalization' @('CultureMappings') $selection.CultureLines
            $operations += [pscustomobject]@{
                Path=$path;Name='Game.ini'
                Bytes=(ConvertTo-GearsBytes $edited.Text $current.Encoding)
                Attributes=($current.Attributes -bor [int][IO.FileAttributes]::ReadOnly);Delete=$false
            }
            if ($legacy) {
                # Remove only v1's text override when the user next clicks Apply.
                # The game's WGS profile and in-game language selection are never written.
                $rule=@(Get-GearsRules | Where-Object File -EQ 'GameUserSettings.ini')[0]
                $operations += New-GearsRestoreOperation $dir $rule $baseline $state.AppliedHashes.'GameUserSettings.ini'
            }
        }
        $backup=New-GearsSnapshot -ConfigDirectory $dir -Storage $storage -Action $(if($UseGameLanguage){'UseGameLanguage'}elseif($Restore){'RestoreText'}else{'ApplyText'}) -FileNames @($operations | ForEach-Object { $_.Name })
        $oldState=if([IO.File]::Exists($storage.StatePath)){[IO.File]::ReadAllBytes($storage.StatePath)}else{$null}
        Assert-GearsStopped
        try {
            foreach ($operation in $operations) {
                if ($operation.Delete) { Remove-GearsOwnedFile $operation.Path }
                else { Write-GearsBytes $operation.Path $operation.Bytes $operation.Attributes }
            }
            if ($Restore -or $UseGameLanguage) { [IO.File]::Delete($storage.StatePath) }
            else {
                $hashes=@{'Game.ini'=(Get-GearsDigest ([IO.File]::ReadAllBytes((Join-Path $dir 'Game.ini'))))}
                $newState=[pscustomobject]@{
                    Version=3;ConfigDirectory=$dir
                    BaselineId=$(if($null -eq $state){$backup.Id}else{$state.BaselineId})
                    TextLanguage=$selection.Text.Code;VoiceLanguage=$selection.Voice.Code;AppliedHashes=$hashes
                }
                $stateBytes=ConvertTo-GearsBytes ($newState | ConvertTo-Json -Depth 8) ([Text.UTF8Encoding]::new($true))
                Write-GearsBytes $storage.StatePath $stateBytes ([int][IO.FileAttributes]::Archive)
            }
        } catch {
            $failure=$_
            try {
                Restore-GearsSnapshot $backup.Snapshot $dir
                if ($null -eq $oldState) { if([IO.File]::Exists($storage.StatePath)){[IO.File]::Delete($storage.StatePath)} }
                else { Write-GearsBytes $storage.StatePath $oldState ([int][IO.FileAttributes]::Archive) }
            } catch { throw "변경 및 자동 복구 중 오류가 발생했습니다. 복구용 백업: $($backup.Directory). 원인: $failure / $_" }
            throw "설정을 적용하지 못해 변경 전 상태로 되돌렸습니다. 원인: $failure"
        }
        if ($UseGameLanguage) {
            $message='언어 재정의를 해제했습니다. 자막·메뉴와 음성은 게임에서 선택한 언어를 따릅니다.'
        } elseif ($Restore) {
            $message='선택기가 변경한 설정을 첫 적용 전 상태로 복원했습니다.'
            if ($legacy) { $message+=' 이전 버전의 자막 설정도 복원했습니다.' }
        } else {
            $message="텍스트 매핑 저장 완료: $($selection.Text.Name). 설정된 음성은 $($selection.Voice.Name)(으)로 유지합니다."
            if ($legacy) { $message+=' 이전 버전의 시작 언어 항목도 정리했습니다.' }
            $message += [Environment]::NewLine + '게임을 재시작해 표시 언어를 확인하세요. 음성팩 설치는 게임에서 직접 관리합니다.'
        }
        [pscustomobject]@{BackupDirectory=$backup.Directory;Message=$message}
    } finally { if($locked){[void]$mutex.ReleaseMutex()};$mutex.Dispose() }
}

function Set-GearsText {
    param([Parameter(Mandatory)][string]$ConfigDirectory,[Parameter(Mandatory)][string]$TextLanguage)
    Invoke-GearsChange -ConfigDirectory $ConfigDirectory -TextLanguage $TextLanguage
}

function Restore-GearsLanguage {
    param([Parameter(Mandatory)][string]$ConfigDirectory)
    Invoke-GearsChange -ConfigDirectory $ConfigDirectory -Restore
}

function Reset-GearsLanguage {
    param([Parameter(Mandatory)][string]$ConfigDirectory)
    Invoke-GearsChange -ConfigDirectory $ConfigDirectory -UseGameLanguage
}
