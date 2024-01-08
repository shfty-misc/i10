#include <WrapGDIP>

#include includes/Init.ahk
#include includes/AppBar.ahk
#include includes/Defs.ahk
#include includes/WindowStatics.ahk
#include includes/Tree/Tree.ahk
#include includes/Navigation.ahk
#include includes/Util.ahk
#include includes/Config/Config.ahk
#include includes/Debug/Logging.ahk
#include includes/GUI/GUI.ahk
#include includes/Main.ahk

AppBar_Init()
GUI_Init()
i10_Init()

SetTimer i10_Update, 0
SetTimer GUI_Update, 50

#include includes/Hotkeys.ahk