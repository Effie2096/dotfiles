let geos = $env.GEOCO
let api_key = $env.YASB_WEATHER_API_KEY

let base = (date now | date to-timezone "Europe/London")

let today = ($base | format date "%Y-%m-%d")
let tomorrow = (($base + 1day) | format date "%Y-%m-%d")

let days = [
  { label: "today", date: $today },
  { label: "tomorrow", date: $tomorrow }
]

def split-time [t] {
	let parts = ($t | split row " ")
		let time = ($parts.0 | split row ":")
		let hour = ($time | get 0 | into int) + if $parts.1 == "PM" { 12 } else {0}
	{
		hour: $hour,
		minute:  ($time | get 1 | into int),
	}
}

$days
| each {|d|
    let res = (http get $"https://api.weatherapi.com/v1/astronomy.json?key=($api_key)&q=($geos)&dt=($d.date)")

    let astro = $res.astronomy.astro

    {
      label: $d.label,
      sunrise: (split-time $astro.sunrise),
      sunset:  (split-time $astro.sunset),
    }
}
| reduce -f {} {|day, acc|
    let label = ($day | get label)
    $acc | upsert $label ($day | reject label)
}
| to json
| save -f ($env.XDG_STATE_HOME | path join astronomy.json)
