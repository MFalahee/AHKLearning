#IfWinActive Path of Exile
#SingleInstance, force
#ClipboardTimeout, 2000
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, 1 ; 1=exact, 2=contains, 3=regex
CoordMode, Mouse, Client ; Mouse coordinates are based on the active window's client area.
SetWorkingDir %A_ScriptDir% ; 
Thread, Interrupt, 0  ; Interrupts the script if it takes longer than 0 seconds to run.
; script functions
; F1: craft items with orbs of alteration automatically in path of exile using AHK looking for a specific affix
F1::
	global logging:=1
	global affix:="Life"
	global craft_number := 0
	
	ClearLog()

	setup := 1 
	LoopSwitch := 1
	_ItemInfo := ""
	_CurrentItem := ""
	_PrevItem := ""
	_currency_clicked := 0
	Gui, New,,CraftingGUI
	Gui +AlwaysOnTop +MinSize200x200
	Gui, Add, Text, vGuiHead w200, Main Script
	Gui, Add, Text, vActiveWindow w200, Current Window: NONE
	Gui, Show, x6000 y500 w300 h300 NA
	GuiControl, Text, GuiHead, Loading parameters...
	;Random, currencyX, 212, 245
	;Random, currencyY, 510, 550
	Random, craftingX, 639, 659
	Random, craftingY, 880, 900
	GuiControl, Text, GuiHead, Crafting
	Gui, Add, Text, vAffix w200, Looking for: %affix%
	Gui, Add, Text, vStatus w200, grabbing alterations
	Gui, Add, Text, vCrafting w200, Crafting: %craft_number% attempts


	; +1 spell skill gems prefix == Magister's || Exalter's ?? +1 level of all skill gems

	if logging {
		WriteLog("Logging Enabled.")
		WriteLog("Starting Crafting Session")
		WriteLog("Looking for: " affix)
	}

	While (LoopSwitch == 1) {
		IfWinActive, Path of Exile
		 {	
			if (_currency_clicked == 0) 
			{
				GuiControl, Text, ActiveWindow, Path of Exile - MAIN
				GuiControl, Text, Status, CURRENCY PROCESS
				if (GrabCurrency(RandomVal(212, 245), RandomVal(510,550)))
					_currency_clicked := 1
				Sleep, 100
				MouseMove, craftingX, craftingY
				Sleep, 100
				Send, {Shift Down}
			}
			else {
			_CurrentItem := CreateIteminfoFromClipboard(ItemToClipboard())

		
			Sleep, RandomVal(200, 300)
			if logging
				WriteLog("MAIN: Crafting")
			Sleep, 500
			if (_CurrentItem != "" && _PrevItem != _CurrentItem)
			{
				;current item is under cursor, copy it into the clipboard
				_item_iterator := 1
				_item_line := _CurrentItem.Pop()
				if logging
				{
					WriteLog("MAIN: Item Found.")
					WriteLog("MAIN: ITERATING THROUGH ITEM LINES")
				}
				While(_CurrentItem.Length > 0)
				{
					;iterate through item lines
							_item_line := _CurrentItem.Pop()
							if (_Item_line != "") 
							{
								if (logging)
								{
									WriteLog("MAIN: Item has affix, checking if it's the one we want.")
								}
								
								try {
									if (InStr(_item_line, affix) != 0) 
									{
										if logging
										{
											WriteLog("MAIN: Item has affix: " %_item_line%)
										}
										_item_iterator := 0
										LoopSwitch := 0
										break
									}
								}
								catch e {
									if logging
										WriteLog("MAIN: Error: " e)
									;something something error
								}
							} 
							else 
							{
								;no affix found, continue
								_item_iterator := 0
							}
				}

				if (LoopSwitch == 0) {
					;this really shouldn't be possible?
					;maybe I misunderstand the timing of things
					if logging
						WriteLog("MAIN: Item has affix, breaking loop.")
					break
				}
				_currency_clicked := CraftItem()
				craft_number++
				GuiControl, Text, Crafting, Crafting: %craft_number% attempts
				_PrevItem := _CurrentItem
			}
			else 
			{
				if logging
					WriteLog("Item not found, looping again.")
				continue
			}
			}
		} 
	}
	

ItemToClipboard()
{
	; WriteLog("ItemToClipboard: STARTING")
	clipboard := ""
	Send {Ctrl down}{c down}{Ctrl up}{c up}
	ClipWait, 0.5
	if (clipboard != "") {
		; if logging
		; 	WriteLog("ItemToClipboard: Clipboard is not empty")
		output := clipboard
		return output
	} else {
		if logging
			WriteLog("ItemToClipboard: Clipboard is empty!")
		output := ""
		return output
	}
}
			
CreateIteminfoFromClipboard(content)
{
	; WriteLog("CreateItemInfofromClipboard: STARTING")
	_Info := []
	_name_line := 0
	_affix_line := 0
	if (content != "") 
	{
		if logging
				; WriteLog("CreateIteminfoFromClipboard: Starting Loop.")
		Loop, Parse, content, `n, `r
		{
			if (InStr(A_LoopField, "---"))
				continue
			else 
			{
				if (_name_line == 1) {
				if logging
					WriteLog("CreateIteminfoFromClipboard: Push:" A_LoopField)
				_Info.Push(A_LoopField)

				_name_line := 0
			}
			if (_affix_line == 1) 
			{
				if logging
					WriteLog("CreateIteminfoFromClipboard: Push: " A_LoopField)
				if (A_LoopField != "")
					_Info.Push(A_LoopField)
			}
			If (InStr(A_LoopField, "Rarity: "))
			;InStr(Haystack, Needle [, CaseSensitive?, StartingPos])
			{
				; if logging
				; 	WriteLog("CreateIteminfoFromClipboard: Found Rarity")
				if (A_LoopField != "")
					_name_line := 1
			}
			If (InStr(A_LoopField, "Item Level"))
			{
				; if logging
				; 	WriteLog("CreateIteminfoFromClipboard: Found Item Level")
				_affix_line := 1
			}
		}
	}
	return _Info
} else {
	return ""
}
}


GrabCurrency(curX, curY)
{	
	GuiControl, Text, GuiHead, Grabbing alterations.
	;Alterations -- X212-245 Y510-550
	;this function moves the mouse to the coordinates provided, and right clicks to "grab" the currency
	IfWinActive Path of Exile ahk_class POEWindowClass
	{
		MouseMove, %curX%, %curY%
		Sleep, 100
		Send, {Click %curX% %curY% Right}
		Sleep, RandomVal(100,200)
		; WriteLog("Currency Click")
		if (ErrorLevel) {
			if logging
				WriteLog("GrabCurrency: ErrorLevel is true, returning 0")
			return 0
		}
		else {
			if logging
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
		MouseGetPos, pX, pY
		PixelGetColor, _currencyCheck, pX+10, pY+10
		; DA721F === orb of alteration
		if (_currencyCheck == "0xDA721F")
		{
			Send {Click}
			Sleep, RandomVal(50, 100)

			if logging
				WriteLog("CraftItem: Clicked")
			return 1
		}
		else {
			if logging
				WriteLog("Currency not found.")
			return 0
		}
	}
	return 0
}

RandomVal(min, max) {
	Random, randy, %min%, %max%
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
		
