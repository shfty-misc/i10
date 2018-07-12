class MonitorFrame extends GuiFrame
{
    text := ""
    
    __New()
    {
        base.__New()

        WinGetPos,,,,taskbarHeight, ahk_class Shell_TrayWnd
        this.height := taskbarHeight
    }

    Init()
    {
        this.Init_Internal(this.gui)
        base.Init()
    }

    Init_Internal(gui)
    {
        global
        Gui, % gui . ":Add", Text, % "v" . gui . "Title" . " w100 Left"
        Gui, % gui . ":Add", Text, % "v" . gui . "Time" . " xs500 ys0 w100 Right"
    }

    Update()
    {
        this.SetTime(A_Now)
    }

    SetColor(color)
    {
    }

    SetText(newText)
    {
        this.text := newText
        this.SetText_Internal(this.gui, this.text)
    }

    SetText_Internal(gui, newText)
    {
        global
        GuiControl, % gui . ":Text", % gui . "Title", % newText
    }

    SetTime(newTime)
    {
        FormatTime, formattedTime, newTime, h:mm tt
        this.SetTime_Internal(this.gui, formattedTime)
    }

    SetTime_Internal(gui, time)
    {
        global
        GuiControl, % gui . ":Text", % gui . "Time", % time
    }
}
