; Base Container class
class Container
{
    parent := ""
    children := []
    activeChild := ""
    lastActiveChild := ""
    guiTreeEntry := 0

    frame := 0

    __New(ByRef parent)
    {
        this.parent := parent
    }

    Update()
    {
        if(!this.frame)
        {
            this.CreateFrame()
        }

        for index, element in this.children
        {
            element.Update()
        }

        if(this.frame)
        {
            this.UpdateFrame()
        }
    }

    Destroy()
    {
        while(this.children.Length() > 0)
        {
            this.children[1].Destroy()
        }

        if(this.frame)
        {
            this.frame.Destroy()
            this.frame := 0
        }

        this.activeChild := 0
        this.lastActiveChild := 0

        this.parent.RemoveChild(this)
    }

    CreateFrame()
    {
        this.frame := new TextFrame()
    }

    GetFrameArea()
    {
        frameArea := this.GetWorkArea()
        frameArea := this.GetWorkArea()
        frameArea.bottom := frameArea.top + this.frame.height
        return frameArea
    }

    UpdateFrame()
    {
        frameArea := this.GetFrameArea()
        this.frame.SetPosition(frameArea.left, frameArea.top, frameArea.right - frameArea.left, frameArea.bottom - frameArea.top)

        isActive := this.parent.GetActiveChild() == this
        this.frame.SetBackgroundColor(isActive ? "4A6EFF" : "E0E0E0")
        this.frame.SetTextElementColor(isActive ? "FFFFFF" : "000000", "Title")

        this.frame.Update()
    }

    AddChild(ByRef child)
    {
        LogMessage("Calling AddChildAt() for new child " . child.ToString())
        return this.AddChildAt(this.children.Length() + 1, child, setActive)
    }

    AddChildAt(index, ByRef child)
    {
        global treeRoot

        child.parent := this
        this.children.InsertAt(index, child)
        LogMessage("Added child " . child.ToString() . " at index " . index)
        treeRoot.MarkGUIDirty()
        return child
    }

    RemoveChild(ByRef child)
    {
        childIndex := this.GetChildIndex(child)
        LogMessage("Calling RemoveChildAt() on child " . child.ToString() . " with index " . childIndex)
        this.RemoveChildAt(this.GetChildIndex(child))
    }

    RemoveChildAt(childIndex)
    {
        global treeRoot
        
        if(childIndex != -1)
        {
            childToRemove := this.children[childIndex]
            childToRemove.parent := ""
            LogMessage("Removing child at index " . childIndex . ": " . childToRemove.ToString())
            this.children.RemoveAt(childIndex)

            newActiveChild := ""
            if(IndexOf(this.GetLastActiveChild(), this.children) != -1)
            {
                newActiveChild := this.GetLastActiveChild()
            }
            else if(this.children[childIndex] != "")
            {
                newActiveChild := this.children[childIndex]
            }
            else if(this.children[childIndex - 1] != "")
            {
                newActiveChild := this.children[childIndex - 1]
            }

            if(newActiveChild != "")
            {
                newActiveChild.SetActiveContainer(true)
            }
            else
            {
                this.SetActiveChild("")
            }

            treeRoot.MarkGUIDirty()
        }
        else
        {
            LogWarning("RemoveChild() failed")
        }
    }

    ReplaceChild(ByRef child, ByRef newChild)
    {
        global treeRoot

        childIndex := IndexOf(child, this.children)
        if(childIndex != -1)
        {
            LogMessage("Replacing child " . child.ToString() . " with new child " . newChild.ToString())
            this.children[childIndex].parent = ""
            newChild.parent := this
            this.children[childIndex] := newChild

            treeRoot.MarkGUIDirty()

            return this.children[childIndex]
        }

        return ""
    }

    ClearChildren()
    {
        while(this.children.Length() > 0)
        {
            childCount := this.GetChildCount()
            this.children[childCount].ClearChildren()
            this.RemoveChild(this.children[childCount])
        }

        this.SetActiveChild("")
    }

    GetChildCount()
    {
        return this.children.Length()
    }

    GetChildIndex(child)
    {
        return IndexOf(child, this.children)
    }

    GetActiveChild()
    {
        return this.activeChild
    }

    GetActiveChildIndex()
    {
        return IndexOf(this.activeChild, this.children)
    }

    GetLastActiveChild()
    {
        return this.lastActiveChild
    }

    GetLastActiveChildIndex()
    {
        return IndexOf(this.lastActiveChild, this.children)
    }

    SetActiveChild(child)
    {
        LogMessage("Setting active child to " . child.ToString())
        this.lastActiveChild := this.activeChild
        this.activeChild := child
    }

    SetActiveContainer(tryWarpMouse = true)
    {
        LogMessage("Setting parent active container to " . this.ToString())
        this.parent.SetActiveChild(this)
        this.parent.SetActiveContainer(false)

        WinSet, Bottom,, % "ahk_id " . this.frame.hwnd

        if(tryWarpMouse)
        {
            TryWarpMouse(this)
        }
    }

    GetParentOfClass(class)
    {
        activeContainer := this.parent
        while(activeContainer.__Class != class)
        {
            if(activeContainer.parent == "")
            {
                return ""
            }

            activeContainer := activeContainer.parent
        }

        return activeContainer
    }

    GetParentMonitor()
    {
        return this.GetParentOfClass("MonitorContainer")
    }

    GetParentWorkspace()
    {
        return this.GetParentOfClass("WorkspaceContainer")
    }

    GetParentSplit()
    {
        return this.GetParentOfClass("SplitContainer")
    }

    GetIndex()
    {
        return IndexOf(this, this.parent.children)
    }

    GetLayout()
    {
        return this.parent.GetLayout()
    }

    GetWorkArea()
    {
        global Orientation_H
        global Orientation_V
        global Layout_Split

        parentWorkArea := this.parent.GetWorkArea()

        parentOrientation := this.parent.GetOrientation()
        parentLayout := this.parent.GetLayout()

        parentWorkArea.top += this.parent.frame.height

        workArea := parentWorkArea

        if(parentLayout == Layout_Split)
        {
            innerGap := this.GetParentMonitor().innerGap

            if(parentOrientation == Orientation_H)
            {
                pw := parentWorkArea.right - parentWorkArea.left
                lw := Floor(pw / this.parent.GetChildCount())
                lx := parentWorkArea.left + (lw * (this.GetIndex() - 1))
                workArea := { left: Floor(lx), top: parentWorkArea.top, right: Ceil(lx + lw), bottom: parentWorkArea.bottom }

                if(this.GetIndex() > 1)
                {
                    workArea.left += Ceil(innerGap / 2)
                }

                if(this.GetIndex() < this.parent.GetChildCount())
                {
                    workArea.right -= Floor(innerGap / 2)
                }
            }
            else if(parentOrientation == Orientation_V)
            {
                ph := parentWorkArea.bottom - parentWorkArea.top
                lh := Floor(ph / this.parent.GetChildCount())
                ly := parentWorkArea.top + (lh * (this.GetIndex() - 1))
                workArea := { left: parentWorkArea.left, top: Floor(ly), right: parentWorkArea.right, bottom: Ceil(ly + lh) }
                
                if(this.GetIndex() > 1)
                {
                    workArea.top += Ceil(innerGap / 2)
                }

                if(this.GetIndex() < this.parent.GetChildCount())
                {
                    workArea.bottom -= Floor(innerGap / 2)
                }
            }
        }

        return workArea
    }

    WorkAreaContainsPoint(x, y)
    {
        workArea := this.GetWorkArea()
        if(x > workArea.left && x < workArea.right && y > workArea.top && y < workArea.bottom)
        {
            return true
        }

        return false
    }

    DisplayAreaContainsPoint(x,y)
    {
        displayArea := this.GetDisplayArea()
        if(x > displayArea.left && x < displayArea.right && y > displayArea.top && y < displayArea.bottom)
        {
            return true
        }

        return false
    }

    WorkAreaContainsWindow(hwnd, useCenter = true)
    {
        winPos := ""
        if(useCenter)
        {
            winPos := GetWindowCenter(hwnd)
        }
        else
        {
            winPos := GetWindowPosition(hwnd)
            offset := GetWindowGapOffset(hwnd)
            winPos.x += offset.left
            winPos.y += offset.right
        }

        return this.WorkAreaContainsPoint(winPos.x, winPos.y)
    }

    DisplayAreaContainsWindow(hwnd, useCenter = true)
    {
        winPos := ""
        if(useCenter)
        {
            winPos := GetWindowCenter(hwnd)
        }
        else
        {
            winPos := GetWindowPosition(hwnd)
            offset := GetWindowGapOffset(hwnd)
            winPos.x += offset.left
            winPos.y += offset.right
        }

        return this.DisplayAreaContainsPoint(winPos.x, winPos.y)
    }

    ToString()
    {
        return "Container"
    }

    IsStringBold()
    {
        return false
    }

    PopulateGUI(guiParent)
    {
        entryString := this.ToString()
    
        optionString := ""
        if(this.guiTreeEntry == 0)
        {
            optionString .= " +Expand"
        }

        if(this.IsStringBold())
        {
            optionString .= " +Bold"
        }
        else
        {
            optionString .= " -Bold"
        }

        global mainGui
        global guiTree
        Gui, % mainGui . ":Default"
        Gui, % mainGui . ":TreeView", guiTree
        this.guiTreeEntry := TV_Update(this.guiTreeEntry, guiParent, entryString, optionString)

        for index, element in this.children
        {
            element.PopulateGUI(this.guiTreeEntry)
        }
    }

    MarkGUIDirty()
    {
        for index, element in this.children
        {
            element.MarkGUIDirty()
        }

        TV_Delete(this.guiTreeEntry)
        this.guiTreeEntry := 0
    }
}