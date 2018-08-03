hotkeyConfig := {}
LoadConfig(hotkeyConfig, "config/Hotkeys.json")

class FunctionObject {
    __Call(method, args*) {
        if (method = "")
            return this.Call(args*)
        if (IsObject(method))
            return this.Call(method, args*)
    }
}

class HotkeyFunction extends FunctionObject {
    method := -1
    params := []

    __New(method, params)
    {
        this.method := Func(method)
        this.params := params
    }

    Call() {
        this.method.Call(this.params*)
    }
}

for hotkeyObjIndex, hotkeyObj in hotkeyConfig.Hotkeys
{
    for hotkeyIndex, hotkey in hotkeyObj.Hotkeys
    {
        hotkeyFunc := new HotkeyFunction(hotkeyObj.Function, hotkeyObj.Params)
        Hotkey, % hotkey, % hotkeyFunc
    }
}
