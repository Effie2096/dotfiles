#Requires AutoHotkey v2.0.2
#SingleInstance Force

ConfigPath := EnvGet("KOMOREBI_CONFIG_HOME")

Groups := Map(
	"Meta", [
		{ bind: "#^!r", desc: "Restart Komorebi", cb: (*) => (Komorebic("stop --ahk"), Komorebic("start --ahk")), arg: "" },
		{ bind: "#^!q", desc: "Quit Komorebi", cb: Komorebic, arg: "stop --ahk" },
		{ bind: "#!h", desc: "Toggle Keybind Help", cb: toggle_help },
		{ bind: "#b", desc: "Toggle Status Bar", cb: toggle_yasb },
	],
	"Apps", [
		{ bind: "#e", desc: "Open File Explorer", cb: Run, arg: "explorer.exe" },
		{ bind: "#Enter", desc: "Open Terminal", cb: RunHidden, arg: "wezterm.exe" }
	],
	"Focus Windows", [
		{ bind: "#h", desc: "Left", cb: Komorebic, arg: "focus left" },
		{ bind: "#j", desc: "Down", cb: Komorebic, arg: "focus down" },
		{ bind: "#k", desc: "Up", cb: Komorebic, arg: "focus up" },
		{ bind: "#l", desc: "Right", cb: Komorebic, arg: "focus right" },
	],
	"Move Windows", [
		{ bind: "#+h", desc: "Left", cb: Komorebic, arg: "move left" },
		{ bind: "#+j", desc: "Down", cb: Komorebic, arg: "move down" },
		{ bind: "#+k", desc: "Up", cb: Komorebic, arg: "move up" },
		{ bind: "#+l", desc: "Right", cb: Komorebic, arg: "move right" },
		{ bind: "#+p", desc: "Promote", cb: Komorebic, arg: "promote" },
	],
	"Move windows across workspaces", [
		{ bind: "#+1", desc: "Workspace 1", cb: Komorebic, arg: "move-to-workspace 0" },
		{ bind: "#+2", desc: "Workspace 2", cb: Komorebic, arg: "move-to-workspace 1" },
		{ bind: "#+3", desc: "Workspace 3", cb: Komorebic, arg: "move-to-workspace 2" },
		{ bind: "#+4", desc: "Workspace 4", cb: Komorebic, arg: "move-to-workspace 3" },
		{ bind: "#+5", desc: "Workspace 5", cb: Komorebic, arg: "move-to-workspace 4" },
		{ bind: "#+6", desc: "Workspace 6", cb: Komorebic, arg: "move-to-workspace 5" },
		{ bind: "#+7", desc: "Workspace 7", cb: Komorebic, arg: "move-to-workspace 6" },
		{ bind: "#+8", desc: "Workspace 8", cb: Komorebic, arg: "move-to-workspace 7" },
		{ bind: "#+9", desc: "Workspace 9", cb: Komorebic, arg: "move-to-workspace 8" },
		{ bind: "#+0", desc: "Workspace 10", cb: Komorebic, arg: "move-to-workspace 9" },
	],
	"Stack Windows", [
		{ bind: "#+Left", desc: "Left", cb: Komorebic, arg: "stack left" },
		{ bind: "#+Down", desc: "Down", cb: Komorebic, arg: "stack down" },
		{ bind: "#+Up", desc: "Up", cb: Komorebic, arg: "stack up" },
		{ bind: "#+Right", desc: "Right", cb: Komorebic, arg: "stack right" },
		{ bind: "#;", desc: "Unstack", cb: Komorebic, arg: "unstack" },
		{ bind: "#Left", desc: "Focus Previous", cb: Komorebic, arg: "cycle-stack previous" },
		{ bind: "#Right", desc: "Focus Next", cb: Komorebic, arg: "cycle-stack next" },
	],
	"Resize", [
		{ bind: "#=", desc: "Increase Horizontal", cb: Komorebic, arg: "resize-axis horizontal increase" },
		{ bind: "#-", desc: "Decrease Horizontal", cb: Komorebic, arg: "resize-axis horizontal decrease" },
		{ bind: "#+=", desc: "Increase Vertical", cb: Komorebic, arg: "resize-axis vertical increase" },
		{ bind: "#+_", desc: "Decrease Vertical", cb: Komorebic, arg: "resize-axis vertical decrease" },
	],
	"Window State", [
		{ bind: "#f", desc: "Toggle Float", cb: Komorebic, arg: "toggle-float" },
		{ bind: "#m", desc: "Toggle Monocle", cb: Komorebic, arg: "toggle-monocle" },
		{ bind: "#+m", desc: "Maximize", cb: Komorebic, arg: "toggle-maximize" },
		{ bind: "#+n", desc: "Minimize", cb: Komorebic, arg: "minimize" },
		{ bind: "#c", desc: "Close", cb: Komorebic, arg: "close" },
		{ bind: "#!l", desc: "Lock Container", cb: Komorebic, arg: "toggle-lock" },
	],
	"Layouts", [
		{ bind: "#s", desc: "Vertical Stack", cb: Komorebic, arg: "change-layout vertical-stack" },
		{ bind: "#g", desc: "Grid", cb: Komorebic, arg: "change-layout grid" },
		{ bind: "#x", desc: "Flip Horizontal", cb: Komorebic, arg: "flip-layout horizontal" },
		{ bind: "#v", desc: "Flip Vertical", cb: Komorebic, arg: "flip-layout vertical" },
		{ bind: "#!o", desc: "Next Layout", cb: Komorebic, arg: "cycle-layout next" },
		{ bind: "#!i", desc: "Previous Layout", cb: Komorebic, arg: "cycle-layout previous" },
		{ bind: "#!=", desc: "Increase Scroll Columns", cb: RunHidden, arg: "nu ./komo_nu.nu scroll-columns true" },
		{ bind: "#!-", desc: "Decrease Scroll Columns", cb: RunHidden, arg: "nu ./komo_nu.nu scroll-columns false" },
	],
	"Workspaces", [
		{ bind: "#1", desc: "Focus Workspace 1", cb: Focus_Workspace, arg: "focus-workspace 0" },
		{ bind: "#2", desc: "Focus Workspace 2", cb: Focus_Workspace, arg: "focus-workspace 1" },
		{ bind: "#3", desc: "Focus Workspace 3", cb: Focus_Workspace, arg: "focus-workspace 2" },
		{ bind: "#4", desc: "Focus Workspace 4", cb: Focus_Workspace, arg: "focus-workspace 3" },
		{ bind: "#5", desc: "Focus Workspace 5", cb: Focus_Workspace, arg: "focus-workspace 4" },
		{ bind: "#6", desc: "Focus Workspace 6", cb: Focus_Workspace, arg: "focus-workspace 5" },
		{ bind: "#7", desc: "Focus Workspace 7", cb: Focus_Workspace, arg: "focus-workspace 6" },
		{ bind: "#8", desc: "Focus Workspace 8", cb: Focus_Workspace, arg: "focus-workspace 7" },
		{ bind: "#9", desc: "Focus Workspace 9", cb: Focus_Workspace, arg: "focus-workspace 8" },
		{ bind: "#0", desc: "Focus Workspace 10", cb: Focus_Workspace, arg: "focus-workspace 9" },
	],
	"Monitors", [
		{ bind: "#i", desc: "Focus Monitor Left", cb: Komorebic, arg: "focus-monitor 1" },
		{ bind: "#o", desc: "Focus Monitor Right", cb: Komorebic, arg: "focus-monitor 0" },
		{ bind: "#+i", desc: "Move Window to Monitor Left", cb: Komorebic, arg: "move-to-monitor 1" },
		{ bind: "#+o", desc: "Move Window to Monitor Right", cb: Komorebic, arg: "move-to-monitor 0" },
	],
	"Debug", [
		{ bind: "#+r", desc: "Retile Windows", cb: Komorebic, arg: "retile" },
		{ bind: "#a", desc: "Manage Window", cb: Komorebic, arg: "manage" },
		{ bind: "#+a", desc: "Unmanage Window", cb: Komorebic, arg: "unmanage" },
	]
)

hotkey_callback(spec) {
	cb := spec.cb
	arg := spec.HasOwnProp("arg") ? spec.arg : ""
	callback(*) {
		if (arg != "") {
			cb(arg)
		} else {
			cb()
		}
	}
	return callback
}

for group, hotkeys in Groups {
	for hk in hotkeys {
		Hotkey(hk.bind, hotkey_callback(hk))
	}
}

RunHidden(cmd) {
	Run(format("{}", cmd), , "Hide")
}

Komorebic(cmd) {
	RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

Yasb(cmd) {
	RunWait(format("yasbc.exe {}", cmd), , "Hide")
}

Focus_Workspace(cmd) {
	Komorebic("focus-monitor-at-cursor")
	Komorebic(cmd)
}

toggle_yasb() {
	if WinExist("YasbBar") {
		Yasb("hide-bar")
		Komorebic("global-work-area-offset -- 0 -27 0 -27")
	} else {
		Yasb("show-bar")
		Komorebic("global-work-area-offset -- 0 0 0 0")
	}
}

Spacer := false
#+s::{
	global Spacer
	if Spacer {
		Komorebic("monitor-work-area-offset 0 -- 0 0 0 0")
		Spacer := false
	} else {
		Komorebic("monitor-work-area-offset 0 -- 0 0 500 0")
		Spacer := true
	}
}

GuiTitle := "Komorebi - Hotkeys"
HotkeyGUI := Gui("+AlwaysOnTop -Caption +ToolWindow -Resize", GuiTitle)
HotkeyGUI.BackColor := "1E1E2E"  ; Can be any RGB color (it will be made transparent below).
HotkeyGUI.SetFont("s14 w700")
HotkeyGUI.Add("Text", "cF5C2E7", "Komorebi - Hotkeys")  ; XX & YY serve to auto-size the window.
; Make all pixels of this color transparent and make the text itself translucent (150):

sub_keysym(hk) {
	str := hk
	str := StrReplace(str, "+", "Shift+")
	str := StrReplace(str, "#", "Win+")
	str := StrReplace(str, "^", "Ctrl+")
	str := StrReplace(str, "!", "Alt+")

	return str
}
guiHeight := 24
y := 0
x := 0
colWidth := 400
lineHeight := 20
xpad := 15
ypad := 15
descWidth := 250
for group, hotkeys in Groups {
	if y >= 24 {
		y := 0
		x += colWidth
		ypad := 15
	}
	ypad += 10
	HotkeyGUI.SetFont("s12 w700")
	HotkeyGUI.Add("Text", format("cF5C2E7 x{} y{}", x + xpad, (y*lineHeight)+lineHeight + ypad), format("{}", group))
	y += 1
	for hk in hotkeys {
		doffset := (x + colWidth) - StrLen(hk.desc)
		HotkeyGUI.SetFont("s12 w400")
		HotkeyGUI.AddText(format( "x{} y{} w{} +Left cCDD6F4", x + xpad, (y*lineHeight) + lineHeight + ypad, colWidth - descWidth), sub_keysym(hk.bind))
		HotkeyGUI.AddText(format( "x{} y{} w{} +Right cCDD6F4", x + xpad + colWidth - descWidth - xpad, (y*lineHeight) + lineHeight + ypad, descWidth), hk.desc)
		y += 1
	}
}
toggle_help() {
	If WinExist("ahk_id" HotkeyGUI.Hwnd) {
		HotkeyGUI.Hide()
	} Else {
		HotkeyGUI.Show()
	}
}

Loop {
	HWNDS := WinGetList("ahk_exe sclang.exe")
	Loop HWNDS.length {
		exStyle := WinGetExStyle(HWNDS[A_Index])
		if (exStyle & 0x00000008) {
			continue
		}
	 WinSetAlwaysOnTop(1, HWNDS[A_Index])
	}
}
