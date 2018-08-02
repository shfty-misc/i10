LoadConfig(ByRef outputVar, filename)
{
    FileRead, fileString, % filename
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

#include includes/Config/OptionsConfig.ahk
#include includes/Config/WindowConfig.ahk
