@echo off
rem Schwungturm neu bauen und in Roblox Studio oeffnen (wird von der Desktop-Verknuepfung genutzt).
chcp 65001 >nul
title Schwungturm - Starten
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Quick
if errorlevel 1 pause
