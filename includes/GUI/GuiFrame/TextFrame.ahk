class TextFrame extends GuiFrame
{
    text := ""
    
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
        Gui, % gui . ":Add", Text, % "v" . gui . "Title" . " w10000"
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

    SetTextColor(newTextColor)
    {
        this.SetTextColor_Internal(this.gui, newTextColor)
    }

    SetTextColor_Internal(gui, newTextColor)
    {
        global
        Gui, % gui . ":Font", % "c" . newTextColor, Verdana
        GuiControl, % gui . ":Font", % gui . "Title"
    }
}
