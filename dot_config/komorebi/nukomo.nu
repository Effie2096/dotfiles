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

	for monitor in $monitors {
		let offset = $monitor | get work_area_size.top | into int
		$"(komorebic global-work-area-offset -- 0 -($offset) 0 -($offset))"
	}

}
