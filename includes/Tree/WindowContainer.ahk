; WindowContainer node - Contains a window
class WindowContainer extends Container
{
    hwnd := ""

    titleBar := 0

    guiTreeTitle := 0
    guiTreeClass := 0
    guiTreeWorkArea := 0
    guiTreeSplitAxis := 0

    __New(ByRef parent, hwnd)
    {
        base.__New(parent)
        
        this.hwnd := hwnd

        if(!this.IsFloating())
        {
            this.titleBar := new WindowTitleBar()

            ; Move window above title bar
            WinSet, AlwaysOnTop, On, % "ahk_id " . this.hwnd
            WinSet, AlwaysOnTop, Off, % "ahk_id " . this.hwnd
        }
    }

    Update()
    {
        global treeRoot
        global Layout_Split

        ; Destroy self if the associated window no longer exists
        if(!WinExist("ahk_id " . this.hwnd))
        {
            this.Destroy()
            return
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
            if(GetWindowIsMaximized(this.hwnd))
            {
                this.Update_Maximized()
            }
            else if(GetWindowIsMinimized(this.hwnd))
            {
                this.Update_Minimized()
            }
            else
            {
                this.Update_Restored()
            }
        }

        ; Activate if the OS has forced focus elsewhere
        if(GetActiveContainer() == this && !GetKeyState("LButton"))
        {
            activeHwnd := WinExist("A")

            if(activeHwnd == this.titleBarHwnd)
            {
                SetWindowActive(this.hwnd)
            }
            else
            {
                progmanHwnd := WinExist("ahk_class Progman")
                desktopHwnd := WinExist("ahk_class WorkerW")
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

        ; Update title bar
        workArea := this.GetWorkArea(true)
        this.titleBar.SetPosition(workArea.left, workArea.top, workArea.right - workArea.left, workArea.bottom - workArea.top)

        windowTitle := GetWindowTitle(this.hwnd)
        if(windowTitle != this.titleBar.titleText)
        {
            this.titleBar.SetTitleText(windowTitle)
        }

        ; Call base update function
        base.Update()
    }

    Destroy()
    {
        parentWorkspace := this.GetParentWorkspace()
        if(parentWorkspace.maximizedWindow == this)
        {
            parentWorkspace.maximizedWindow := ""
        }

        this.titleBar.Destroy()
        this.titleBar := 0

        oldParent := this.parent
        this.parent.RemoveChild(this)
        oldParent.GetActiveChild().SetActiveContainer()
    }

    Close()
    {
        WinClose, % "ahk_id " . this.hwnd
    }

    SetMinimized()
    {
        SetWindowMinimized(this.titleBar.hwnd)
        SetWindowMinimized(this.hwnd)
    }

    SetMaximized()
    {
        SetWindowMinimized(this.titleBar.hwnd)
        SetWindowMaximized(this.hwnd)
    }

    SetRestored()
    {
        SetWindowRestored(this.titleBar.hwnd)
        SetWindowRestored(this.hwnd)
    }

    Update_Maximized()
    {
        ; Minimize if not on active workspace
        if(this.GetParentWorkspace() != this.GetParentMonitor().GetActiveChild())
        {
            LogMessage("Minimizing inactive workspace window " . this.hwnd)
            this.SetMinimized()
        }
        else
        {
            ; Restore if not the maximized window
            maximizedWindow := this.GetParentWorkspace().maximizedWindow
            if(maximizedWindow != this)
            {
                LogMessage("Restoring active workspace window " . this.hwnd)
                this.SetRestored()
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

        ; Minimize if not on active workspace
        if(this.GetParentWorkspace() != this.GetParentMonitor().GetActiveChild())
        {
            LogMessage("Minimizing inactive workspace window " . this.hwnd)
            this.SetMinimized()
        }
        else
        {
            if(GetWindowIsMinimized(this.hwnd))
            {
                LogMessage("Restoring active workspace window " . this.hwnd)
                this.SetRestored()
            }
        }
    }

    Update_Minimized()
    {
        global Layout_Tabbed

        ; Restore if on active workspace
        if(this.GetParentWorkspace() == this.GetParentMonitor().GetActiveChild())
        {
            ; Restore if this is the maximized window
            maximizedWindow := this.GetParentWorkspace().maximizedWindow

            if(maximizedWindow == this)
            {
                LogMessage("Maximizing active workspace maximized window " . this.hwnd)
                this.SetMaximized()
            }
            else if(maximizedWindow != "")
            {

            }
            else
            {
                parentSplit := this.GetParentSplit()
                if(parentSplit.layout != Layout_Tabbed)
                {
                    LogMessage("Restoring active workspace non-tabbed window " . this.hwnd)
                    this.SetRestored()
                }
                else if(parentSplit.GetActiveChild() == this)
                {
                    LogMessage("Restoring active workspace active window " . this.hwnd)
                    this.SetRestored()
                }
            }
        }
    }

    Update_Restored()
    {
        global Layout_Tabbed

        if(this.IsBeingDragged())
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

            return
        }
        else
        {
            ; Move window into work area
            offset := GetWindowGapOffset(this.hwnd)

            workArea := this.GetWorkArea(true)
            workAreaWidth := workArea.right - workArea.left
            workAreaHeight := workArea.bottom - workArea.top

            tx := workArea.left - offset.left
            ty := (workArea.top - offset.top) + this.titleBar.height
            tw := workAreaWidth + offset.left + offset.right
            th := (workAreaHeight + offset.top + offset.bottom) - this.titleBar.height
            
            winPos := GetWindowPosition(this.hwnd)
            if(tx != winPos.x || ty != winPos.y || tw != winPos.w || th != winPos.h)
            {
                SetWindowPosition(this.hwnd, tx, ty, tw, th)
            }

            ; Minimize if not on active workspace
            if(this.GetParentWorkspace() != this.GetParentMonitor().GetActiveChild())
            {
                LogMessage("Minimizing inactive workspace window " . this.hwnd)
                this.SetMinimized()
            }
            else
            {
                ; Restore if this is the maximized window
                maximizedWindow := this.GetParentWorkspace().maximizedWindow
                if(maximizedWindow == this)
                {
                    LogMessage("Maximizing active workspace maximized window " . this.hwnd)
                    this.SetMaximized()
                }
                else if(maximizedWindow != "")
                {
                    LogMessage("Minimizing active workspace non-maximized window " . this.hwnd)
                    this.SetMinimized()
                }
                else
                {
                    parentSplit := this.GetParentSplit()
                    if(parentSplit.layout == Layout_Tabbed && parentSplit.GetActiveChild() != this)
                    {
                        LogMessage("Minimizing active workspace unfocused tabbed window " . this.hwnd)
                        this.SetMinimized()
                    }
                }
            }
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

                workArea := this.GetWorkArea(true)
                workAreaWidth := workArea.right - workArea.left
                workAreaHeight := workArea.bottom - workArea.top

                tx := workArea.left - offset.left
                ty := workArea.top - offset.top

                WinGetPos,x,y
                if(x != tx || y != ty)
                {
                    return true
                }
            }
        }

        return false
    }

    GetWorkArea(useGapOffset = false)
    {
        global Layout_Split
        global Layout_Tabbed
        global Orientation_H
        global Orientation_V

        parentMonitor := this.GetParentMonitor()
        parentSplit := this.GetParentSplit()

        if(this.IsFloating())
        {
            winPos := GetWindowPosition(this.hwnd)
            return { left: winPos.x, top: winPos.y, right: winPos.x + winPos.w, bottom: winPos.y + winPos.h }
        }

        if(GetWindowIsMinimized(this.hwnd))
        {
            return { left: 0, top: 0, right: 0, bottom: 0 }
        }

        if(GetWindowIsMaximized(this.hwnd))
        {
            return parentMonitor.GetWorkArea()
        }

        workArea := base.GetWorkArea()

        if(useGapOffset)
        {
            innerGap := parentMonitor.innerGap
            halfGap := Floor(innerGap / 2)
            if(parentSplit.layout == Layout_Split)
            {
                if(parentSplit.orientation == Orientation_H)
                {
                    if(this.GetIndex() == 1)
                    {
                        workArea.left += innerGap
                        if(this.parent.GetChildCount() == 1)
                        {
                            workArea.right -= innerGap
                        }
                        else
                        {
                            workArea.right -= halfGap
                        }
                    }
                    else if(this.GetIndex() == this.parent.GetChildCount())
                    {
                        workArea.left += halfGap
                        workArea.right -= innerGap
                    }
                    else
                    {
                        workArea.left += halfGap
                        workArea.right -= halfGap
                    }

                    workArea.top += innerGap
                    workArea.bottom -= innerGap
                }
                else if(parentSplit.orientation == Orientation_V)
                {
                    if(this.GetIndex() == 1)
                    {
                        workArea.top += innerGap
                        if(this.parent.GetChildCount() == 1)
                        {
                            workArea.bottom -= innerGap
                        }
                        else
                        {
                            workArea.bottom -= halfGap
                        }
                    }
                    else if(this.GetIndex() == this.parent.GetChildCount())
                    {
                        workArea.top += halfGap
                        workArea.bottom -= innerGap
                    }
                    else
                    {
                        workArea.top += halfGap
                        workArea.bottom -= halfGap
                    }

                    workArea.left += innerGap
                    workArea.right -= innerGap
                }
            }
            else
            {
                workArea.left += innerGap
                workArea.top += innerGap
                workArea.right -= innerGap
                workArea.bottom -= innerGap
            }
        }

        return workArea
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
