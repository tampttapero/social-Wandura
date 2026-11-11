# Sao luu database Postiz vao thu muc backups\
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
New-Item -ItemType Directory -Force backups | Out-Null
$file = "backups\postiz-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql"
docker exec postiz-postgres pg_dump -U postiz-user postiz-db-local | Out-File -Encoding utf8 $file
Write-Host "Da sao luu: $file" -ForegroundColor Green
