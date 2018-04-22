#Requires -Modules psake
[cmdletbinding()]
param(
    [ValidateSet('Build','Test','BuildHelp','Install','Clean','Analyze','Publish','osFinish','FullBuild','avScriptModule')]
    [string[]]$Task = 'Build'
)

if ($Task -eq 'osFinish') {
    if (-not($env:APPVEYOR_BUILD_FOLDER)) {
        throw "This task is intended for use in Appveyor only."
    }

    $stagingDirectory = (Resolve-Path $env:APPVEYOR_BUILD_FOLDER).Path
    $releaseDirectory = Join-Path $env:APPVEYOR_BUILD_FOLDER '\Release'
    $zipFile = Join-Path $stagingDirectory "Grouper-$($env:APPVEYOR_REPO_BRANCH).zip"
    Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($releaseDirectory, $zipFile)
    Push-AppveyorArtifact $zipFile
} elseif ($Task -eq 'avScriptModule') {
    if (-not($env:APPVEYOR_BUILD_FOLDER)) {
        throw "This task is intended for use in Appveyor only."
    }

    try {
        Invoke-psake (Join-Path $env:APPVEYOR_BUILD_FOLDER build.psake.ps1) -taskList BuildScriptModule -ErrorAction Stop
    } catch {
        throw "Failed to build script module."
    }
    Push-AppveyorArtifact Join-Path $env:APPVEYOR_BUILD_FOLDER '\Release\Grouper.psm1'
} else {
    Import-Module psake;Import-Module Pester;Import-Module PSScriptAnalyzer
    Invoke-psake -buildFile "$PSScriptRoot\build.psake.ps1" -taskList $Task -Verbose:$VerbosePreference
}