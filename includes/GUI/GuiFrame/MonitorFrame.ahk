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
        this.AddTextElement(this.gui, "Title", "w100")
        this.AddTextElement(this.gui, "Network", "x+10 y7 w100")
        this.AddTextElement(this.gui, "Volume", "x+10 y7 w100")
        this.AddTextElement(this.gui, "Time", "x+10 y7 w100")
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
