; WindowContainer node - Contains a window
class WindowContainer extends Container
{
    hwnd := ""
    hidden := false

    guiTreeTitle := 0
    guiTreeClass := 0
    guiTreeWorkArea := 0

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
            DetectHiddenWindows, Off
            return
        }
        else if(!this.hidden && GetWindowIsHidden(this.hwnd))
        {
            this.Destroy(false)
            DetectHiddenWindows, Off
            return
        }
        else
        {
            DetectHiddenWindows, Off
        }

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

    Destroy(showWindow = true)
    {
        if(showWindow)
        {
            ; Unhide window
            this.SetShown()
        }

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
            this.frame := new GDIPFrame()
            this.frame.border.top := 0
            this.frame.border.bottom := 0
        }
    }

    UpdateFrame()
    {
        base.UpdateFrame()

        windowTitle := GetWindowTitle(this.hwnd)
        if(windowTitle != this.frame.titleText)
        {
            titleText := windowTitle

            if(GetWindowIsPopup(this.hwnd))
            {
                titleText .= " (Popup)"
            }

            if(GetWindowIsChild(this.hwnd))
            {
                titleText .= " (Child)"
            }

            this.frame.text := titleText
        }
    }

    GetFrameArea()
    {
        global Layout_Tabbed
        global Orientation_H
        global Orientation_V

        frameArea := this.GetWorkArea()
        frameArea.bottom := frameArea.top + this.frame.height

        if(this.parent.layout == Layout_Tabbed)
        {
            if(this.parent.orientation == Orientation_H)
            {
                tabWidth := frameArea.right - frameArea.left
                frameWidth := Floor(tabWidth / this.parent.children.Length())

                frameArea.left := frameArea.left + frameWidth * (this.GetIndex() - 1)
                frameArea.right := frameArea.left + frameWidth
            }
            else if(this.parent.orientation == Orientation_V)
            {
                frameArea.top += this.frame.height * (this.GetIndex() - 1)
                frameArea.bottom += this.frame.height * (this.GetIndex() - 1)
            }
        }

        return frameArea
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
        this.hidden := true
        SetWindowHidden(this.hwnd)
    }

    SetShown()
    {
        this.hidden := false
        SetWindowShown(this.hwnd)
    }

    UpdateVisibility()
    {
        ; Show/Hide based on active workspace
        global Layout_Tabbed
        isTab := this.parent.layout == Layout_Tabbed
        isActiveTab := isTab && this.IsActive()

        parentWorkspace := this.GetParentWorkspace()
        parentMonitor := this.GetParentMonitor()

        if(parentWorkspace != parentMonitor.GetActiveChild())
        {
            if(!this.hidden)
            {
                this.SetHidden()
            }
        }
        else
        {
            if(this.hidden)
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
                    SetWindowShown(this.frame.hwnd)
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

        if(GetWindowIsMinimized(this.hwnd) || GetWindowIsMaximized(this.hwnd))
        {
            this.SetRestored()
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
        windowArea := this.GetWindowArea()
        windowAreaWidth := windowArea.right - windowArea.left
        windowAreaHeight := windowArea.bottom - windowArea.top
        
        winPos := GetWindowPosition(this.hwnd)
        if(windowArea.left != winPos.x || windowArea.top != winPos.y || windowAreaWidth != winPos.w || windowAreaHeight != winPos.h)
        {
            SetWindowPosition(this.hwnd, windowArea.left, windowArea.top, windowAreaWidth, windowAreaHeight)
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
                windowArea := this.GetWindowArea()

                WinGetPos,x,y
                if(x != windowArea.left || y != windowArea.top)
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

    GetWindowArea()
    {
        offset := GetWindowGapOffset(this.hwnd)

        workArea := this.GetWorkArea()
        workAreaWidth := workArea.right - workArea.left
        workAreaHeight := workArea.bottom - workArea.top

        tx := workArea.left - offset.left
        ty := workArea.top - offset.top
        tw := workAreaWidth + offset.left + offset.right
        th := workAreaHeight + offset.top + offset.bottom

        if(this.GetParentWorkspace().maximizedWindow != this)
        {
            height := 0
            
            global Layout_Tabbed
            global Orientation_V
            if(this.parent.layout == Layout_Tabbed && this.parent.orientation == Orientation_V)
            {
                height := this.frame.height * this.parent.children.Length()
            }
            else
            {
                height := this.frame.height
            }

            ty += height
            th -= height
        }

        return { left: tx, top: ty, right: tx + tw, bottom: ty + th }
    }

    WorkAreaContainsPoint(x,y)
    {
        if(this.hidden)
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
    }

    MarkGUIDirty()
    {
        TV_Delete(this.guiTreeTitle)
        this.guiTreeTitle := 0

        TV_Delete(this.guiTreeClass)
        this.guiTreeClass := 0

        TV_Delete(this.guiTreeWorkArea)
        this.guiTreeWorkArea := 0

        base.MarkGUIDirty()
    }
}
