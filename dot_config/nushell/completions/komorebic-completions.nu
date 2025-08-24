# === Komorebic Completions for Nushell ===
# Auto-generated from `komorebic --help`

# Completion helpers
def nu_complete_directions [] { [ "left" "right" "up" "down" ] }
def nu_complete_next_prev [] { [ "next" "previous" ] }
def nu_complete_edges [] { [ "left" "right" "top" "bottom" ] }
def nu_complete_sizing [] { [ "increase" "decrease" ] }
def nu_complete_axis [] { [ "horizontal" "vertical" "horizontal-and-vertical"] }
def nu_complete_bool [] { [ "true" "false" ] }
def nu_complete_query [] { [ "focused-monitor-index", "focused-workspace-index", "focused-container-index", "focused-window-index", "focused-workspace-name", "focused-workspace-layout", "focused-container-kind", "version"]}
def nu_complete_layouts [] { ["bsp", "columns", "rows", "vertical-stack", "horizontal-stack", "ultrawide-vertical-stack", "grid", "right-main-vertical-stack"] }
def nu_complete_monitors [] { komorebic state | from json | get monitors.elements | enumerate | flatten | get index }
def nu_complete_monitor_names [] { komorebic state | from json | get monitors.elements.name }
def nu_complete_workspace_names [] { komorebic state | from json | get monitors.elements.workspaces.elements | each { |w| $w.name } | get (komorebic query focused-monitor-index | into int) }
def nu_complete_workspace_indices [] { komorebic state | from json | get monitors.elements.workspaces.elements | get (komorebic query focused-monitor-index | into int) | enumerate | flatten | get index }

def "nu-complete komorebic monitor-workspace-indices" [
	context: string, position?: int
] {
	let parts = ($context | str substring ..$position | str trim | split row ' ')

	# parts[0] = komorebic
	# parts[1] = send-to-monitor-workspace
	# parts[2] = monitor index (first positional)
	# parts[3] = workspace index (second positional)

	if ($parts | length) <= 2 {
		return (nu_complete_monitors)
	}

	if ($parts | length) == 3 {
		return (komorebic state
			| from json
			| get monitors.elements.workspaces.elements
			| get (komorebic query focused-monitor-index
				| into int)
			| enumerate
			| flatten
			| get index)
	}

	[]
}

def "nu-complete komorebic monitor-workspace-names" [
	context: string, position?: int
] {
	let parts = ($context | str substring ..$position | str trim | split row ' ')

	# parts[0] = komorebic
	# parts[1] = send-to-monitor-workspace
	# parts[2] = monitor index (first positional)
	# parts[3] = workspace name (second positional)

	if ($parts | length) <= 2 {
		return (nu_complete_monitors)
	}

	if ($parts | length) == 3 {
		return (komorebic state
			| from json
			| get monitors.elements.workspaces.elements
			| each {
				|w| $w.name
			}
			| get (komorebic query focused-monitor-index
				| into int))
	}

	[]
}

export extern "komorebic quickstart" [
]  # Gather example configurations for a new-user quickstart

export extern "komorebic start" [
	-c, --config # Path to a static configuration JSON file
	-a, --await-configuration # Wait for 'komorebic complete-configuration' to be sent before processing events
	-t, --tcp-port # Start a TCP server on the given port to allow the direct sending of SocketMessages
	--whkd # Start whkd in a background process
	--ahk # Start autohotkey configuration file
	--bar # Start komorebi-bar in a background process
	--masir # Start masir in a background process for focus-follows-mouse
	--clean-state # Do not attempt to auto-apply a dumped state temp file from a previously running instance of komorebi
]  # Start komorebi.exe as a background process

export extern "komorebic stop" [
	--whkd # Stop whkd if it is running as a background process
	--ahk # Stop ahk if it is running as a background process
	--bar # Stop komorebi-bar if it is running as a background process
	--masir # Stop masir if it is running as a background process
]  # Stop the komorebi.exe process and restore all hidden windows

export extern "komorebic kill" [
	--whkd # Kill whkd if it is running as a background process
	--ahk # Kill ahk if it is running as a background process
	--bar # Kill komorebi-bar if it is running as a background process
	--masir # Kill masir if it is running as a background process
]  # Kill background processes started by komorebic

export extern "komorebic check" [
	-k, --komorebi-config # Path to a static configuration JSON file
]  # Check komorebi configuration and related files for common errors

export extern "komorebic configuration" [
]  # Show the path to komorebi.json

export extern "komorebic bar-configuration" [
]  # Show the path to komorebi.bar.json

export extern "komorebic whkdrc" [
]  # Show the path to whkdrc

export extern "komorebic data-directory" [
]  # Show the path to komorebi's data directory in %LOCALAPPDATA%

export extern "komorebic state" [
]  # Show a JSON representation of the current window manager state

export extern "komorebic global-state" [
]  # Show a JSON representation of the current global state

export extern "komorebic gui" [
]  # Launch the komorebi-gui debugging tool

export extern "komorebic toggle-shortcuts" [
]  # Toggle the komorebi-shortcuts helper

export extern "komorebic visible-windows" [
]  # Show a JSON representation of visible windows

export extern "komorebic monitor-information" [
]  # Show information about connected monitors

export extern "komorebic query" [
  state?: string@nu_complete_query
]  # Query the current window manager state

export extern "komorebic subscribe-socket" [
]  # Subscribe to komorebi events using a Unix Domain Socket

export extern "komorebic unsubscribe-socket" [
]  # Unsubscribe from komorebi events

export extern "komorebic subscribe-pipe" [
]  # Subscribe to komorebi events using a Named Pipe

export extern "komorebic unsubscribe-pipe" [
]  # Unsubscribe from komorebi events

export extern "komorebic log" [
]  # Tail komorebi.exe's process logs (cancel with Ctrl-C)

export extern "komorebic quick-save-resize" [
]  # Quicksave the current resize layout dimensions

export extern "komorebic quick-load-resize" [
]  # Load the last quicksaved resize layout dimensions

export extern "komorebic save-resize" [
]  # Save the current resize layout dimensions to a file

export extern "komorebic load-resize" [
]  # Load the resize layout dimensions from a file

export extern "komorebic focus" [
	direction?: string@nu_complete_directions
]  # Change focus to the window in the specified direction

export extern "komorebic move" [
	direction?: string@nu_complete_directions
]  # Move the focused window in the specified direction

export extern "komorebic minimize" [
]  # Minimize the focused window

export extern "komorebic close" [
]  # Close the focused window

export extern "komorebic force-focus" [
]  # Forcibly focus the window at the cursor with a left mouse click

export extern "komorebic cycle-focus" [
	direction: string@nu_complete_next_prev
]  # Change focus to the window in the specified cycle direction

export extern "komorebic cycle-move" [
	direction: string@nu_complete_next_prev
]  # Move the focused window in the specified cycle direction

export extern "komorebic eager-focus" [
	direction: string@nu_complete_directions
]  # Focus the first managed window matching the given exe

export extern "komorebic stack" [
	direction: string@nu_complete_directions
]  # Stack the focused window in the specified direction

export extern "komorebic unstack" [
]  # Unstack the focused window

export extern "komorebic cycle-stack" [
	direction: string@nu_complete_next_prev
]  # Cycle the focused stack in the specified cycle direction

export extern "komorebic cycle-stack-index" [
	direction: string@nu_complete_next_prev
]  # Cycle the index of the focused window in the focused stack in the specified cycle direction

export extern "komorebic focus-stack-window" [
]  # Focus the specified window index in the focused stack

export extern "komorebic stack-all" [
]  # Stack all windows on the focused workspace

export extern "komorebic unstack-all" [
]  # Unstack all windows in the focused container

export extern "komorebic resize-edge" [
	edge: string@nu_complete_edges  # Which edge to resize
	sizing: string@nu_complete_sizing
]  # Resize the focused window in the specified direction

export extern "komorebic resize-axis" [
	axis: string@nu_complete_axis  # Axis to resize
	sizing: string@nu_complete_sizing
]  # Resize the focused window or primary column along the specified axis

export extern "komorebic move-to-monitor" [
	index: string@nu_complete_monitors  # Target monitor index
]  # Move the focused window to the specified monitor

export extern "komorebic cycle-move-to-monitor" [
	direction: string@nu_complete_next_prev
]  # Move the focused window to the monitor in the given cycle direction

export extern "komorebic move-to-workspace" [
	index: string@nu_complete_workspace_indices  # Workspace index
]  # Move the focused window to the specified workspace

export extern "komorebic move-to-named-workspace" [
	name: string@nu_complete_workspace_names  # Named workspace
]  # Move the focused window to the specified workspace

export extern "komorebic cycle-move-to-workspace" [
	direction: string@nu_complete_next_prev
]  # Move the focused window to the workspace in the given cycle direction

export extern "komorebic send-to-monitor" [
	index: string@nu_complete_monitors  # Target monitor index
]  # Send the focused window to the specified monitor

export extern "komorebic cycle-send-to-monitor" [
	direction: string@nu_complete_next_prev
]  # Send the focused window to the monitor in the given cycle direction

export extern "komorebic send-to-workspace" [
	workspace_index: string@nu_complete_workspace_indices
]  # Send the focused window to the specified workspace

export extern "komorebic send-to-named-workspace" [
	name: string@nu_complete_workspace_names  # Named workspace
]  # Send the focused window to the specified workspace

export extern "komorebic cycle-send-to-workspace" [
	direction: string@nu_complete_next_prev
]  # Send the focused window to the workspace in the given cycle direction

export extern "komorebic send-to-monitor-workspace" [
	...targets: string@"nu-complete komorebic monitor-workspace-indices"
]  # Send the focused window to the specified monitor workspace

export extern "komorebic move-to-monitor-workspace" [
	...targets: string@"nu-complete komorebic monitor-workspace-indices"
]  # Move the focused window to the specified monitor workspace

export extern "komorebic send-to-last-workspace" [
]  # Send the focused window to the last focused monitor workspace

export extern "komorebic move-to-last-workspace" [
]  # Move the focused window to the last focused monitor workspace

export extern "komorebic focus-monitor" [
	monitor_index: string@nu_complete_monitors
]  # Focus the specified monitor

export extern "komorebic focus-monitor-at-cursor" [
]  # Focus the monitor at the current cursor location

export extern "komorebic focus-last-workspace" [
]  # Focus the last focused workspace on the focused monitor

export extern "komorebic focus-workspace" [
	workspace_index: string@nu_complete_workspace_indices
]  # Focus the specified workspace on the focused monitor

export extern "komorebic focus-workspaces" [
	workspace_index: string@nu_complete_workspace_indices
]  # Focus the specified workspace on all monitors

export extern "komorebic focus-monitor-workspace" [
	...targets: string@"nu-complete komorebic monitor-workspace-indices"
]  # Focus the specified workspace on the target monitor

export extern "komorebic focus-named-workspace" [
	workspace_name: string@nu_complete_workspace_names
]  # Focus the specified workspace

export extern "komorebic close-workspace" [
]  # Close the focused workspace (must be empty and unnamed)

export extern "komorebic cycle-monitor" [
	direction: string@nu_complete_next_prev
]  # Focus the monitor in the given cycle direction

export extern "komorebic cycle-workspace" [
	direction: string@nu_complete_next_prev
]  # Focus the workspace in the given cycle direction

export extern "komorebic cycle-empty-workspace" [
	direction: string@nu_complete_next_prev
]  # Focus the next empty workspace in the given cycle direction (if one exists)

export extern "komorebic move-workspace-to-monitor" [
	monitor_index: string@nu_complete_monitors
]  # Move the focused workspace to the specified monitor

export extern "komorebic cycle-move-workspace-to-monitor" [
	direction: string@nu_complete_next_prev
]  # Move the focused workspace monitor in the given cycle direction

export extern "komorebic swap-workspaces-with-monitor" [
	monitor_index: string@nu_complete_monitors
]  # Swap focused monitor workspaces with specified monitor

export extern "komorebic new-workspace" [
]  # Create and append a new workspace on the focused monitor

export extern "komorebic resize-delta" [
]  # Set the resize delta (used by resize-edge and resize-axis)

export extern "komorebic invisible-borders" [
]  # Set the invisible border dimensions around each window

export extern "komorebic global-work-area-offset" [
]  # Set offsets to exclude parts of the work area from tiling

export extern "komorebic monitor-work-area-offset" [
	monitor_index: string@nu_complete_monitors
]  # Set offsets for a monitor to exclude parts of the work area from tiling

export extern "komorebic toggle-window-based-work-area-offset" [
]  # Toggle application of the window-based work area offset for the focused workspace

export extern "komorebic focused-workspace-container-padding" [
]  # Set container padding on the focused workspace

export extern "komorebic focused-workspace-padding" [
]  # Set workspace padding on the focused workspace

export extern "komorebic adjust-container-padding" [
	sizing: string@nu_complete_sizing
	size: int # Pixels to adjust by as an integer
]  # Adjust container padding on the focused workspace

export extern "komorebic adjust-workspace-padding" [
	sizing: string@nu_complete_sizing
	size: int # Pixels to adjust by as an integer
]  # Adjust workspace padding on the focused workspace

export extern "komorebic change-layout" [
	layout: string@nu_complete_layouts
]  # Set the layout on the focused workspace

export extern "komorebic cycle-layout" [
	direction: string@nu_complete_next_prev
]  # Cycle between available layouts

export extern "komorebic flip-layout" [
	axis: string@nu_complete_axis
]  # Flip the layout on the focused workspace

export extern "komorebic promote" [
]  # Promote the focused window to the top of the tree

export extern "komorebic promote-focus" [
]  # Promote the user focus to the top of the tree

export extern "komorebic promote-window" [
	direction: string@nu_complete_directions
]  # Promote the window in the specified direction

export extern "komorebic retile" [
]  # Force the retiling of all managed windows

export extern "komorebic monitor-index-preference" [
	index: int@nu_complete_monitors # Preferred monitor index (zero-indexed)
	left: int # Left value of the monitor's size Rect
	top: int # Top value of the monitor's size Rect
	right: int # Right value of the monitor's size Rect
	bottom: int # Bottom value of the monitor's size Rect
]  # Set the monitor index preference for a monitor identified using its size

export extern "komorebic display-index-preference" [
	monitor_index: string@nu_complete_monitors # Preferred monitor index (zero-indexed)
	display_name: string@nu_complete_monitor_names # Display name as identified in komorebic state
]  # Set the display index preference for a monitor identified using its display name

export extern "komorebic ensure-workspaces" [
	monitor_index: int@nu_complete_monitors # Monitor index (zero-indexed)
	workspace_count: int # Number of desired workspaces
]  # Create at least this many workspaces for the specified monitor

export extern "komorebic ensure-named-workspaces" [
	monitor: int@nu_complete_monitors # Monitor index (zero-indexed)
	...names: list<string> # Names of desired workspaces
]  # Create these many named workspaces for the specified monitor

export extern "komorebic container-padding" [
	monitor: int@nu_complete_monitors # Monitor index (zero-indexed)
	workspace: int@"nu-complete komorebic monitor-workspace-indices" # Workspace index on the specified monitor (zero-indexed)
	size: int # Pixels to pad with as an integer
]  # Set the container padding for the specified workspace

export extern "komorebic named-workspace-container-padding" [
	workspace: int@nu_complete_workspace_indices # Target workspace name
	size: int # Pixels to pad with as an integer
]  # Set the container padding for the specified workspace

export extern "komorebic workspace-padding" [
	monitor: int@nu_complete_monitors # Monitor index (zero-indexed)
	workspace: int@"nu-complete komorebic monitor-workspace-indices" # Workspace index on the specified monitor (zero-indexed)
	size: int # Pixels to pad with as an integer
]  # Set the workspace padding for the specified workspace

export extern "komorebic named-workspace-padding" [
	monitor: string@nu_complete_workspace_names # Target workspace name
	size: int # Pixels to pad with as an integer
]  # Set the workspace padding for the specified workspace

export extern "komorebic workspace-layout" [
	monitor: int # Monitor index (zero-indexed)
	workspace: int # Workspace index on the specified monitor (zero-indexed)
	value: string@nu_complete_layouts # 
]  # Set the layout for the specified workspace

export extern "komorebic named-workspace-layout" [
	monitor: string@nu_complete_workspace_names # Target workspace name
	value: string@nu_complete_layouts # 
]  # Set the layout for the specified workspace

export extern "komorebic workspace-layout-rule" [
	monitor: int@nu_complete_monitors # Monitor index (zero-indexed)
	workspace: int@"nu-complete komorebic monitor-workspace-indices" # Workspace index on the specified monitor (zero-indexed)
	at_container_count: int # The number of window containers on-screen required to trigger this layout rule
	layout: string@nu_complete_layouts # 
]  # Add a dynamic layout rule for the specified workspace

export extern "komorebic named-workspace-layout-rule" [
]  # Add a dynamic layout rule for the specified workspace

export extern "komorebic clear-workspace-layout-rules" [
]  # Clear all dynamic layout rules for the specified workspace

export extern "komorebic clear-named-workspace-layout-rules" [
]  # Clear all dynamic layout rules for the specified workspace

export extern "komorebic workspace-tiling" [
]  # Enable or disable window tiling for the specified workspace

export extern "komorebic named-workspace-tiling" [
]  # Enable or disable window tiling for the specified workspace

export extern "komorebic workspace-name" [
]  # Set the workspace name for the specified workspace

export extern "komorebic toggle-window-container-behaviour" [
]  # Toggle the behaviour for new windows (stacking or dynamic tiling)

export extern "komorebic toggle-float-override" [
]  # Enable or disable float override, which makes it so every new window opens in floating mode

export extern "komorebic toggle-workspace-window-container-behaviour" [
]  # Toggle the behaviour for new windows (stacking or dynamic tiling) for currently focused workspace. If there was no behaviour set for the workspace previously it takes the opposite of the global value

export extern "komorebic toggle-workspace-float-override" [
]  # Enable or disable float override, which makes it so every new window opens in floating mode, for the currently focused workspace. If there was no override value set for the workspace previously it takes the opposite of the

export extern "komorebic toggle-workspace-layer" [
]  # Toggle between the Tiling and Floating layers on the focused workspace

export extern "komorebic toggle-pause" [
]  # Toggle window tiling on the focused workspace

export extern "komorebic toggle-tiling" [
]  # Toggle window tiling on the focused workspace

export extern "komorebic toggle-float" [
]  # Toggle floating mode for the focused window

export extern "komorebic toggle-monocle" [
]  # Toggle monocle mode for the focused container

export extern "komorebic toggle-maximize" [
]  # Toggle native maximization for the focused window

export extern "komorebic toggle-lock" [
]  # Toggle a lock for the focused container, ensuring it will not be displaced by any new windows

export extern "komorebic restore-windows" [
]  # Restore all hidden windows (debugging command)

export extern "komorebic manage" [
]  # Force komorebi to manage the focused window

export extern "komorebic unmanage" [
]  # Unmanage a window that was forcibly managed

export extern "komorebic replace-configuration" [
]  # Replace the configuration of a running instance of komorebi from a static configuration file

export extern "komorebic reload-configuration" [
]  # Reload legacy komorebi.ahk or komorebi.ps1 configurations (if they exist)

export extern "komorebic watch-configuration" [
]  # Enable or disable watching of legacy komorebi.ahk or komorebi.ps1 configurations (if they exist)

export extern "komorebic complete-configuration" [
]  # For legacy komorebi.ahk or komorebi.ps1 configurations, signal that the final configuration option has been sent

export extern "komorebic window-hiding-behaviour" [
]  # Set the window behaviour when switching workspaces / cycling stacks

export extern "komorebic cross-monitor-move-behaviour" [
]  # Set the behaviour when moving windows across monitor boundaries

export extern "komorebic toggle-cross-monitor-move-behaviour" [
]  # Toggle the behaviour when moving windows across monitor boundaries

export extern "komorebic unmanaged-window-operation-behaviour" [
]  # Set the operation behaviour when the focused window is not managed

export extern "komorebic session-float-rule" [
]  # Add a rule to float the foreground window for the rest of this session

export extern "komorebic session-float-rules" [
]  # Show all session float rules

export extern "komorebic clear-session-float-rules" [
]  # Clear all session float rules

export extern "komorebic ignore-rule" [
]  # Add a rule to ignore the specified application

export extern "komorebic manage-rule" [
]  # Add a rule to always manage the specified application

export extern "komorebic initial-workspace-rule" [
]  # Add a rule to associate an application with a workspace on first show

export extern "komorebic initial-named-workspace-rule" [
]  # Add a rule to associate an application with a named workspace on first show

export extern "komorebic workspace-rule" [
]  # Add a rule to associate an application with a workspace

export extern "komorebic named-workspace-rule" [
]  # Add a rule to associate an application with a named workspace

export extern "komorebic clear-workspace-rules" [
]  # Remove all application association rules for a workspace by monitor and workspace index

export extern "komorebic clear-named-workspace-rules" [
]  # Remove all application association rules for a named workspace

export extern "komorebic clear-all-workspace-rules" [
]  # Remove all application association rules for all workspaces

export extern "komorebic enforce-workspace-rules" [
]  # Enforce all workspace rules, including initial workspace rules that have already been applied

export extern "komorebic identify-object-name-change-application" [
]  # Identify an application that sends EVENT_OBJECT_NAMECHANGE on launch

export extern "komorebic identify-tray-application" [
]  # Identify an application that closes to the system tray

export extern "komorebic identify-layered-application" [
]  # Identify an application that has WS_EX_LAYERED, but should still be managed

export extern "komorebic remove-title-bar" [
]  # Whitelist an application for title bar removal

export extern "komorebic toggle-title-bars" [
]  # Toggle title bars for whitelisted applications

export extern "komorebic border" [
]  # Enable or disable borders

export extern "komorebic border-colour" [
]  # Set the colour for a window border kind

export extern "komorebic border-width" [
]  # Set the border width

export extern "komorebic border-offset" [
]  # Set the border offset

export extern "komorebic border-style" [
]  # Set the border style

export extern "komorebic border-implementation" [
]  # Set the border implementation

export extern "komorebic stackbar-mode" [
]  # Set the stackbar mode

export extern "komorebic transparency" [
]  # Enable or disable transparency for unfocused windows

export extern "komorebic transparency-alpha" [
]  # Set the alpha value for unfocused window transparency

export extern "komorebic toggle-transparency" [
]  # Toggle transparency for unfocused windows

export extern "komorebic animation" [
]  # Enable or disable movement animations

export extern "komorebic animation-duration" [
]  # Set the duration for movement animations in ms

export extern "komorebic animation-fps" [
]  # Set the frames per second for movement animations

export extern "komorebic animation-style" [
]  # Set the ease function for movement animations

export extern "komorebic mouse-follows-focus" [
]  # Enable or disable mouse follows focus on all workspaces

export extern "komorebic toggle-mouse-follows-focus" [
]  # Toggle mouse follows focus on all workspaces

export extern "komorebic ahk-app-specific-configuration" [
]  # Generate common app-specific configurations and fixes to use in komorebi.ahk

export extern "komorebic pwsh-app-specific-configuration" [
]  # Generate common app-specific configurations and fixes in a PowerShell script

export extern "komorebic convert-app-specific-configuration" [
]  # Convert a v1 ASC YAML file to a v2 ASC JSON file

export extern "komorebic fetch-app-specific-configuration" [
]  # Fetch the latest version of applications.json from komorebi-application-specific-configuration

export extern "komorebic application-specific-configuration-schema" [
]  # Generate a JSON Schema for applications.json

export extern "komorebic notification-schema" [
]  # Generate a JSON Schema of subscription notifications

export extern "komorebic socket-schema" [
]  # Generate a JSON Schema of socket messages

export extern "komorebic static-config-schema" [
]  # Generate a JSON Schema of the static configuration file

export extern "komorebic generate-static-config" [
]  # Generates a static configuration JSON file based on the current window manager state

export extern "komorebic enable-autostart" [
]  # Generates the komorebi.lnk shortcut in shell:startup to autostart komorebi

export extern "komorebic disable-autostart" [
]  # Deletes the komorebi.lnk shortcut in shell:startup to disable autostart

export extern "komorebic help" [
]  # Print this message or the help of the given subcommand(s)
