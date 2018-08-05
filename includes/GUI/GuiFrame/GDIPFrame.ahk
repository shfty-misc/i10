class GDIPFrame extends GuiFrame
{
    canvasHwnd := ""
    canvasImage := ""
    canvasGraphics := ""

    borderColor := 0xFF2C4FDB
    backgroundColor := 0xFF4A6EFF
    textColor := "FFFFFFFF"

    border := { left: 1, top: 1, right: 1, bottom: 1 }
    text := ""

    _borderBrush := ""
    _backgroundBrush := ""
    
    Init()
    {
        this.CreateCanvas(this.gui, this.height)
        GuiControlGet, canvasHwnd, hwnd, % this.gui . "Canvas"
        this.canvasHwnd := canvasHwnd

        base.Init()
    }

    CreateCanvas(gui, height)
    {
        global
        Gui, % gui . ":Add", Picture, % "x0 y0 w400 h" . height . " 0xE v" . gui . "Canvas"
    }

    Update()
    {
        base.Update()

        this.DrawGDIP()
        this.UpdateImage()
    }

    DrawGDIP()
    {

        innerX := this.border.left
        innerY := this.border.top
        innerW := this.bounds.w - this.border.left - this.border.right
        innerH := this.bounds.h - this.border.top - this.border.bottom

        borderBrush := Gdip_BrushCreateSolid(this.borderColor)
        backgroundBrush := Gdip_BrushCreateSolid(this.backgroundColor)
        
        Gdip_FillRectangle(this.canvasGraphics, borderBrush, 0, 0, this.bounds.w, this.bounds.h)
        Gdip_FillRectangle(this.canvasGraphics, backgroundBrush, innerX, innerY, innerW, innerH)
        Gdip_TextToGraphics(this.canvasGraphics, this.text, "x" . innerX + 4 . " y" innerY + 2 . " w" . innerW . " h" . innerH . " c" . this.textColor . " r0 s11 Left vCenter", "Verdana")

        Gdip_DeleteBrush(borderBrush)
        Gdip_DeleteBrush(backgroundBrush)
    }

    UpdateImage()
    {
        hBitmap := Gdip_CreateHBITMAPFromBitmap(this.canvasImage)
        SetImage(this.canvasHwnd, hBitmap)
        DeleteObject(hBitmap)
    }

    Destroy()
    {
        this.DeleteGDIPResources()

        base.Destroy()
    }

    SetPosition(x, y, w, h)
    {
        base.SetPosition(x, y, w, h)
        this.RefreshGDIPResources()
    }

    RefreshGDIPResources()
    {
        this.DeleteGDIPResources()
        this.CreateGDIPResources()
    }

    CreateGDIPResources()
    {
        this.canvasImage := Gdip_CreateBitmap(this.bounds.w, this.bounds.h)
        this.canvasGraphics := Gdip_GraphicsFromImage(this.canvasImage)
    }

    DeleteGDIPResources()
    {
        Gdip_DeleteGraphics(this.canvasGraphics)
        Gdip_DisposeImage(this.canvasImage)
    }

    SetBorderColor(newColor)
    {
        this.borderColor := newColor
    }

    SetTextColor(newColor)
    {
        this.textColor := newColor
    }
}
