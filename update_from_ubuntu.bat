@echo off
setlocal

REM launch PowerShell script
powershell -ExecutionPolicy Bypass -NoLogo -File "%~dp0update_from_ubuntu.ps1"

endlocal
