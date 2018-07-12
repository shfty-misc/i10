class GuiFrame
{
    gui := 0
    hwnd := 0
    height := 24
    border := 2

    bounds := { x: 0, y:0, w:0, h:0 }

    __New()
    {
        global guiFactory
        this.gui := guiFactory.CreateGUI("-Caption +ToolWindow", "frame")
            
        Gui, % this.gui . ":+HwndframeHwnd"
        this.hwnd := frameHwnd

        this.Init()
    }

    Init()
    {
        Gui, % this.gui . ":Show", x0 y0
    }

    Update()
    {

    }

    Destroy()
    {
        Gui, % this.gui . ":Destroy"
        this.gui := 0
        this.hwnd := 0
    }

    SetColor(color)
    {
        Gui, % this.gui . ":Color", % color
    }

    SetPosition(x, y, w, h)
    {
        this.bounds.x := x - this.border
        this.bounds.y := y
        this.bounds.w := w + this.border * 2
        this.bounds.h := this.height

        SetWindowPosition(this.hwnd, this.bounds.x, this.bounds.y, this.bounds.w, this.bounds.h)
    }
}
