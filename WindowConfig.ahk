; Core
ExcludeWindow("^$")                                                    ; Windows with no title
ExcludePopup("^$")                                                     ; Popups with no title
ExcludeChild("^$")                                                     ; Children with no title

ExcludeWindow("ahk_class Shell_TrayWnd")                               ; Primary taskbar
ExcludeWindow("ahk_class Shell_SecondaryTrayWnd")                      ; Secondary taskbars
ExcludeWindow("ahk_class Windows.UI.Core.CoreWindow")                  ; UWA inner containers

ExcludePopup("ahk_class Windows.UI.Core.CoreWindow")                   ; Taskbar right-click menus
ExcludePopup("ahk_class Xaml_WindowedPopupClass")                      ; UWA right-click menus
ExcludePopup("ahk_class Qt5QWindowToolTipSaveBits")                    ; Qt tooltips
ExcludePopup("Program Manager ahk_class Progman")                      ; Program manager
ExcludePopup("ahk_class TaskListOverlayWnd")                           ; Task List Overlay
ExcludePopup("ahk_class TaskListThumbnailWnd")                         ; Task List Thumbnail
ExcludePopup("ahk_class MultitaskingViewFrame")                        ; Alt + Tab Overlay
ExcludePopup("ahk_class SysDragImage")                                 ; Drag Overlays
ExcludePopup("ahk_class AutoHotkeyGUI")                                ; AHK GUI windows
ExcludePopup("ahk_class tooltips_class32")                             ; AHK GUI Tooltips
ExcludePopup("ahk_class Qt5QWindowPopupDropShadowSaveBits")            ; Qt dropdown menus
ExcludePopup("ahk_class Qt5QWindowToolTipDropShadowSaveBits")          ; Qt tooltips
ExcludePopup("ahk_class gdkWindowTemp")                                ; GDK Popups
ExcludePopup("ahk_class SysShadow")                                    ; Shadows

FloatWindow("ahk_class OperationStatusWindow")                          ; File explorer progress dialogs
FloatWindow("ahk_class #32770")                                         ; Popup dialogs

; General
ExcludeWindow("Wox")                                                    ; Wox
ExcludeWindow("NVIDIA GeForce Overlay")                                 ; GeForce overlay
ExcludeWindow("^$ ahk_class UnrealWindow")                               ; UE4 Tooltips
ExcludeWindow("ahk_class TApplication")                                ; VS Code installer frame
ExcludeWindow("^((?!Deluge).)*$ ahk_class gdkWindowToplevel")           ; Deluge popups

ExcludePopup("ahk_class MozillaWindowClass")                            ; Firefox tooltips
ExcludePopup("^$ ahk_class UnrealWindow")                               ; UE4 Tooltips

FloatWindow("SteamVR Status ahk_class Qt5QWindowIcon")                  ; SteamVR status window
FloatWindow("vrmonitor ahk_class Qt5QWindowToolSaveBits")               ; ???
FloatWindow("RemotePC ahk_class HwndWrapper.*")                         ; RemotePC machine list

SetWindowSleep("Skype ahk_class ApplicationFrameWindow", 500)           ; Skype UWA

; STARSHIP-V2
FloatWindow("ahk_class NIOH")                                           ; Nioh

; JOSH-DEV
ExcludeWindow("MainWindow")                                             ; RPC Print Server
FloatWindow("NCC Touchscreen")                                          ; NCC Touch App
