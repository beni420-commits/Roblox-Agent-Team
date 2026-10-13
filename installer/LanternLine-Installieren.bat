@echo off
rem Lantern Line - Der Nachtzug: Einrichtung fuer Roblox Studio (Doppelklick).
rem Laedt Rojo, baut die Spieldatei, legt eine Desktop-Verknuepfung an und oeffnet Roblox Studio.
chcp 65001 >nul
title Lantern Line - Einrichtung
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Game LanternLine
echo.
pause
