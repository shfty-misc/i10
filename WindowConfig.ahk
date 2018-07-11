; Window Excludes
ExcludeWindow("^$")                                                     ; Windows with no title
ExcludeWindow("Program Manager ahk_class Progman")                      ; Program manager
ExcludeWindow("ahk_class TaskListOverlayWnd")                           ; Task List Overlay
ExcludeWindow("ahk_class TaskListThumbnailWnd")                         ; Task List Thumbnail
ExcludeWindow("ahk_class MultitaskingViewFrame")                        ; Alt + Tab Overlay
ExcludeWindow("NVIDIA GeForce Overlay")                                 ; GeForce overlay
ExcludeWindow("ahk_class AutoHotkeyGUI")                                ; AHK GUI windows
ExcludeWindow("MainWindow")                                             ; RPC Print Server
ExcludeWindow("ahk_class Windows.UI.Core.CoreWindow")                   ; UWA inner containers
ExcludeWindow("ahk_class Xaml_WindowedPopupClass")                      ; UWA right-click menus
ExcludeWindow("ahk_class Qt5QWindowPopupDropShadowSaveBits")            ; P4V dropdown menus
ExcludeWindow("Wox")                                                    ; Wox

; Window Floats
FloatWindow("ahk_class OperationStatusWindow")                          ; File explorer progress dialogs
FloatWindow("SteamVR Status ahk_class Qt5QWindowIcon")                  ; SteamVR status window
FloatWindow("vrmonitor ahk_class Qt5QWindowToolSaveBits")               ; ???
FloatWindow(".* - Steam ahk_class vguiPopupWindow")                     ; Steam popups
FloatWindow("ahk_class NIOH")                                           ; Nioh
FloatWindow("RemotePC ahk_class HwndWrapper.*")                         ; RemotePC machine list
FloatWindow("NCC Touchscreen")                                          ; NCC Touch App

; Window Includes
IncludeWindow(".+ ahk_class ApplicationFrameWindow")                    ; UWA outer containers
IncludeWindow("Steam ahk_class vguiPopupWindow")                        ; Steam Main Window
IncludeWindow("Friends ahk_class vguiPopupWindow")                      ; Steam Friends
IncludeWindow(".* - Chat ahk_class vguiPopupWindow")                    ; Steam Chat
IncludeWindow(".* - qutebrowser ahk_class Qt5QWindowIcon")              ; Qutebrowser
IncludeWindow("ahk_class UnrealWindow")                                 ; Unreal Engine 4
IncludeWindow(".* - Perforce Helix P4V ahk_class Qt5QWindowIcon")       ; Perforce
IncludeWindow("Blizzard Battle.net ahk_class Qt5QWindowOwnDCIcon")      ; Battle.net
IncludeWindow(".* - RemotePC ahk_class RPCMDI_Window")                  ; RemotePC Client Window

; Window Delays
SetWindowSleep("Skype ahk_class ApplicationFrameWindow", 500)           ; Skype UWA
