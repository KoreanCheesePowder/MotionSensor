$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

function Invoke-SmartThings {
  param([Parameter(Mandatory = $true)][string[]]$Arguments)
  & smartthings @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "SmartThings CLI command failed: smartthings $($Arguments -join ' ')"
  }
}

Write-Host "[1/2] 기존 Driver Information Capability 적용" -ForegroundColor Cyan
Write-Host "  buildbook37604.driverInformation" -ForegroundColor DarkGray
Write-Host "  제작자: 치즈가루" -ForegroundColor DarkGray
Write-Host "  버전: v1.0.3" -ForegroundColor DarkGray

Write-Host "[2/2] 드라이버 패키징 및 설치" -ForegroundColor Cyan
Invoke-SmartThings @("edge:drivers:package", ".", "--install")

Write-Host "Installation completed." -ForegroundColor Green
