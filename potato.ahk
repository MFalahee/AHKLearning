#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Gui, myGui:New
gui, font, S12
Gui, +AlwaysOnTop
Gui, Add, GroupBox, xm ym+10  Section w150 h240, Mouse Info
Gui, Add, Text, vMyText xp+10 yp+20 w200 h200, loading--
gui, show,, GOOOO
return

^o::
Loop {
MouseGetPos, posX, posY
PixelGetColor, col, posX, posY
GuiControl, myGui:Text, MyText, X:%posX% Y:%posY% Color: %col%
;GuiControl,, MyText, X: %posX% Y: %posY% Color: %col%
Sleep 200
}
Return

Escape::
Pause

^p::
if WinExist("Farmer Against Potatoes Idle")
	WinActivate
GuiControl, myGui:Text, MyText, Potato Smash start!
sleep 200
SoundPlay, *-1
loop 
{
PixelSearch, Px, Py,715,601, 1977,1680, 0x4A96D1, 0, Fast
if ErrorLevel {
	GuiControl, myGui:Text, MyText, Potato Smash: go 1
	sleep 25
}
else {
GuiControl, myGui:Text, MyText, Potato Smash: %Px% %Py%
MouseClick, left, %Px%, %Py%, 1
sleep 25
}
PixelSearch, thisX, thisY,  715,601, 1977,1680,  0x12BDFC, 0, Fast
if ErrorLevel {
	GuiControl, myGui:Text, MyText, Potato Smash: go 2
	sleep 25
}
else {
	GuiControl, myGui:Text, MyText, Potato Smash: %thisX% %thisY%
	MouseClick, left, %thisX%, %thisY%, 1
	sleep 25
}
PixelSearch, BetterX, BetterY,  715,601, 1977,1680,  0x13C0FD, 0, Fast
if ErrorLevel {
	GuiControl, myGui:Text, MyText, Potato Smash: go 3
	sleep 10
}
else {
	GuiControl, myGui:Text, MyText, Potato Smash: %BetterX% %BetterY%
	MouseClick, left, %BetterX%, %BetterY%, 1
	sleep 25
}
GuiControl, myGui:Text, MyText, end loop sleep
sleep 25
}

