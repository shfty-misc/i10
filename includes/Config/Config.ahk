#include <JSON>

#include includes/Config/OptionsConfig.ahk
#include includes/Config/WindowConfig.ahk
#include includes/Config/HotkeyConfig.ahk

LoadConfig(ByRef outputVar, filename, debugMessage = false)
{
    FileRead, fileString, % filename

    if(debugMessage)
    {
        MsgBox, % fileString
    }

    jsonObject := JSON.Load(fileString)

    if(jsonObject)
    {
        outputVar := jsonObject
        return true
    }

    return false
}

SaveConfig(config, filename)
{
    FileDelete, % filename
    FileAppend, % JSON.Dump(config,, "`t"), % filename
}

