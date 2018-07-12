class WindowFrame extends TextFrame
{
    SetPosition(x, y, w, h)
    {
        SetWindowPosition(this.hwnd, x - this.border, y, w + this.border * 2, h + this.border)
    }
}
