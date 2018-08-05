#include <Gdip>

gdipToken := -1

GDI_Init()
{
    global gdipToken
    gdipToken := Gdip_Startup()
    if(!gdipToken)
    {
        MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
        ExitApp
    }
}

GDI_Shutdown()
{
    global gdipToken
    Gdip_Shutdown(gdipToken)
}

OnExit("GDI_Shutdown")