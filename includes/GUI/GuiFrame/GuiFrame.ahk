#include <GuiFactory>

class GuiFrame
{
    gui := 0
    hwnd := 0
    height := 22
    border := 2
    backgroundColor := ""

    bounds := { x: 0, y:0, w:0, h:0 }

    __New()
    {
        this.gui := GuiFactory.CreateGUI("-Caption +ToolWindow", this.__Class)
            
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
        WinClose, % "ahk_id " . this.hwnd
        this.hwnd := 0

        Gui, % this.gui . ":Destroy"
        this.gui := 0
    }

    SetBackgroundColor(newColor)
    {
        if(this.backgroundColor != newColor)
        {
            this.backgroundColor := newColor
            Gui, % this.gui . ":Color", % this.backgroundColor
        }
    }

    SetPosition(x, y, w, h)
    {
        this.bounds := { x: x, y: y, w: w, h: h }
        SetWindowPosition(this.hwnd, x, y, w, h)
    }
}
