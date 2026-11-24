param(
  [string]$Tarea,
  [string]$Estado
)

$emoji = switch ($Estado) {
  "Sin empezar"  { ":clipboard:" }
  "En progreso"  { ":construction:" }
  "Listo"        { ":white_check_mark:" }
  default        { ":memo:" }
}

$nombreCompleto = $Tarea

if ($env:NOTION_TOKEN -and $env:NOTION_DB_ID) {
  $headers = @{
    "Authorization"  = "Bearer $($env:NOTION_TOKEN)"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json; charset=utf-8"
  }
  try {
    $filtro = @{ filter = @{ property = "Nombre"; title = @{ starts_with = $Tarea } } } | ConvertTo-Json -Depth 6
    $res = Invoke-RestMethod -Method Post -Uri "https://api.notion.com/v1/databases/$($env:NOTION_DB_ID)/query" -Headers $headers -Body ([Text.Encoding]::UTF8.GetBytes($filtro))
    if ($res.results.Count -gt 0) {
      $pagina = $res.results[0]
      $nombreCompleto = $pagina.properties.Nombre.title[0].plain_text
      $cuerpo = @{ properties = @{ Estado = @{ status = @{ name = $Estado } } } } | ConvertTo-Json -Depth 6
      Invoke-RestMethod -Method Patch -Uri "https://api.notion.com/v1/pages/$($pagina.id)" -Headers $headers -Body ([Text.Encoding]::UTF8.GetBytes($cuerpo)) | Out-Null
      Write-Host "Notion actualizado: $nombreCompleto -> $Estado"
    } else { Write-Host "No encontre la tarea '$Tarea'" }
  } catch { Write-Host "Notion fallo: $($_.Exception.Message)" }
}

powershell -ExecutionPolicy Bypass -File .\notify.ps1 "$emoji *PLAN* $nombreCompleto cambio a *$Estado* (Notion)"
