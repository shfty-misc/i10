; Navigation functions
GetAdjacentContainer(ByRef container, delta, axis)
{
    activeSplit := container.GetParentSplit()
    if(activeSplit.orientation == axis)
    {
        activeIndex := activeSplit.GetActiveChildIndex()
        activeIndex += delta
        if(activeIndex < 1 || activeIndex > activeSplit.GetChildCount())
        {
            return ""
        }

        return activeSplit.children[activeIndex]
    }

    return ""
}

Navigate(delta, axis, move = false)
{
    LogMessage("Navigation delta " . delta . " , axis " . axis . " move? " . move)
    global treeRoot
    global Layout_Split

    ; Choose either the active window or the active leaf split
    sourceContainer := GetActiveContainer()

    if(sourceContainer == "")
    {
        MsgBox Navigation Error: No active source container
        return
    }

    parentWorkspace := sourceContainer.GetParentWorkspace()
    if(sourceContainer == parentWorkspace.maximizedWindow)
    {
        ; If we're navigating from a maximized window, start from the parent workspace's root split
        sourceContainer := parentWorkspace.GetRootSplitContainer()
    }

    ; Walk up the tree split-by-split until we find one with an adjacent container
    targetContainer := sourceContainer
    adjacentContainer := GetAdjacentContainer(targetContainer, delta, axis)
    while(adjacentContainer == "")
    {
        parentSplit := targetContainer.GetParentSplit()
        if(parentSplit == "")
        {
            break
        }

        targetContainer := parentSplit
        adjacentContainer := GetAdjacentContainer(targetContainer, delta, axis)
    }

    ; If there is no adjacent container
    if(adjacentContainer == "")
    {
        if(move)
        {
            if(sourceContainer.__Class == "WindowContainer")
            {
                ; Set source parent orientation to navigation axis
                sourceParent := sourceContainer.parent
                prevOrientation := sourceParent.orientation
                sourceParent.orientation := axis

                ; If there are more than two children, store them in a new split using the original orientation
                if(sourceParent.children.Length() > 2)
                {
                    newSplit := new SplitContainer(sourceParent, prevOrientation, Layout_Split)

                    tempChildren := []

                    for index, element in sourceParent.children
                    {
                        if(element != sourceContainer)
                        {
                            tempChildren.Push(element)
                        }
                    }

                    sourceParent.ClearChildren()

                    if(delta < 0)
                    {
                        sourceParent.AddChild(sourceContainer)
                        sourceParent.AddChild(newSplit)
                    }
                    else if(delta > 0)
                    {
                        sourceParent.AddChild(newSplit)
                        sourceParent.AddChild(sourceContainer)
                    }

                    for index, element in tempChildren
                    {
                        newSplit.AddChild(element)
                    }
                }

                sourceContainer.SetActiveContainer()
            }
        }

        return
    }

    ; Walk down the tree from the adjacent container to find its innermost split container
    targetSplit := ""
    targetWindow := ""

    if(adjacentContainer.__Class == "WindowContainer")
    {
        targetWindow := adjacentContainer
        targetSplit := adjacentContainer.GetParentSplit()
    }
    else
    {
        if(adjacentContainer.__Class == "MonitorContainer")
        {
            targetSplit := adjacentContainer.GetActiveChild().GetRootSplitContainer()
        }
        else if(adjacentContainer.__Class == "SplitContainer")
        {
            targetSplit := adjacentContainer
        }
        
        targetWindow := targetSplit.GetActiveChild()
        while(targetWindow != "" && targetWindow.__Class != "WindowContainer")
        {
            targetSplit := targetWindow
            targetWindow := targetSplit.GetActiveChild()
        }
    }

    ; Move or activate as appropriate
    if(move)
    {
        ; Only move if this is a window container
        if(sourceContainer.__Class == "WindowContainer")
        {
            ; If we're moving to another monitor
            if(sourceContainer.GetParentMonitor() != targetSplit.GetParentMonitor())
            {
                ; Check to see if the source container is parented to the workspace's root split
                parentRootSplit := sourceContainer.GetParentWorkspace().GetRootSplitContainer()
                if(sourceContainer.GetParentSplit() != parentRootSplit)
                {
                    targetSplit := parentRootSplit
                    targetWindow := ""
                }

                targetRootSplit := targetSplit.GetParentWorkspace().GetRootSplitContainer()
                if(targetSplit != targetRootSplit)
                {
                    targetSplit := targetRootSplit
                    targetWindow := ""
                }
            }


            MoveWindow(sourceContainer, targetSplit, targetWindow, delta)

            sourceContainer.SetActiveContainer()
        }
    }
    else
    {
        activeContainer := ""
        if(targetWindow != "")
        {
            activeContainer := targetWindow
        }
        else
        {
            activeContainer := targetSplit
            SetWindowInactive()
        }
        
        activeContainer.SetActiveContainer()
    }
}

MoveWindow(ByRef sourceWindow, ByRef targetSplit, ByRef targetWindow, delta)
{
    global treeRoot

    if(sourceWindow.IsFloating())
    {
        sourceWorkArea := sourceWindow.GetWorkArea()
        sourceWidth := sourceWorkArea.right - sourceWorkArea.left
        sourceHeight := sourceWorkArea.bottom - sourceWorkArea.top
        
        targetWorkArea := targetSplit.GetWorkArea()
        targetWidth := targetWorkArea.right - targetWorkArea.left
        targetHeight := targetWorkArea.bottom - targetWorkArea.top

        SetWindowPosition(sourceWindow.hwnd, targetWorkArea.left + (targetWidth / 2) - (sourceWidth / 2), targetWorkArea.top + (targetHeight / 2) - (sourceHeight /  2), sourceWidth, sourceHeight)
    }
    else
    {
        sourceParent := sourceWindow.parent
        
        if(sourceParent == targetSplit)
        {
            ; If moving within the same parent, swap position
            sourceParent.RemoveChild(sourceWindow)
            if(delta < 0)
            {
                sourceParent.AddChildAt(targetWindow.GetIndex(), sourceWindow)
            }
            else if(delta > 0)
            {
                sourceParent.AddChildAt(targetWindow.GetIndex() + 1, sourceWindow)
            }
        }
        else
        {
            ; If moving a window out of a child and into its parent, insert adjacent to child
            containerIndex := GetContainerRootIndex(targetSplit, sourceParent)
            if(containerIndex != -1)
            {
                sourceParent.RemoveChild(sourceWindow)
                if(delta < 0)
                {
                    targetSplit.AddChildAt(containerIndex, sourceWindow)
                }
                else if(delta > 0)
                {
                    targetSplit.AddChildAt(containerIndex + 1, sourceWindow)
                }
            }
            else
            {
                ; If moving into a different container tree, append to either the start or end
                sourceParent.RemoveChild(sourceWindow)
                if(delta < 0)
                {
                    targetSplit.AddChild(sourceWindow)
                }
                else if(delta > 0)
                {
                    targetSplit.AddChildAt(1, sourceWindow)
                }
            }
        }

        sourceWindow.SetActiveContainer()
    }
            
    ; Invoke source container's update function to update its position in the tree
    sourceWindow.Update()
}

MoveActiveWindow(delta, axis)
{
    Navigate(delta, axis, true)
}

; Gap manipulation functions
ModifyActiveMonitorInnerGap(offset)
{
    activeMonitor := GetActiveMonitorContainer()
    if(activeMonitor != "")
    {
        activeMonitor.innerGap += offset
    }
}

ModifyActiveMonitorOuterGap(offset)
{
    activeMonitor := GetActiveMonitorContainer()
    if(activeMonitor != "")
    {
        activeMonitor.outerGap += offset
    }
}
