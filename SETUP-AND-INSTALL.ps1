$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

function Invoke-SmartThings {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  & smartthings @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "SmartThings CLI command failed: smartthings $($Arguments -join ' ')"
  }
}

Write-Host "[1/2] Driver Information" -ForegroundColor Cyan
Write-Host "  Author: CheesePowder" -ForegroundColor DarkGray
Write-Host "  Version: v1.0.7" -ForegroundColor DarkGray

Write-Host "[2/2] Packaging and installing driver" -ForegroundColor Cyan
Invoke-SmartThings @("edge:drivers:package", ".", "--install")

Write-Host "Installation completed." -ForegroundColor Green
