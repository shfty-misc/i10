; Initialization

; Reload if the user attempts to run the script while an instance already exists
#SingleInstance force

; Skip the gentle method of window activation
#WinActivateForce

; Use stricter empty variable checking
#NoEnv

; Enable warnings for debugging
#Warn

; Enable RegEx title matching for more precise window filtering
SetTitleMatchMode, RegEx

; Prevent the script from automatically sleeping
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1
SetKeyDelay, -1
SetMouseDelay, -1

; Convenient mouse coordinate space
CoordMode, Mouse, Screen

; Prevent threads from interrupting eachother to avoid data corruption
Critical

; Only three threads should ever be running - main, GUI, last pressed hotkey
#MaxThreads 3

; Only allow one active thread per hotkey
; Multiple presses will be buffered by virtue of running in Critical mode
#MaxThreadsPerHotkey 1
