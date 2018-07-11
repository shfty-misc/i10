; MonitorContainer Structure

#include includes/Tree/Container.ahk
#include includes/Tree/RootContainer.ahk
#include includes/Tree/WorkspaceContainer.ahk
#include includes/Tree/MonitorContainer.ahk
#include includes/Tree/SplitContainer.ahk
#include includes/Tree/WindowContainer.ahk

; Functions
GetWindowWithHwnd(container, hwnd)
{
    for index, element in container.children
    {
        if(element.__Class == "WindowContainer" && element.hwnd == hwnd)
        {
            return element
        }
        else
        {
            candidateWindow := GetWindowWithHwnd(element, hwnd)
            if(candidateWindow != "")
            {
                return candidateWindow
            }
        }
    }

    return ""
}

GetContainerRootIndex(parentContainer, targetContainer)
{
    for index, element in parentContainer.children
    {
        if(element == targetContainer)
        {
            return index
        }
        else
        {
            containerIndex := GetContainerRootIndex(element, targetContainer)
            if(containerIndex != -1)
            {
                return index
            }
        }
    }

    return -1
}

GetActiveMonitorContainer()
{
    global treeRoot
    return treeRoot.GetActiveChild().GetActiveChild()
}

GetActiveWorkspaceContainer()
{
    return GetActiveMonitorContainer().GetActiveChild()
}

GetWorkspaceRootSplitContainer(workspaceContainer)
{
    for index, element in workspaceContainer.children
    {
        if(element.__Class == "SplitContainer")
        {
            return element
        }
    }

    return ""
}

GetActiveRootSplitContainer()
{
    return GetWorkspaceRootSplitContainer(GetActiveWorkspaceContainer())
}

GetActiveLeafSplitContainer()
{
    rootSplit := GetActiveRootSplitContainer()
    if(rootSplit != "")
    {
        split := rootSplit
        activeChild := rootSplit.GetActiveChild()
        while(activeChild != "" && activeChild.__Class != "WindowContainer")
        {
            split := activeChild
            activeChild := split.GetActiveChild()
        }
        return split
    }

    return ""
}

GetActiveContainer()
{
    split := GetActiveMonitorContainer()
    activeChild := split.GetActiveChild()
    while(activeChild != "")
    {
        split := activeChild
        activeChild := split.GetActiveChild()
    }
    return split
}

GetLeafSplitContainer(parentContainer)
{
    split := parentContainer
    
    activeChild := split.GetActiveChild()
    while(activeChild != "" && activeChild.__Class != "WindowContainer")
    {
        split := activeChild
        activeChild := split.GetActiveChild()
    }
    return split
}

GetContainerUnderPoint(parentContainer, x, y)
{
    for ci, child in parentContainer.children
    {
        if(child.WorkAreaContainsPoint(x, y))
        {
            if(child.children.Length() > 0)
            {
                return GetContainerUnderMouse(child)
            }
            else
            {
                return child
            }
        }
    }

    return ""
}

GetContainerUnderMouse(ByRef parentContainer)
{
    MouseGetPos, x, y
    return GetContainerUnderPoint(parentContainer, x, y)
}

GetMonitorUnderMouse()
{
    global treeRoot

    MouseGetPos, x, y

    for mi, monitor in treeRoot.GetActiveChild().children
    {
        if(monitor.workAreaContainsPoint(x, y))
        {
            return monitor
        }
    }

    return ""
}

SetSplitAxis(newSplitAxis)
{
    activeContainer := GetActiveContainer()
    if(activeContainer.__Class == "WindowContainer")
    {
        activeContainer.splitAxis := newSplitAxis
    }
}

SetLayout(layout)
{
    GetActiveLeafSplitContainer().layout := layout
}

SetOrientation(orientation)
{
    GetActiveLeafSplitContainer().orientation := orientation
}

SetTabbedLayout()
{
    global Orientation_H
    global Layout_Tabbed 

    SetLayout(Layout_Tabbed)
    SetOrientation(Orientation_H)
}

SetStackingLayout()
{
    global Orientation_V
    global Layout_Tabbed

    SetLayout(Layout_Tabbed)
    SetOrientation(Orientation_V)
}

ToggleSplitLayout()
{
    global Orientation_H
    global Orientation_V
    global Layout_Split
    global Layout_Tabbed

    activeSplitContainer := GetActiveLeafSplitContainer()
    if(activeSplitContainer.layout == Layout_Split)
    {
        if(activeSplitContainer.orientation == Orientation_H)
        {
            activeSplitContainer.orientation := Orientation_V
        }
        else if(activeSplitContainer.orientation == Orientation_V)
        {
            activeSplitContainer.orientation := Orientation_H
        }
    }
    else
    {
        activeSplitContainer.layout := Layout_Split
    }
}

TryWarpMouse(ByRef targetContainer)
{
    global MouseWarp_None
    global MouseWarp_Workspace
    global MouseWarp_Window

    mouseWarpSetting := GetOption("MouseWarping")
    if(mouseWarpSetting == MouseWarp_None)
    {
    }
    else if(mouseWarpSetting == MouseWarp_Workspace)
    {
        if(targetContainer.GetParentMonitor() != sourceContainer.GetParentMonitor())
        {
            WarpMouse(targetContainer)
        }
    }
    else if(mouseWarpSetting == MouseWarp_Window)
    {
        WarpMouse(targetContainer)
    }
}

WarpMouse(ByRef targetContainer)
{
    workArea := targetContainer.GetWorkArea()
    workAreaWidth := workArea.right - workArea.left
    workAreaHeight := workArea.bottom - workArea.top
    x := workArea.left + workAreaWidth / 2
    y := workArea.top + workAreaHeight / 2

    global treeRoot
    treeRoot.prevMousePosition.x := x
    treeRoot.prevMousePosition.y := y

    MouseMove, % x , % y, 0
}

FocusParentContainer()
{
    activeContainer := GetActiveContainer()

    if(activeContainer.__Class == "WindowContainer")
    {
        SetWindowInactive()
    }

    activeParent := activeContainer.parent
    if(activeParent.__Class != "WorkspaceContainer")
    {
        activeParent.SetActiveChild("")
    }
}

FocusChildContainer()
{
    activeContainer := GetActiveContainer()
    lastActiveChild := activeContainer.GetLastActiveChild()

    activeContainer.SetActiveChild(lastActiveChild)
}

CloseActiveWindow()
{
    activeContainer := GetActiveContainer()
    if(activeContainer.__Class == "WindowContainer")
    {
        activeContainer.Close()
    }
}

SetWindowContainerFullscreen(windowContainer)
{
    if(windowContainer.__Class == "WindowContainer")
    {
        parentWorkspace := windowContainer.GetParentWorkspace()
        if(parentWorkspace.maximizedWindow == "")
        {
            parentWorkspace.maximizedWindow := windowContainer
        }
        else
        {
            parentWorkspace.maximizedWindow := ""
        }
    }
}

ToggleActiveWindowFullscreen()
{
    SetWindowContainerFullscreen(GetActiveContainer())
}