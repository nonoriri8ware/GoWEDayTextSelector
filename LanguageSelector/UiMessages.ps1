#requires -Version 5.1
# Presentation-only translations. Loading or calling this file never changes settings.

function ConvertTo-GearsUiMessage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][AllowNull()][AllowEmptyString()][string]$Message,
        [Parameter(Position=1)][ValidateSet('en','ko')][string]$UiLanguage = 'en'
    )

    if ($UiLanguage -eq 'ko' -or [string]::IsNullOrEmpty($Message)) { return $Message }

    $languageNames = @{
        '한국어'='Korean'; '영어'='English'; '일본어'='Japanese'
        '프랑스어'='French'; '독일어'='German'; '이탈리아어'='Italian'
        '스페인어 (스페인)'='Spanish (Spain)'; '스페인어 (중남미)'='Spanish (Latin America)'
        '포르투갈어 (브라질)'='Portuguese (Brazil)'; '포르투갈어 (포르투갈)'='Portuguese (Portugal)'
        '중국어 간체'='Chinese (Simplified)'; '중국어 번체'='Chinese (Traditional)'
        '아랍어'='Arabic'; '체코어'='Czech'; '핀란드어'='Finnish'; '헝가리어'='Hungarian'
        '노르웨이어'='Norwegian'; '네덜란드어'='Dutch'; '폴란드어'='Polish'
        '러시아어'='Russian'; '스웨덴어'='Swedish'; '튀르키예어'='Turkish'
    }
    if ($languageNames.ContainsKey($Message)) { return $languageNames[$Message] }

    # Keep quoted native error details and values verbatim. A unique token prevents
    # either a user's path or an INI value from being interpreted as UI wording.
    $protected = [Collections.Generic.List[string]]::new()
    $tokenPrefix = '__GearsUi_' + [guid]::NewGuid().ToString('N') + '_'
    $translated = [regex]::Replace($Message, '(?s)"[^"\r\n]*"|''[^''\r\n]*''', [Text.RegularExpressions.MatchEvaluator]{
        param($match)
        $token = $tokenPrefix + $protected.Count + '__'
        $protected.Add($match.Value)
        return $token
    })

    $namesPattern = (($languageNames.Keys | Sort-Object Length -Descending | ForEach-Object { [regex]::Escape($_) }) -join '|')
    # Only translate language names inside a known status template. Blind string
    # replacement would corrupt paths such as C:\Games\한국어\언어 선택기.
    $selectionPattern = '(?<text>' + $namesPattern + ') 자막·메뉴 / (?<voice>' + $namesPattern + ') 음성'
    $translated = [regex]::Replace($translated, $selectionPattern, [Text.RegularExpressions.MatchEvaluator]{
        param($match)
        return $languageNames[$match.Groups['text'].Value] + ' subtitles/UI / ' + $languageNames[$match.Groups['voice'].Value] + ' audio'
    })
    $voicePattern = '(?m)^(?<voice>' + $namesPattern + ')(?= 기본 음성 파일)'
    $translated = [regex]::Replace($translated, $voicePattern, [Text.RegularExpressions.MatchEvaluator]{
        param($match)
        return $languageNames[$match.Groups['voice'].Value]
    })
    $savedVoicePattern = '(?<prefix>저장된 음성 오버라이드: |음성 매핑 저장 완료: |설정된 음성 언어: |선택한 자막·메뉴 언어: )(?<voice>' + $namesPattern + ')(?=\.|\r|\n|$)'
    $translated = [regex]::Replace($translated, $savedVoicePattern, [Text.RegularExpressions.MatchEvaluator]{
        param($match)
        return $match.Groups['prefix'].Value + $languageNames[$match.Groups['voice'].Value]
    })
    $textSavedPattern = '텍스트 매핑 저장 완료: (?<text>' + $namesPattern + ')\. 설정된 음성은 (?<voice>' + $namesPattern + ')\(으\)로 유지합니다\.'
    $translated = [regex]::Replace($translated, $textSavedPattern, [Text.RegularExpressions.MatchEvaluator]{
        param($match)
        return 'Text mapping saved: ' + $languageNames[$match.Groups['text'].Value] + '. Configured audio remains ' + $languageNames[$match.Groups['voice'].Value] + '.'
    })

    $phrases = @{
        '언어 재정의가 있지만 이 도구의 적용 기록은 없습니다. 게임 언어 따르기로 해제할 수 있습니다.' = 'Language overrides exist without this tool''s apply history. Use game language can remove them.'
        '별도 자막·음성 매핑이 없습니다. 게임에서 선택한 언어를 따릅니다.' = 'No custom text/audio mappings are present. The in-game language is used.'
        '해제할 언어 재정의가 없습니다. 게임에서 선택한 언어를 따릅니다.' = 'There are no language overrides to remove. The in-game language is used.'
        '언어 재정의를 해제했습니다. 자막·메뉴와 음성은 게임에서 선택한 언어를 따릅니다.' = 'Language overrides removed. Subtitles, menus and voices now follow the language selected in the game.'
        '게임 설정 폴더를 찾지 못했습니다. 게임을 한 번 실행한 뒤 종료하거나 설정 폴더를 직접 선택하세요.' = 'Game config folder not found. Start and close the game once, or choose the config folder manually.'
        'GameUserSettings.ini가 있는 실제 설정 폴더를 선택하세요.' = 'Choose the game config folder containing GameUserSettings.ini.'
        '설정 폴더를 지정하세요.' = 'Choose a config folder.'
        '설정 파일의 문자 인코딩을 안전하게 읽을 수 없습니다: ' = 'Cannot safely read the config file encoding: '
        '언어 설정이 여러 줄에 걸쳐 있지만 끝이 잘못되어 있습니다. 파일을 확인하세요.' = 'A multiline language setting has an invalid ending. Check the config file.'
        '언어 설정의 괄호가 닫히지 않았습니다.' = 'A language setting has an unclosed parenthesis.'
        '자막·메뉴 언어와 음성 언어를 각각 선택하세요.' = 'Choose both a subtitles/UI language and an audio language.'
        '자막·메뉴 언어를 선택하세요.' = 'Choose a subtitles/UI language.'
        '설정된 음성 언어를 확인하지 못했습니다. 게임에서 음성용 언어를 먼저 선택하세요.' = 'Could not determine the configured audio language. Select the audio language in the game first.'
        'Game.ini (적용 후 읽기 전용)' = 'Game.ini (read-only after applying)'
        '음성 언어를 선택하세요.' = 'Choose an audio language.'
        '음성팩 설치 상태를 확인하지 못했습니다. 게임에서 확인하세요.' = 'Could not check voice-pack installation. Check it in the game.'
        ' 기본 음성 파일이 비어 있거나 없습니다. 게임 설정 > 시스템에서 이 언어팩 설치를 100% 완료하세요.' = ' base audio files are empty or missing. Complete this language pack download to 100% in game Settings > System.'
        ' 기본 음성 파일을 확인했습니다. 모드별 추가 설치·게임 내 활성화 여부는 게임에서 확인하세요.' = ' base audio files found. Check the game for any additional mode downloads and audio activation.'
        '백업 정보의 경로 또는 버전이 일치하지 않습니다. backups 폴더를 확인하세요.' = 'The backup path or version does not match. Check the backups folder.'
        '아직 이 선택기로 적용하지 않았습니다. 두 언어를 선택한 뒤 적용하세요.' = 'No settings have been applied with this selector. Choose both languages, then apply.'
        '게임 등이 언어 설정을 변경했습니다. 원하는 조합을 다시 적용하세요.' = 'The game or another program changed the language settings. Apply your preferred combination again.'
        '설정 파일이 선택한 값과 일치합니다. 실제 화면·음성은 게임에서 확인하세요.' = 'Config files match the selected values. Check the actual text and audio in the game.'
        '선택기 저장: ' = 'Saved selection: '
        '백업 파일 이름이 올바르지 않습니다.' = 'Invalid backup file name.'
        '게임이 실행 중입니다. 게임을 완전히 종료한 뒤 다시 적용하거나 복원하세요.' = 'The game is running. Close it completely before applying or restoring settings.'
        '다른 언어 선택기가 설정을 변경 중입니다. 잠시 후 다시 시도하세요.' = 'Another language selector is changing the settings. Try again shortly.'
        '이 선택기로 적용한 설정이 없어 복원할 내용이 없습니다.' = 'There are no settings applied by this selector to restore.'
        '원본 백업의 설정 경로가 일치하지 않습니다.' = 'The original backup config path does not match.'
        '원본 백업에 필요한 파일 정보가 없습니다.' = 'The original backup is missing required file information.'
        '변경 및 자동 복구 중 오류가 발생했습니다. 복구용 백업: ' = 'The change and automatic recovery both failed. Recovery backup: '
        '설정을 적용하지 못해 변경 전 상태로 되돌렸습니다. 원인: ' = 'The settings could not be applied. The previous state was restored. Cause: '
        '원인: ' = 'Cause: '
        '선택기가 바꾼 언어 설정을 첫 적용 전 상태로 복원했습니다. 이후 바뀐 다른 설정은 유지했습니다.' = 'Language settings were restored to their state before the first apply. Other settings changed since then were preserved.'
        '설정 파일 저장 완료: ' = 'Config files saved: '
        '. 게임에서 반영 여부와 언어팩 설치 상태를 확인하세요.' = '. Check the result and language pack installation in the game.'
        '게임 프로필의 언어를 확인하지 못했습니다. 게임 안에서 언어 설정을 확인하세요.' = 'Could not read the game profile language. Check the language setting in the game.'
        '이 설정 폴더에 대응하는 게임 프로필은 자동으로 확인하지 않습니다.' = 'The game profile for this config folder cannot be checked automatically.'
        '설정 프로필이 여러 개여서 현재 게임 언어를 확정할 수 없습니다. 게임 안에서 확인하세요.' = 'Multiple settings profiles were found, so the current game language is uncertain. Check it in the game.'
        '게임 프로필에 저장된 언어: ' = 'Language saved in the game profile: '
        ' (실행 중인 화면 언어와 다를 수 있음)' = ' (may differ from the language currently shown in the game)'
        '자막·메뉴 언어는 게임의 시스템 > 언어 선택에서 바꿉니다. 변경 후 게임을 재시작하세요.' = 'Change subtitles/UI language in the game under System > Language Select, then restart the game.'
        '아직 이 선택기로 음성을 적용하지 않았습니다.' = 'No audio override has been applied with this selector.'
        '저장된 음성 오버라이드: ' = 'Saved audio override: '
        '음성 매핑이 변경되었습니다. 원하는 음성을 다시 적용하세요.' = 'The audio mapping changed. Apply your preferred audio language again.'
        '음성 설정 파일이 선택한 값과 일치합니다. 실제 음성은 게임에서 확인하세요.' = 'The audio config file matches the selected value. Check the actual audio in the game.'
        '이전 버전의 자막 설정은 다음 적용 때 원래 값으로 복원합니다. 게임 안에서 고른 언어는 유지됩니다.' = 'The text override from the previous version will be restored to its original value on the next apply. Your in-game language selection will be preserved.'
        '음성 설정을 첫 적용 전 상태로 복원했습니다.' = 'Audio settings were restored to their state before the first apply.'
        ' 이전 버전의 자막 설정도 복원했습니다.' = ' The text override from the previous version was also restored.'
        '음성 매핑 저장 완료: ' = 'Audio mapping saved: '
        '. 자막·메뉴는 게임 내 언어 설정을 따릅니다.' = '. Subtitles/UI follow the in-game language setting.'
        ' 이전 버전이 추가한 자막 설정은 원래 값으로 복원했습니다.' = ' The text override added by the previous version was restored to its original value.'
        '설정된 음성 언어: ' = 'Configured audio language: '
        '. 실제 재생 언어를 감지하는 표시는 아닙니다.' = '. This does not detect the language currently playing.'
        '아직 자막·메뉴 언어를 적용하지 않았습니다.' = 'No subtitles/UI language has been applied yet.'
        '선택한 자막·메뉴 언어: ' = 'Selected subtitles/UI language: '
        '텍스트 매핑 파일이 선택한 값과 일치합니다. 게임을 재시작해 실제 표시를 확인하세요.' = 'The text mapping file matches the selected value. Restart the game to check the displayed language.'
        '이전 버전의 자막 저장 형식 오류가 남아 있습니다. 게임 종료 후 적용을 다시 누르세요.' = 'The previous version used an incorrect text setting format. Close the game and click Apply again.'
        '텍스트 매핑이 변경되었습니다. 원하는 언어를 다시 적용하세요.' = 'The text mapping changed. Apply your preferred language again.'
        '이전 버전 설정이 있습니다. 자막·메뉴 언어를 선택한 뒤 적용하세요.' = 'Settings from an earlier version were found. Choose a subtitles/UI language, then apply.'
        '이전 버전의 시작 언어 항목은 다음 적용 때 정리하며, 게임 안에서 고른 언어는 유지됩니다.' = 'The startup language override from the previous version will be removed on the next apply. Your in-game language selection will be preserved.'
        '선택기가 변경한 설정을 첫 적용 전 상태로 복원했습니다.' = 'Settings changed by the selector were restored to their state before the first apply.'
        ' 이전 버전의 시작 언어 항목도 정리했습니다.' = ' The startup language override from the previous version was also removed.'
        '게임을 재시작해 표시 언어를 확인하세요. 음성팩 설치는 게임에서 직접 관리합니다.' = 'Restart the game to check the displayed language. Manage voice-pack installation in the game.'
    }
    foreach ($phrase in @($phrases.Keys | Sort-Object Length -Descending)) {
        $translated = $translated.Replace($phrase, $phrases[$phrase])
    }

    for ($index = 0; $index -lt $protected.Count; $index++) {
        $translated = $translated.Replace(($tokenPrefix + $index + '__'), $protected[$index])
    }
    return $translated
}
