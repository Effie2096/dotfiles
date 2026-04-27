#Requires AutoHotkey v2.0.2
#SingleInstance Force

TaskTitle := "Taskwarrior"
TraySetIcon("tw.ico", , true)

TaskGUI := Gui("+AlwaysOnTop -Caption +ToolWindow -Resize +Owner", TaskTitle)

TaskGUI.BackColor := "1E1E2E"
TaskGUI.SetFont("s14 w600")
TaskGUI.Add("Text", "cF5C2E7 Center w350", "New Task")

TaskInput := TaskGUI.AddEdit("vTask w350 -WantReturn")

class RefPanel {
	static isVisible := false
	static Controls := []

	init() {
		global TaskGUI
		RefPanel.Controls := []
		TaskGUI.SetFont("s12 w600")
		RefPanel.Controls.Push(TaskGUI.Add("Text", "cF5C2E7 Hidden h0", "Ref"))
		TaskGUI.SetFont("s10 w500")
		RefPanel.Controls.Push(TaskGUI.Add("Text", "cF5C2E7 Hidden h0 YP+20", "+home"))
		RefPanel.Controls.Push(TaskGUI.Add("Text", "cF5C2E7 Hidden h0 YP+20", "project:NAME"))
		RefPanel.Controls.Push(TaskGUI.Add("Text", "cF5C2E7 Hidden h0 YP+20", "project:HIERARCHY.NAME"))
		RefPanel.Controls.Push(TaskGUI.Add("Text", "cF5C2E7 Hidden h0 YP+20", "status:pending"))
	}

	hide() {
		global TaskGUI
		RefPanel.isVisible := false
		for ctrl in RefPanel.Controls {
			ctrl.Visible := RefPanel.isVisible
			ctrl.Move(, , , 0)
		}
		refreshGUI(TaskGUI)
	}

	toggle() {
		global TaskGUI
		RefPanel.isVisible := !RefPanel.isVisible
		for ctrl in RefPanel.Controls {
			ctrl.Visible := RefPanel.isVisible
			if RefPanel.isVisible {
				ctrl.Move(, , , 20)
			} else {
				ctrl.Move(, , , 0)
			}
		}
		refreshGUI(TaskGUI)
	}
}

rp := RefPanel()
rp.init()

TaskGUI.Add("Button", "Default Hidden w0 h0")
	.OnEvent("Click", ProcessTaskInput)

TaskGUI.OnEvent("Escape", (*) => (
	TaskInput.Text := "",
	TaskGUI.Hide()
))

ProcessTaskInput(*) {
	global TaskGUI, TaskInput
	Input := TaskGUI.Submit()

	if Input.Task == "" {
		return
	}

	try {
		escapedTask := RegExReplace(
			Input.Task,
			"(?<!\\)([$!'“();`*?{}\[\]<>|&%#~])|\\(?![$!'“();`*?{}\[\]<>|&%#~])",
			"\$0"
		)
		RunWait(format("task add {1:s}", escapedTask), , "Hide")
	} catch {
		MsgBox "Task not created"
	}

	TaskInput.Text := ""
}

addRoundedCorners(gui) {
	WinGetClientPos(&gX, &gY, &gWidth, &gHeight, gui.Hwnd)
	WinSetRegion(Format("0-0 w{1} h{2} r30-30", gWidth, gHeight), gui.Hwnd)
}

refreshGUI(gui) {
	gui.Show("Autosize")
	addRoundedCorners(gui)
}

add_task() {
	If WinExist("ahk_id" TaskGUI.Hwnd) {
		rp.hide()
		TaskGUI.Hide()
		TaskInput.Text := ""
	} Else {
		refreshGUI(TaskGUI)
	}
}
#t:: add_task()

HotIfWinActive "ahk_id " . TaskGUI.Hwnd
Hotkey "^h", rp.toggle
