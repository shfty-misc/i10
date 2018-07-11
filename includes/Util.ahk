; Utility functions
IndexOf(object, ByRef array)
{
    for arrayIndex, arrayElement in array
    {
        if(arrayElement == object)
        {
            return arrayIndex
        }
    }

    return -1
}

SetTaskbarVisibile(visible)
{
    if(visible)
    {
        WinShow ahk_class Shell_TrayWnd
    }
    else
    {
        WinHide ahk_class Shell_TrayWnd
    }
}

TV_Update(treeEntry, treeParent, entryString, optionString)
{
    if(!treeEntry)
    {
        treeEntry := TV_Add(entryString, treeParent, optionString)
    }
    else
    {
        treeEntry := TV_Modify(treeEntry, optionString, entryString)
    }

    return treeEntry
}