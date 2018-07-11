class GuiWindowFactory
{
    guiGroups := {}

    CreateGUI(options = "", group = "gui")
    {
        if(!this.guiGroups[group])
        {
            this.guiGroups[group] := 1
        }
        else
        {
            this.guiGroups[group] += 1
        }

        guiName := group . this.guiGroups[group]
        
        Gui, % guiName . ":New", %options%

        return guiName
    }
}

guiFactory := new GuiWindowFactory()