$env.XDG_CONFIG_HOME = ($env.HOME | path join .config)
$env.XDG_DATA_HOME = ($env.HOME | path join .local/share)
$env.XDG_STATE_HOME = ($env.HOME | path join .local/state)
$env.XDG_CACHE_HOME = ($env.HOME | path join .cache)

$env.EDITOR = "nvim"

$env.CODESTATS_KEY = open --raw ($env.HOME | path join .secrets/codestats_key)

$env.BW_SESSION = open --raw ($env.HOME | path join .secrets/bw_session)

$env.BAT_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join bat)
$env.YAZI_CONFIG_HOME = ($env.XDG_CONFIG_HOME | path join yazi)

let astronomy = open ($env.XDG_STATE_HOME | path join astronomy.json)
$env.CURRENT_THEME = "light"

def "set-alacritty-theme" [theme:string] {
	let alacritty_conf_path = ($env.XDG_CONFIG_HOME | path join alacritty alacritty.toml)
		open $alacritty_conf_path
		| update general.import {|config|
			$config.general.import
				| each {|item|
					if $item in ["catppuccin-latte.toml", "eldritch.toml"] {
						if $theme == "light" { "catppuccin-latte.toml" } else { "eldritch.toml" }
					} else {
						$item
					}
				}
		}
		| save --force $alacritty_conf_path
}

def --env set-theme [] {
	let now = date now
	let today = $astronomy.today

	let sunrise = ($today.sunrise | into datetime)
	let sunset	= ($today.sunset	| into datetime)

	let new_theme = if ($now >= $sunrise and $now <= $sunset) {
		"light"
	} else {
		"dark"
	}

	if $env.CURRENT_THEME == $new_theme {
		return
	}

	set-application-themes $new_theme

	$env.CURRENT_THEME = $new_theme
}

def --env set-application-themes [theme:string] {
	$env.LS_COLORS = (^vivid generate (if $theme == "light" { "catppuccin-latte" } else { "catppuccin-mocha" }))
	$env.BAT_THEME = (if $theme == "light" { "Catppuccin Latte" } else { "Eldritch" })

	set-alacritty-theme $theme
}

set-theme
set-application-themes $env.CURRENT_THEME


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
	"polars",
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

alias v = ^nvim

def --wrapped ff [...args] {
	^fzf -m --preview 'bat --style=numbers,header --decorations=always --color=always {}' --preview-window 'right,60%,border-left' ...$args
	| lines
	| reduce {|it, acc| $acc | append $it }
}

def --wrapped nuf [
    ...args
]: list<any> -> list<any>, table -> table, record -> record, string -> string {
    let input = $in

    match ($input | describe | str replace --regex '<.*' '') {
        "list" => {
            $input | str join "\n" | ^fzf ...$args | lines
        },
        _ => {
            $input | each {|i| $i | to json --raw}
              | str join "\n"
              | ^fzf ...$args
              | lines
              | each {$in | from json}
              | reduce {|it, acc| $acc | append $it}
        }
    }
}


def neovide --wrapped [...rest] { job spawn { ^neovide ...$rest } }

def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	^yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != $env.PWD and ($cwd | path exists) {
		cd $cwd
	}
	rm -fp $tmp
}

def gitui --wrapped [...args] {
	^gitui --theme=$"(if $env.CURRENT_THEME == 'light' { 'catppuccin-latte.ron' } else { 'catppuccin-mocha.ron' })" ...$args
}

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
