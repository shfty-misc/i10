Recommended Windows Configuration Changes
=========================================

Free up built-in windows hotkeys
--------------------------------
Open gpedit.msc
Set Configuration/Administrative Templates/Windows Components/File Explorer/Turn Off Windows + X Hotkeys to Enabled
Set Configuration/Administrative Templates/System/Ctrl+Alt+Del Options/Remove Lock Computer to Enabled

Disable edge snapping
---------------------
Settings > System > Multitasking > Disable 'Arrange windows automatically by dragging'

Prevent windows store, photos and settings applications auto-opening
--------------------------------------------------------------------
-Disable SuperFetch via cmd
    -sc config sysmain start=disabled
    -sc stop sysmain

Hide desktop icons
------------------
-Open Settings > Personalization > Themes > Desktop icon settings.
-Deselect all checkboxes
-Click Apply

Disable animations
------------------
-Open Settings > Display
-Set Show animations in Windows to Off

Compatibility
=============

Games
-----
Certain exclusive fullscreen games may misbehave and try to remain focused at all times
This can be fixed by setting the game in question to use borderless window mode
