; SplitContainer node - contains WindowContainer nodes and represents their focus and layout
class SplitContainer extends Container
{
    layout := Layout_None
    orientation := Orientation_None
    guiWorkArea := 0

    __New(ByRef parent, orientation, layout)
    {
        base.__New(parent)
        
        this.layout := layout
        this.orientation := orientation
    }

    Update()
    {
        if(this.parent.__Class != "RootContainer")
        {
            if(this.parent.__Class == "WorkspaceContainer")
            {
                if(this.GetParentMonitor().children.Length() != 1 && this.GetParentWorkspace() != this.GetParentMonitor().GetActiveChild())
                {
                    if(this.GetChildCount() == 0)
                    {
                        this.Destroy()
                        return
                    }
                }
            }
            else
            {
                if(this.GetChildCount() == 0)
                {
                    this.Destroy()
                    return
                }
            }
        }

        base.Update()
    }

    GetLayout()
    {
        return this.layout
    }

    GetOrientation()
    {
        return this.orientation
    }

    CreateFrame()
    {
        if(this.parent.__Class != "RootContainer")
        {
            base.CreateFrame()
        }
    }

    UpdateFrame()
    {
        if(this.parent.__Class != "RootContainer")
        {
            base.UpdateFrame()
            this.frame.SetTextElement(this.ToString(), "Title")
        }
    }

    ToString()
    {
        NodeString := this.GetOrientation() . " " . this.GetLayout()

        return NodeString
    }

    IsStringBold()
    {
        return this == this.parent.GetActiveChild()
    }

    PopulateGUI(guiParent)
    {
        base.PopulateGUI(guiParent)

        workArea := this.GetWorkArea()
        this.guiWorkArea := TV_Update(this.guiWorkArea, this.guiTreeEntry, "Work Area: " . workArea.left . ", " . workArea.top . ", " . workArea.right . ", " . workArea.bottom, "+First")
    }

    MarkGUIDirty()
    {
        TV_Delete(this.guiWorkArea)
        this.guiWorkArea := 0

        base.MarkGUIDirty()
    }
}