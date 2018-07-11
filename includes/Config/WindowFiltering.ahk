ExcludeWindow(winTitle)
{
    GroupAdd, ExcludedWindows, % winTitle

    global mainGui
    global guiExcludes
    Gui, % mainGui . ":Default"
    Gui, % mainGui . ":ListView", guiExcludes
    LV_Add(, winTitle)
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

IncludeWindow(winTitle)
{
    GroupAdd, IncludedWindows, % winTitle

    global mainGui
    global guiIncludes
    Gui, % mainGui . ":Default"
    Gui, % mainGui . ":ListView", guiIncludes
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
    if(ShouldFloatWindow(hwnd) || ShouldIncludeWindow(hwnd))
    {
        return false
    }
    
    return QueryIncludesWindow("ahk_group ExcludedWindows", hwnd)
}

ShouldFloatWindow(hwnd)
{
    return QueryIncludesWindow("ahk_group FloatingWindows", hwnd)
}

ShouldIncludeWindow(hwnd)
{
    return QueryIncludesWindow("ahk_group IncludedWindows", hwnd)
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