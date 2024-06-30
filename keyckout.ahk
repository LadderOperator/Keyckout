#Requires AutoHotkey v2
#Include "modules/UI.ahk"
#SingleInstance Ignore

TraySetIcon("Keyckout.ico")
Tray := A_TrayMenu
Tray.delete
Tray.add "Exit", (*) => ExitApp()


; Read settings

KeycoutSettingsManager := SettingsManager("settings.ini")

Settings := KeycoutSettingsManager.Load()

global Transparency := Settings["Transparency"]
global WaitingTime := Settings["WaitingTime"]
global UseDPIScale := Settings["UseDPIScale"]
global EnableDefault := Settings["EnableDefault"]

; Initialize GUI class
global PopupGUI := PopupWindow(Transparency, UseDPIScale)

; Hotkey for the Windows key
LWin::{
    keyPressed := A_TickCount
    global InputKeys := InputHook("M")
    SetTimer PopupCallbackWrapper, -WaitingTime ; Wait before showing/updating the window
    InputKeys.Start()
    KeyWait "LWin"
    SetTimer PopupCallbackWrapper, 0
    if (A_TickCount - keyPressed < WaitingTime) {
        AllKeys := InputKeys.Input
        InputKeys.Stop()
        SendInput("{LWin down}" . AllKeys . "{LWin up}") ; Send original keys
    } else {
        PopupGUI.Hide()
    }
    
}

PopupCallbackWrapper() {
    InputKeys.Stop()
    ActiveWinTitle := WinGetTitle("A")
    ActiveWinProc := WinGetProcessName("A")
    OutputDebug ActiveWinTitle
    OutputDebug ActiveWinProc
    PopupGUI.Show(ActiveWinTitle, ActiveWinProc)
}