; Hotkeys

; Use keyboard hook for more reliable hotkeys
#UseHook

; Disable windows key
LWin & vk07::return
LWin::vk07

; Disable game bar shortcut
#g::return

; Mouse input passthrough handlers
~LButton::treeRoot.HandleMouseDown()
~WheelUp::treeRoot.HandleMouseWheel(-1)
~WheelDown::treeRoot.HandleMouseWheel(1)
