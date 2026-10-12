@echo off
rem Schwungturm - Einrichtung (Doppelklick). Startet installer\install.ps1 ohne Administratorrechte.
chcp 65001 >nul
title Schwungturm - Einrichtung
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
echo.
pause
