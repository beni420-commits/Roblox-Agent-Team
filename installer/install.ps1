<#
.SYNOPSIS
    Richtet „Schwungturm“ auf einem Windows-PC zum Testen in Roblox Studio ein.

.DESCRIPTION
    Ein Roblox-Spiel läuft immer in Roblox bzw. Roblox Studio – es gibt keine eigenständige PC-Version.
    Dieses Skript macht den Weg dorthin so einfach wie möglich:
      1. prüft, ob es im Projektordner liegt,
      2. lädt das Build-Werkzeug Rojo (offizielles GitHub-Release, Prüfsumme wird kontrolliert),
      3. baut daraus die Spieldatei build\Schwungturm.rbxlx,
      4. sucht Roblox Studio (und öffnet sonst die offizielle Download-Seite),
      5. installiert das Rojo-Plugin für Studio und legt eine Desktop-Verknüpfung an,
      6. öffnet das Spiel in Roblox Studio (dort mit „Play“ bzw. F5 testen).
    Es braucht keine Administratorrechte und ändert nichts außerhalb des Projektordners,
    außer der Desktop-Verknüpfung und dem Rojo-Plugin in Studios Plugin-Ordner.

.PARAMETER Quick
    Nur neu bauen und öffnen (für die Desktop-Verknüpfung nach einem Update des Projektordners).

.PARAMETER NoOpen
    Am Ende nichts öffnen.

.PARAMETER Uninstall
    Entfernt Rojo aus dem Projektordner, die gebaute Spieldatei, die Desktop-Verknüpfung und das Rojo-Plugin.

.PARAMETER RojoVersion
    Rojo-Version (Standard: 7.7.1, wie in rokit.toml).

.PARAMETER RojoPath
    Pfad zu einer vorhandenen Rojo-Datei (überspringt den Download; vor allem für Tests).
#>
[CmdletBinding()]
param(
    [switch]$Quick,
    [switch]$NoOpen,
    [switch]$Uninstall,
    [string]$RojoVersion = '7.7.1',
    [string]$RojoPath = ''
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$script:PlaceFileName = 'Schwungturm.rbxlx'
$script:ShortcutName = 'Schwungturm testen.lnk'
$script:StudioDownloadPage = 'https://create.roblox.com/'

function Write-Step {
    param([int]$Number, [int]$Total, [string]$Text)
    Write-Host ''
    Write-Host ("[{0}/{1}] {2}" -f $Number, $Total, $Text) -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Text)
    Write-Host ("    OK  {0}" -f $Text) -ForegroundColor Green
}

function Write-Note {
    param([string]$Text)
    Write-Host ("    ->  {0}" -f $Text) -ForegroundColor Yellow
}

function Get-RepoRoot {
    param([string]$ScriptDirectory)
    $root = Split-Path -Parent $ScriptDirectory
    $project = Join-Path $root 'default.project.json'
    if (-not (Test-Path -LiteralPath $project)) {
        throw "Projektordner nicht gefunden. Das Skript muss im Ordner 'installer' des heruntergeladenen Projekts liegen (erwartet: $project)."
    }
    return $root
}

function Test-RojoVersionText {
    param([string]$VersionText, [string]$Version)
    if ([string]::IsNullOrWhiteSpace($VersionText)) {
        return $false
    }
    return ($VersionText.Trim() -match ("^Rojo\s+" + [regex]::Escape($Version) + "$"))
}

function Select-ReleaseAsset {
    param([Parameter(Mandatory = $true)]$Release)
    $assets = @($Release.assets | Where-Object {
            $_.name -match 'windows' -and $_.name -match '(x86_64|x64|amd64)' -and $_.name -like '*.zip'
        })
    if ($assets.Count -eq 0) {
        throw 'Im Rojo-Release wurde keine Windows-Datei (x86_64, .zip) gefunden.'
    }
    return $assets[0]
}

function Test-AssetDigest {
    param([Parameter(Mandatory = $true)]$Asset, [Parameter(Mandatory = $true)][string]$FilePath)
    $actual = (Get-FileHash -LiteralPath $FilePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $digestProperty = $Asset.PSObject.Properties['digest']
    if ($null -eq $digestProperty -or [string]::IsNullOrWhiteSpace([string]$digestProperty.Value)) {
        # Ältere Releases ohne veröffentlichte Prüfsumme: Hash anzeigen, damit man ihn vergleichen kann.
        return [pscustomobject]@{ Verified = $false; Sha256 = $actual }
    }
    $expected = ([string]$digestProperty.Value).ToLowerInvariant() -replace '^sha256:', ''
    if ($expected -ne $actual) {
        throw "Prüfsumme stimmt nicht (erwartet $expected, erhalten $actual). Download abgebrochen."
    }
    return [pscustomobject]@{ Verified = $true; Sha256 = $actual }
}

function Get-RojoExecutable {
    param([string]$RepoRoot, [string]$Version)
    $bin = Join-Path $RepoRoot '.tools\bin'
    $exe = Join-Path $bin 'rojo.exe'
    if (Test-Path -LiteralPath $exe) {
        $current = ''
        try {
            $current = [string](& $exe --version 2>$null)
        }
        catch {
            $current = '' # beschädigte Datei: neu herunterladen
        }
        if (Test-RojoVersionText -VersionText $current -Version $Version) {
            Write-Ok ("Rojo {0} ist schon vorhanden" -f $Version)
            return $exe
        }
    }

    # Windows PowerShell 5.1 nutzt sonst ggf. altes TLS; GitHub verlangt TLS 1.2.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $headers = @{ 'User-Agent' = 'Schwungturm-Installer'; 'Accept' = 'application/vnd.github+json' }
    $releaseUrl = "https://api.github.com/repos/rojo-rbx/rojo/releases/tags/v$Version"
    Write-Note ("Lade Rojo {0} von GitHub (rojo-rbx/rojo) ..." -f $Version)
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
    $asset = Select-ReleaseAsset -Release $release

    $temp = Join-Path ([IO.Path]::GetTempPath()) ("schwungturm-rojo-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temp | Out-Null
    try {
        $zip = Join-Path $temp $asset.name
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -UseBasicParsing -Headers @{ 'User-Agent' = 'Schwungturm-Installer' }
        $check = Test-AssetDigest -Asset $asset -FilePath $zip
        if ($check.Verified) {
            Write-Ok ("Prüfsumme bestätigt (SHA-256 {0})" -f $check.Sha256)
        }
        else {
            Write-Note ("Keine Prüfsumme im Release veröffentlicht. SHA-256 der Datei: {0}" -f $check.Sha256)
        }
        $extract = Join-Path $temp 'extract'
        Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
        $found = @(Get-ChildItem -LiteralPath $extract -Recurse -Filter 'rojo.exe')
        if ($found.Count -eq 0) {
            throw 'rojo.exe wurde im heruntergeladenen Archiv nicht gefunden.'
        }
        New-Item -ItemType Directory -Path $bin -Force | Out-Null
        Copy-Item -LiteralPath $found[0].FullName -Destination $exe -Force
    }
    finally {
        Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Ok ("Rojo installiert: {0}" -f $exe)
    return $exe
}

function Invoke-PlaceBuild {
    param([string]$Rojo, [string]$RepoRoot)
    $buildDir = Join-Path $RepoRoot 'build'
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    $place = Join-Path $buildDir $script:PlaceFileName
    $project = Join-Path $RepoRoot 'default.project.json'
    # Ausgabe direkt anzeigen, nicht als Rückgabewert der Funktion weiterreichen.
    & $Rojo build $project --output $place | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Rojo konnte die Spieldatei nicht bauen (Exit-Code $LASTEXITCODE)."
    }
    if (-not (Test-Path -LiteralPath $place)) {
        throw "Die Spieldatei wurde nicht erzeugt: $place"
    }
    Write-Ok ("Spieldatei gebaut: {0}" -f $place)
    return $place
}

function Find-RobloxStudio {
    param([string]$LocalAppData = $env:LOCALAPPDATA)
    if ([string]::IsNullOrWhiteSpace($LocalAppData)) {
        return $null
    }
    # Offizieller Installationsort laut Roblox-Doku: %localappdata%\Roblox\Versions\[version]\RobloxStudioBeta.exe
    $versions = Join-Path (Join-Path $LocalAppData 'Roblox') 'Versions'
    if (-not (Test-Path -LiteralPath $versions)) {
        return $null
    }
    $candidates = @(Get-ChildItem -LiteralPath $versions -Directory | ForEach-Object {
            $exe = Join-Path $_.FullName 'RobloxStudioBeta.exe'
            if (Test-Path -LiteralPath $exe) { Get-Item -LiteralPath $exe }
        } | Sort-Object -Property LastWriteTime -Descending)
    if ($candidates.Count -eq 0) {
        return $null
    }
    return $candidates[0].FullName
}

function Install-RojoPlugin {
    param([string]$Rojo)
    & $Rojo plugin install | Out-Host
    if ($LASTEXITCODE -eq 0) {
        Write-Ok 'Rojo-Plugin für Studio installiert (nur für Live-Sync beim Entwickeln nötig)'
    }
    else {
        Write-Note 'Rojo-Plugin konnte nicht installiert werden – zum Testen nicht nötig.'
    }
}

function New-DesktopShortcut {
    param([string]$RepoRoot)
    $desktop = [Environment]::GetFolderPath('Desktop')
    if ([string]::IsNullOrWhiteSpace($desktop)) {
        Write-Note 'Kein Desktop-Ordner gefunden – Verknüpfung übersprungen.'
        return
    }
    $target = Join-Path $RepoRoot 'installer\Schwungturm-Starten.bat'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path $desktop $script:ShortcutName))
    $shortcut.TargetPath = $target
    $shortcut.WorkingDirectory = Join-Path $RepoRoot 'installer'
    $shortcut.Description = 'Schwungturm neu bauen und in Roblox Studio öffnen'
    $shortcut.Save()
    Write-Ok ("Desktop-Verknüpfung '{0}' angelegt" -f ($script:ShortcutName -replace '\.lnk$', ''))
}

function Open-Place {
    param([string]$Studio, [string]$Place)
    if ($Studio) {
        # Offizieller Aufruf laut Roblox-Doku: --task EditFile --localPlaceFile "<Pfad>"
        Start-Process -FilePath $Studio -ArgumentList @('--task', 'EditFile', '--localPlaceFile', ('"{0}"' -f $Place))
    }
    else {
        Start-Process -FilePath $Place
    }
    Write-Ok 'Roblox Studio wird geöffnet ...'
}

function Invoke-Uninstall {
    param([string]$RepoRoot)
    $exe = Join-Path $RepoRoot '.tools\bin\rojo.exe'
    if (Test-Path -LiteralPath $exe) {
        try {
            & $exe plugin uninstall 2>$null | Out-Null
            Write-Ok 'Rojo-Plugin aus Studio entfernt'
        }
        catch {
            Write-Note 'Rojo-Plugin konnte nicht entfernt werden (ggf. nicht installiert).'
        }
        Remove-Item -LiteralPath $exe -Force
        Write-Ok 'Rojo entfernt'
    }
    $place = Join-Path (Join-Path $RepoRoot 'build') $script:PlaceFileName
    if (Test-Path -LiteralPath $place) {
        Remove-Item -LiteralPath $place -Force
        Write-Ok 'Spieldatei entfernt'
    }
    $desktop = [Environment]::GetFolderPath('Desktop')
    if ($desktop) {
        $link = Join-Path $desktop $script:ShortcutName
        if (Test-Path -LiteralPath $link) {
            Remove-Item -LiteralPath $link -Force
            Write-Ok 'Desktop-Verknüpfung entfernt'
        }
    }
    Write-Host ''
    Write-Host 'Deinstallation abgeschlossen. Roblox Studio selbst bleibt installiert.' -ForegroundColor Green
}

function Invoke-Main {
    Write-Host '=============================================' -ForegroundColor White
    Write-Host '  Schwungturm – Einrichtung für Roblox Studio' -ForegroundColor White
    Write-Host '=============================================' -ForegroundColor White

    $repoRoot = Get-RepoRoot -ScriptDirectory $PSScriptRoot
    if ($Uninstall) {
        Invoke-Uninstall -RepoRoot $repoRoot
        return
    }

    $total = 5
    if ($Quick) { $total = 3 }
    $step = 1

    Write-Step $step $total 'Projekt prüfen'
    Write-Ok ("Projektordner: {0}" -f $repoRoot)
    $step++

    Write-Step $step $total 'Build-Werkzeug Rojo bereitstellen'
    if ($RojoPath) {
        $rojo = $RojoPath
        Write-Ok ("Verwende vorhandenes Rojo: {0}" -f $rojo)
    }
    else {
        $rojo = Get-RojoExecutable -RepoRoot $repoRoot -Version $RojoVersion
    }
    $step++

    Write-Step $step $total 'Spieldatei bauen'
    $place = Invoke-PlaceBuild -Rojo $rojo -RepoRoot $repoRoot
    $step++

    $studio = Find-RobloxStudio
    if (-not $Quick) {
        Write-Step $step $total 'Roblox Studio prüfen'
        if ($studio) {
            Write-Ok ("Roblox Studio gefunden: {0}" -f $studio)
        }
        else {
            Write-Note 'Roblox Studio ist nicht installiert. Die offizielle Roblox-Seite wird geöffnet.'
            Write-Note 'Dort "Studio herunterladen" wählen, installieren und mit deinem Konto anmelden.'
            if (-not $NoOpen) {
                Start-Process $script:StudioDownloadPage
                Read-Host '    Wenn Roblox Studio installiert ist, Enter drücken'
                $studio = Find-RobloxStudio
            }
        }
        $step++

        Write-Step $step $total 'Rojo-Plugin und Desktop-Verknüpfung'
        Install-RojoPlugin -Rojo $rojo
        New-DesktopShortcut -RepoRoot $repoRoot
    }

    if (-not $NoOpen) {
        Open-Place -Studio $studio -Place $place
    }

    Write-Host ''
    Write-Host 'Fertig!' -ForegroundColor Green
    Write-Host '  So testest du: In Roblox Studio oben auf "Play" klicken (oder F5).'
    Write-Host '  Checkliste für den Test: reports\owner_test_template.md'
    Write-Host '  Nach einem Update des Projektordners: Desktop-Verknüpfung "Schwungturm testen" starten.'
}

# Nur ausführen, wenn das Skript gestartet (nicht per Punkt-Operator für Tests geladen) wird.
if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-Main
    }
    catch {
        Write-Host ''
        Write-Host ("FEHLER: {0}" -f $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Hilfe: installer\ANLEITUNG.md (Abschnitt "Probleme")' -ForegroundColor Red
        exit 1
    }
}
