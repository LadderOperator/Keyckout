#Requires AutoHotkey v2.0

class SettingsManager {

    Settings := Map()
    SettingsFile := "settings.ini"

    __New(SettingsFile := "settings.ini") {
        this.SettingsFile := SettingsFile
    }

    Load() {
        ; Load settings from a file
        If FileExist(this.SettingsFile) {

            this.Settings["Transparency"] := Float(IniRead(this.SettingsFile, "Settings", "Transparency", 0.9))
            this.Settings["WaitingTime"] := Integer(IniRead(this.SettingsFile, "Settings", "WaitingTime", 500))
            this.Settings["UseDPIScale"] := Integer(IniRead(this.SettingsFile, "Settings", "UseDPIScale", 0))
            this.Settings["EnableDefault"] := Integer(IniRead(this.SettingsFile, "Settings", "EnableDefault", 1))
        }

        Return this.Settings
    }

    Modify(SettingKey, SettingValue) {
        ; Modify settings in a file
        IniWrite(this.SettingsFile, "Settings", SettingKey, SettingValue)
        this.Settings[SettingKey] := SettingValue
    }
}

class CheatsheetRegister {

    Cheatsheets := Map()

    __New(CheatsheetFolder := "cheatsheet", CheatsheetConfig := "cheatsheet.ini") {
        
    CheatsheetPath := Format("{1}\{2}", CheatsheetFolder, CheatsheetConfig)
        CheatsheetList := IniRead(CheatsheetPath)
        
        For Cheatsheet in StrSplit(CheatSheetList, "`n") {

            this.Cheatsheets[Cheatsheet] := Map()
            this.Cheatsheets[Cheatsheet]["Type"] := IniRead(CheatsheetPath, Cheatsheet, "Type")

            ; If not default, must have match title and process
            If Cheatsheet != "default" {
                this.Cheatsheets[Cheatsheet]["MatchTitle"] := IniRead(CheatsheetPath, Cheatsheet, "MatchTitle")
                this.Cheatsheets[Cheatsheet]["MatchProcess"] := IniRead(CheatsheetPath, Cheatsheet, "MatchProcess")
            }
            OutputDebug IniRead(CheatsheetPath, Cheatsheet, "Files")
            this.Cheatsheets[Cheatsheet]["Files"] := StrSplit(IniRead(CheatsheetPath, Cheatsheet, "Files"), ",")
        }
    }

    MatchRule(MatchTitle, MatchProcess) {
        MatchedCheatsheets := Array()
        For CheatsheetKey, CheatsheetValue In this.Cheatsheets {
            OutputDebug CheatsheetKey
            If CheatsheetKey != "default" {
                OutputDebug CheatsheetValue["MatchTitle"]
                OutputDebug CheatsheetValue["MatchProcess"]
                If RegExMatch(MatchTitle, CheatsheetValue["MatchTitle"]) 
                    And RegExMatch(MatchProcess, CheatsheetValue["MatchProcess"]) {
                    MatchedCheatsheets.Push(Array(CheatsheetKey, CheatsheetValue))
                }
            }
        }
        If MatchedCheatsheets.Length = 0 {
            MatchedCheatsheets.Push(Array("default", this.Cheatsheets["default"]))
        }
        Return MatchedCheatsheets
    }
}