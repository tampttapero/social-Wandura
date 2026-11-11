# Khoi tao va chay Social Wandura.
# Dung: .\scripts\setup.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Chua co Docker. Cai Docker Desktop: winget install --id Docker.DockerDesktop -e --source winget"
}
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "Docker Desktop chua chay. Hay mo Docker Desktop roi chay lai." }

function New-Secret([int]$len = 48) {
    $bytes = New-Object byte[] $len
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([Convert]::ToBase64String($bytes) -replace '[^A-Za-z0-9]', '').Substring(0, [Math]::Min(40, $len))
}

if (-not (Test-Path .env)) {
    $content = Get-Content .env.example -Raw
    $content = $content -replace '(?m)^JWT_SECRET=.*$', "JWT_SECRET=$(New-Secret 64)"
    $content = $content -replace '(?m)^POSTGRES_PASSWORD=.*$', "POSTGRES_PASSWORD=$(New-Secret 32)"
    [IO.File]::WriteAllText((Join-Path $root '.env'), $content)
    Write-Host "Da tao .env voi mat khau ngau nhien. Dien API key cac mang xa hoi vao .env." -ForegroundColor Green
} else {
    Write-Host ".env da ton tai - giu nguyen." -ForegroundColor Yellow
}

docker compose pull
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw "docker compose up that bai." }

$port = (Select-String -Path .env -Pattern '^APP_PORT=(\d+)').Matches.Groups[1].Value
if (-not $port) { $port = 4007 }
$url = "http://localhost:$port"
Write-Host "Dang cho Postiz khoi dong (lan dau co the mat 2-5 phut)..."
for ($i = 0; $i -lt 60; $i++) {
    try {
        $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -lt 500) { Write-Host "San sang: $url" -ForegroundColor Green; Start-Process $url; exit 0 }
    } catch { }
    Start-Sleep -Seconds 10
}
Write-Warning "Chua thay Postiz phan hoi. Xem log: docker compose logs -f postiz"
