appBarData := ""

AppBar_Init()
{
    WinGetPos, appX,appY,appW,appH, ahk_id %A_ScriptHwnd%

    appBarMessage := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" )

    global appBarData
    VarSetCapacity(appBarData, 36, 0)
    Off := NumPut(36, appBarData)
    Off := NumPut(A_ScriptHwnd, Off+0 )
    Off := NumPut(appBarMessage, Off+0 )
    Off := NumPut(1, Off+0 )
    Off := NumPut(appX, Off+0 )
    Off := NumPut(appY, Off+0 )
    Off := NumPut(appW, Off+0 )
    Off := NumPut(appH, Off+0 )
    Off := NumPut(1, Off+0 )

    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_NEW:=0x0), UInt, &appBarData) 
    OnMessage(appBarMessage, "AppBar_Callback")  
}

AppBar_Callback(wParam, lParam, msg, hwnd) {
    if(wParam == 2)
    {
        global treeRoot

        if(lParam == 1)
        {
            LogMessage("Fullscreen window activated")

            WinGet, id, list
            Loop, %id%
            {
                hwnd := id%A_Index%
                window := GetWindowWithHwnd(treeRoot, hwnd)
                if(window != "")
                {
                    if(GetWindowIsFullscreen(hwnd))
                    {
                        window.GetParentMonitor().fullscreenWindow := window
                    }
                }
            }
        }
        else
        {
            LogMessage("Fullscreen window deactivated")
            for index, element in treeRoot.GetActiveChild().children
            {
                fullscreenWindow := element.fullscreenWindow
                if(fullscreenWindow != "")
                {
                    if(!GetWindowIsFullscreen(hwnd))
                    {
                        element.fullscreenWindow := ""
                    }
                }
            }
        }
    }
}

AppBar_Shutdown()
{
    global appBarData
    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_REMOVE := 0x1), UInt, &appBarData)
}

OnExit("AppBar_Shutdown")