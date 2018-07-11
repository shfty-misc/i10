; Hotkeys

; Use keyboard hook for more reliable hotkeys
#UseHook

; Disable windows key
LWin & vk07::return
LWin::vk07

~LButton::treeRoot.HandleMouseDown()

#+e::exitapp
#+r::reload
#+p::pause

pause::pause

; Split Axis
#h::SetSplitAxis(Orientation_H)
#v::SetSplitAxis(Orientation_V)

; Layout
#e::ToggleSplitLayout()
#w::SetTabbedLayout()
#s::SetStackingLayout()

; Application launching
#Enter::Run, C:\Shortcuts\ConEmu.lnk
;#d::Send, !{Space}

; Active window manipulation
#f::ToggleActiveWindowFullscreen()
#c::CloseActiveWindow()

; Navigation
#j::Navigate(-1, Orientation_H)
#k::Navigate(1, Orientation_V)
#l::Navigate(-1, Orientation_V)
#;::Navigate(1, Orientation_H)

#Up::Navigate(-1, Orientation_V)
#Down::Navigate(1, Orientation_V)
#Left::Navigate(-1, Orientation_H)
#Right::Navigate(1, Orientation_H)

#a::FocusParentContainer()
#d::FocusChildContainer()

#g::return

; Window movement
#+Up::MoveActiveWindow(-1, Orientation_V)
#+Down::MoveActiveWindow(1, Orientation_V)
#+Left::MoveActiveWindow(-1, Orientation_H)
#+Right::MoveActiveWindow(1, Orientation_H)
#+j::MoveActiveWindow(-1, Orientation_H)
#+k::MoveActiveWindow(1, Orientation_V)
#+l::MoveActiveWindow(-1, Orientation_V)
#+;::MoveActiveWindow(1, Orientation_H)

; Workspaces
#1::SetActiveWorkspace(1)
#2::SetActiveWorkspace(2)
#3::SetActiveWorkspace(3)
#4::SetActiveWorkspace(4)
#5::SetActiveWorkspace(5)
#6::SetActiveWorkspace(6)
#7::SetActiveWorkspace(7)
#8::SetActiveWorkspace(8)
#9::SetActiveWorkspace(9)

#+1::MoveActiveWindowToWorkspace(1)
#+2::MoveActiveWindowToWorkspace(2)
#+3::MoveActiveWindowToWorkspace(3)
#+4::MoveActiveWindowToWorkspace(4)
#+5::MoveActiveWindowToWorkspace(5)
#+6::MoveActiveWindowToWorkspace(6)
#+7::MoveActiveWindowToWorkspace(7)
#+8::MoveActiveWindowToWorkspace(8)
#+9::MoveActiveWindowToWorkspace(9)

; Gap Size
#n::ModifyActiveMonitorInnerGap(5)
#+n::ModifyActiveMonitorInnerGap(-5)
#m::ModifyActiveMonitorOuterGap(5)
#+m::ModifyActiveMonitorOuterGap(-5)