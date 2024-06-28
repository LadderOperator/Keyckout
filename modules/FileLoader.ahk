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

    CheatsheetFolder := "cheatsheet"
    Cheatsheets := Map()

    __New(CheatsheetConfig := "cheatsheet.ini") {
        
    CheatsheetPath := Format("{1}\{2}", this.CheatsheetFolder, this.CheatsheetConfig)
        CheatsheetList := IniRead(CheatsheetPath)
        
        For Cheatsheet in StrSplit(CheatSheetList, "`n") {

            this.Cheatsheets[Cheatsheet] := Map()
            this.Cheatsheets[Cheatsheet]["Type"] := IniRead(CheatsheetPath, Cheatsheet, "Type")

            ; If not default, must have match title and process
            If Cheatsheet != "Default" {
                this.Cheatsheets[Cheatsheet]["MatchTitle"] := IniRead(CheatsheetPath, Cheatsheet, "MatchTitle")
                this.Cheatsheets[Cheatsheet]["MatchProcess"] := IniRead(CheatsheetPath, Cheatsheet, "MatchProcess")
            }
            
            this.Cheatsheets[Cheatsheet]["Files"] := StrSplit(IniRead(CheatsheetPath, Cheatsheet, "Files"), ";")
        }
    }

    MatchRule(MatchTitle, MatchProcess) {
        For CheatsheetKey, CheatsheetValue In this.Cheatsheets {
            If CheatsheetKey != "default" {
                If RegExMatch(this.Cheatsheets[CheatsheetKey]["MatchTitle"], MatchTitle) 
                    Or RegExMatch(this.Cheatsheets[CheatsheetKey]["MatchProcess"], MatchProcess) {
                    Return this.Cheatsheets[CheatsheetKey]
                }
            }
        }
        Return this.Cheatsheets["default"]
    }
}