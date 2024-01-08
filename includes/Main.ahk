#include <JSON>

isPaused := false
treeRoot := new RootContainer("")

i10_Init()
{
    global treeRoot
    treeRoot.Init()
}

; Main Loop
i10_Update()
{
    global isPaused
    if(!isPaused)
    {
        global treeRoot
        treeRoot.Update()
    }
}

i10_Run(target)
{
    Run, % target
}

i10_Pause()
{
    global isPaused
    isPaused := !isPaused
}

i10_Restart()
{
    Reload
}

i10_Exit()
{
    ExitApp
}

i10_Shutdown()
{
    global treeRoot
    treeRoot.Destroy()
}

i10_SaveState()
{
    global treeRoot
    JSON.Dump(treeRoot,, "`t")
}

OnExit("i10_Shutdown")
