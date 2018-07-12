; WindowContainer node - Contains a window
class WindowContainer extends Container
{
    hwnd := ""

    guiTreeTitle := 0
    guiTreeClass := 0
    guiTreeWorkArea := 0
    guiTreeSplitAxis := 0

    __New(ByRef parent, hwnd)
    {
        base.__New(parent)
        
        this.hwnd := hwnd
    }

    Update()
    {
        global treeRoot
        global Layout_Split

        ; Destroy self if the associated window no longer exists
        DetectHiddenWindows, On
        if(!WinExist("ahk_id " . this.hwnd))
        {
            this.Destroy()
            return
        }
        DetectHiddenWindows, Off

        ; Destroy self and exclude associated window if it goes fullscreen
        if(this.GetParentMonitor().fullscreenWindow != "")
        {
            return
        }

        if(this.IsFloating())
        {
            this.Update_Floating()
        }
        else
        {
            maximizedWindow := this.GetParentWorkspace().maximizedWindow

            if(this.IsBeingDragged())
            {
                if(maximizedWindow == "")
                {
                    this.UpdateDragged()
                }
            }
            else
            {
                this.UpdatePosition()
            }

        }

        this.UpdateVisibility()
        this.UpdateFocus()

        ; Call base update function
        base.Update()
    }

    Destroy()
    {
        ; Unhide window
        this.SetShown()

        ; If this is the maximized window on its parent workspace, null out the reference
        parentWorkspace := this.GetParentWorkspace()
        if(parentWorkspace.maximizedWindow == this)
        {
            parentWorkspace.maximizedWindow := ""
        }

        ; Remove self from parent
        oldParent := this.parent
        base.Destroy()
        oldParent.GetActiveChild().SetActiveContainer()
    }

    CreateFrame()
    {
        if(!this.IsFloating())
        {
            this.frame := new WindowFrame()

            ; Move frame below window
            WinSet, Bottom,, % "ahk_id " . this.frame.hwnd
        }
    }

    UpdateFrame()
    {
        base.UpdateFrame()

        windowTitle := GetWindowTitle(this.hwnd)
        if(windowTitle != this.frame.titleText)
        {
            this.frame.SetText(windowTitle)
        }
    }

    Close()
    {
        WinClose, % "ahk_id " . this.hwnd
    }

    SetMinimized()
    {
        SetWindowMinimized(this.hwnd)
    }

    SetMaximized()
    {
        SetWindowMaximized(this.hwnd)
    }

    SetRestored()
    {
        SetWindowRestored(this.hwnd)
    }

    SetHidden()
    {
        SetWindowHidden(this.frame.hwnd)
        SetWindowHidden(this.hwnd)
    }

    SetShown()
    {
        SetWindowShown(this.frame.hwnd)
        SetWindowShown(this.hwnd)
    }

    UpdateVisibility()
    {
        ; Show/Hide based on active workspace
        isHidden := GetWindowIsHidden(this.hwnd)

        global Layout_Tabbed
        isTab := this.parent.layout == Layout_Tabbed
        isActiveTab := isTab && this.parent.GetActiveChild() == this

        parentWorkspace := this.GetParentWorkspace()
        parentMonitor := this.GetParentMonitor()

        if(parentWorkspace != parentMonitor.GetActiveChild())
        {
            if(!isHidden)
            {
                this.SetHidden()
            }
        }
        else
        {
            if(isHidden)
            {
                if(parentWorkspace.maximizedWindow == "")
                {
                    if(!isTab || (isTab && isActiveTab))
                    {
                        LogMessage("Showing active workspace window " . this.hwnd)
                        this.SetShown()
                    }
                }
                else if(parentWorkspace.maximizedWindow == this)
                {
                    this.SetShown()
                }
            }
            else
            {
                if(parentWorkspace.maximizedWindow != "" && parentWorkspace.maximizedWindow != this)
                {
                    this.SetHidden()
                }

                if(isTab && !isActiveTab)
                {
                    this.SetHidden()
                }
            }
        }
    }

    UpdateFocus()
    {
        if(GetActiveContainer() == this && !GetKeyState("LButton"))
        {
            activeHwnd := WinExist("A")

            if(activeHwnd == this.frame.hwnd)
            {
                SetWindowActive(this.hwnd)
            }
            else
            {
                progmanHwnd := WinExist("ahk_class Progman")
                desktopHwnd := WinExist("ahk_class WorkerW")
                global treeRoot
                if(activeHwnd == "" || activeHwnd == progmanHwnd || activeHwnd == desktopHwnd || GetWindowWithHwnd(treeRoot, activeHwnd))
                {
                    if(activeHwnd != this.hwnd)
                    {
                        if(GetWindowTitle(activeHwnd) != "" || GetWindowTitle(activeHwnd) != "")
                        {
                            LogMessage("Active window is " . GetWindowTitle(activeHwnd) . ", Class: " . GetWindowClass(activeHwnd))
                            LogMessage("Setting window " . this.hwnd . " active")
                            SetWindowActive(this.hwnd)
                        }
                    }
                }
            }
        }
    }

    Update_Floating()
    {
        global treeRoot

        ; Iterate through monitors
        for mi, monitor in treeRoot.GetActiveChild().children
        {
            if(monitor != this.GetParentMonitor())
            {
                if(monitor.DisplayAreaContainsWindow(this.hwnd, true))
                {
                    activeWorkspace := monitor.GetActiveChild()
                    this.parent.RemoveChild(this)
                    activeWorkspace.AddChildAt(0, this)
                    this.SetActiveContainer(false)
                    return
                }
            }
        }
    }

    UpdateDragged()
    {
        this.SetActiveContainer(false)

        sourceParent := this.parent

        activeMonitor := GetMonitorUnderMouse()
        if(activeMonitor != "")
        {
            activeContainer := GetContainerUnderMouse(activeMonitor)
            if(activeContainer != "" && activeContainer != this)
            {
                if(activeContainer.__Class == "SplitContainer")
                {
                    sourceParent.RemoveChild(this)
                    activeContainer.AddChild(this)
                    this.SetActiveContainer(false)
                }
                else if(activeContainer.__Class == "WindowContainer")
                {
                    if(!activeContainer.IsFloating())
                    {
                        activeSplit := activeContainer.GetParentSplit()
                        if(sourceParent == activeSplit)
                        {
                            if(activeContainer.GetIndex() > this.GetIndex())
                            {
                                activeSplit.ReplaceChild(activeContainer, this)
                                activeSplit.SetActiveChild(this)
                                sourceParent.ReplaceChild(this, activeContainer)
                                sourceParent.SetActiveChild(activeContainer)
                            }
                            else if(activeContainer.GetIndex() < this.GetIndex())
                            {
                                sourceParent.ReplaceChild(this, activeContainer)
                                sourceParent.SetActiveChild(activeContainer)
                                activeSplit.ReplaceChild(activeContainer, this)
                                activeSplit.SetActiveChild(this)
                            }
                        }
                        else
                        {
                            activeSplit.ReplaceChild(activeContainer, this)
                            activeSplit.SetActiveChild(this)
                            sourceParent.ReplaceChild(this, activeContainer)
                            sourceParent.SetActiveChild(activeContainer)
                        }
                    }
                }
            }
        }
    }

    UpdatePosition()
    {
        ; Move window into work area
        offset := GetWindowGapOffset(this.hwnd)

        workArea := this.GetWorkArea()
        workAreaWidth := workArea.right - workArea.left
        workAreaHeight := workArea.bottom - workArea.top

        tx := workArea.left - offset.left
        ty := (workArea.top - offset.top)
        tw := workAreaWidth + offset.left + offset.right
        th := (workAreaHeight + offset.top + offset.bottom)

        if(this.GetParentWorkspace().maximizedWindow != this)
        {
            ty += this.frame.height
            th -= this.frame.height
        }
        
        winPos := GetWindowPosition(this.hwnd)
        if(tx != winPos.x || ty != winPos.y || tw != winPos.w || th != winPos.h)
        {
            SetWindowPosition(this.hwnd, tx, ty, tw, th)
        }
    }
    
    IsFloating()
    {
        return this.parent.__Class == "WorkspaceContainer"
    }

    IsBeingDragged()
    {
        if(GetWindowIsActive(this.hwnd))
        {
            if(GetKeyState("LButton"))
            {
                offset := GetWindowGapOffset(this.hwnd)

                workArea := this.GetWorkArea()
                workAreaWidth := workArea.right - workArea.left
                workAreaHeight := workArea.bottom - workArea.top

                tx := workArea.left - offset.left
                ty := workArea.top - offset.top + this.frame.height

                WinGetPos,x,y
                if(x != tx || y != ty)
                {
                    return true
                }
            }
        }

        return false
    }

    GetWorkArea()
    {
        global Layout_Split
        global Layout_Tabbed
        global Orientation_H
        global Orientation_V

        if(this.IsFloating())
        {
            winPos := GetWindowPosition(this.hwnd)
            return { left: winPos.x, top: winPos.y, right: winPos.x + winPos.w, bottom: winPos.y + winPos.h }
        }

        if(this == this.GetParentWorkspace().maximizedWindow)
        {
            return this.GetParentWorkspace().GetWorkArea()
        }

        workArea := base.GetWorkArea()

        return workArea
    }

    WorkAreaContainsPoint(x,y)
    {
        if(GetWindowIsHidden(this.hwnd))
        {
            return false
        }

        return base.WorkAreaContainsPoint(x,y)
    }

    ToString()
    {
        NodeString := "Window " this.hwnd

        if(this == this.GetParentWorkspace().maximizedWindow)
        {
            NodeString .= " (Maximized)"
        }

        return NodeString
    }

    IsStringBold()
    {
        return this == GetActiveContainer()
    }

    PopulateGUI(guiParent)
    {
        base.PopulateGUI(guiParent)

        this.guiTreeTitle := TV_Update(this.guiTreeTitle, this.guiTreeEntry, "Title: " . GetWindowTitle(this.hwnd), "")
        this.guiTreeClass := TV_Update(this.guiTreeClass, this.guiTreeEntry, "Class: " . GetWindowClass(this.hwnd), "")

        workArea := this.GetWorkArea()
        this.guiTreeWorkArea := TV_Update(this.guiTreeWorkArea, this.guiTreeEntry, "Work Area: " . workArea.left . ", " . workArea.top . ", " . workArea.right . ", " . workArea.bottom, "")

        this.guiTreeSplitAxis := TV_Update(this.guiTreeSplitAxis, this.guiTreeEntry, "Split Axis: " . this.GetSplitAxis(), "")
    }

    MarkGUIDirty()
    {
        TV_Delete(this.guiTreeTitle)
        this.guiTreeTitle := 0

        TV_Delete(this.guiTreeClass)
        this.guiTreeClass := 0

        TV_Delete(this.guiTreeWorkArea)
        this.guiTreeWorkArea := 0

        TV_Delete(this.guiTreeSplitAxis)
        this.guiTreeSplitAxis := 0

        base.MarkGUIDirty()
    }
}
