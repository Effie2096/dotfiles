# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

$env.XDG_CONFIG_HOME = ($env.HOME | path join .config)
$env.XDG_DATA_HOME = ($env.HOME | path join .local/share)
$env.XDG_STATE_HOME = ($env.HOME | path join .local/state)
$env.XDG_CACHE_HOME = ($env.HOME | path join .cache)

$env.Path = ($env.Path | prepend ($env.HOME | path join .cargo/bin))

$env.EDITOR = "nvim"
$env.CODESTATS_KEY = open --raw ($env.HOME | path join .secrets/codestats_key)

$env.BAT_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join bat)
$env.YAZI_CONFIG_HOME = ($env.XDG_CONFIG_HOME | path join yazi)

if not ("GEOCO" in $env) and not ("YASB_WEATHER_API_KEY" in $env) {
	let weather_secrets = open --raw ($env.HOME | path join .secrets/weather)
		| lines
		| where $it !~ '^\s*(#|$)'
		| parse "{key}={value}"
		| transpose -r --as-record

	load-env $weather_secrets
	nu ($env.HOME | path join bin/astronomy.nu)
}

let astronomy = open ($env.XDG_STATE_HOME | path join astronomy.json)
$env.CURRENT_THEME = "light"

def --env "set-theme" [] {
  let now = date now | format date "%H:%M" | split row ":" | each {|el| $el | into int}

  mut theme = $env.CURRENT_THEME
    if ($now.0 >= $astronomy.today.sunrise.hour and
	$now.1 >= $astronomy.today.sunrise.minute
	and
	$now.0 <= $astronomy.today.sunset.hour and
	$now.1 <= $astronomy.today.sunset.minute
       ) {
      $env.CURRENT_THEME = "light"
    } else {
      $env.CURRENT_THEME = "dark"
    }
  if $env.CURRENT_THEME != $theme {
    $env.LS_COLORS = (^vivid generate (if $env.CURRENT_THEME == "light" { "catppuccin-latte" } else { "catppuccin-mocha" }))
  }
}

set-theme
$env.LS_COLORS = (^vivid generate (if $env.CURRENT_THEME == "light" { "catppuccin-latte" } else { "catppuccin-mocha" }))

const IS_WINDOWS = ($nu.os-info.name == "windows")

if not (which fnm | is-empty) {
	fnm env --json | from json | load-env
	$env.PATH = $env.PATH
		| prepend (
			$env.FNM_MULTISHELL_PATH | (if not $IS_WINDOWS { $in | path join 'bin' } else { $in }))
	$env.config.hooks.env_change.PWD = (
		$env.config.hooks.env_change.PWD? | append {
			condition: {|| ['.nvmrc' '.node-version'] | any {|el| $el | path exists}}
			code: {|| fnm use}
		}
	)
}

const NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ...$NU_PLUGIN_DIRS
]

const plugins = [
	"gstat",
	"query"
]
$plugins | each {
	|plugin| plugin add $"nu_plugin_($plugin)(if $IS_WINDOWS {'.exe'})"
}

$env.STARSHIP_SHELL = "nu"

$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.PROMPT_INDICATOR_VI_NORMAL = "`"
$env.PROMPT_INDICATOR_VI_INSERT = " "
$env.PROMPT_MULTILINE_INDICATOR = ":::"

mkdir ($nu.data-dir | path join "vendor/autoload")

def --wrapped scoop [...args] {
	if ($args | is-empty) {
		return (powershell scoop.ps1)
	}
	match $args.0 {
		"search" => { scoop-search.exe ...($args | skip 1) }
		_ => { powershell scoop.ps1 ...$args }
	}
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ($env.XDG_CACHE_HOME | path join carapace)
carapace _carapace nushell | save --force ($env.XDG_CACHE_HOME | path join carapace/init.nu)
if ($"$env.XDG_CACHE_HOME/carapace/init.nu" | path exists) {
	source ~/.cache/carapace/init.nu
}

let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

def "nu-complete zoxide path" [context: string] {
	let parts = $context | split row " " | skip 1
	{
		options: {
			sort: false,
			completion_algorithm: substring,
			case_sensitive: false,
		},
		completions: (^zoxide query --list --exclude $env.PWD -- ...$parts | lines),
	}
}

def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
	__zoxide_z ...$rest
}

# Enable the external completer
$env.config.completions.external = {
  enable: true
  completer: $carapace_completer
}

# Load completions
source ~/.config/nushell/completions/komorebic-completions.nu

$env.config.render_right_prompt_on_last_line = true
^starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.TRANSIENT_PROMPT_COMMAND = {||
  set-theme
  $" (^starship module directory)(starship module character)"
}
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {||
  $"(^starship module status --status $env.LAST_EXIT_CODE)(starship module cmd_duration --cmd-duration $env.CMD_DURATION_MS)(starship module time)"
}

source ($nu.data-dir | path join zoxide.nu)
use ($nu.data-dir | path join mise.nu)

alias ll = ^eza --icons --color=always -GF -a --group-directories-first
alias la = ^eza --icons --color=always --long --classify --all --group-directories-first --group --header --git

alias bat = ^bat --theme=$"(if $env.CURRENT_THEME == 'light' { 'Catppuccin Latte' } else { 'Catppuccin Mocha' })"

# alias gitui = ^gitui --theme=$"(if $env.CURRENT_THEME == 'light' { 'catppuccin-latte.ron' } else { 'catppuccin-mocha.ron' })"

$env.config.keybindings ++= [{
	name: clear_term
	modifier: CONTROL
	keycode: Char_l
	mode: vi_insert
	event: [
		{ send: ClearScreen }
		{
			send: executehostcommand,
			cmd: "tput cup (tput lines) 0"
		}
	]
}]

(^tput cup (^tput lines) 0)
