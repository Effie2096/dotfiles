#Requires AutoHotkey v2.0.2
#SingleInstance Force

ConfigPath := EnvGet("KOMOREBI_CONFIG_HOME")

Movement := Map(
	"Left", "m",
	"Down", "n",
	"Up", "e",
	"Right", "i",
	"MonLeft", "o",
	"MonRight", "u",
)

; # Win | ^ Ctrl | ! Alt | + Shift
Groups := Map(
	"Meta", [
		{ bind: "#^!r", desc: "Restart Komorebi", cb: (*) => (Komorebic("stop --ahk"), Komorebic("start --ahk")), arg: "" },
		{ bind: "#^!q", desc: "Quit Komorebi", cb: Komorebic, arg: "stop --ahk" },
		{ bind: "#?", desc: "Toggle Keybind Help", cb: toggle_help },
		{ bind: "#^!b", desc: "Toggle Status Bar", cb: toggle_yasb },
	],
	"Apps", [
		{ bind: "#y", desc: "Open File Explorer", cb: Run, arg: "explorer.exe" },
		{ bind: "#b", desc: "Open Web Browser", cb: Run, arg: "zen.exe" },
		{ bind: "#Enter", desc: "Open Terminal", cb: RunHidden, arg: "wezterm.exe" }
	],
	"Focus Windows", [
		{ bind: format("#{1}", Movement["Left"]), desc: "Left", cb: Komorebic, arg: "focus left" },
		{ bind: format("#{1}", Movement["Down"]), desc: "Down", cb: Komorebic, arg: "focus down" },
		{ bind: format("#{1}", Movement["Up"]), desc: "Up", cb: Komorebic, arg: "focus up" },
		{ bind: format("#{1}", Movement["Right"]), desc: "Right", cb: Komorebic, arg: "focus right" },
	],
	"Move Windows", [
		{ bind: format("#+{1}", Movement["Left"]), desc: "Left", cb: Komorebic, arg: "move left" },
		{ bind: format("#+{1}", Movement["Down"]), desc: "Down", cb: Komorebic, arg: "move down" },
		{ bind: format("#+{1}", Movement["Up"]), desc: "Up", cb: Komorebic, arg: "move up" },
		{ bind: format("#+{1}", Movement["Right"]), desc: "Right", cb: Komorebic, arg: "move right" },
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
		{ bind: "#+f", desc: "Toggle Float", cb: Komorebic, arg: "toggle-float" },
		{ bind: "#f", desc: "Toggle Focus", cb: Komorebic, arg: "toggle-monocle" },
		{ bind: "#.", desc: "Minimize", cb: Komorebic, arg: "minimize" },
		{ bind: "#q", desc: "Close", cb: Komorebic, arg: "close" },
		{ bind: "#!l", desc: "Lock Container", cb: Komorebic, arg: "toggle-lock" },
	],
	"Layouts", [
		{ bind: "#!b", desc: "BSP", cb: Komorebic, arg: "change-layout bsp" },
		{ bind: "#!s", desc: "Scrolling", cb: Komorebic, arg: "change-layout scrolling" },
		{ bind: "#!g", desc: "Grid", cb: Komorebic, arg: "change-layout grid" },
		{ bind: "#!x", desc: "Flip Horizontal", cb: Komorebic, arg: "flip-layout horizontal" },
		{ bind: "#!v", desc: "Flip Vertical", cb: Komorebic, arg: "flip-layout vertical" },
		{ bind: format("#!{1}", Movement["MonRight"]), desc: "Next Layout", cb: Komorebic, arg: "cycle-layout next" },
		{ bind: format("#!{1}", Movement["MonLeft"]), desc: "Previous Layout", cb: Komorebic, arg: "cycle-layout previous" },
		{ bind: "#!=", desc: "Increase Scroll Columns", cb: Nukomo, arg: "scroll-columns increase" },
		{ bind: "#!-", desc: "Decrease Scroll Columns", cb: Nukomo, arg: "scroll-columns decrease" },
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
		{ bind: "#!f", desc: "Toggle Workspace Float Override", cb: Komorebic, arg: "toggle-workspace-float-override" },
		{ bind: "#^f", desc: "Toggle Workspace Layer", cb: Komorebic, arg: "toggle-workspace-layer" },
	],
	"Monitors", [
		{ bind: format("#{1}", Movement["MonLeft"]), desc: "Focus Monitor Left", cb: Komorebic, arg: "cycle-monitor previous" },
		{ bind: format("#{1}", Movement["MonRight"]), desc: "Focus Monitor Right", cb: Komorebic, arg: "cycle-monitor next" },
		{ bind: format("#+{1}", Movement["MonLeft"]), desc: "Move Window to Monitor Left", cb: Komorebic, arg: "cycle-move-to-monitor previous" },
		{ bind: format("#+{1}", Movement["MonRight"]), desc: "Move Window to Monitor Right", cb: Komorebic, arg: "cycle-move-to-monitor next" },
		{ bind: "#+s", desc: "Toggle Side Offset for Current", cb: Nukomo, arg: "side-offset" },
	],
	"Debug", [
		{ bind: "#+r", desc: "Retile Windows", cb: Komorebic, arg: "retile" },
		{ bind: "#a", desc: "Manage Window", cb: Komorebic, arg: "manage" },
		{ bind: "#+a", desc: "Unmanage Window", cb: Komorebic, arg: "unmanage" },
	]
)

validate_keymaps() {
	keysHash := Map()
	for group, hotkeys in Groups {
		for hk in hotkeys {
			if (!keysHash.Has(hk.bind)) {
				keysHash[(hk.bind)] := { group: group, desc: hk.desc }
			} else {
				extra :=
					format("`t{1}:`n`t`t{2}: {3}`n`t{4}:`n`t`t{5}: {6}",
						keysHash.Get(hk.bind)
						.group, hk.bind, keysHash.get(hk.bind)
						.desc,
						group, hk.bind, hk.desc)
				throw Error("duplicate binding " hk.bind, "komorebi.ahk", extra)
			}
		}
	}
}
try {
	validate_keymaps()
} catch as err {
	MsgBox Format("{1}: {2}.`n`n`nWhat:`t{3}`nExtra:`n{4}"
		, type(err), err.Message, err.What, err.Extra)
}

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

Nukomo(cmd) {
	RunWait(format("nu ./nukomo.nu {}", cmd), , "Hide")
}

toggle_yasb() {
	if WinExist("YasbBar") {
		Yasb("hide-bar")
	} else {
		Yasb("show-bar")
	}
}

GuiTitle := "Komorebi - Hotkeys"
HotkeyGUI := Gui("+AlwaysOnTop -Caption +ToolWindow -Resize", GuiTitle)
HotkeyGUI.BackColor := "1E1E2E"
HotkeyGUI.SetFont("s14 w700")
HotkeyGUI.Add("Text", "cF5C2E7", "Komorebi - Hotkeys")

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
	HotkeyGUI.Add("Text", format("cF5C2E7 x{} y{}", x + xpad, (y * lineHeight) + lineHeight + ypad), format("{}", group))
	y += 1
	for hk in hotkeys {
		doffset := (x + colWidth) - StrLen(hk.desc)
		HotkeyGUI.SetFont("s12 w400")
		HotkeyGUI.AddText(format("x{} y{} w{} +Left cCDD6F4", x + xpad, (y * lineHeight) + lineHeight + ypad, colWidth - descWidth), sub_keysym(hk.bind))
		HotkeyGUI.AddText(format("x{} y{} w{} +Right cCDD6F4", x + xpad + colWidth - descWidth - xpad, (y * lineHeight) + lineHeight + ypad, descWidth), hk.desc)
		y += 1
	}
}

toggle_help() {
	If WinExist("ahk_id" HotkeyGUI.Hwnd) {
		HotkeyGUI.Hide()
	} Else {
		HotkeyGUI.Show()
		WinGetClientPos(&gX, &gY, &gWidth, &gHeight, HotkeyGUI.Hwnd)
		WinSetRegion(Format("0-0 w{1} h{2} r30-30", gWidth, gHeight), HotkeyGUI.Hwnd)
	}
}

; Loop {
; 	HWNDS := WinGetList("ahk_exe sclang.exe")
; 	Loop HWNDS.length {
; 		exStyle := WinGetExStyle(HWNDS[A_Index])
; 		if (exStyle & 0x00000008) {
; 			continue
; 		}
; 	 WinSetAlwaysOnTop(1, HWNDS[A_Index])
; 	}
; }
