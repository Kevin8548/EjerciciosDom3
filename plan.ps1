param(
  [string]$Tarea,
  [string]$Estado
)

$emoji = switch ($Estado) {
  "Por hacer"    { ":clipboard:" }
  "En progreso"  { ":construction:" }
  "Hecho"        { ":white_check_mark:" }
  default        { ":memo:" }
}

powershell -ExecutionPolicy Bypass -File .\notify.ps1 "$emoji *PLAN* $Tarea cambio a *$Estado* (Notion)"