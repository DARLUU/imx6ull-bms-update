@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0update_from_ubuntu_full.ps1"

