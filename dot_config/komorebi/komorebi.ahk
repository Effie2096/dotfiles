#Requires AutoHotkey v2.0.2
#SingleInstance Force

ConfigPath := EnvGet("KOMOREBI_CONFIG_HOME")

; Run applications
#e::Run "explorer.exe"
; #e::Run("explorer.exe shell:AppsFolder\Files_1y0xx7n9077q4!App", , "Hide")
#Enter::Run("wezterm.exe", , "Hide")
; #Enter::Run("powershell.exe wt", , "Hide")

Komorebic(cmd) {
	RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

Yasb(cmd) {
	RunWait(format("yasbc.exe {}", cmd), , "Hide")
}

; Meta Binds
; Restart Komorebi
^#!r::{
	Komorebic("stop --ahk")
	Komorebic("start --ahk")
}
; Restart just Bars
; #!r::{
;     RunWait("powershell Stop-Process -Name:komorebi-bar -ErrorAction SilentlyContinue", , "Hide")
;     Run(format("komorebi-bar.exe -c {}{}", ConfigPath, "\komorebi.bar.json"), , "Hide")
;     Run(format("komorebi-bar.exe -c {}{}", ConfigPath, "\komorebi.bar.2.json"), , "Hide")
; }
; Quit Komorebi
#!+q::Komorebic("stop --ahk")


#c::Komorebic("close")

BarShowing := true
#b::{
	global BarShowing
	if BarShowing {
		Yasb("hide-bar")
			Komorebic("global-work-area-offset 0 -- -32 0 -32")
			BarShowing := false
	} else {

		Yasb("show-bar")
			Komorebic("global-work-area-offset 0 -- -5 0 0")
			BarShowing := true
	}

}

Spacer := false
#+s::{
	global Spacer
	if Spacer {
                Komorebic("monitor-work-area-offset 0 -- 0 -5 0 -5")
                Spacer := false
        } else {
                Komorebic("monitor-work-area-offset 0 -- 0 -5 500 -5")
                Spacer := true
        }
}

; Focus windows
#h::Komorebic("focus left")
#j::Komorebic("focus down")
#k::Komorebic("focus up")
#l::Komorebic("focus right")

; Move windows
#+h::Komorebic("move left")
#+j::Komorebic("move down")
#+k::Komorebic("move up")
#+l::Komorebic("move right")

; Stack windows
#+Left::Komorebic("stack left")
#+Down::Komorebic("stack down")
#+Up::Komorebic("stack up")
#+Right::Komorebic("stack right")
#;::Komorebic("unstack")
#Left::Komorebic("cycle-stack previous")
#Right::Komorebic("cycle-stack next")

; Resize
#=::Komorebic("resize-axis horizontal increase")
#-::Komorebic("resize-axis horizontal decrease")
#+=::Komorebic("resize-axis vertical increase")
#+_::Komorebic("resize-axis vertical decrease")

; Manipulate windows
#f::Komorebic("toggle-float")
#m::Komorebic("toggle-monocle")
#+m::Komorebic("toggle-maximize")
#+n::Komorebic("minimize")

; Window manager options
#+r::Komorebic("retile")
#p::{
	Komorebic("toggle-pause")
	Komorebic("toggle-mouse-follows-focus")
}
#a::Komorebic("manage")
#+a::Komorebic("unmanage")

; Layouts
#s::Komorebic("change-layout vertical-stack")
#g::Komorebic("change-layout grid")
#x::Komorebic("flip-layout horizontal")
#v::Komorebic("flip-layout vertical")
#!o::Komorebic("cycle-layout next")
#!i::Komorebic("cycle-layout previous")


; Workspaces
Focus_Workspace(cmd) {
	Komorebic("focus-monitor-at-cursor")
	Komorebic(cmd)
}
#1::Focus_Workspace("focus-workspace 0")
#2::Focus_Workspace("focus-workspace 1")
#3::Focus_Workspace("focus-workspace 2")
#4::Focus_Workspace("focus-workspace 3")
#5::Focus_Workspace("focus-workspace 4")
#6::Focus_Workspace("focus-workspace 5")
#7::Focus_Workspace("focus-workspace 6")
#8::Focus_Workspace("focus-workspace 7")
#9::Focus_Workspace("focus-workspace 8")
#0::Focus_Workspace("focus-workspace 9")

; Move windows across workspaces
#+1::Komorebic("move-to-workspace 0")
#+2::Komorebic("move-to-workspace 1")
#+3::Komorebic("move-to-workspace 2")
#+4::Komorebic("move-to-workspace 3")
#+5::Komorebic("move-to-workspace 4")
#+6::Komorebic("move-to-workspace 5")
#+7::Komorebic("move-to-workspace 6")
#+8::Komorebic("move-to-workspace 7")
#+9::Komorebic("move-to-workspace 8")
#+0::Komorebic("move-to-workspace 9")

; Monitors
#i::Komorebic("focus-monitor 1")
#o::Komorebic("focus-monitor 0")

#+i::Komorebic("move-to-monitor 1")
#+o::Komorebic("move-to-monitor 0")



; #+c::Send "#!+c"

; ; Focus windows
; #h::Send "#!h"
; #j::Send "#!j"
; #k::Send "#!k"
; #l::SendInput "#!l"

; ; Move windows
; #+h::Send "#!+h"
; #+j::Send "#!+j"
; #+k::Send "#!+k"
; #+l::Send "#!+l"

; ; Stack windows
; ; #+Left::Send "#!+Left"
; ; #+Down::Send "#!+Down"
; ; #+Up::Send "#!+Up"
; ; #+Right::Send "#!+Right"
; ; #;::Send "#!;"
; ; #Left::Send "#!Left"
; ; #Right::Send "#!Right"

; ; Resize
; #=::Send "#!="
; #-::Send "#!-"
; #+=::Send "#!+="
; #+-::Send "#!+-"

; ; Manipulate windows
; #f::Send "#!f"
; #+f::Send "#!+f"
; #m::Send "#!m"
; #+m::Send "#!+m"
; #N::Send "#!n"

; ; Window manager options
; #+q::Send "#!+q"
; #+r::Send "#!+r"
; #p::Send "#!p"

; ; Layouts
; ; #x::Send "#!x"
; #v::Send "#!v"

; ; Workspaces
; #1::Send "#!1"
; #2::Send "#!2"
; #3::Send "#!3"
; #4::Send "#!4"
; #5::Send "#!5"
; #6::Send "#!6"
; #7::Send "#!7"
; #8::Send "#!8"
; #9::Send "#!9"
; #0::Send "#!0"

; ; Move windows across workspaces
; #+1::Send "#!+1"
; #+2::Send "#!+2"
; #+3::Send "#!+3"
; #+4::Send "#!+4"
; #+5::Send "#!+5"
; #+6::Send "#!+6"
; #+7::Send "#!+7"
; #+8::Send "#!+8"
; #+9::Send "#!+9"
; #+0::Send "#!+0"

; ; Monitors
; #i::Send "#!i"
; #o::Send "#!o"

; #+i::Send "#!+i"
; #+o::Send "#!+o"
