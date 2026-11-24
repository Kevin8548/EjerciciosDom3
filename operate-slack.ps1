$webhook = $env:SLACK_WEBHOOK_URL

function Send-Slack($texto) {
  $json = @{ text = $texto } | ConvertTo-Json
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
  Invoke-RestMethod -Uri $webhook -Method Post -ContentType "application/json; charset=utf-8" -Body $bytes | Out-Null
}

Send-Slack ":eyes: *OPERATE* Vigilando el contenedor galeria"

docker events --filter "container=galeria" --filter "event=start" --filter "event=stop" --filter "event=die" --filter "event=restart" --filter "event=kill" --format "{{.Action}}" | ForEach-Object {
  $hora = Get-Date -Format "HH:mm:ss"
  Send-Slack ":gear: *OPERATE* Contenedor galeria - evento: $_ ($hora)"
}