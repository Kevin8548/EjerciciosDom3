param(
  [string]$Tarea,
  [string]$Estado
)

$emoji = switch ($Estado) {
  "Sin empezar"  { ":clipboard:" }
  "Por hacer"    { ":clipboard:" }
  "En progreso"  { ":construction:" }
  "En curso"     { ":construction:" }
  "Hecho"        { ":white_check_mark:" }
  "Listo"        { ":white_check_mark:" }
  "Finalizado"   { ":white_check_mark:" }
  default        { ":memo:" }
}

$nombreCompleto = $Tarea

if ($env:NOTION_TOKEN -and $env:NOTION_DB_ID) {
  $headers = @{
    "Authorization"  = "Bearer $($env:NOTION_TOKEN)"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json; charset=utf-8"
  }

  # 1. Buscar la tarea por el inicio de su nombre
  $filtro = @{ filter = @{ property = "Nombre"; title = @{ starts_with = $Tarea } } } | ConvertTo-Json -Depth 6
  $bytesFiltro = [System.Text.Encoding]::UTF8.GetBytes($filtro)
  $res = Invoke-RestMethod -Method Post -Uri "https://api.notion.com/v1/databases/$($env:NOTION_DB_ID)/query" -Headers $headers -Body $bytesFiltro

  if ($res.results.Count -gt 0) {
    $pagina = $res.results[0]
    $nombreCompleto = $pagina.properties.Nombre.title[0].plain_text

    # 2. Cambiar el Estado
    $cuerpo = @{ properties = @{ Estado = @{ status = @{ name = $Estado } } } } | ConvertTo-Json -Depth 6
    $bytesCuerpo = [System.Text.Encoding]::UTF8.GetBytes($cuerpo)
    Invoke-RestMethod -Method Patch -Uri "https://api.notion.com/v1/pages/$($pagina.id)" -Headers $headers -Body $bytesCuerpo | Out-Null
    Write-Host "Notion actualizado: $nombreCompleto -> $Estado"
  } else {
    Write-Host "No encontre la tarea '$Tarea' en Notion"
  }
}
else {
  Write-Host "Sin NOTION_TOKEN/NOTION_DB_ID: solo se avisa a Slack"
}

powershell -ExecutionPolicy Bypass -File .\notify.ps1 "$emoji *PLAN* $nombreCompleto cambio a *$Estado* (Notion)"