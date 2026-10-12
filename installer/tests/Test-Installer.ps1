#Requires -Version 7
# Tests für installer/install.ps1. Laufen mit PowerShell 7 (Linux oder Windows), z. B.:
#   pwsh -NoProfile -File installer/tests/Test-Installer.ps1
# Windows-spezifische Teile (Windows PowerShell 5.1, Desktop-Verknüpfung, Studio-Start) prüft das nicht.
Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerDir = Split-Path -Parent $testDir
$repoRoot = Split-Path -Parent $installerDir
$installer = Join-Path $installerDir 'install.ps1'

. $installer # lädt nur die Funktionen (Main läuft beim Punkt-Laden nicht)

$script:passed = 0
$script:failed = 0

function Test-Case {
    param([string]$Name, [scriptblock]$Body)
    try {
        & $Body
        $script:passed++
        Write-Host ("  ✓ {0}" -f $Name)
    }
    catch {
        $script:failed++
        Write-Host ("  ✗ {0}`n      {1}" -f $Name, $_.Exception.Message)
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function New-TempDir {
    $path = Join-Path ([IO.Path]::GetTempPath()) ('schwungturm-test-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

Write-Host '▶ installer/install.ps1'

Test-Case 'Select-ReleaseAsset wählt die Windows-x86_64-ZIP aus mehreren Assets' {
    $release = [pscustomobject]@{
        assets = @(
            [pscustomobject]@{ name = 'rojo-7.7.1-linux-x86_64.zip'; browser_download_url = 'l' },
            [pscustomobject]@{ name = 'rojo-7.7.1-macos-aarch64.zip'; browser_download_url = 'm' },
            [pscustomobject]@{ name = 'rojo-7.7.1-windows-x86_64.zip'; browser_download_url = 'w' }
        )
    }
    $asset = Select-ReleaseAsset -Release $release
    Assert-True ($asset.browser_download_url -eq 'w') 'falsches Asset gewählt'
}

Test-Case 'Select-ReleaseAsset bricht ohne Windows-Datei mit klarer Meldung ab' {
    $release = [pscustomobject]@{ assets = @([pscustomobject]@{ name = 'rojo-linux.zip'; browser_download_url = 'l' }) }
    $threw = $false
    try { Select-ReleaseAsset -Release $release | Out-Null } catch { $threw = $_.Exception.Message -like '*Windows*' }
    Assert-True $threw 'kein Fehler bzw. unklare Meldung'
}

Test-Case 'Test-RojoVersionText erkennt genau die gewünschte Version' {
    Assert-True (Test-RojoVersionText -VersionText "Rojo 7.7.1`n" -Version '7.7.1') 'exakte Version nicht erkannt'
    Assert-True (-not (Test-RojoVersionText -VersionText 'Rojo 7.7.10' -Version '7.7.1')) '7.7.10 fälschlich akzeptiert'
    Assert-True (-not (Test-RojoVersionText -VersionText 'Rojo 7.6.0' -Version '7.7.1')) 'alte Version akzeptiert'
    Assert-True (-not (Test-RojoVersionText -VersionText '' -Version '7.7.1')) 'leere Ausgabe akzeptiert'
}

Test-Case 'Test-AssetDigest: passende Prüfsumme bestätigt, falsche bricht ab, fehlende zeigt Hash' {
    $dir = New-TempDir
    try {
        $file = Join-Path $dir 'x.zip'
        [IO.File]::WriteAllText($file, 'hallo')
        $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()
        $ok = Test-AssetDigest -Asset ([pscustomobject]@{ name = 'x'; digest = "sha256:$hash" }) -FilePath $file
        Assert-True $ok.Verified 'korrekte Prüfsumme nicht bestätigt'
        $threw = $false
        try { Test-AssetDigest -Asset ([pscustomobject]@{ name = 'x'; digest = 'sha256:00' }) -FilePath $file | Out-Null } catch { $threw = $true }
        Assert-True $threw 'falsche Prüfsumme nicht erkannt'
        $none = Test-AssetDigest -Asset ([pscustomobject]@{ name = 'x' }) -FilePath $file
        Assert-True ((-not $none.Verified) -and $none.Sha256 -eq $hash) 'fehlende Prüfsumme falsch behandelt'
    }
    finally { Remove-Item -LiteralPath $dir -Recurse -Force }
}

Test-Case 'Get-RepoRoot findet den Projektordner und lehnt fremde Ordner ab' {
    Assert-True ((Get-RepoRoot -ScriptDirectory $installerDir) -eq $repoRoot) 'Projektordner nicht gefunden'
    $dir = New-TempDir
    try {
        $threw = $false
        try { Get-RepoRoot -ScriptDirectory (Join-Path $dir 'installer') | Out-Null } catch { $threw = $true }
        Assert-True $threw 'fremder Ordner akzeptiert'
    }
    finally { Remove-Item -LiteralPath $dir -Recurse -Force }
}

Test-Case 'Find-RobloxStudio nimmt die neueste installierte Version, sonst $null' {
    $dir = New-TempDir
    try {
        Assert-True ($null -eq (Find-RobloxStudio -LocalAppData $dir)) 'ohne Roblox-Ordner nicht $null'
        Assert-True ($null -eq (Find-RobloxStudio -LocalAppData '')) 'ohne LOCALAPPDATA nicht $null'
        $old = Join-Path $dir 'Roblox/Versions/version-old'
        $new = Join-Path $dir 'Roblox/Versions/version-new'
        $player = Join-Path $dir 'Roblox/Versions/version-player'
        New-Item -ItemType Directory -Path $old, $new, $player | Out-Null
        $oldExe = Join-Path $old 'RobloxStudioBeta.exe'
        $newExe = Join-Path $new 'RobloxStudioBeta.exe'
        Set-Content -LiteralPath $oldExe -Value 'x'
        Set-Content -LiteralPath $newExe -Value 'x'
        Set-Content -LiteralPath (Join-Path $player 'RobloxPlayerBeta.exe') -Value 'x'
        (Get-Item -LiteralPath $oldExe).LastWriteTime = (Get-Date).AddDays(-30)
        (Get-Item -LiteralPath $newExe).LastWriteTime = (Get-Date)
        Assert-True ((Find-RobloxStudio -LocalAppData $dir) -eq $newExe) 'nicht die neueste Studio-Version gewählt'
    }
    finally { Remove-Item -LiteralPath $dir -Recurse -Force }
}

$rojoCommand = Get-Command rojo -ErrorAction SilentlyContinue
if ($rojoCommand) {
    Test-Case 'Invoke-PlaceBuild baut build/Schwungturm.rbxlx mit Server- und Client-Skripten' {
        $result = @(Invoke-PlaceBuild -Rojo $rojoCommand.Source -RepoRoot $repoRoot)
        Assert-True ($result.Count -eq 1) ('Rückgabe ist kein einzelner Pfad: ' + ($result -join ' | '))
        $place = [string]$result[0]
        Assert-True ($place.EndsWith('Schwungturm.rbxlx')) ('falscher Pfad: ' + $place)
        $xml = Get-Content -LiteralPath $place -Raw
        Assert-True ($xml -match 'ServerScriptService') 'ServerScriptService fehlt'
        Assert-True ($xml -match 'StarterPlayerScripts') 'StarterPlayerScripts fehlt'
        Assert-True ($xml -match 'LocalizationTable') 'LocalizationTable fehlt'
    }

    Test-Case 'Gesamtlauf -Quick -NoOpen mit vorhandenem Rojo endet erfolgreich' {
        $output = & pwsh -NoProfile -File $installer -Quick -NoOpen -RojoPath $rojoCommand.Source 2>&1 | Out-String
        Assert-True ($LASTEXITCODE -eq 0) ("Exit-Code {0}: {1}" -f $LASTEXITCODE, $output)
        Assert-True ($output -match 'Fertig') 'keine Abschlussmeldung'
    }
}
else {
    Write-Host '  - Build-Tests übersprungen (rojo nicht im PATH)'
}

Test-Case 'Gesamtlauf außerhalb des Projektordners scheitert mit Exit-Code 1 und Meldung' {
    $dir = New-TempDir
    try {
        $copyDir = Join-Path $dir 'installer'
        New-Item -ItemType Directory -Path $copyDir | Out-Null
        Copy-Item -LiteralPath $installer -Destination $copyDir
        $output = & pwsh -NoProfile -File (Join-Path $copyDir 'install.ps1') -Quick -NoOpen 2>&1 | Out-String
        Assert-True ($LASTEXITCODE -eq 1) 'falscher Exit-Code'
        Assert-True ($output -match 'Projektordner nicht gefunden') 'keine verständliche Fehlermeldung'
    }
    finally { Remove-Item -LiteralPath $dir -Recurse -Force }
}

Test-Case 'Invoke-Uninstall entfernt Rojo und Spieldatei, auch wenn rojo.exe defekt ist' {
    $dir = New-TempDir
    try {
        New-Item -ItemType Directory -Path (Join-Path $dir '.tools/bin'), (Join-Path $dir 'build') | Out-Null
        $fakeExe = Join-Path $dir '.tools/bin/rojo.exe'
        $fakePlace = Join-Path $dir ('build/' + $script:PlaceFileName)
        Set-Content -LiteralPath $fakeExe -Value 'kein Programm'
        Set-Content -LiteralPath $fakePlace -Value 'x'
        Invoke-Uninstall -RepoRoot $dir | Out-Null
        Assert-True (-not (Test-Path -LiteralPath $fakeExe)) 'rojo.exe nicht entfernt'
        Assert-True (-not (Test-Path -LiteralPath $fakePlace)) 'Spieldatei nicht entfernt'
    }
    finally { Remove-Item -LiteralPath $dir -Recurse -Force }
}

# Download-Pfad mit nachgebildeter GitHub-API (echte Downloads sind in Tests nicht möglich/erwünscht).
function New-FakeRojoZip {
    param([string]$Directory)
    $stage = Join-Path $Directory 'stage'
    New-Item -ItemType Directory -Path $stage | Out-Null
    Set-Content -LiteralPath (Join-Path $stage 'rojo.exe') -Value 'fake-rojo'
    $zip = Join-Path $Directory 'rojo-7.7.1-windows-x86_64.zip'
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
    return $zip
}

Test-Case 'Get-RojoExecutable: lädt, prüft die Prüfsumme, entpackt nach .tools/bin' {
    $dir = New-TempDir
    try {
        $zip = New-FakeRojoZip -Directory $dir
        $hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
        $script:FakeZip = $zip
        $script:FakeDigest = "sha256:$hash"
        function Invoke-RestMethod {
            param($Uri, $Headers)
            return [pscustomobject]@{ assets = @([pscustomobject]@{ name = 'rojo-7.7.1-windows-x86_64.zip'; browser_download_url = 'https://example.invalid/r.zip'; digest = $script:FakeDigest }) }
        }
        function Invoke-WebRequest {
            param($Uri, $OutFile, [switch]$UseBasicParsing, $Headers)
            Copy-Item -LiteralPath $script:FakeZip -Destination $OutFile
        }
        $repo = Join-Path $dir 'repo'
        New-Item -ItemType Directory -Path $repo | Out-Null
        $result = @(Get-RojoExecutable -RepoRoot $repo -Version '7.7.1')
        Assert-True ($result.Count -eq 1) 'Rückgabe ist kein einzelner Pfad'
        $exe = Join-Path $repo '.tools\bin\rojo.exe'
        Assert-True (Test-Path -LiteralPath $exe) 'rojo.exe nicht installiert'
        Assert-True ((Get-Content -LiteralPath $exe -Raw).Trim() -eq 'fake-rojo') 'falscher Inhalt'

        # Falsche Prüfsumme: Abbruch, nichts installiert
        $script:FakeDigest = 'sha256:0000'
        $repo2 = Join-Path $dir 'repo2'
        New-Item -ItemType Directory -Path $repo2 | Out-Null
        $threw = $false
        try { Get-RojoExecutable -RepoRoot $repo2 -Version '7.7.1' | Out-Null } catch { $threw = $_.Exception.Message -like '*Prüfsumme*' }
        Assert-True $threw 'falsche Prüfsumme nicht erkannt'
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $repo2 '.tools\bin\rojo.exe'))) 'trotz falscher Prüfsumme installiert'
    }
    finally {
        Remove-Item Function:\Invoke-RestMethod, Function:\Invoke-WebRequest -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $dir -Recurse -Force
    }
}

if (-not $IsWindows) {
    Test-Case 'Get-RojoExecutable: vorhandenes Rojo in passender Version wird nicht neu geladen' {
        $dir = New-TempDir
        try {
            $bin = Join-Path $dir '.tools\bin'
            New-Item -ItemType Directory -Path $bin | Out-Null
            $exe = Join-Path $bin 'rojo.exe'
            Set-Content -LiteralPath $exe -Value "#!/bin/sh`necho 'Rojo 7.7.1'"
            & chmod +x $exe
            function Invoke-RestMethod { throw 'Download hätte nicht stattfinden dürfen' }
            $result = @(Get-RojoExecutable -RepoRoot $dir -Version '7.7.1')
            Assert-True ($result.Count -eq 1 -and $result[0] -eq $exe) 'vorhandenes Rojo nicht verwendet'
        }
        finally {
            Remove-Item Function:\Invoke-RestMethod -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $dir -Recurse -Force
        }
    }
}

Test-Case 'Kompatibilität mit Windows PowerShell 5.1: keine Syntax nur für PowerShell 7' {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($installer, [ref]$tokens, [ref]$errors)
    Assert-True ($errors.Count -eq 0) ('Syntaxfehler: ' + ($errors | Out-String))
    $bad = $ast.FindAll({
            param($node)
            $type = $node.GetType().Name
            if ($type -in @('TernaryExpressionAst', 'PipelineChainAst')) { return $true }
            if ($node -is [System.Management.Automation.Language.BinaryExpressionAst] -and $node.Operator -eq 'QuestionQuestion') { return $true }
            if ($node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Operator -eq 'QuestionQuestionEquals') { return $true }
            if ($node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.NullConditional) { return $true }
            if ($node -is [System.Management.Automation.Language.IndexExpressionAst] -and $node.NullConditional) { return $true }
            if ($node -is [System.Management.Automation.Language.CommandParameterAst] -and $node.ParameterName -eq 'Parallel') { return $true }
            return $false
        }, $true)
    Assert-True (@($bad).Count -eq 0) ('PowerShell-7-Syntax gefunden: ' + (@($bad) | ForEach-Object { $_.Extent.Text } | Out-String))
}

Test-Case 'Dateiformate: install.ps1 UTF-8 mit BOM; .bat-Dateien reines ASCII mit CRLF' {
    $bytes = [IO.File]::ReadAllBytes($installer)
    Assert-True ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) 'install.ps1 ohne UTF-8-BOM (Umlaute in PowerShell 5.1 kaputt)'
    foreach ($bat in Get-ChildItem -LiteralPath $installerDir -Filter '*.bat') {
        $raw = [IO.File]::ReadAllBytes($bat.FullName)
        Assert-True (@($raw | Where-Object { $_ -gt 127 }).Count -eq 0) ("{0} enthält Nicht-ASCII-Zeichen" -f $bat.Name)
        $text = [Text.Encoding]::ASCII.GetString($raw)
        Assert-True (($text -split "`r`n").Count -eq ($text -split "`n").Count) ("{0} hat nicht durchgehend CRLF" -f $bat.Name)
    }
}

Write-Host ''
Write-Host ("{0} bestanden, {1} fehlgeschlagen, {2} gesamt" -f $script:passed, $script:failed, ($script:passed + $script:failed))
if ($script:failed -gt 0) { exit 1 }
