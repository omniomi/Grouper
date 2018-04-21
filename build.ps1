#Requires -Modules psake
[cmdletbinding()]
param(
    [ValidateSet('Build','Test','BuildHelp','Install','Clean','Analyze','Publish','osFinish','FullBuild')]
    [string[]]$Task = 'Build'
)

if ($Task -eq 'osFinish') {
    $stagingDirectory = (Resolve-Path $env:APPVEYOR_BUILD_FOLDER).Path
    $releaseDirectory = Join-Path $env:APPVEYOR_BUILD_FOLDER '\Release\Grouper'
    $zipFile = Join-Path $stagingDirectory "Grouper-$($env:APPVEYOR_REPO_BRANCH).zip"
    Add-Type -assemblyname System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($releaseDirectory, $zipFile)
    Write-Host $zipFile
    Push-AppveyorArtifact $zipFile
} else {
    Import-Module psake;Import-Module Pester;Import-Module PSScriptAnalyzer
    Invoke-psake -buildFile "$PSScriptRoot\build.psake.ps1" -taskList $Task -Verbose:$VerbosePreference
}