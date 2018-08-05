; MonitorContainer - Represents a workspace, contains SplitContainers
class MonitorContainer extends Container
{
    monitor := ""
    outerGap := GetOption("DefaultOuterGap")
    innerGap := GetOption("DefaultInnerGap")
    guiWorkArea := 0
    fullscreenWindow := ""

    __New(ByRef parent, ByRef monitor)
    {
        base.__New(parent)

        this.monitor := monitor

        newWorkspace := new WorkspaceContainer(this, 1)
        this.AddChild(newWorkspace)
        this.SetActiveChild(newWorkspace)
    }

    Update()
    {
        if(this.fullscreenWindow == "")
        {
            base.Update()
        }
    }

    CreateFrame()
    {
        this.frame := new MonitorFrame()
        this.frame.border.left := 0
        this.frame.border.top := 0
        this.frame.border.right := 0
    }

    RemoveChildAt(childIndex, updateActive = false)
    {
        ; Override updateActive to prevent auto-switching when an empty unfocused workspace destroys itself
        base.RemoveChildAt(childIndex, false)
    }

    UpdateFrame()
    {
        base.UpdateFrame()

        this.frame.text := ""
        this.frame.text .= GetNetworkIsConnected() ? "Connected" : "No Connection"
        this.frame.text .= "     "

        this.frame.text .= Floor(GetSystemVolume()) . "%", "Volume"
        this.frame.text .= "     "

        FormatTime, formattedTime, A_Now, h:mm tt
        this.frame.text .= formattedTime
        this.frame.text .= "     "
    }

    GetDisplayArea()
    {
        monitor := this.monitor
        SysGet displayArea, Monitor, %monitor%
        return {left: displayAreaLeft, top: displayAreaTop, right: displayAreaRight, bottom: displayAreaBottom}
    }

    GetWorkArea()
    {
        monitor := this.monitor
        SysGet monWorkArea, MonitorWorkArea, %monitor%
        return {left: monWorkAreaLeft + this.outerGap, top: monWorkAreaTop + this.outerGap, right: monWorkAreaRight - this.outerGap, bottom: monWorkAreaBottom - this.outerGap}
    }

    GetFrameArea()
    {
        frameArea := this.GetWorkArea()
        frameArea.bottom := frameArea.top + this.frame.height
        return frameArea
    }

    ToString()
    {
        NodeString := GetMonitorName(this.monitor)
        if(GetMonitorIsPrimary(this.monitor))
        {
            NodeString .= " (Primary)"
        }

        return NodeString
    }

    IsStringBold()
    {
        return this == GetActiveMonitorContainer()
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

; Functions
GetMonitorName(monitor)
{
    monName := ""
    SysGet, monName, MonitorName, % monitor
    return monName
}

GetMonitorIsPrimary(monitor)
{
    monPrimary := ""
    SysGet, monPrimary, MonitorPrimary
    return monitor == monPrimary
}