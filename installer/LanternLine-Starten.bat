@echo off
rem Lantern Line neu bauen und in Roblox Studio oeffnen (wird von der Desktop-Verknuepfung genutzt).
chcp 65001 >nul
title Lantern Line - Starten
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Game LanternLine -Quick
if errorlevel 1 pause
