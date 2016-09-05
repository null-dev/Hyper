% Picks colors from images

setscreen("graphics:max;max")
put "Welcome to RGB ColorPicker by: Andy Bao"
put "Type the file to open:"
var f : string
get f : *
put "Click and hold on where you would like to place the picture:"
var x, y, button : int
var r, g, b : real
var o := Pic.FileNew(f)
var die : boolean := false
loop
    Mouse.Where (x, y, button)
    if not button = 0 then
        View.Set("offscreenonly")
        cls
        Text.Locate (1, 1)
        var rx := x - (Pic.Width(o) div 2)
        var ry := y - (Pic.Height(o) div 2)
        put "Placing picture at: X: ", rx, ", Y: ", ry, "..."
        Pic.Draw(o, rx, ry, picCopy)
        View.Update()
        View.Set("nooffscreenonly")
        die := true
    elsif die and button = 0 then
        exit
    end if
end loop
loop
    Mouse.Where (x, y, button)
    if not button = 0 then
        Text.Locate (1, 1)
        var colorDot := View.WhatDotColor ( x, y )
        RGB.GetColor(colorDot, r, g, b)
        put "R: ", r, ", G: ", g, ", B: ", b, ", C: ", colorDot
    end if
end loop
