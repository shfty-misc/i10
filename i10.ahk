; i10 - i3 Clone for Windows

#include <JSON>

#include includes/Init.ahk
#include includes/Callbacks.ahk
#include includes/Defs.ahk
#include includes/WindowStatics.ahk
#include includes/Tree.ahk
#include includes/Navigation.ahk
#include includes/Util.ahk
#include includes/Config.ahk
#include includes/Debug/Logging.ahk
#include includes/GUI/GUI.ahk
#include includes/Main.ahk

GUI_Init()
i10_Init()

SetTimer i10_Update, 0
SetTimer GUI_Update, 50

#include includes/Hotkeys.ahk