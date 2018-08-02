windowConfig := {}
LoadConfig(windowConfig, "config/Windows.json")

; Window Filtering Functions
QueryIncludesWindow(winTitle, hwnd)
{
    WinGet, id, list, % winTitle
    Loop, %id%
    {
        candidateHwnd := id%A_Index%
        if(hwnd == candidateHwnd)
        {
            return true
        }
    }

    return false
}

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

    shouldFloat := false
    
    global windowConfig
    for index, element in windowConfig.ExcludedWindows
    {
        if(QueryIncludesWindow(element, hwnd))
        {
            return true
        }
    }

    return false
}

ShouldExcludePopup(hwnd)
{
    shouldFloat := false
    
    global windowConfig
    for index, element in windowConfig.ExcludedPopups
    {
        if(QueryIncludesWindow(element, hwnd))
        {
            return true
        }
    }

    return false
}

ShouldExcludeChild(hwnd)
{
    shouldFloat := false
    
    global windowConfig
    for index, element in windowConfig.ExcludedChildren
    {
        if(QueryIncludesWindow(element, hwnd))
        {
            return true
        }
    }

    return false
}

ShouldFloatWindow(hwnd)
{
    shouldFloat := false
    
    global windowConfig
    for index, element in windowConfig.FloatedWindows
    {
        if(QueryIncludesWindow(element, hwnd))
        {
            return true
        }
    }

    return false
}

GetSleepForWindow(hwnd)
{
    global windowConfig
    for index, element in windowConfig.SleepWindows
    {
        if(QueryIncludesWindow(index, hwnd))
        {
            return element
        }
    }

    return -1
}