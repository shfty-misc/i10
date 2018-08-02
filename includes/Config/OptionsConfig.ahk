defaultOptions := {}

defaultOptions["FocusFollowsMouse"] := false
defaultOptions["MouseWarping"] := MouseWarp_Window

defaultOptions["WorkspaceLayout"] := Layout_None
defaultOptions["DefaultOrientation"] := Orientation_None

defaultOptions["DefaultOuterGap"] := 0
defaultOptions["DefaultInnerGap"] := 15

defaultOptions["DebugMode"] := false

options := {}

if(!LoadConfig(options, "config/Options.json"))
{
    options := defaultOptions
    SaveConfig(defaultOptions, "config/Options.json")
}

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
