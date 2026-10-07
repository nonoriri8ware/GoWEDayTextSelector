#requires -Version 5.1
# Read-only inspection of the game's own saved language. Never writes WGS files.

function New-GearsProfileLanguageResult {
    param(
        [bool]$Known = $false,
        [string]$Language = '',
        [string]$Summary = '',
        [string]$Reason = '',
        [string]$RawLanguage = '',
        [string]$SourcePath = ''
    )
    [pscustomobject]@{
        Known = $Known
        Language = $Language
        Summary = $Summary
        Reason = $Reason
        RawLanguage = $RawLanguage
        SourcePath = $SourcePath
    }
}

function Read-GearsProfileFString {
    param([byte[]]$Bytes, [int]$Offset, [int]$MaxCharacters = 128)
    if ($Offset -lt 0 -or $Offset -gt $Bytes.Length - 4) { throw 'Invalid FString boundary.' }
    $length = [BitConverter]::ToInt32($Bytes, $Offset)
    if ($length -eq 0 -or $length -eq [int]::MinValue) { throw 'Invalid FString length.' }
    $characters = [Math]::Abs($length)
    if ($characters -gt $MaxCharacters) { throw 'FString exceeds permitted length.' }
    $byteCount = if ($length -lt 0) { $characters * 2 } else { $characters }
    $start = $Offset + 4
    if ($byteCount -gt $Bytes.Length - $start) { throw 'Truncated FString.' }
    if ($length -lt 0) {
        if ($Bytes[$start + $byteCount - 1] -ne 0 -or $Bytes[$start + $byteCount - 2] -ne 0) {
            throw 'Unterminated FString.'
        }
        $encoding = New-Object Text.UnicodeEncoding($false, $false, $true)
        $value = $encoding.GetString($Bytes, $start, $byteCount - 2)
    } else {
        if ($Bytes[$start + $byteCount - 1] -ne 0) { throw 'Unterminated FString.' }
        for ($i = $start; $i -lt $start + $byteCount - 1; $i++) {
            if ($Bytes[$i] -lt 32 -or $Bytes[$i] -gt 126) { throw 'Unexpected FString character.' }
        }
        $value = [Text.Encoding]::ASCII.GetString($Bytes, $start, $byteCount - 1)
    }
    if ($value.IndexOf([char]0) -ge 0) { throw 'Embedded FString terminator.' }
    [pscustomobject]@{ Value = $value; NextOffset = $start + $byteCount }
}

function Read-GearsProfileLanguageBytes {
    param([byte[]]$Bytes)
    # ASCII decoding keeps byte offsets intact; only the exact known ASCII keys
    # below are searched. This is deliberately not a general save-game editor.
    $text = [Text.Encoding]::ASCII.GetString($Bytes)
    $settingsClass = '/Script/TCSettings.TCSettingsSubsystem'
    $blackboard = 'SaveGameSettingsGameplayBlackboard'
    if ($text.IndexOf($settingsClass, [StringComparison]::Ordinal) -lt 0 -or
        $text.IndexOf($blackboard, [StringComparison]::Ordinal) -lt 0) {
        return [pscustomobject]@{ Candidate = $false; Valid = $false; Language = ''; RawLanguage = ''; Reason = 'NotSettings' }
    }
    $result = [pscustomobject]@{ Candidate = $true; Valid = $false; Language = ''; RawLanguage = ''; Reason = 'UnsupportedFormat' }
    if ($Bytes.Length -lt 8 -or $text.Substring(0, 4) -cne 'GVAS' -or
        [BitConverter]::ToInt32($Bytes, 4) -ne 3) { return $result }

    $key = 'Settings.SelectedLanguage'
    $keyOffset = $text.IndexOf($key, [StringComparison]::Ordinal)
    if ($keyOffset -lt 4) { $result.Reason = 'MissingLanguage'; return $result }
    if ($text.IndexOf($key, $keyOffset + $key.Length, [StringComparison]::Ordinal) -ge 0) {
        $result.Reason = 'DuplicateLanguageKey'; return $result
    }
    try {
        $keyField = Read-GearsProfileFString -Bytes $Bytes -Offset ($keyOffset - 4)
        if ($keyField.Value -cne $key) { throw 'Unexpected language key.' }
        $scriptField = Read-GearsProfileFString -Bytes $Bytes -Offset $keyField.NextOffset
        if ($scriptField.Value -cne '/Script/TCGameplayBlackboard') { throw 'Unexpected data class.' }
        $typeField = Read-GearsProfileFString -Bytes $Bytes -Offset $scriptField.NextOffset
        if ($typeField.Value -cne 'TCGameplayBlackboardDataType_String') { throw 'Unexpected language data type.' }
        $offset = $typeField.NextOffset
        if ($offset -gt $Bytes.Length - 5 -or [BitConverter]::ToInt32($Bytes, $offset) -ne 0 -or $Bytes[$offset + 4] -ne 1) {
            throw 'Unknown blackboard serialization.'
        }
        $languageField = Read-GearsProfileFString -Bytes $Bytes -Offset ($offset + 5) -MaxCharacters 24
        $result.RawLanguage = $languageField.Value
        $allowed = @('ko','en','ja','fr','de','it','es-ES','es-419','pt-BR','pt-PT','zh-Hans','zh-Hant','ar','cs','fi','hu','nb','nl','pl','ru','sv','tr')
        if ($allowed -cnotcontains $languageField.Value) { $result.Reason = 'UnknownLanguage'; return $result }
        $result.Valid = $true
        $result.Language = $languageField.Value
        $result.Reason = 'Known'
    } catch {
        $result.Reason = 'InvalidLanguageRecord'
    }
    return $result
}

function Get-GearsGameProfileLanguage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ConfigDirectory,
        [string]$ProfileRoot
    )
    $unknownSummary = '게임 프로필의 언어를 확인하지 못했습니다. 게임 안에서 언어 설정을 확인하세요.'
    try {
        $configItem = Get-Item -LiteralPath $ConfigDirectory -ErrorAction Stop
        if (-not $configItem.PSIsContainer) { throw 'Not a configuration directory.' }
        $actualConfig = [IO.Path]::GetFullPath($configItem.FullName).TrimEnd([char[]]'\/')
        if (-not $PSBoundParameters.ContainsKey('ProfileRoot')) {
            if ([string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) { throw 'Missing local app data path.' }
            $expectedConfig = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'Microsoft\Gears of War E-Day\WinGDK\6BE41AB5\Saved\Config\WinGDK')).TrimEnd([char[]]'\/')
            if (-not [StringComparer]::OrdinalIgnoreCase.Equals($actualConfig, $expectedConfig)) {
                return New-GearsProfileLanguageResult -Reason 'UnrelatedConfigDirectory' -Summary '이 설정 폴더에 대응하는 게임 프로필은 자동으로 확인하지 않습니다.'
            }
            $ProfileRoot = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.Fairlightbasegame_8wekyb3d8bbwe\SystemAppData\wgs'
        }
        if ([string]::IsNullOrWhiteSpace($ProfileRoot) -or -not (Test-Path -LiteralPath $ProfileRoot -PathType Container)) {
            return New-GearsProfileLanguageResult -Reason 'ProfileMissing' -Summary $unknownSummary
        }
        $rootItem = Get-Item -LiteralPath $ProfileRoot -Force -ErrorAction Stop
        if ($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Profile directory is a link.' }
        $rootPath = [IO.Path]::GetFullPath($rootItem.FullName).TrimEnd([char[]]'\/')
        $rootPrefix = $rootPath + [IO.Path]::DirectorySeparatorChar
        $pending = New-Object 'Collections.Generic.Queue[string]'
        $pending.Enqueue($rootPath)
        $candidates = New-Object 'Collections.Generic.List[object]'
        $inspected = 0
        while ($pending.Count -gt 0) {
            $directory = $pending.Dequeue()
            foreach ($item in @(Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop)) {
                $inspected++
                if ($inspected -gt 4096) { throw 'Profile scan limit exceeded.' }
                # Do not follow junctions or symbolic links beyond the selected root.
                if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
                $fullPath = [IO.Path]::GetFullPath($item.FullName)
                if (-not $fullPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Profile path escapes root.' }
                if ($item.PSIsContainer) { $pending.Enqueue($fullPath); continue }
                if ($item.Length -lt 8 -or $item.Length -gt 2MB) { continue }
                $bytes = [IO.File]::ReadAllBytes($fullPath)
                if ($bytes.Length -gt 2MB) { throw 'Profile size changed during reading.' }
                if ([Text.Encoding]::ASCII.GetString($bytes, 0, 4) -cne 'GVAS') { continue }
                $parsed = Read-GearsProfileLanguageBytes -Bytes $bytes
                if ($parsed.Candidate) { $candidates.Add([pscustomobject]@{ Parsed = $parsed; Path = $fullPath }) }
            }
        }
        if ($candidates.Count -gt 1) {
            return New-GearsProfileLanguageResult -Reason 'MultipleProfiles' -Summary '설정 프로필이 여러 개여서 현재 게임 언어를 확정할 수 없습니다. 게임 안에서 확인하세요.'
        }
        if ($candidates.Count -eq 0) {
            return New-GearsProfileLanguageResult -Reason 'SettingsProfileMissing' -Summary $unknownSummary
        }
        $candidate = $candidates[0]
        if (-not $candidate.Parsed.Valid) {
            return New-GearsProfileLanguageResult -Reason $candidate.Parsed.Reason -RawLanguage $candidate.Parsed.RawLanguage -SourcePath $candidate.Path -Summary $unknownSummary
        }
        $language = $candidate.Parsed.Language
        return New-GearsProfileLanguageResult -Known $true -Language $language -RawLanguage $language -Reason 'Known' -SourcePath $candidate.Path -Summary ('게임 프로필에 저장된 언어: ' + $language + ' (실행 중인 화면 언어와 다를 수 있음)')
    } catch {
        return New-GearsProfileLanguageResult -Reason 'ReadFailed' -Summary $unknownSummary
    }
}
