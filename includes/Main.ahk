; Tree structure
treeRoot := new RootContainer("")
isPaused := false

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

TogglePause()
{
    global isPaused
    isPaused := !isPaused
}