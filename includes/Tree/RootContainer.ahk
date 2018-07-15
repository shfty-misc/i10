; RootContainer - Represents the tree root, contains WorkspaceContainers
class RootContainer extends Container
{
    unmanagedWindows := []

    prevMousePosition := { x: 0, y: 0 }
    prevHoveredContainer := ""

    __New(ByRef parent)
    {
        global Orientation_H
        global Layout_Split
        
        base.__New(parent)
    }

    Update()
    {
        global treeRoot
        global Orientation_H
        global Layout_Split

        if(this.children.Length() == 0)
        {
            newSplit := new SplitContainer(this, Orientation_H, Layout_Split)
            this.AddChild(newSplit)
            this.SetActiveChild(newSplit)
        }

        ; Enumerate monitors and create corresponding MonitorContainers
        SysGet, monCount, MonitorCount
        rootSplit := this.GetActiveChild()

        ; If the monitor count has changed        
        if(monCount != rootSplit.GetChildCount())
        {
            ; Clear root split children
            rootSplit.ClearChildren()

            ; Create a monitor container for each physical monitor
            monitors := []
            Loop, % monCount
            {
                newMonitor := new MonitorContainer(this, A_Index)
                monitors.Push(newMonitor)
            }

            ; Loop through the created monitors, sort them left-to-right and add them to the root split in order
            furthestLeft := 0
            furthestLeftIndex := -1
            while(monitors.Length() > 0)
            {
                for index, element in monitors
                {
                    candidateLeft := element.getWorkArea().left
                    if(index == 1 || candidateLeft < furthestLeft)
                    {
                        furthestLeft := candidateLeft
                        furthestLeftIndex := index
                    }
                }
                
                furthestLeftMonitor := monitors[furthestLeftIndex]
                monitors.RemoveAt(furthestLeftIndex)
                rootSplit.AddChild(furthestLeftMonitor)

                if(GetMonitorIsPrimary(element.monitor))
                {
                    rootSplit.SetActiveChild(element)
                }
            }
        }
        
        ; Enumerate windows and create correspdonding WindowContainers
        WinGet, id, list
        Loop, %id%
        {
            hwnd := id%A_Index%

            ; Skip windows with no title or class
            windowTitle := GetWindowTitle(hwnd)
            windowClass := GetWindowClass(hwnd)
            if(windowTitle == "" && windowClass == "")
            {
                continue
            }

            if(ShouldExcludeWindow(hwnd))
            {
                global mainGui
                global guiUnmanaged
                
                if(IndexOf(hwnd, this.unmanagedWindows) == -1)
                {
                    LogMessage("Excluding window " . hwnd . ", Title: " . GetWindowTitle(hwnd) . ", Class: " . GetWindowClass(hwnd))

                    this.unmanagedWindows.Push(hwnd)

                    Gui, % mainGui . ":Default"
                    Gui, % mainGui . ":ListView", guiUnmanaged
                    
                    LV_Add(, hwnd, windowTitle, windowClass)
                    LV_ModifyCol(1)
                    LV_ModifyCol(2)
                    LV_ModifyCol(3, "AutoHdr")
                }
            }
            else
            {
                if(GetWindowWithHwnd(this, hwnd) == "")
                {
                    activeMonitor := rootSplit.GetActiveChild()
                    
                    newWindow := new WindowContainer("", hwnd)
                    LogMessage("Creating window container for " . hwnd)
                    LogMessage("Title: " . windowTitle . ", Class: " . windowClass)

                    if(ShouldFloatWindow(hwnd))
                    {
                        LogMessage("Setting up window " . hwnd . " as floating")
                        activeWorkspace := activeMonitor.GetActiveChild()

                        SetWindowAlwaysOnTop(hwnd)

                        ; Iterate through monitors
                        for mi, monitor in this.GetActiveChild().children
                        {
                            if(monitor.DisplayAreaContainsWindow(hwnd, true))
                            {
                                activeWorkspace := monitor.GetActiveChild()
                                activeWorkspace.AddChildAt(0, newWindow)
                                activeWorkspace.SetActiveChild(newWindow)
                            }
                        }
                    }
                    else
                    {
                        LogMessage("Setting up window " . hwnd . " as managed")

                        sleepMs := GetSleepForWindow(hwnd)
                        if(sleepMs > 0)
                        {
                            LogMessage("Sleeping for " . sleepMs . " to allow window " . hwnd . " to initialize")
                            Sleep, % sleepMs
                        }
                        
                        ; Position window over active monitor so it will auto-arrange correctly
                        workArea := activeMonitor.GetWorkArea()
                        workAreaWidth := workArea.right - workArea.left
                        workAreaHeight := workArea.bottom - workArea.top

                        SetWindowRestored(hwnd)
                        SetWindowPosition(hwnd, workArea.left + workAreaWidth / 3, workArea.top + workAreaHeight / 3, workAreaWidth / 3, workAreaHeight / 3)
                        
                        ; Iterate through monitors
                        for mi, monitor in this.GetActiveChild().children
                        {
                            if(monitor.DisplayAreaContainsWindow(hwnd))
                            {
                                activeWorkspace := monitor.GetActiveChild()
                                leafSplit := GetLeafSplitContainer(GetWorkspaceRootSplitContainer(activeWorkspace))
                                leafSplit.AddChild(newWindow)

                                if(activeWorkspace.maximizedWindow == "")
                                {
                                    newWindow.SetActiveContainer()
                                }
                            }
                        }
                    }
                }
            }
        }

        ; Clean up unmanaged window references when they close
        hwndsToRemove := []
        for index, element in this.unmanagedWindows
        {
            if(!WinExist("ahk_id " . element))
            {
                Gui, % mainGui . ":Default"
                Gui, % mainGui . ":ListView", guiUnmanaged

                ; Cache element for removal after loop
                hwndsToRemove.Push(element)

                ; Clean up GUI hwnd
                Loop, % LV_GetCount()
                {
                    LV_GetText(guiHwnd, A_Index, 1)
                    if(guiHwnd == element)
                    {
                        LV_Delete(A_Index)
                    }
                }
            }
        }

        ; Remove cached unmanaged window hwnds
        for index, element in hwndsToRemove
        {
            this.unmanagedWindows.Remove(IndexOf(element, this.unmanagedWindows))
        }

        ; Update mouse focus
        MouseGetPos, x, y

        hoveredMonitor := GetMonitorUnderMouse()
        activeWorkspace := hoveredMonitor.GetActiveChild()
        hoveredContainer := GetContainerUnderMouse(activeWorkspace)

        if(GetOption("FocusFollowsMouse"))
        {
            if(!GetKeyState("LButton"))
            {
                if(hoveredMonitor.fullscreenWindow == "")
                {
                    hasMovedMouse := x != this.prevMousePosition.x
                    hasMovedMouse |= y != this.prevMousePosition.y
                    if(hasMovedMouse)
                    {
                        if(this.prevHoveredContainer != hoveredContainer)
                        {
                            this.UpdateFocus()
                        }
                    }
                }
            }
        }

        this.prevMousePosition.x := x
        this.prevMousePosition.y := y
        this.prevHoveredContainer := hoveredContainer

        base.Update()
    }

    UpdateFocus()
    {
        LogMessage("Updating mouse focus")
        hoveredMonitor := GetMonitorUnderMouse()
        hoveredContainer := GetContainerUnderMouse(hoveredMonitor.GetActiveChild())

        if(hoveredContainer != "")
        {
            LogMessage("Hovered container: " . hoveredContainer.ToString())
            if(hoveredContainer != GetActiveContainer())
            {
                LogMessage("Hovered container inactive, setting active")
                hoveredContainer.SetActiveContainer(false)
            }
        }
    }

    CreateFrame()
    {
    }

    UpdateFrame()
    {
    }

    HandleMouseDown()
    {
        this.UpdateFocus()
    }

    GetWorkArea()
    {
        return { left: 0, top: 0, right: 0, bottom: 0 }
    }

    ToString()
    {
        NodeString := "Root"
        
        return NodeString
    }

    IsStringBold()
    {
        return true
    }
}