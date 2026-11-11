# Cap nhat Postiz len ban moi (sao luu truoc)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
& "$PSScriptRoot\backup.ps1"
docker compose pull
docker compose up -d
Write-Host "Da cap nhat. Xem log: docker compose logs -f postiz" -ForegroundColor Green
