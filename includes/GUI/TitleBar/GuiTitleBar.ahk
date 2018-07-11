class GuiTitleBar
{
    gui := 0
    hwnd := 0
    height := 24
    border := 2

    __New()
    {
        global guiFactory
        this.gui := guiFactory.CreateGUI("-Caption", "titleBar")
            
        Gui, % this.gui . ":+HwndtitleBarHwnd"
        this.hwnd := titleBarHwnd

        this.Init()
    }

    Init()
    {
        Gui, % this.gui . ":Show", x0 y0
    }

    Destroy()
    {
        Gui, % this.gui . ":Destroy"
        this.gui := 0
        this.hwnd := 0
    }

    SetPosition(x, y, w, h)
    {
        SetWindowPosition(this.hwnd, x - this.border, y, w + this.border * 2, h + this.border)
    }
}
