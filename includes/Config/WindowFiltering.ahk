ExcludeWindow(winTitle)
{
    GroupAdd, ExcludedWindows, % winTitle

    global mainGui
    global guiExcludes
    Gui, % mainGui . ":Default"
    Gui, % mainGui . ":ListView", guiExcludes
    LV_Add(, winTitle)
}

ExcludePopup(winTitle)
{
    GroupAdd, ExcludedPopups, % winTitle
}

ExcludeChild(winTitle)
{
    GroupAdd, ExcludedChildren, % winTitle
}

FloatWindow(winTitle)
{
    GroupAdd, FloatingWindows, % winTitle

    global mainGui
    global guiFloats
    Gui, % mainGui . ":Default"
    Gui, % mainGui . ":ListView", guiFloats
    LV_Add(, winTitle)
}

sleepList := {}
SetWindowSleep(winTitle, duration)
{
    global sleepList
    sleepList[winTitle] := duration
}

GetWindowSleepList()
{
    global sleepList
    return sleepList
}

QueryIncludesWindow(winTitle, hwnd)
{
    WinGet, id, list, % winTitle
    Loop, %id%
    {
        if(id%A_Index% == hwnd)
        {
            return true
        }
    }

    return false
}

; Window Filtering Functions
ShouldExcludeWindow(hwnd)
{
    if(GetWindowIsPopup(hwnd))
    {
        return ShouldExcludePopup(hwnd)
    }

    if(GetWindowIsChild(hwnd))
    {
        return ShouldExcludeChild(hwnd)
    }

    return QueryIncludesWindow("ahk_group ExcludedWindows", hwnd)
}

ShouldExcludePopup(hwnd)
{
    return QueryIncludesWindow("ahk_group ExcludedPopups", hwnd)
}

ShouldExcludeChild(hwnd)
{
    return QueryIncludesWindow("ahk_group ExcludedChildren", hwnd)
}

ShouldFloatWindow(hwnd)
{
    return QueryIncludesWindow("ahk_group FloatingWindows", hwnd)
}

GetSleepForWindow(hwnd)
{
    for index, element in GetWindowSleepList()
    {
        if(QueryIncludesWindow(index, hwnd))
        {
            return element
        }
    }

    return -1
}