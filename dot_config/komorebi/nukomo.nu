def main [] { }

const SIZING = ["increase" "decrease"]
export def "main scroll-columns" [sizing: string]  {
	if not ($sizing in $SIZING) {
		error make { msg: $"Invalid sizing: ($sizing). Must be one of: ($SIZING | str join ', ')" }
	}

	let monitor_idx = (komorebic query focused-monitor-index) | into int
	let workspace_idx = (komorebic query focused-workspace-index) | into int

	let workspace_state = (komorebic state
	| from json | get monitors | get elements | get $monitor_idx
	| get workspaces.elements | get $workspace_idx)

	if (($workspace_state | get layout.Default) == "Scrolling") {
		let curr_columns = ($workspace_state | get layout_options.scrolling.columns)
		mut new_columns = match $sizing {
			"increase" => { $curr_columns + 1}
			"decrease" => { $curr_columns - 1}
		}
		if ($new_columns <= 0) { $new_columns = 1 }
		if ($new_columns > 4) { $new_columns = 4 }

		(komorebic scrolling-layout-columns $new_columns)
	}

}

export def "main bar-offset" [] {
	let monitors = (komorebic state | from json | get monitors.elements)

	let _ = $monitors | enumerate | each {|monitor|
		let offset = $monitor.item | get work_area_offset | default {left: 0, top: 0, right: 0, bottom: 0}
		| items {|key, value| {$key: ($value | into int)}}
		| reduce {|$it, $acc| $acc | merge $it}

		let new_offset = if ($offset.top == 0) { 24 } else { 0 }
		(komorebic monitor-work-area-offset -- ($monitor.index) ($offset.left) -($new_offset) ($offset.right) -($new_offset))
	}
}

export def "main side-offset" [] {
	let monitor_idx = (komorebic query focused-monitor-index) | into int
	let offset = (komorebic state | from json | get monitors.elements | get $monitor_idx | get work_area_offset | default {left: 0, top: 0, right: 0, bottom: 0})
	# | items {|key, value| {$key: ($value | into int)}}
	# | reduce {|$it, $acc| $acc | merge $it}

	let new_offset = if ($offset.left == 0) { 650 } else { 0 }
	(komorebic monitor-work-area-offset -- ($monitor_idx) ($new_offset) ($offset.top) ($new_offset) ($offset.bottom))
}
