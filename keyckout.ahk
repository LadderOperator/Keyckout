#Requires AutoHotkey v2

#Include "modules/UI.ahk"
#Include "modules/FileLoader.ahk"

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
    SetTimer PopupGUI, -WaitingTime ; Wait before showing/updating the window
    InputKeys.Start()
    KeyWait "LWin"
    SetTimer PopupGUI, 0
    if (A_TickCount - keyPressed < WaitingTime) {
        AllKeys := InputKeys.Input
        SendInput("{LWin down}" . AllKeys . "{LWin up}") ; Send original keys
        InputKeys.Stop()
    } else {
        PopupGUI.Hide()
    }
    InputKeys.Stop()
}