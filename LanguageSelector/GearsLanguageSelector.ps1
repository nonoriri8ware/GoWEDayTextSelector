[CmdletBinding()]
param(
    [string]$ConfigDirectory,
    [switch]$SmokeTest,
    [ValidateSet('en', 'ko')][string]$UiLanguage = 'en'
)

$script:UiLanguage = $UiLanguage.ToLowerInvariant()
$script:UiStrings = @{
    en = @{
        Apply = 'Apply text language'
        ApplyError = 'Could not apply the text language.
{0}'
        Backup = 'Backup: {0}'
        Browse = 'Browse...'
        BrowsePrompt = 'Choose the game settings folder containing GameUserSettings.ini.'
        Close = 'Close'
        Code = 'View settings code'
        CodeError = 'Could not display the settings code.
{0}'
        CodeTitle = 'Settings code (read-only)'
        ConfigTitle = 'Game settings folder'
        HeaderSubtitle = 'Select the text language separately from the configured voice language.'
        HeaderTitle = 'Choose subtitle and menu language'
        LoadError = 'Could not load the language selector components.

{0}'
        MissingFolder = 'The settings folder does not exist.'
        MissingSpecifiedFolder = 'The specified settings folder does not exist.'
        No = 'Cancel'
        NoConfig = 'No settings folder was found. Run the game once and close it, then reopen this tool or use Browse to select the settings folder.'
        NoSelection = 'Select the subtitle and menu language you want to use.'
        Notes = 'Apply once; run the game normally afterward while these settings remain in place.
Close the game before applying, then restart it and check the text.
The configured voice language is preserved. Voice-pack downloads are managed in the game.
Selecting a language here does not apply changes until you click Apply.'
        OK = 'OK'
        OpenError = 'Could not open the folder.
{0}'
        OpenFolder = 'Open folder'
        Preview = 'Subtitles / menus: {0}

Apply saves the subtitle/menu settings and backs up the existing values.
The configured voice language is preserved. Restart the game to test the resulting text.'
        PreviewError = 'Could not prepare the preview: {0}'
        PreviewTitle = 'Pending changes'
        Refresh = 'Refresh status'
        Restore = 'Use game language'
        RestoreError = 'Could not use the game language.
{0}'
        RestorePrompt = 'Remove custom text and voice overrides and follow the language selected in the game?
No previous backup is required. Older startup language overrides are also removed.
Other game settings and your in-game language selection will be kept.

Close the game completely before continuing.'
        SetupError = 'Could not read the configured voice language: {0}'
        StatusError = 'Could not read the settings status.
{0}'
        StatusTitle = 'Current status'
        TextTitle = 'Subtitles / menus'
        UiLanguage = 'Interface language'
        Unknown = 'Not detected'
        VoiceHint = 'The configured voice language will be displayed after reading the settings.'
        VoiceTitle = 'Configured voice language (read-only)'
        WindowTitle = 'GoWEDayTextSelector'
        Yes = 'Use game language'
    }
    ko = @{
        Apply = '선택한 자막 적용'
        ApplyError = '자막 언어를 적용하지 못했습니다.
{0}'
        Backup = '백업: {0}'
        Browse = '폴더 선택'
        BrowsePrompt = 'GameUserSettings.ini가 들어 있는 게임 설정 폴더를 선택하세요.'
        Close = '닫기'
        Code = '설정 코드 보기'
        CodeError = '설정 코드를 표시하지 못했습니다.
{0}'
        CodeTitle = '적용할 설정 코드 (읽기 전용)'
        ConfigTitle = '게임 설정 폴더'
        HeaderSubtitle = '설정된 음성 언어를 유지하고 자막과 메뉴 언어를 별도로 선택합니다.'
        HeaderTitle = '자막과 메뉴 언어를 선택하세요'
        LoadError = '언어 선택기 구성 요소를 불러오지 못했습니다.

{0}'
        MissingFolder = '설정 폴더가 존재하지 않습니다.'
        MissingSpecifiedFolder = '지정한 설정 폴더가 존재하지 않습니다.'
        No = '취소'
        NoConfig = '설정 폴더를 찾지 못했습니다. 게임을 한 번 실행하고 종료한 뒤 다시 열거나, 폴더 선택으로 설정 폴더를 지정하세요.'
        NoSelection = '사용할 자막과 메뉴 언어를 선택하세요.'
        Notes = '한 번 적용하면 설정이 유지되는 동안 다음부터는 게임만 실행하면 됩니다.
적용 전에 게임을 종료하고, 적용 후 다시 시작해 자막과 메뉴를 확인하세요.
설정된 음성 언어는 유지합니다. 음성팩 다운로드는 게임에서 직접 관리하세요.
언어를 고르기만 해서는 설정이 바뀌지 않습니다. 적용 버튼을 눌러야 저장됩니다.'
        OK = '확인'
        OpenError = '폴더를 열지 못했습니다.
{0}'
        OpenFolder = '폴더 열기'
        Preview = '자막·메뉴: {0}

적용 버튼을 누르면 자막·메뉴 설정을 저장하고 기존 값을 백업합니다.
설정된 음성 언어는 유지합니다. 게임을 다시 시작한 뒤 자막과 메뉴를 확인하세요.'
        PreviewError = '미리보기를 만들지 못했습니다: {0}'
        PreviewTitle = '적용 내용 미리보기'
        Refresh = '현재 상태 새로고침'
        Restore = '게임 언어 따르기'
        RestoreError = '게임 언어로 되돌리지 못했습니다.
{0}'
        RestorePrompt = '자막·음성 재정의를 해제하고 게임에서 선택한 언어를 따를까요?
예전 백업은 필요하지 않습니다. 이전 버전의 시작 언어 항목도 해제합니다.
다른 게임 설정과 게임 안에서 고른 언어는 유지합니다.

계속하기 전에 게임을 완전히 종료하세요.'
        SetupError = '설정된 음성 언어를 읽지 못했습니다: {0}'
        StatusError = '설정 상태를 확인하지 못했습니다.
{0}'
        StatusTitle = '현재 상태'
        TextTitle = '자막 · 메뉴 언어'
        UiLanguage = '화면 언어'
        Unknown = '확인되지 않음'
        VoiceHint = '설정 파일을 읽으면 설정된 음성 언어가 표시됩니다.'
        VoiceTitle = '설정된 음성 언어 (읽기 전용)'
        WindowTitle = 'GoWEDayTextSelector'
        Yes = '게임 언어 따르기'
    }
}
$script:LanguageNamesEnglish = @{
    ko='Korean'; en='English'; ja='Japanese'; fr='French'; de='German'; it='Italian'
    'es-ES'='Spanish (Spain)'; 'es-419'='Spanish (Latin America)'; 'pt-BR'='Portuguese (Brazil)'; 'pt-PT'='Portuguese (Portugal)'
    'zh-Hans'='Chinese (Simplified)'; 'zh-Hant'='Chinese (Traditional)'; ar='Arabic'; cs='Czech'; fi='Finnish'; hu='Hungarian'
    nb='Norwegian'; nl='Dutch'; pl='Polish'; ru='Russian'; sv='Swedish'; tr='Turkish'
}
function Get-UiText {
    param([string]$Key, [object[]]$Values = @())
    $value = [string]$script:UiStrings[$script:UiLanguage][$Key]
    if ($Values.Count -gt 0) { return ($value -f $Values) }
    return $value
}
function Convert-CoreUiText {
    param([AllowEmptyString()][string]$Message)
    if (Get-Command ConvertTo-GearsUiMessage -ErrorAction SilentlyContinue) {
        return [string](ConvertTo-GearsUiMessage -Message $Message -UiLanguage $script:UiLanguage)
    }
    return $Message
}
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

try {
    $versionPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'VERSION'
    $script:AppVersion = [IO.File]::ReadAllText($versionPath).Trim()
    if ($script:AppVersion -notmatch '^\d+\.\d+\.\d+$') {
        throw 'VERSION must contain a version such as 0.0.1.'
    }
    foreach ($strings in $script:UiStrings.Values) {
        $strings.WindowTitle = 'GoWEDayTextSelector v' + $script:AppVersion
    }
    . (Join-Path $PSScriptRoot 'LanguageCore.ps1')
    . (Join-Path $PSScriptRoot 'UiMessages.ps1')
}
catch {
    $loadMessage = Get-UiText 'LoadError' -Values @((Convert-CoreUiText $_.Exception.Message))
    if ($SmokeTest) { throw $loadMessage }
    [void][System.Windows.Forms.MessageBox]::Show($loadMessage, (Get-UiText 'WindowTitle'), 'OK', 'Error')
    exit 1
}

$script:CurrentConfigDirectory = ''
$script:ConfigIsValid = $false
$script:IsLoading = $true
$script:UiFont = New-Object System.Drawing.Font('Malgun Gothic', 9)
$script:MutedColor = [System.Drawing.Color]::FromArgb(86, 99, 118)
$script:PageColor = [System.Drawing.Color]::FromArgb(246, 248, 251)
$script:InkColor = [System.Drawing.Color]::FromArgb(24, 38, 57)

function New-UiLabel {
    param([string]$Text, [int]$Size = 9, [switch]$Bold)
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.AutoSize = $false
    $label.Dock = 'Fill'
    $label.ForeColor = $script:InkColor
    $fontStyle = [System.Drawing.FontStyle]::Regular
    if ($Bold) { $fontStyle = [System.Drawing.FontStyle]::Bold }
    $label.Font = New-Object System.Drawing.Font('Malgun Gothic', $Size, $fontStyle)
    $label.Margin = New-Object System.Windows.Forms.Padding(0)
    return $label
}

function New-UiButton {
    param([string]$Text)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.AutoSize = $false
    $button.Size = New-Object System.Drawing.Size(124, 34)
    $button.Margin = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(190, 201, 215)
    $button.BackColor = [System.Drawing.Color]::White
    $button.ForeColor = $script:InkColor
    $button.Cursor = 'Hand'
    return $button
}

function New-LocalizedLabel {
    param([string]$Key, [int]$Size = 9, [switch]$Bold)
    $control = New-UiLabel (Get-UiText $Key) -Size $Size -Bold:$Bold
    $control.Tag = 'i18n:' + $Key
    return $control
}
function New-LocalizedButton {
    param([string]$Key)
    $control = New-UiButton (Get-UiText $Key)
    $control.Tag = 'i18n:' + $Key
    return $control
}
function Update-LocalizedCaptions {
    param([System.Windows.Forms.Control]$Control)
    if ($Control.Tag -is [string] -and $Control.Tag.StartsWith('i18n:')) {
        $Control.Text = Get-UiText $Control.Tag.Substring(5)
    }
    foreach ($child in $Control.Controls) { Update-LocalizedCaptions -Control $child }
}
function Get-LanguageDisplayName {
    param([string]$Code)
    if ($script:UiLanguage -eq 'en' -and $script:LanguageNamesEnglish.ContainsKey($Code)) {
        return [string]$script:LanguageNamesEnglish[$Code]
    }
    $entry = @((Get-GearsLanguageCatalog).Text | Where-Object Code -EQ $Code)
    if ($entry.Count -gt 0) { return [string]$entry[0].Name }
    if ([string]::IsNullOrWhiteSpace($Code)) { return Get-UiText 'Unknown' }
    return Convert-CoreUiText $Code
}

$script:SetupInfo = $null
$script:Form = New-Object System.Windows.Forms.Form
$script:Form.Text = Get-UiText 'WindowTitle'
$script:Form.Tag = 'i18n:WindowTitle'
$script:Form.ClientSize = New-Object System.Drawing.Size(830, 780)
$script:Form.MinimumSize = New-Object System.Drawing.Size(846, 819)
$script:Form.StartPosition = 'CenterScreen'
$script:Form.Font = $script:UiFont
$script:Form.BackColor = $script:PageColor
$script:Form.ForeColor = $script:InkColor
$script:Form.AutoScaleMode = 'Dpi'

$outer = New-Object System.Windows.Forms.TableLayoutPanel
$outer.Dock = 'Fill'
$outer.Margin = New-Object System.Windows.Forms.Padding(0)
$outer.ColumnCount = 1
$outer.RowCount = 2
[void]$outer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
[void]$outer.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 92)))
[void]$outer.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
$script:Form.Controls.Add($outer)

$header = New-Object System.Windows.Forms.Panel
$header.Size = New-Object System.Drawing.Size(830, 92)
$header.Dock = 'Fill'
$header.Margin = New-Object System.Windows.Forms.Padding(0)
$header.BackColor = [System.Drawing.Color]::FromArgb(29, 48, 74)
$headerTitle = New-LocalizedLabel 'HeaderTitle' 17 -Bold
$headerTitle.Dock = 'None'
$headerTitle.Location = New-Object System.Drawing.Point(24, 18)
$headerTitle.Size = New-Object System.Drawing.Size(590, 36)
$headerTitle.Anchor = 'Top, Left, Right'
$headerTitle.ForeColor = [System.Drawing.Color]::White
$headerSubtitle = New-LocalizedLabel 'HeaderSubtitle'
$headerSubtitle.Dock = 'None'
$headerSubtitle.Location = New-Object System.Drawing.Point(26, 58)
$headerSubtitle.Size = New-Object System.Drawing.Size(590, 32)
$headerSubtitle.Anchor = 'Top, Left, Right'
$headerSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(206, 221, 241)
$header.Controls.Add($headerTitle)
$header.Controls.Add($headerSubtitle)
$interfaceLabel = New-LocalizedLabel 'UiLanguage'
$interfaceLabel.Dock = 'None'
$interfaceLabel.Location = New-Object System.Drawing.Point(638, 11)
$interfaceLabel.Size = New-Object System.Drawing.Size(168, 20)
$interfaceLabel.Anchor = 'Top, Right'
$interfaceLabel.ForeColor = $headerSubtitle.ForeColor
$script:UiLanguageCombo = New-Object System.Windows.Forms.ComboBox
$script:UiLanguageCombo.DropDownStyle = 'DropDownList'
$script:UiLanguageCombo.Location = New-Object System.Drawing.Point(638, 35)
$script:UiLanguageCombo.Size = New-Object System.Drawing.Size(168, 26)
$script:UiLanguageCombo.Anchor = 'Top, Right'
$script:UiLanguageCombo.DisplayMember = 'Name'
[void]$script:UiLanguageCombo.Items.Add([pscustomobject]@{Code='en';Name='English'})
[void]$script:UiLanguageCombo.Items.Add([pscustomobject]@{Code='ko';Name='한국어'})
$script:UiLanguageCombo.SelectedIndex = $(if ($script:UiLanguage -eq 'ko') { 1 } else { 0 })
$header.Controls.Add($interfaceLabel)
$header.Controls.Add($script:UiLanguageCombo)
$outer.Controls.Add($header, 0, 0)

$body = New-Object System.Windows.Forms.TableLayoutPanel
$body.Dock = 'Fill'
$body.Margin = New-Object System.Windows.Forms.Padding(0)
$body.Padding = New-Object System.Windows.Forms.Padding(24, 18, 24, 18)
$body.ColumnCount = 1
$body.RowCount = 6
[void]$body.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
foreach ($height in @(76, 122, 98, 188, 46)) {
    [void]$body.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', $height)))
}
[void]$body.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
$outer.Controls.Add($body, 0, 1)

$configGroup = New-Object System.Windows.Forms.TableLayoutPanel
$configGroup.Dock = 'Fill'
$configGroup.Margin = New-Object System.Windows.Forms.Padding(0)
$configGroup.ColumnCount = 3
$configGroup.RowCount = 2
[void]$configGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
[void]$configGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 104)))
[void]$configGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 104)))
[void]$configGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 27)))
[void]$configGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 35)))
$configTitle = New-LocalizedLabel 'ConfigTitle' 10 -Bold
$configGroup.Controls.Add($configTitle, 0, 0)
$configGroup.SetColumnSpan($configTitle, 3)
$script:ConfigPathBox = New-Object System.Windows.Forms.TextBox
$script:ConfigPathBox.ReadOnly = $true
$script:ConfigPathBox.TabStop = $false
$script:ConfigPathBox.Dock = 'Fill'
$script:ConfigPathBox.Margin = New-Object System.Windows.Forms.Padding(0, 3, 10, 0)
$script:ConfigPathBox.BackColor = [System.Drawing.Color]::White
$configGroup.Controls.Add($script:ConfigPathBox, 0, 1)
$browseButton = New-LocalizedButton 'Browse'
$browseButton.Dock = 'Fill'
$browseButton.Margin = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
$configGroup.Controls.Add($browseButton, 1, 1)
$script:OpenFolderButton = New-LocalizedButton 'OpenFolder'
$script:OpenFolderButton.Dock = 'Fill'
$script:OpenFolderButton.Margin = New-Object System.Windows.Forms.Padding(0)
$configGroup.Controls.Add($script:OpenFolderButton, 2, 1)
$body.Controls.Add($configGroup, 0, 0)

$languageGroup = New-Object System.Windows.Forms.TableLayoutPanel
$languageGroup.Dock = 'Fill'
$languageGroup.Margin = New-Object System.Windows.Forms.Padding(0)
$languageGroup.ColumnCount = 3
$languageGroup.RowCount = 3
[void]$languageGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)))
[void]$languageGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 20)))
[void]$languageGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 50)))
[void]$languageGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 28)))
[void]$languageGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 34)))
[void]$languageGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 48)))
$languageGroup.Controls.Add((New-LocalizedLabel 'TextTitle' 10 -Bold), 0, 0)
$languageGroup.Controls.Add((New-LocalizedLabel 'VoiceTitle' 10 -Bold), 2, 0)
$script:VoiceBox = New-Object System.Windows.Forms.TextBox
$script:VoiceBox.ReadOnly = $true
$script:VoiceBox.TabStop = $false
$script:VoiceBox.Dock = 'Fill'
$script:VoiceBox.Margin = New-Object System.Windows.Forms.Padding(0, 2, 0, 0)
$script:VoiceBox.BackColor = [System.Drawing.Color]::FromArgb(235, 239, 245)
$script:TextCombo = New-Object System.Windows.Forms.ComboBox
foreach ($combo in @($script:TextCombo)) {
    $combo.DropDownStyle = 'DropDownList'
    $combo.Dock = 'Fill'
    $combo.Margin = New-Object System.Windows.Forms.Padding(0, 2, 0, 0)
    $combo.DisplayMember = 'Name'
    $combo.ValueMember = 'Code'
    $combo.DropDownHeight = 320
}
$languageGroup.Controls.Add($script:VoiceBox, 2, 1)
$languageGroup.Controls.Add($script:TextCombo, 0, 1)
$script:VoiceStatusLabel = New-LocalizedLabel 'VoiceHint'
$script:VoiceStatusLabel.ForeColor = $script:MutedColor
$script:VoiceStatusLabel.Padding = New-Object System.Windows.Forms.Padding(0, 9, 0, 0)
$languageGroup.Controls.Add($script:VoiceStatusLabel, 0, 2)
$languageGroup.SetColumnSpan($script:VoiceStatusLabel, 3)
$body.Controls.Add($languageGroup, 0, 1)

$notes = New-LocalizedLabel 'Notes'
$notes.ForeColor = $script:MutedColor
$notes.Padding = New-Object System.Windows.Forms.Padding(10, 8, 10, 8)
$notes.BackColor = [System.Drawing.Color]::FromArgb(233, 239, 247)
$notes.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
$body.Controls.Add($notes, 0, 2)

$previewGroup = New-Object System.Windows.Forms.TableLayoutPanel
$previewGroup.Dock = 'Fill'
$previewGroup.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
$previewGroup.ColumnCount = 1
$previewGroup.RowCount = 2
[void]$previewGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
[void]$previewGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 26)))
[void]$previewGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
$previewGroup.Controls.Add((New-LocalizedLabel 'PreviewTitle' 10 -Bold), 0, 0)
$script:PreviewBox = New-Object System.Windows.Forms.TextBox
$script:PreviewBox.Dock = 'Fill'
$script:PreviewBox.Margin = New-Object System.Windows.Forms.Padding(0)
$script:PreviewBox.Multiline = $true
$script:PreviewBox.ReadOnly = $true
$script:PreviewBox.TabStop = $false
$script:PreviewBox.ScrollBars = 'Vertical'
$script:PreviewBox.WordWrap = $true
$script:PreviewBox.BackColor = [System.Drawing.Color]::White
$script:PreviewBox.Font = $script:UiFont
$previewGroup.Controls.Add($script:PreviewBox, 0, 1)
$body.Controls.Add($previewGroup, 0, 3)

$actions = New-Object System.Windows.Forms.FlowLayoutPanel
$actions.Dock = 'Fill'
$actions.Margin = New-Object System.Windows.Forms.Padding(0)
$script:ApplyButton = New-LocalizedButton 'Apply'
$script:ApplyButton.Size = New-Object System.Drawing.Size(160, 35)
$script:ApplyButton.BackColor = [System.Drawing.Color]::FromArgb(35, 88, 153)
$script:ApplyButton.ForeColor = [System.Drawing.Color]::White
$script:ApplyButton.FlatAppearance.BorderColor = $script:ApplyButton.BackColor
$script:RestoreButton = New-LocalizedButton 'Restore'
$script:RestoreButton.Size = New-Object System.Drawing.Size(174, 35)
$refreshButton = New-LocalizedButton 'Refresh'
$refreshButton.Size = New-Object System.Drawing.Size(154, 35)
$actions.Controls.Add($script:ApplyButton)
$actions.Controls.Add($script:RestoreButton)
$actions.Controls.Add($refreshButton)
$script:CodePreviewButton = New-LocalizedButton 'Code'
$script:CodePreviewButton.Size = New-Object System.Drawing.Size(134, 35)
$script:CodePreviewButton.Enabled = $false
$actions.Controls.Add($script:CodePreviewButton)
$body.Controls.Add($actions, 0, 4)

$statusGroup = New-Object System.Windows.Forms.TableLayoutPanel
$statusGroup.Dock = 'Fill'
$statusGroup.Margin = New-Object System.Windows.Forms.Padding(0)
$statusGroup.ColumnCount = 1
$statusGroup.RowCount = 2
[void]$statusGroup.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
[void]$statusGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 26)))
[void]$statusGroup.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
$statusGroup.Controls.Add((New-LocalizedLabel 'StatusTitle' 10 -Bold), 0, 0)
$script:StatusBox = New-Object System.Windows.Forms.TextBox
$script:StatusBox.Dock = 'Fill'
$script:StatusBox.Margin = New-Object System.Windows.Forms.Padding(0)
$script:StatusBox.Multiline = $true
$script:StatusBox.ReadOnly = $true
$script:StatusBox.TabStop = $false
$script:StatusBox.ScrollBars = 'Vertical'
$script:StatusBox.BackColor = [System.Drawing.Color]::White
$statusGroup.Controls.Add($script:StatusBox, 0, 1)
$body.Controls.Add($statusGroup, 0, 5)

function Update-LanguagePreview {
    if ($script:IsLoading) { return }
    $hasSelection = ($null -ne $script:TextCombo.SelectedItem)
    $script:ApplyButton.Enabled = ($hasSelection -and $script:ConfigIsValid)
    $script:CodePreviewButton.Enabled = ($hasSelection -and $script:ConfigIsValid)
    if (-not $hasSelection) {
        $script:PreviewBox.Text = Get-UiText 'NoSelection'
        return
    }
    try {
        $null = Get-GearsPreview -ConfigDirectory $script:CurrentConfigDirectory -TextLanguage $script:TextCombo.SelectedItem.Code
        $script:PreviewBox.Text = Get-UiText 'Preview' -Values @($script:TextCombo.SelectedItem.Name)
    }
    catch {
        $script:PreviewBox.Text = Get-UiText 'PreviewError' -Values @((Convert-CoreUiText $_.Exception.Message))
        $script:CodePreviewButton.Enabled = $false
        $script:ApplyButton.Enabled = $false
    }
}
function New-GearsCodePreviewDialog {
    $code = Convert-CoreUiText ([string](Get-GearsPreview -ConfigDirectory $script:CurrentConfigDirectory -TextLanguage $script:TextCombo.SelectedItem.Code))
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = Get-UiText 'CodeTitle'
    $dialog.ClientSize = New-Object System.Drawing.Size(760, 440)
    $dialog.MinimumSize = New-Object System.Drawing.Size(600, 340)
    $dialog.StartPosition = 'CenterParent'
    $dialog.Font = $script:UiFont
    $dialog.BackColor = $script:PageColor
    $dialog.AutoScaleMode = 'Dpi'
    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = 'Fill'
    $layout.Padding = New-Object System.Windows.Forms.Padding(16)
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    [void]$layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
    [void]$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 46)))
    $codeBox = New-Object System.Windows.Forms.TextBox
    $codeBox.Name = 'ConfigCode'
    $codeBox.Dock = 'Fill'
    $codeBox.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
    $codeBox.Multiline = $true
    $codeBox.ReadOnly = $true
    $codeBox.TabStop = $false
    $codeBox.WordWrap = $false
    $codeBox.ScrollBars = 'Both'
    $codeBox.BackColor = [System.Drawing.Color]::White
    $codeBox.Font = New-Object System.Drawing.Font('Consolas', 9)
    $codeBox.Text = $code
    $layout.Controls.Add($codeBox, 0, 0)
    $closeButton = New-LocalizedButton 'Close'
    $closeButton.Anchor = 'Top, Right'
    $closeButton.Margin = New-Object System.Windows.Forms.Padding(0, 8, 0, 0)
    $closeButton.DialogResult = 'Cancel'
    $layout.Controls.Add($closeButton, 0, 1)
    $dialog.CancelButton = $closeButton
    $dialog.Controls.Add($layout)
    return $dialog
}
function Select-LanguageCode {
    param([System.Windows.Forms.ComboBox]$Combo, [string]$Code)
    $Combo.SelectedIndex = -1
    for ($itemIndex = 0; $itemIndex -lt $Combo.Items.Count; $itemIndex++) {
        if ($Combo.Items[$itemIndex].Code -eq $Code) {
            $Combo.SelectedIndex = $itemIndex
            break
        }
    }
}

function Update-ConfigStatus {
    param([switch]$LoadSelections)
    $script:ConfigIsValid = $false
    $script:VoiceBox.Text = Get-UiText 'Unknown'
    $script:VoiceStatusLabel.Text = Get-UiText 'VoiceHint'
    $script:VoiceStatusLabel.ForeColor = $script:MutedColor
    $script:RestoreButton.Enabled = $false
    $script:OpenFolderButton.Enabled = -not [string]::IsNullOrWhiteSpace($script:CurrentConfigDirectory)
    if ($LoadSelections) { $script:IsLoading = $true; $script:TextCombo.SelectedIndex = -1 }
    try {
        if ([string]::IsNullOrWhiteSpace($script:CurrentConfigDirectory)) {
            $script:StatusBox.Text = Get-UiText 'NoConfig'
            return
        }
        $null = Resolve-GearsConfigDirectory -ConfigDirectory $script:CurrentConfigDirectory
        $script:ConfigIsValid = $true
        # Reset remains available even when the old backup state is missing or corrupt.
        $script:RestoreButton.Enabled = $true
        $state = Get-GearsStatus -ConfigDirectory $script:CurrentConfigDirectory
        $script:StatusBox.Text = Convert-CoreUiText $state.Summary
        if ($LoadSelections) { Select-LanguageCode -Combo $script:TextCombo -Code $state.TextLanguage }
        try {
            $voiceStatus = Get-GearsVoiceStatus -ConfigDirectory $script:CurrentConfigDirectory
            if ($voiceStatus.Known) { $script:VoiceBox.Text = Get-LanguageDisplayName $voiceStatus.Language }
            $script:VoiceStatusLabel.Text = Convert-CoreUiText $voiceStatus.Summary
        }
        catch {
            $script:VoiceStatusLabel.Text = Get-UiText 'SetupError' -Values @((Convert-CoreUiText $_.Exception.Message))
        }
    }
    catch { $script:StatusBox.Text = Get-UiText 'StatusError' -Values @((Convert-CoreUiText $_.Exception.Message)) }
    finally { $script:IsLoading = $false; Update-LanguagePreview }
}
function Show-UiMessage {
    param([string]$Message, [string]$Title, [switch]$Confirm)
    $dialog = New-Object System.Windows.Forms.Form
    $dialog.Text = $Title
    $dialog.ClientSize = New-Object System.Drawing.Size(580, 260)
    $dialog.MinimumSize = New-Object System.Drawing.Size(480, 240)
    $dialog.StartPosition = 'CenterParent'
    $dialog.Font = $script:UiFont
    $dialog.BackColor = $script:PageColor
    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = 'Fill'
    $layout.Padding = New-Object System.Windows.Forms.Padding(18)
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    [void]$layout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
    [void]$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$layout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 42)))
    $messageBox = New-Object System.Windows.Forms.TextBox
    $messageBox.Multiline = $true
    $messageBox.ReadOnly = $true
    $messageBox.TabStop = $false
    $messageBox.BorderStyle = 'None'
    $messageBox.BackColor = $script:PageColor
    $messageBox.Dock = 'Fill'
    $messageBox.ScrollBars = 'Vertical'
    $messageBox.Text = $Message
    $layout.Controls.Add($messageBox, 0, 0)
    $buttons = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttons.Dock = 'Fill'
    $buttons.FlowDirection = 'RightToLeft'
    if ($Confirm) {
        $cancel = New-LocalizedButton 'No'
        $cancel.DialogResult = 'No'
        $buttons.Controls.Add($cancel)
        $accept = New-LocalizedButton 'Yes'
        $accept.DialogResult = 'Yes'
        $buttons.Controls.Add($accept)
        $dialog.CancelButton = $cancel
        $initialControl = $cancel
    }
    else {
        $accept = New-LocalizedButton 'OK'
        $accept.DialogResult = 'OK'
        $buttons.Controls.Add($accept)
        $dialog.CancelButton = $accept
        $dialog.AcceptButton = $accept
        $initialControl = $accept
    }
    $layout.Controls.Add($buttons, 0, 1)
    $dialog.Controls.Add($layout)
    try {
        # Attach the buttons to the form before assigning its active control.
        $dialog.ActiveControl = $initialControl
        return $dialog.ShowDialog($script:Form)
    }
    finally { $dialog.Dispose() }
}
function Show-ActionError {
    param([string]$Message)
    $script:StatusBox.Text = $Message
    [void](Show-UiMessage -Message $Message -Title (Get-UiText 'WindowTitle'))
}
function Update-TextCatalog {
    $previousCode = ''
    if ($null -ne $script:TextCombo.SelectedItem) { $previousCode = $script:TextCombo.SelectedItem.Code }
    $script:IsLoading = $true
    try {
        $script:TextCombo.Items.Clear()
        foreach ($entry in (Get-GearsLanguageCatalog).Text) {
            [void]$script:TextCombo.Items.Add([pscustomobject]@{Code=[string]$entry.Code;Name=(Get-LanguageDisplayName $entry.Code)})
        }
        Select-LanguageCode -Combo $script:TextCombo -Code $previousCode
    }
    finally { $script:IsLoading = $false }
}
function Set-InterfaceLanguage {
    param([ValidateSet('en','ko')][string]$Language)
    $script:UiLanguage = $Language
    Update-LocalizedCaptions -Control $script:Form
    Update-TextCatalog
    Update-ConfigStatus
}
Update-TextCatalog
$script:TextCombo.Add_SelectedIndexChanged({ Update-LanguagePreview })
$script:UiLanguageCombo.Add_SelectedIndexChanged({
    if (-not $script:IsLoading -and $null -ne $script:UiLanguageCombo.SelectedItem) {
        Set-InterfaceLanguage -Language $script:UiLanguageCombo.SelectedItem.Code
    }
})
$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = Get-UiText 'BrowsePrompt'
    $dialog.ShowNewFolderButton = $false
    if ($script:CurrentConfigDirectory) { $dialog.SelectedPath = $script:CurrentConfigDirectory }
    try {
        if ($dialog.ShowDialog($script:Form) -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:CurrentConfigDirectory = $dialog.SelectedPath
            $script:ConfigPathBox.Text = $script:CurrentConfigDirectory
            Update-ConfigStatus -LoadSelections
        }
    }
    finally { $dialog.Dispose() }
})
$script:OpenFolderButton.Add_Click({
    try {
        if (-not (Test-Path -LiteralPath $script:CurrentConfigDirectory -PathType Container)) { throw (Get-UiText 'MissingFolder') }
        Start-Process -FilePath 'explorer.exe' -ArgumentList ('"' + $script:CurrentConfigDirectory + '"')
    }
    catch { Show-ActionError (Get-UiText 'OpenError' -Values @((Convert-CoreUiText $_.Exception.Message))) }
})
$refreshButton.Add_Click({ Update-ConfigStatus })
$script:CodePreviewButton.Add_Click({
    if ($null -eq $script:TextCombo.SelectedItem) { return }
    try {
        $dialog = New-GearsCodePreviewDialog
        try { [void]$dialog.ShowDialog($script:Form) }
        finally { $dialog.Dispose() }
    }
    catch { Show-ActionError (Get-UiText 'CodeError' -Values @((Convert-CoreUiText $_.Exception.Message))) }
})
$script:ApplyButton.Add_Click({
    if ($null -eq $script:TextCombo.SelectedItem) { return }
    $script:Form.UseWaitCursor = $true
    $script:ApplyButton.Enabled = $false
    try {
        $result = Set-GearsText -ConfigDirectory $script:CurrentConfigDirectory -TextLanguage $script:TextCombo.SelectedItem.Code
        Update-ConfigStatus
        $message = Convert-CoreUiText $result.Message
        $backup = if ($result.BackupDirectory) { Get-UiText 'Backup' -Values @($result.BackupDirectory) } else { '' }
        $script:StatusBox.Text = "$message`r`n$backup`r`n`r`n$($script:StatusBox.Text)"
    }
    catch { Show-ActionError (Get-UiText 'ApplyError' -Values @((Convert-CoreUiText $_.Exception.Message))) }
    finally { $script:Form.UseWaitCursor = $false; Update-LanguagePreview }
})
$script:RestoreButton.Add_Click({
    $answer = Show-UiMessage -Message (Get-UiText 'RestorePrompt') -Title (Get-UiText 'Restore') -Confirm
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $script:Form.UseWaitCursor = $true
    try {
        $result = Reset-GearsLanguage -ConfigDirectory $script:CurrentConfigDirectory
        Update-ConfigStatus -LoadSelections
        $message = Convert-CoreUiText $result.Message
        $backup = if ($result.BackupDirectory) { Get-UiText 'Backup' -Values @($result.BackupDirectory) } else { '' }
        $script:StatusBox.Text = "$message`r`n$backup`r`n`r`n$($script:StatusBox.Text)"
    }
    catch { Show-ActionError (Get-UiText 'RestoreError' -Values @((Convert-CoreUiText $_.Exception.Message))) }
    finally { $script:Form.UseWaitCursor = $false }
})
$startupError = ''
try {
    if (-not [string]::IsNullOrWhiteSpace($ConfigDirectory)) {
        if (-not (Test-Path -LiteralPath $ConfigDirectory -PathType Container)) { throw (Get-UiText 'MissingSpecifiedFolder') }
        $script:CurrentConfigDirectory = (Resolve-Path -LiteralPath $ConfigDirectory).ProviderPath
    }
    else {
        $script:CurrentConfigDirectory = Find-GearsConfigDirectory
    }
}
catch { $startupError = $_.Exception.Message }
$script:ConfigPathBox.Text = $script:CurrentConfigDirectory
Update-ConfigStatus -LoadSelections
if ($startupError) { $script:StatusBox.Text = (Convert-CoreUiText $startupError) + "`r`n`r`n" + $script:StatusBox.Text }

try {
    if ($SmokeTest) {
        $previewDirectory = Join-Path $PSScriptRoot 'tests'
        [void][System.IO.Directory]::CreateDirectory($previewDirectory)
        # Create native control handles without displaying a visible window.
        $script:Form.ShowInTaskbar = $false
        $script:Form.Opacity = 0
        $script:Form.StartPosition = 'Manual'
        $script:Form.Location = New-Object System.Drawing.Point(-32000, -32000)
        $script:Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        $script:Form.PerformLayout()
        $script:Form.ActiveControl = $script:TextCombo
        $script:ConfigPathBox.Select(0, 0)
        $script:Form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
        $bitmap = New-Object System.Drawing.Bitmap($script:Form.Width, $script:Form.Height)
        try {
            $script:Form.DrawToBitmap($bitmap, (New-Object System.Drawing.Rectangle(0, 0, $bitmap.Width, $bitmap.Height)))
            $previewPath = Join-Path $previewDirectory ('ui-preview-' + $script:UiLanguage + '.png')
            $bitmap.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $bitmap.Save((Join-Path $previewDirectory 'ui-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Output "UI smoke test passed. Preview: $previewPath"
        }
        finally { $bitmap.Dispose() }
    }
    else { [void]$script:Form.ShowDialog() }
}
finally { $script:Form.Dispose() }
