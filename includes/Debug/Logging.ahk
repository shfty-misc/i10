logLines := []
logLineCount := 100

Log_Message := "Message"
Log_Warning := "Warning"
Log_Error := "Error"

Log(level, string)
{
    if(GetOption("DebugMode"))
    {
        global mainGui
        global guiLog
        Gui, % mainGui . ":Default"
        Gui, % mainGui . ":ListView", guiLog

        LV_Add("", level, Exception("", -3).What . "()", string)
        LV_ModifyCol(1)
        LV_ModifyCol(2)
        LV_ModifyCol(3, "AutoHdr")
        LV_Modify(LV_GetCount(), "Vis")

        global logLineCount
        if(LV_GetCount() > logLineCount)
        {
            LV_Delete(1)
        }
    }
}

LogMessage(string)
{
    if(GetOption("DebugMode"))
    {
        global Log_Message
        Log(Log_Message, string)
    }
}

LogWarning(string)
{
    if(GetOption("DebugMode"))
    {
        global Log_Warning
        Log(Log_Warning, string)
    }
}

LogError(string)
{
    if(GetOption("DebugMode"))
    {
        global Log_Error
        Log(Log_Error, string)
    }
}
