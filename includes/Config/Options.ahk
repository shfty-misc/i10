options := {}

options["FocusFollowsMouse"] := false
options["MouseWarping"] := MouseWarp_Window
options["WorkspaceLayout"] := Layout_None
options["DefaultOrientation"] := Orientation_None
options["DefaultOuterGap"] := 0
options["DefaultInnerGap"] := 15
options["DebugMode"] := false

GetOption(key)
{
    global options
    return options[key]
}

SetOption(key, value)
{
    global options
    options[key] := value
}