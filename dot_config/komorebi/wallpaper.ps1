$arg = $args[0]
$jsonContent = Get-Content -Raw -Path "$Env:KOMOREBI_CONFIG_HOME/komorebi.json"
$leconfig = $jsonContent | ConvertFrom-Json
$leconfig.monitors[0].wallpaper.path = $arg

$leconfig | ConvertTo-Json -Depth 32 | Set-Content -Path "$Env:KOMOREBI_CONFIG_HOME/komorebi.json"
