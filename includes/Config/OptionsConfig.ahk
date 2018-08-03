defaultOptions := {}

defaultOptions["FocusFollowsMouse"] := false
defaultOptions["MouseWarping"] := MouseWarp_Window

defaultOptions["WorkspaceLayout"] := Layout_None
defaultOptions["DefaultOrientation"] := Orientation_None

defaultOptions["DefaultOuterGap"] := 0
defaultOptions["DefaultInnerGap"] := 15

defaultOptions["DebugMode"] := false

optionsConfig := {}

if(!LoadConfig(optionsConfig, "config/Options.json"))
{
    optionsConfig := defaultOptions
    SaveConfig(defaultOptions, "config/Options.json")
}

GetOption(key)
{
    global optionsConfig
    return optionsConfig[key]
}

SetOption(key, value)
{
    global optionsConfig
    optionsConfig[key] := value
}
