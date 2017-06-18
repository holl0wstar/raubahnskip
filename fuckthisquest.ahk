; ==========================
; SCRIPT SETTINGS

; How often the script presses {Numpad0}.
TIMER_INTERVAL := 600

; The keybind to start or stop the script - Can change to anything you might want.
TOGGLE_HOTKEY := "F6"

; Confirm keybind - DOESN'T WORK. NO CLUE WHY.
; If you want to change these, you'll have to do manually by digging into the script.
; Confirm = {Numpad0}
; LeftDPad = {{Numpad4}}
; Those are the defaults
;CONFIRM_HOTKEY := "{Numpad0}"
; LEFTDPAD_HOTKEY := "{{Numpad4}}"

; Some of this mumbo jumbo made by Sky, but most of the gruntwork done by Talim.
; ==========================
Counter := 0
; ==========================
; Counter stuff


setupScript:
    Gui +LastFound +AlwaysOnTop +ToolWindow -Caption
    Gui, Color, 000000
    Gui, Font, s14 q3
    Gui, Add, Text, vtxtRunning cLime w600
    Gui, Add, Text, vtxtStatus cLime w600
    Gui, Add, Text, vtxtBusy cLime w600
    Gui, Add, Text, vtxtCounter cLime w600
    WinSet, TransColor, 000000 150
    Gui, Show, x1300 y500 NoActivate
    GuiControl,, txtRunning, Starting up

    SetTimer timerLoop, %TIMER_INTERVAL%, Period
    Hotkey %TOGGLE_HOTKEY%, toggleScript
return

toggleScript:
    bToggle := !bToggle
return

timerLoop:
	SetTimer timerLoop, %TIMER_INTERVAL%, Off
    if (!bToggle)
    {
        GuiControl,, txtRunning, Script stopped.  Press %TOGGLE_HOTKEY% to start.
        MouseGetPos, xpos, ypos 

    	GuiControl,, txtStatus, %xpos% %ypos%
        GuiControl,, txtBusy, 
        Return
    }
    else
    {
        GuiControl,, txtRunning, Script active.  Press %TOGGLE_HOTKEY% to stop.
	    GuiControl,, txtCounter, Amount of times this script has run: %Counter%.
    }

    doQuestStep()

    SetTimer timerLoop, %TIMER_INTERVAL%, On
return

doQuestStep()
{
    CoordMode, Pixel, Screen
    WinGetPos gamePosX, gamePosY, gameWidth, gameHeight, ahk_class FFXIVGAME

    ;Duty dialog search rect
    dutyPosX1 := (gamePosX + (gameWidth / 2)) - 200
    dutyPosX2 := (gamePosX + (gameWidth / 2)) + 200
    dutyPosY1 := (gamePosY + (gameHeight / 2)) - 200
    dutyPosY2 := (gamePosY + (gameHeight / 2)) + 200
    ;dutyPosX1 := 1500
    ;dutyPosX2 := 1700
    ;dutyPosY1 := 600
    ;dutyPosY2 := 700

    ;Skip cutscene dialog search rect
    skipPosX1 := (gamePosX + (gameWidth / 2)) - 200
    skipPosX2 := (gamePosX + (gameWidth / 2)) + 200
    skipPosY1 := (gamePosY + (gameHeight / 2)) - 200
    skipPosY2 := (gamePosY + (gameHeight / 2)) + 200

    PixelGetColor, color, gamePosX, gamePosX
    GuiControl,, txtStatus, %color%.

    ; Check if we're in a cutscene
	if color = 0x000000
	{
	    GuiControl,, txtBusy, In cutscene.
    	CoordMode, Pixel, Screen
    	ImageSearch, posX, posY, skipPosX1, skipPosY1, skipPosX2, skipPosY2, *55 skip.png
    	if ErrorLevel = 0
    	{
        	GuiControl,, txtBusy, Skipping cutscene.
			ControlSend, , {Numpad0}, FINAL FANTASY XIV
        	Sleep 500
        	ControlSend, , {Numpad0}, FINAL FANTASY XIV
		    Sleep 100
		    Counter:= global Counter+1
    	}
    	else
		ControlSend, , {Escape}, FINAL FANTASY XIV

    	Return
	}

	; Close system menu if we accidentally opened it
	ImageSearch, posX, posY, skipPosX1, skipPosY1, skipPosX2, skipPosY2, *55 system.png
    if ErrorLevel = 0
    {
        GuiControl,, txtBusy, Closing system menu.
		ControlSend, , {Escape}, FINAL FANTASY XIV
		Return
    }

    ; Check for the duty dialog
    CoordMode, Pixel, Screen
    ImageSearch, posX, posY, dutyPosX1, dutyPosY1, dutyPosX2, dutyPosY2, *55 duty.png
    if ErrorLevel = 0
    {
        GuiControl,, txtBusy, Found duty dialog.  Commencing duty.
		ControlSend, , {Numpad4}, FINAL FANTASY XIV
        Sleep 500
        ControlSend, , {Numpad0}, FINAL FANTASY XIV
        Return
    }

    GuiControl,, txtBusy, Searching for duty dialog.
    ControlSend, , {Numpad0}, FINAL FANTASY XIV
}

F8::
	MsgBox, Reloading script
	Reload
return