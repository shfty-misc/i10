#include includes/GUI/GuiFactory.ahk
#include includes/GUI/GuiFrame/GuiFrame.ahk
#include includes/GUI/GuiFrame/TextFrame.ahk
#include includes/GUI/GuiFrame/MonitorFrame.ahk

; GUI
mainGui := ""
guiTree := ""
guiUnmanaged := ""
guiIncludes := ""
guiFloats := ""
guiExcludes := ""
guiOptions := ""
guiLog := ""

; Functions
GUI_Init()
{
    ; Set Icon
    Menu, Tray, Icon, graphics/logo.ico
    Menu, Tray, Tip, i10
    if(!GetOption("DebugMode"))
    {
        Menu, Tray, NoStandard
    }
    Menu, Tray, Add, Open, SpawnGui 
    Menu, Tray, Default, Open
    Menu, Tray, Add, Window Spy, OpenWindowSpy
    Menu, Tray, Add, Exit, Exit

    ; Setup GUI
    global guiFactory
    global mainGui
    mainGui := guiFactory.CreateGUI("+Delimiter`n +AlwaysOnTop", "main")

    ; Create tabs
    tabs := "State`nOptions`n"
    if(GetOption("DebugMode"))
    {
        tabs .= "Log"
    }
    Gui, % mainGui . ":Add", Tab, w620 h780, %tabs%

    ; Tree
    global guiTree
    Gui, % mainGui . ":Add", Text, Section, Tree
    Gui, % mainGui . ":Add", TreeView, w590 h360 vguiTree

    Gui, % mainGui . ":Add", Button,, Toggle Floating
    Gui, % mainGui . ":Add", Button, x+5, Exclude

    Gui, % mainGui . ":Add", Text, Section xs0, Unmanaged Windows
    global guiUnmanaged
    Gui, % mainGui . ":Add", ListView, w590 h260 vguiUnmanaged +NoSort +NoSortHdr, HWND`nTitle`nClass
    
    Gui, % mainGui . ":Add", Button,, Include
    Gui, % mainGui . ":Add", Button,x+5, Float

    ; Options
    Gui, % mainGui . ":Tab", 2
    Gui, % mainGui . ":Add", Text,, Options
    global guiOptions
    Gui, % mainGui . ":Add", ListView, w590 h160 vguiOptions +NoSort +NoSortHdr, Key`nValue

    global options
    for key, value in options
    {
        LV_Add("", key, value)
    }

    LV_ModifyCol(1)
    LV_ModifyCol(2, "AutoHdr")

    global guiIncludes
    Gui, % mainGui . ":Add", Text, Section, Included Windows
    Gui, % mainGui . ":Add", ListView, w590 h160 vguiIncludes +NoSort +NoSortHdr, WinTitle

    global guiFloats
    Gui, % mainGui . ":Add", Text, Section, Floated Windows
    Gui, % mainGui . ":Add", ListView, w590 h160 vguiFloats +NoSort +NoSortHdr, WinTitle

    global guiExcludes
    Gui, % mainGui . ":Add", Text, Section, Excluded Windows
    Gui, % mainGui . ":Add", ListView, w590 h160 vguiExcludes +NoSort +NoSortHdr, WinTitle

    ; Log
    if(GetOption("DebugMode"))
    {
        Gui, % mainGui . ":Tab", 3
        global guiLog
        Gui, % mainGui . ":Add", ListView, w590 h740 vguiLog +NoSort +NoSortHdr, Level`nSource`nLog
    }
}

GUI_Update()
{
    global treeRoot
    
    global guiTree
    GuiControl, -Redraw, guiTree
    treeRoot.PopulateGUI(0)
    GuiControl, +Redraw, guiTree
}

SpawnGui()
{
    global mainGui
    Gui, % mainGui . ":Show", w640 h800, i10
}

OpenWindowSpy()
{
    Run, C:\OtherPrograms\AutoHotkey\WindowSpy.ahk
}

Exit()
{
    ExitApp
}
