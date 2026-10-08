# GoWEDayTextSelector

Select subtitle and menu language independently of voices in Gears of War: E-Day. Supports Xbox PC Game Pass.

## Usage

**Tested with Xbox PC Game Pass version 1.1.3.0** (2026-10-07). Confirmed combination: Korean subtitles + English voices. Other game versions have not been verified.

### About this tool

This is an unofficial community tool. It is not affiliated with, endorsed by, or supported by Microsoft or The Coalition. Game names and trademarks belong to their respective owners and are used to identify the supported game and platform.

The release contains only this tool's scripts and documentation. It does not include game executables, assets, voice packs, or game/engine source code.

### Compatibility and multiplayer

- Tested in **single-player only**. Use in single-player is recommended.
- Multiplayer behavior and anti-cheat compatibility have **not been tested**. This unofficial tool cannot guarantee protection from account restrictions or bans.
- The tool edits local language settings. It does not inject code, modify the game executable, or bypass DRM, license checks, or anti-cheat.
- **Steam is not supported.** The maintainer does not own the Steam version and cannot test or provide support for it.

### Setup

1. Download the ZIP from [Releases](https://github.com/nonoriri8ware/GoWEDayTextSelector/releases) and extract all files into a writable folder. It can be outside the game folder.
2. In the game, select the language whose voices you want. Complete the voice-pack download, then fully close the game.
3. Run **GoWEDayTextSelector.cmd**.
4. Check **Configured voice language**, choose **Subtitles / menus**, and click **Apply text language**.
5. Launch the game normally. You only need to apply again when changing the text language or if the settings have been changed.

The tool starts in English. Use **Interface language** to switch between English and Korean. Voice-pack downloads are managed by you in the game. The voice field displays saved settings, not live audio detection.

**Example:** Select English in the game and install its voice pack. Close the game, choose Korean in the selector, and apply. Korean subtitles with English voices have been confirmed after restarting on Xbox PC Game Pass.

### Return to the game language

Close the game and click **Use game language**. This removes the selector's text/audio overrides and uses the language selected in the game. If that is English, both text and voices return to English.

Previous backups are not required. The tool keeps other game settings and saves a recovery snapshot before changes. Keep the CMD file, VERSION file, and LanguageSelector folder together. Windows PowerShell 5.1 is required.

## 사용방법

**Xbox PC Game Pass 1.1.3.0에서 동작 확인** (2026-10-07). 확인한 조합은 한국어 자막 + 영어 음성입니다. 다른 게임 버전은 검증하지 않았습니다.

### 도구 안내

이 프로젝트는 비공식 커뮤니티 도구입니다. Microsoft 또는 The Coalition과 제휴 관계가 없으며, 해당 회사의 승인이나 지원을 받지 않습니다. 게임명과 상표는 각 권리자에게 귀속되며 지원하는 게임과 플랫폼을 설명하기 위해 사용합니다.

배포 파일에는 이 도구의 스크립트와 문서만 포함됩니다. 게임 실행 파일, 리소스, 음성팩, 게임·엔진 소스 코드는 포함하지 않습니다.

### 지원 범위와 멀티플레이

- **싱글플레이에서만 동작을 확인했으며, 싱글플레이 사용을 권장합니다.**
- **멀티플레이 동작과 안티치트 호환성은 검증하지 않았습니다.** 비공식 도구이며 계정 제한이나 밴이 발생하지 않는다고 보장할 수 없습니다.
- 로컬 언어 설정을 수정하는 도구입니다. 코드 주입, 게임 실행 파일 변조, DRM·라이선스 검사·안티치트 우회는 하지 않습니다.
- **Steam 버전은 지원하지 않습니다.** 제작자가 Steam 버전을 소유하고 있지 않아 테스트와 대응이 불가능합니다.

### 설정 순서

1. [Releases](https://github.com/nonoriri8ware/GoWEDayTextSelector/releases)에서 ZIP을 내려받아 쓰기 가능한 폴더에 전부 압축을 풉니다. 게임 폴더가 아니어도 됩니다.
2. 게임 안에서 원하는 음성의 언어를 선택합니다. 음성팩 다운로드를 완료한 뒤 게임을 완전히 종료합니다.
3. **GoWEDayTextSelector.cmd**를 실행합니다.
4. **설정된 음성 언어**를 확인하고 **자막·메뉴 언어**를 고른 뒤 **선택한 자막 적용**을 누릅니다.
5. 게임을 실행합니다. 자막 언어를 바꾸거나 설정이 변경된 경우에만 다시 적용하면 됩니다.

도구 화면은 기본 영어입니다. **Interface language → 한국어**로 바꿀 수 있습니다. 음성팩은 게임에서 직접 설치해야 합니다. 음성 표시는 저장된 설정을 읽은 값이며 실제 재생 음성을 감지하지는 않습니다.

**예시:** 게임 언어를 English로 선택하고 영어 음성팩을 설치합니다. 게임 종료 후 선택기에서 Korean을 적용합니다. Xbox PC Game Pass에서 재실행 후에도 한국어 자막 + 영어 음성이 유지되는 것을 확인했습니다.

### 게임 언어로 되돌리기

게임을 종료하고 **게임 언어 따르기**를 누릅니다. 선택기의 자막·음성 재정의를 해제하고 게임에서 선택한 언어를 사용합니다. 게임 언어가 English라면 자막과 음성 모두 영어로 돌아갑니다.

예전 백업은 필요하지 않습니다. 다른 게임 설정은 보존하며 변경 직전 복구용 백업을 만듭니다. CMD 파일, VERSION 파일, LanguageSelector 폴더를 함께 보관하세요. Windows PowerShell 5.1이 필요합니다.
