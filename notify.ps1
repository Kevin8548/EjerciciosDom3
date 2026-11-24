param([string]$Mensaje)

if (-not $env:SLACK_WEBHOOK_URL) {
  Write-Host "Falta definir SLACK_WEBHOOK_URL"
  exit 1
}

$json = @{ text = $Mensaje } | ConvertTo-Json
$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
Invoke-RestMethod -Uri $env:SLACK_WEBHOOK_URL -Method Post -ContentType "application/json; charset=utf-8" -Body $bytes | Out-Null