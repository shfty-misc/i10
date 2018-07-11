class WindowTitleBar extends GuiTitleBar
{
    titleText := ""
    
    __New()
    {
        base.__New()
    }

    Init()
    {
        this.Init_Internal(this.gui)
        base.Init()
    }

    Init_Internal(gui)
    {
        global
        Gui, % gui . ":Add", Text, % "v" . gui . "TitleBar" . " w10000"
    }

    SetTitleText(newText)
    {
        this.titleText := newText
        this.SetTitleText_Internal(this.gui, this.titleText)
    }

    SetTitleText_Internal(gui, newText)
    {
        global
        GuiControl, % gui . ":Text", % gui . "TitleBar", % newText
    }
}
