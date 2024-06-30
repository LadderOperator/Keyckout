#Requires AutoHotkey v2.0

#Include "3rd/WebView2/WebView2.ahk"
#Include "FileLoader.ahk"

global GuiAnimation := Animation()

class PopupWindow {

    PopupGUIObj := 0
    HTMLContent := 0
    CheatsheetContent := 0
    WebViewCore := 0
    WebView := 0

    WinVisible := false
    WindowWidth := Integer(0.9*SysGet(0))
    WindowHeight := Integer(0.9*SysGet(1))
    DPIScale := "+DPIScale"
    DPIFactor := 1.0
    Transparency := 0.9

    CurrentCheatsheet := 0


    __New(Transparency, UseDPIScale) {
        this.PopupGUIObj := GUI()
        this.PopupGUIObj.OnEvent("Close", (*) => (this.WebViewCore := this.WebView := 0))
        this.SetStyle(Transparency, UseDPIScale)
        this.HTMLContent := HTMLComposer(this.WindowWidth)
        this.CheatsheetContent := CheatsheetRegister()
    }

    SetStyle(Transparency, UseDPIScale := 1 ) {
        this.Transparency := Transparency
        If UseDPIScale = 1 {
            this.DPIScale := "+DPIScale"
            this.DPIFactor := A_ScreenDPI / 96
        } Else {
            this.DPIScale := "-DPIScale"
            this.DPIFactor := 1.0
        }
        this.WindowHeight := Integer(0.9*SysGet(1) / this.DPIFactor)
        this.WindowWidth := Integer(0.9*SysGet(0) / this.DPIFactor)
        this.PopupGUIObj.Opt("-Caption +AlwaysOnTop +ToolWindow " . this.DPIScale)
      
    }

    Update(ActiveWinTitle, ActiveWinProc) {
        MatchedCheatsheet := this.CheatsheetContent.MatchRule(ActiveWinTitle, ActiveWinProc)
        If this.CurrentCheatsheet != MatchedCheatsheet[1] {
            this.CurrentCheatsheet := MatchedCheatsheet[1]
            DocHTML := this.HTMLContent.MakeDocHTML(MatchedCheatsheet*)
            this.WebView.NavigateToString(DocHTML)
            this.WebViewCore.MoveFocus(0) ; The most elegant way to focus on the  current tab
        } Else {
            this.WebView.ExecuteScript("document.querySelector('.container').classList.remove('hide')", (*) => {})
        }

    }

    Show(ActiveWinTitle, ActiveWinProc) {
        If !this.WinVisible {
            this.WinVisible := true
            this.PopupGUIObj.Show(Format("w{1} h{2} Center Maximize", this.WindowWidth, this.WindowHeight))
            If !this.WebViewCore {
                this.WebViewCore := WebView2.create(this.PopupGUIObj.hwnd)
                this.WebView := this.WebViewCore.CoreWebView2
                this.WebView.SetVirtualHostNameToFolderMapping("keyckout", A_InitialWorkingDir, 2)
            }
            WinSetTransparent(0, this.PopupGUIObj.hwnd)
            this.Update(ActiveWinTitle, ActiveWinProc)
            GuiFadeIn(this.PopupGUIObj.hwnd, [0, this.Transparency], 10)
        }
    }

    Hide() {
        If this.WinVisible {
            this.WinVisible := false
            GuiFadeOut(this.PopupGUIObj.hwnd, [this.Transparency, 0], 10)
            this.WebView.ExecuteScript("document.querySelector('.container').classList.add('hide')", (*) => {})
            this.PopupGUIObj.Hide()
        }
    }
}

class HTMLComposer {

    HTMLBaseTemplate := ""
    TabTemplate := "<div class='{{TAB_CLASS}}' data-tab='{{TAB_ID}}'>{{CHEATSHEET_NAME}}</div>"
    TabContentTemplate := "
    (        
        <div class='{{CONTENT_CLASS}}' id='tab-{{TAB_ID}}'>
            {{CONTENT_HTML}}
        </div>
    )"
    KeysGroupTemplate := "
    (
        <div class='kgroup'>
            <h2>{{GROUP_NAME}}</h2>
            {{GROUPED_KEYS}}
        </div>
    )"
    KeysTemplate := "
    (
        <div class='ktable'>
            <div class='kvalue'>
                {{KEYS_VALUE}}
            </div>
            <div class='kdescription'>
                {{KEYS_DESCRIPTION}}
            </div>
        </div>
    )"
    ImgTemplate := "<img class='kimg' src='http://keyckout/cheatsheet/{{CHEATSHEET_FOLDER}}/{{CHEATSHEET_IMG}}' style='max-width:100%;'>"


    __New(Width, TemplateFile := "template.html") {
        this.HTMLBaseTemplate := FileRead(A_InitialWorkingDir . "\modules\html\" . TemplateFile, "UTF-8")
    }

    Compose(HTMLTemplate, ReplacePair) {
        Template := HTMLTemplate
        For Pair in ReplacePair {
            Template := StrReplace(Template, Pair[1], Pair[2])
        }
        Return Template
    }

    MakeTabsHTML(TabList) {
        TabsHTML := ""
        For Idx, Tab In TabList {
            TabsHTML := TabsHTML . this.MakeOneTabHTML(Idx, Tab) ; Idx starts with 1
        }
        Return Format("<div class='tabs'>{1}</div>", TabsHTML)
    }

    MakeOneTabHTML(Idx, Tab) {
        ReplacePair := [
            ["{{TAB_ID}}", String(Idx)],
            ["{{CHEATSHEET_NAME}}", Tab]
        ]
        If Idx = 1 {
            ReplacePair.Push([ "{{TAB_CLASS}}", "tab active"])
        } Else {
            ReplacePair.Push([ "{{TAB_CLASS}}", "tab"])
        }
        CurrentTabHTML := this.Compose(this.TabTemplate, ReplacePair)
        Return CurrentTabHTML
    }
    MakeTabsContentHTML(Cheatsheet, CheatsheetMap) {
        TabsContentHTML := ""
        For Idx, CheatsheetFile in CheatsheetMap["Files"] {
            ReplacePair := []
            If Idx == 1 {
                ReplacePair.Push(["{{CONTENT_CLASS}}", "content active"])
            } Else {
                ReplacePair.Push(["{{CONTENT_CLASS}}", "content"])
            }

            ReplacePair.Push(["{{TAB_ID}}", String(Idx)])

            SWitch CheatsheetMap["Type"] {
                Case "pic": 
                ContentReplacePair := [
                    ["{{CHEATSHEET_FOLDER}}", Cheatsheet],
                    ["{{CHEATSHEET_IMG}}", CheatsheetFile]
                ]
                ContentHTML := this.Compose(this.ImgTemplate, ContentReplacePair)
                }
            ReplacePair.Push(["{{CONTENT_HTML}}", ContentHTML])
            TabsContentHTML := TabsContentHTML . this.Compose(this.TabContentTemplate, ReplacePair)
        }
        Return TabsContentHTML
    }

    MakeDocHTML(Cheatsheet, CheatsheetMap) {
        OutputDebug Cheatsheet
        OutputDebug CheatsheetMap["Type"]
        OutputDebug CheatsheetMap["Files"][1]
        ReplacePair := [
            ["{{TABS}}", this.MakeTabsHTML(CheatsheetMap["Files"])],
            ["{{TABS_CONTENT}}", this.MakeTabsContentHTML(Cheatsheet, CheatsheetMap)]
        ]
        DocHTML := this.Compose(this.HTMLBaseTemplate, ReplacePair)
        Return DocHTML
    }


}

GuiFadeIn(WinHwnd, TransparencyFromTo, Duration := 10) {
    StartTransparency := TransparencyFromTo[1]
    EndTransparency := TransparencyFromTo[2]
    Loop Duration {
        Sleep 1
        WinSetTransparent(Integer(255*GuiAnimation.EaseOutSine(StartTransparency, EndTransparency, Duration, A_Index)), WinHwnd)
    }
}

GuiFadeOut(WinHwnd, TransparencyFromTo, Duration := 10) {
    StartTransparency := TransparencyFromTo[1]
    EndTransparency := TransparencyFromTo[2]
    Loop Duration {
        Sleep 1
        WinSetTransparent(Integer(255*GuiAnimation.EaseOutExpo(StartTransparency, EndTransparency, Duration, A_Index)), WinHwnd)
    }
}

class Animation {

    EaseInExpo(Start, End, Duration, Index, a := 5) {
        Delta := End - Start
        If Index = 1 {
            Return Start
        } Else {
            x := (Index - 1) / (Duration - 1)
            V := Exp(a*(x - 1)) * Delta + Start
            Return V
        }
    }
    EaseOutSine(Start, End, Duration, Index) {
        Delta := End - Start
        If Index = 1 {
            Return Start
        } Else {
            x := (Index - 1) / (Duration - 1)
            V := Sin(1.5708*x) * Delta + Start
            Return V
        }
    }
    EaseOutExpo(Start, End, Duration, Index, a := 5) {
        Delta := End - Start
        If Index = 1 {
            Return Start
        } Else {
            x := (Index - 1) / (Duration - 1)
            V := End - (1 - Exp(a*(x - 1))) * Delta
            Return V
        }
    }
}