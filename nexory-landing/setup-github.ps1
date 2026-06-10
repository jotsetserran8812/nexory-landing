# =====================================================
#  Nexory Landing — Setup GitHub + Netlify
#  Ejecuta este script UNA sola vez desde PowerShell
# =====================================================

$RepoName   = "nexory-landing"
$RepoDesc   = "Landing page oficial de Nexory — Agentes de IA para atencion al cliente 24/7"
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "=== NEXORY LANDING — GitHub Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Pedir el token
Write-Host "Necesitas un GitHub Personal Access Token (classic) con permiso 'repo'." -ForegroundColor Yellow
Write-Host "Para generarlo:"
Write-Host "  1. Ve a https://github.com/settings/tokens/new"
Write-Host "  2. Dale un nombre: 'nexory-deploy'"
Write-Host "  3. Expiracion: 90 dias (o la que prefieras)"
Write-Host "  4. Marca el checkbox 'repo' (primer grupo)"
Write-Host "  5. Clic en 'Generate token' y copia el token"
Write-Host ""

$Token = Read-Host "Pega tu GitHub Token aqui (no se muestra por seguridad)" -AsSecureString
$TokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token))

$Username = Read-Host "Tu usuario de GitHub (ej: joseth-dev)"

# 2. Crear el repo en GitHub via API
Write-Host ""
Write-Host "Creando repositorio '$RepoName' en GitHub..." -ForegroundColor Cyan

$Headers = @{
    Authorization = "token $TokenPlain"
    Accept        = "application/vnd.github.v3+json"
}
$Body = @{
    name        = $RepoName
    description = $RepoDesc
    private     = $false
    auto_init   = $false
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
        -Method POST -Headers $Headers -Body $Body -ContentType "application/json"
    Write-Host "Repositorio creado: $($Response.html_url)" -ForegroundColor Green
} catch {
    $ErrorMsg = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($ErrorMsg.errors[0].message -like "*already exists*") {
        Write-Host "El repo ya existe, continuando..." -ForegroundColor Yellow
    } else {
        Write-Host "Error al crear repo: $($ErrorMsg.message)" -ForegroundColor Red
        exit 1
    }
}

# 3. Inicializar git y hacer push
Write-Host ""
Write-Host "Inicializando Git y subiendo archivos..." -ForegroundColor Cyan

Set-Location $ScriptDir

git init
git config user.email "jotsetserr04@gmail.com"
git config user.name "joseth"
git branch -M main
git add .
git commit -m "feat: landing page inicial de Nexory"

$RemoteUrl = "https://${Username}:${TokenPlain}@github.com/${Username}/${RepoName}.git"
git remote add origin $RemoteUrl
git push -u origin main

Write-Host ""
Write-Host "=== LISTO! ===" -ForegroundColor Green
Write-Host "Tu repo esta en: https://github.com/$Username/$RepoName" -ForegroundColor Green
Write-Host ""
Write-Host "SIGUIENTE PASO — Conectar con Netlify:" -ForegroundColor Yellow
Write-Host "  1. Ve a https://app.netlify.com"
Write-Host "  2. Clic en 'Add new site' → 'Import an existing project'"
Write-Host "  3. Elige GitHub y selecciona el repo '$RepoName'"
Write-Host "  4. Build command: (dejar vacio)"
Write-Host "  5. Publish directory: . (punto)"
Write-Host "  6. Clic 'Deploy site'"
Write-Host ""
Write-Host "Netlify te dara una URL tipo: https://nexory-landing.netlify.app" -ForegroundColor Cyan
