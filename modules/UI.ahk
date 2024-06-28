#Requires AutoHotkey v2.0

#Include "3rd/WebView2/WebView2.ahk"

class PopupWindow {

    PopupGUIObj := ""
    HTMLContent := ""
    CheatsheetContent := ""

    WinVisible := false
    WindowWidth := Integer(0.9*SysGet(0))
    WindowHeight := Integer(0.9*SysGet(1))
    DPIScale := "+DPIScale"
    DPIFactor := 1.0
    Transparency := 0.9
    WebViewCore := 0
    WebView := 0

    __New(Transparency, UseDPIScale) {
        this.PopupGUIObj := GUI()
        this.PopupGUIObj.OnEvent("Close", (*) => (this.WebViewCore := this.WebView := 0))
        this.SetStyle(Transparency, UseDPIScale)
        this.HTMLContent := HTMLComposer()
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
        this.WebView.NavigateToString(this.HTMLContent.Compose("{{pic}}", "<img src='http://keyckout/cheatsheet/default/Keyckout.png'>"))
    }

    Show() {
        If !this.WinVisible {
            this.WinVisible := true
            this.PopupGUIObj.Show(Format("w{1} h{2} Center", this.WindowWidth, this.WindowHeight))
            this.WebViewCore := WebView2.create(this.PopupGUIObj.hwnd)
            this.WebView := this.WebViewCore.CoreWebView2
            this.WebView.SetVirtualHostNameToFolderMapping("keyckout", A_InitialWorkingDir, 2)
            this.Update("","")
            WinSetTransparent(Integer(255*this.Transparency), "ahk_id " . this.PopupGUIObj.hwnd)
        }
    }

    Hide() {
        If this.WinVisible {
            this.WinVisible := false
            this.PopupGUIObj.Hide()
            this.WebViewCore := this.WebView := 0
        }
    }

    Call() {
        this.Show()
    }
}

class HTMLComposer {

    HTMLBaseTemplate := "template.html"

    __New(TemplateFile := "template.html") {
        this.HTMLBaseTemplate := TemplateFile
    }

    Compose(PlaceHolder, HTMLString) {
        Template := FileRead(A_InitialWorkingDir . "\modules\html\" . this.HTMLBaseTemplate)
        Template := StrReplace(Template, PlaceHolder, HTMLString)
        Return Template
    }


}