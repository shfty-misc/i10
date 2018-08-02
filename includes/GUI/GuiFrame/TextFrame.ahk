class TextFrame extends GuiFrame
{
    textElements := {}
    textColors := {}

    Init()
    {
        this.PopulateText()
        base.Init()
    }

    PopulateText()
    {
        this.AddTextElement(this.gui, "Title", "w1000")
    }

    AddTextElement(gui, name, options = "")
    {
        global
        Gui, % gui . ":Add", Text, % "v" . gui . name . " " . options
    }

    SetTextElement(newText, elementName)
    {
        if(this.textElements[elementName] != newText)
        {
            this.textElements[elementName] := newText
            this.SetTextElement_Internal(this.gui, elementName, this.textElements[elementName])
        }
    }

    SetTextElement_Internal(gui, elementName, newText)
    {
        global
        GuiControl, % gui . ":Text", % gui . elementName, % newText
    }

    GetTextElementColor(elementName)
    {
        return this.textColors[elementName]
    }

    SetTextElementColor(newTextColor, elementName)
    {
        if(this.textColors[elementName] != newTextColor)
        {
            this.textColors[elementName] := newTextColor
            this.SetTextElementColor_Internal(this.gui, elementName, this.textColors[elementName])
        }
    }

    SetTextElementColor_Internal(gui, elementName, newTextColor)
    {
        global
        Gui, % gui . ":Font", % "c" . newTextColor, Verdana
        GuiControl, % gui . ":Font", % gui . elementName
    }
}
