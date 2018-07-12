; SplitContainer node - contains WindowContainer nodes and represents their focus and layout
class SplitContainer extends Container
{
    layout := Layout_None
    orientation := Orientation_None
    guiSplitAxis := 0
    guiWorkArea := 0

    __New(ByRef parent, orientation, layout)
    {
        base.__New(parent)
        
        this.layout := layout
        this.orientation := orientation
    }

    Update()
    {
        global treeRoot

        if(this.parent.__Class != "WorkspaceContainer" && this.parent.__Class != "RootContainer")
        {
            if(this.GetChildCount() == 0)
            {
                this.Destroy()
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

        this.guiSplitAxis := TV_Update(this.guiSplitAxis, this.guiTreeEntry, "Split Axis: " . this.GetSplitAxis(), "+First")

        workArea := this.GetWorkArea()
        this.guiWorkArea := TV_Update(this.guiWorkArea, this.guiTreeEntry, "Work Area: " . workArea.left . ", " . workArea.top . ", " . workArea.right . ", " . workArea.bottom, "+First")
    }

    MarkGUIDirty()
    {
        TV_Delete(this.guiSplitAxis)
        this.guiSplitAxis := 0

        TV_Delete(this.guiWorkArea)
        this.guiWorkArea := 0

        base.MarkGUIDirty()
    }
}