@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0LanguageSelector\GearsLanguageSelector.ps1"
set "selector_exit=%errorlevel%"
if not "%selector_exit%"=="0" pause
exit /b %selector_exit%
