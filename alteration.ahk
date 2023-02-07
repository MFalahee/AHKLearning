#IfWinActive Path of Exile
#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client
SetWorkingDir %A_ScriptDir%/ahk
; Ensures a consistent starting directory.
; loop to find affix on item, stop if one we are looking for, otherwise craft, repeat 

F2::
;this function will check the color of pixels nearby the cursor to determine if the cursor is over a currency
;if it is, it will return the name of the currency, otherwise it will return "none"

Gui, New,, CurrencyGUI
Gui +AlwaysOnTop +MinSize200x200
Gui, Add, Text, vGuiHead w200, Is It Blue?
Gui, Add, Text, vMousePos w15, Mouse Position: NONE
Gui, Add, Text, vMouseColor w15, Mouse Color: NONE
Gui, Add, Text, vPosUp w15, Currency Color: NONE
Gui, Show, x6000 y500

Loop,
	{
		MouseGetPos, x, y
		PixelGetColor, _mouseColor, x, y
		PixelGetColor, _currencyColor, x+10, y+10
		GuiControl, Text, MousePos, %x%, %y%
		GuiControl, Text, MouseColor, %_mouseColor%
		GuiControl, Text, PosUp,%_currencyColor%
		Sleep, 100
	}
; DA721F === alteration PixelColor

F1::
	ClearLog()
	logging := 1
	affix := "life"
	timer := 150
	craft_number := 0
	setup := 1
	_Check := True
	_ItemInfo := ""
	Gui, New,,CraftingGUI
	Gui +AlwaysOnTop +MinSize200x200
	Gui, Add, Text, vGuiHead w200, Main Script
	Gui, Add, Text, vActiveWindow w200, Current Window: NONE
	Gui, Show, x6000 y500 w300 h300
	GuiControl, Text, GuiHead, Loading parameters...
	Random, currencyX, 212, 245
	Random, currencyY, 510, 550
	Random, craftingX, 639, 659
	Random, craftingY, 880, 900
	GuiControl, Text, GuiHead, Crafting
	Gui, Add, Text, vAffix w200, Looking for: %affix%
	Gui, Add, Text, vStatus w200, grabbing alterations
	Gui, Add, Text, vDosStatus w200, DOS STATUS: NONE


	if WinExist("Path of Exile") {
		WinActivate
		WinGetTitle, currentWindowTitle
		GuiControl, Text, ActiveWindow, Current Window: %currentWindowTitle%
	} else {
		MsgBox, 16,, "Path of Exile is not running!"
		ExitApp
	}
	if logging	{
		WriteLog("Starting Crafting Session")
		WriteLog("Looking for: " affix)
		WriteLog("Current Window: " currentWindowTitle)
		WriteLog("copying item under cursor @ crafting position")
	}
	_ItemInfo := CreateIteminfoFromClipboard(ItemToClipboard())
	WriteLog(_ItemInfo.Length)
	GrabCurrency(currencyX, currencyY, logging)
	Sleep, 1000
	While (_Check != 0) {
		If logging 
			WriteLog("Crafting Loop")
		If setup {
			GuiControl, Text, Status, STARTING CRAFT SESSION...
			MouseMove, %craftingX%, %craftingY%
			Send {Shift down}
			Send {Ctrl down}
			Sleep, 3000
			setup := 0
		} else {
			GuiControl, Text, Status, CRAFTING LOOP...
			If (_ItemInfo.Has(1))
				{
					If logging
						WriteLog("ItemInfo: " _ItemInfo)
					try {
						GuiControl,Text, Status, Checking Affixes...
						WriteLog("Checking Affixes...")
						
						result := FindAffix(_ItemInfo, affix, logging)
					}
					catch e{
						WriteLog("Exception thrown!")
							MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
					. "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
						}
				}
		; 	res := CraftItem()
		; 	if (res) {
		; 		Random, tzz, 500, 2000
		; 		Sleep, tzz
		; 		craft_number++
		; 	}
		; 	GuiControl, Text, Status, Craft Attempts: %craft_number%
		; 	_ItemInfo := CreateIteminfoFromClipboard(ItemToClipboard())
		_Check := 0
		}
}

Return


ItemToClipboard()
{
	WriteLog("ItemToClipboard: STARTING")
	Clipboard := ""
	output := "failed"
	SendMode, Input
	Send, +^{c}
	ClipWait
	if (Clipboard != "")
		output := ClipboardAll
	If(ErrorLevel)
		{
			WriteLog("ItemToClipboard: ErrorLevel is true, returning 0")
			return 0
		}
		else
		{
			WriteLog("ItemToClipboard: Returning successfully")
			WriteLog(%output%)
			return output
		}
}
			
CreateIteminfoFromClipboard(Clipboardcontent)
{
	WriteLog("CreateItemInfofromClipboard: STARTING")
	_Info := []
	_name_line := 0
	_affix_line := 0
	WriteLog(Clipboardcontent != "")
	If (Clipboardcontent.Has(1)) 	
	{	
		WriteLog("Inside Clipboard Loop.")
		Loop, Parse, Clipboardcontent, `n, `r
			if (_name_line) {
				_Info.Insert(A_LoopField)
				_name_line := 0
			}
			if (_affix_line) {
				_Info.Insert(A_LoopField)
			}
			If (InStr(A_LoopField, "Rarity: ")) {
				_name_line := 1
			}
			If (InStr(A_LoopField, "Item Level"))
				_affix_line := 1
	}
	return _Info
}
; Item Class: Amulets
; Rarity: Magic
; Aqua Onyx Amulet
; --------
; Quality (Attribute Modifiers): +20% (augmented)
; --------
; Requirements:
; Level: 28
; --------
; Item Level: 84
; --------
; +19 to all Attributes (implicit)
; --------
; +41 to maximum Mana

FindAffix(item, affix, logs)
{
	bool := False
	if logs
		WriteLog("FindAffix: Looping through item array.")
	Loop, item.MaxIndex()
	{
		If (A_Index < 5)
			continue
		else {
			Sleep, 20
			Line := item[A_Index]
			If InStr(Line, affix) {
				if logs
					WriteLog("FindAffix: Found affix: " affix)
					WriteLog(item[A_Index])
				bool := True
				break
			} else {
				if logs
					WriteLog("FindAffix: Did not find affix: " affix)
					WriteLog(item[A_Index])
				continue
			}
		}
		if logs {
			WriteLog("FindAffix: A_Index: " %A_Index%)
			WriteLog("FindAffix: Item: " %item%[A_Index])
		}
		return bool
	}
}

GrabCurrency(curX, curY, logs)
{	
	GuiControl, Text, GuiHead, Grabbing alterations.
	if logs
		WriteLog("GrabCurrency: STARTING")
	;Alterations -- X212-245 Y510-550
	;this function moves the mouse to the coordinates provided, and right clicks to "grab" the currency
	;potentially update to check the cursor for the currency icon as a "successful grab" check
	IfWinActive Path of Exile ahk_class POEWindowClass
	{
		MouseMove, curX, curY
		Sleep, 200
		Send, {Click %curX% %curY% Right}
		Sleep, RandomVal(100,200,logs)
		WriteLog("Currency Click")

		if (ErrorLevel) {
			if logs
				WriteLog("GrabCurrency: ErrorLevel is true, returning 0")
			return 0
		}
		else {
			if logs
				WriteLog("GrabCurrency: Returning successfully")
			return 1
		}
	}
	
}

CraftItem() {
	;this function crafts an item by shift clicking with the selected currency
	;it also updates the Gui to show the craft number
	GuiControl, Text, GuiHead, Beep Boop Bop: we click until we stop!
	IfWinActive Path of Exile ahk_class POEWindowClass
	{	
		WriteLog("Actually crafting")
		MouseGetPos, pX, pY
		PixelGetColor, _currencyCheck, pX+10, pY+10
		if (_currencyCheck != "0xDA721F")
		{
			WriteLog("Currency not found")
			return 0
		}
		else {
			WriteLog("Currency click")
			Send {Click}
			Sleep, 20
			return 1
		}
	}

}

RandomVal(min, max, logs) {
	Random, randy, %min%, %max%
	if logs
		WriteLog("RandomVal: Returning " randy)
	return randy
}

WriteLog(text) {
	FileAppend, % A_NowUTC ": " text "`n", craftinglogfile.txt ; can provide a full path to write to another directory
}

ClearLog() {
	FileDelete, craftinglogfile.txt
}
GuiClose:
GuiEscape:
Send {Shift up}
ExitApp

+Esc::
	Send {Shift up}
	ExitApp
		
