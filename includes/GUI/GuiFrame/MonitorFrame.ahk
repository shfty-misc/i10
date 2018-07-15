class MonitorFrame extends TextFrame
{
    __New()
    {
        base.__New()

        WinGetPos,,,,taskbarHeight, ahk_class Shell_TrayWnd
        this.height := taskbarHeight
    }

    PopulateText()
    {
        base.PopulateText()
        
        this.AddTextElement(this.gui, "Network")
        this.AddTextElement(this.gui, "Volume")
        this.AddTextElement(this.gui, "Time")
    }

    Update()
    {
        base.Update()

        this.SetTextElement(GetNetworkIsConnected() ? "Connected" : "No Connection", "Network")
        this.SetTextElement(Floor(GetSystemVolume()) . "%", "Volume")
        FormatTime, formattedTime, A_Now, h:mm tt
        this.SetTextElement(formattedTime, "Time")

        this.SetTextElementColor(this.GetTextElementColor("Title"), "Network")
        this.SetTextElementColor(this.GetTextElementColor("Title"), "Volume")
        this.SetTextElementColor(this.GetTextElementColor("Title"), "Time")
    }
}
