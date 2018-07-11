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

GetWindowGapOffset(hwnd)
{
    winPos := GetWindowPosition(hwnd)
    winRight := winPos.x + winPos.w
    winBottom := winPos.y + winPos.h

    eb := GetWindowExtendedFrameBounds(hwnd)
    return { left: eb.left - winPos.x, top: eb.top - winPos.y, right: winRight - eb.right, bottom: winBottom - eb.bottom }
}

GetWindowExtendedFrameBounds(hwnd)
{
    static extendedBounds
    VarSetCapacity(extendedBounds,16,0)

    ;-- Workaround for AutoHotkey Basic
    ptrType:=(A_PtrSize==8) ? "Ptr":"UInt"

    success := DllCall("dwmapi\DwmGetWindowAttribute",ptrType, hwnd,"UInt", 9,ptrType, &extendedBounds,"UInt", 16)

    ;-- Populate the output variables
    left := NumGet(extendedBounds, 0, "Int")
    top  := NumGet(extendedBounds, 4, "Int")
    right := NumGet(extendedBounds, 8, "Int")
    bottom := NumGet(extendedBounds, 12, "Int")
    
    return {left: left, top: top, right: right, bottom: bottom}
}

GetWindowIsFullscreen(hwnd)
{
    WinGet style, Style, ahk_id %hwnd%
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

SetWindowAlwaysOnTop(hwnd)
{
    if(!GetWindowAlwaysOnTop(hwnd))
    {
        WinSet, AlwaysOnTop, On, ahk_id %hwnd%
    }
}
