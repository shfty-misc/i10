; OS window manipulation functions

GetWindowPosition(hwnd)
{
    WinGetPos, x, y, w, h, ahk_id %hwnd%
    return { x: x, y: y, w: w, h: h }
}

GetWindowCenter(hwnd)
{
    windowPosition := GetWindowPosition(hwnd)
    return { x: windowPosition.x + (windowPosition.w / 2), y: windowPosition.y + (windowPosition.h / 2) }
}

GetWindowTitle(hwnd)
{
    WinGetTitle, winTitle, ahk_id %hwnd%
    return winTitle
}

GetWindowClass(hwnd)
{
    WinGetClass, winClass, ahk_id %hwnd%
    return winClass
}

GetWindowIsActive(hwnd)
{
    return hwnd == WinExist("A")
}

GetWindowIsMaximized(hwnd)
{
    WinGet, winMinMax, MinMax, ahk_id %hwnd%
    return winMinMax == 1
}

GetWindowIsMinimized(hwnd)
{
    WinGet, winMinMax, MinMax, ahk_id %hwnd%
    return winMinMax == -1
}

GetWindowIsPopup(hwnd)
{
    WinGet, winStyle, Style, ahk_id %hwnd%
    return (winStyle & 0x80000000) != 0
}

GetWindowIsChild(hwnd)
{
    WinGet, winStyle, Style, ahk_id %hwnd%
    return winStyle & 0x40000000
}

GetWindowAlwaysOnTop(hwnd)
{
    WinGet, winExStyle, ExStyle, ahk_id %hwnd%
    return winExStyle & 0x00000008
}

GetWindowIsFullscreen(hwnd)
{
    WinGet, style, Style, ahk_id %hwnd%
    if((style & 0x20800000) ? 0 : 1)
    {
        winPos := GetWindowPosition(hwnd)
        winRight := winPos.x + winPos.w
        winBottom := winPos.y + winPos.h

        global treeRoot
        for index, element in treeRoot.GetActiveChild().children
        {
            displayArea := element.GetDisplayArea()
            isFullscreen := true
            isFullscreen &= winPos.x == displayArea.left
            isFullscreen &= winRight == displayArea.right
            isFullscreen &= winPos.y == displayArea.top
            isFullscreen &= winBottom == displayArea.bottom
            if(isFullscreen)
            {
                return true
            }
        }
    }

    return false
}

GetWindowIsHidden(hwnd)
{
    WinGet, style, Style, % "ahk_id " . hwnd
    return style & 0x10000000 ? 0 : 1
}

SetWindowPosition(hwnd, x, y, w, h)
{
    WinMove, % "ahk_id " . hwnd,, x, y, w, h
}

SetWindowActive(hwnd)
{
    if(!GetWindowIsActive(hwnd))
    {
        WinActivate, ahk_id %hwnd%
    }
}

SetWindowInactive()
{
    if(WinExist("A") != WinExist("ahk_class Progman"))
    {
        WinActivate, ahk_class Progman
    }
}

SetWindowMaximized(hwnd)
{
    if(!GetWindowIsMaximized(hwnd))
    {
        WinMaximize, ahk_id %hwnd%
    }
}

SetWindowRestored(hwnd)
{
    if(GetWindowIsMaximized(hwnd) || GetWindowIsMinimized(hwnd))
    {
        WinRestore, ahk_id %hwnd%
    }
}

SetWindowMinimized(hwnd)
{
    if(!GetWindowIsMinimized(hwnd))
    {
        WinMinimize, ahk_id %hwnd%
    }
}

SetWindowHidden(hwnd)
{
    WinHide, % "ahk_id " . hwnd
}

SetWindowShown(hwnd)
{
    WinShow, % "ahk_id " . hwnd
}

SetWindowAlwaysOnTop(hwnd)
{
    if(!GetWindowAlwaysOnTop(hwnd))
    {
        WinSet, AlwaysOnTop, On, ahk_id %hwnd%
    }
}
