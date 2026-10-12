@echo off
rem Schwungturm - Deinstallation (Rojo, Spieldatei, Verknuepfung, Rojo-Plugin).
chcp 65001 >nul
title Schwungturm - Deinstallation
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Uninstall
echo.
pause
