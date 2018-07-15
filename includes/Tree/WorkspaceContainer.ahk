; WorkspaceContainer - Represents a workspace, contains MonitorContainers
class WorkspaceContainer extends Container
{
    workspaceIndex := -1
    maximizedWindow := ""

    __New(ByRef parent, index)
    {
        global Layout_Split
        global Layout_None
        global Orientation_H
        global Orientation_V
        global Orientation_None

        base.__New(parent)

        this.workspaceIndex := index

        workArea := this.GetWorkArea()
        workAreaWidth := workArea.right - workArea.left
        workAreaHeight := workArea.bottom - workArea.top

        ; Apply default orientation and layout
        layout := GetOption("WorkspaceLayout")
        if(layout == Layout_None)
        {
            layout := Layout_Split
        }

        orientation := GetOption("DefaultOrientation")
        if(orientation == Orientation_None)
        {
            if(workAreaWidth > workAreaHeight)
            {
                orientation := Orientation_H
            }
            else
            {
                orientation := Orientation_V
            }
        }

        newSplit := new SplitContainer(this, orientation, layout)
        this.AddChild(newSplit)
        this.SetActiveChild(newSplit)
    }

    Update()
    {
        if(this.GetChildCount() == 0 && this.parent.children.Length() > 1)
        {
            this.Destroy()
            return
        }

        base.Update()

        if(this.parent.GetActiveChild() != this || this.maximizedWindow != "")
        {
            SetWindowHidden(this.frame.hwnd)
            SetWindowHidden(this.GetRootSplitContainer().frame.hwnd)
        }
        else
        {
            SetWindowShown(this.frame.hwnd)
            SetWindowShown(this.GetRootSplitContainer().frame.hwnd)
        }
    }

    UpdateFrame()
    {
        base.UpdateFrame()
        this.frame.SetTextElement(this.ToString(), "Title")
    }

    GetRootSplitContainer()
    {
        for index, element in this.children
        {
            if(element.__Class == "SplitContainer")
            {
                return element
            }
        }

        return ""
    }

    GetWorkArea()
    {
        workArea := base.GetWorkArea()

        innerGap := this.GetParentMonitor().innerGap
        
        if(this.maximizedWindow == "")
        {
            workArea.left += innerGap
            workArea.top += innerGap
            workArea.right -= innerGap
            workArea.bottom -= innerGap
        }

        return workArea
    }

    ToString()
    {
        NodeString := "Workspace " . this.workspaceIndex

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

GetWorkspaceContainer(ByRef monitorContainer, workspaceIndex)
{
    if(monitorContainer != "")
    {
        foundWorkspace := ""
        for index, element in monitorContainer.children
        {
            if(element.workspaceIndex == workspaceIndex)
            {
                return element
            }
        }

        if(foundWorkspace == "")
        {
            LogMessage("Workspace not found, creating...")
            newWorkspace := new WorkspaceContainer(monitorContainer, workspaceIndex)
            monitorContainer.AddChild(newWorkspace)
            return newWorkspace
        }

        return foundWorkspace
    }
}

SetActiveWorkspace(workspaceIndex)
{
    LogMessage("Setting active workspace to " . workspaceIndex)
    activeMonitor := GetActiveMonitorContainer()
    if(activeMonitor != "")
    {
        workspace := GetWorkspaceContainer(activeMonitor, workspaceIndex)
        workspace.SetActiveContainer(false)
    }
}

MoveActiveWindowToWorkspace(workspaceIndex)
{
    LogMessage("Moving active window to workspace " . workspaceIndex)
    activeContainer := GetActiveContainer()
    if(activeContainer.__Class == "WindowContainer")
    {
        activeMonitor := activeContainer.GetParentMonitor()
        if(activeMonitor != "")
        {
            LogMessage("Removing " . activeContainer.hwnd . " from parent split " . activeContainer.parent.ToString())
            activeContainer.parent.RemoveChild(activeContainer)

            targetWorkspace := GetWorkspaceContainer(activeMonitor, workspaceIndex)

            if(activeContainer.IsFloating())
            {
                targetWorkspace.AddChildAt(0, activeContainer)
                targetWorkspace.SetActiveChild(activeContainer)
            }
            else
            {
                targetSplit := GetLeafSplitContainer(GetWorkspaceRootSplitContainer(targetWorkspace))
                targetSplit.AddChild(activeContainer)
                targetSplit.SetActiveChild(activeContainer)
            }
        }
    }
}
