class MonitorFrame extends GDIPFrame
{
    __New()
    {
        base.__New()

        WinGetPos,,,,taskbarHeight, ahk_class Shell_TrayWnd
        this.height := taskbarHeight
    }
}
