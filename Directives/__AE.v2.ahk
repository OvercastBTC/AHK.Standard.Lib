﻿/************************************************************************
 * function ......: Auto Execution (AE)
 * @description ..: A work in progress (WIP) of standard AE setup(s)
 * @file AE.v2.ahk
 * @author OvercastBTC
 * @date 2023.09.18
 * @version 1.0.0
 * @ahkversion v2+
 ***********************************************************************/
; --------------------------------------------------------------------------------
/************************************************************************
 * function ...........: Resource includes for .exe standalone
 * @author OvercastBTC
 * @date 2023.08.15
 * @version 3.0.2
 ***********************************************************************/
;@Ahk2Exe-IgnoreBegin
#Include <CheckUpdate\ScriptVersionMap>
version :=  ScriptVersion.ScriptVersionMap['main'] 
;@Ahk2Exe-IgnoreEnd
SetVersion := "3.0.0" ; If quoted literal not empty, do 'SetVersion'
;@Ahk2Exe-Nop
;@Ahk2Exe-Obey U_V, = "%A_PriorLine~U)^(.+")(.*)".*$~$2%" ? "SetVersion" : "Nop"
;@Ahk2Exe-%U_V% %A_PriorLine~U)^(.+")(.*)".*$~$2%
; --------------------------------------------------------------------------------
#Requires AutoHotkey v2+
#Warn All, OutputDebug
#SingleInstance Force
#WinActivateForce
; --------------------------------------------------------------------------------
#MaxThreads 255 ; Allows a maximum of 255 instead of default threads.
#MaxThreadsBuffer true
A_MaxHotkeysPerInterval := 1000
; --------------------------------------------------------------------------------
SendMode("Input")
SetWorkingDir(A_ScriptDir)
SetTitleMatchMode(2)
; --------------------------------------------------------------------------------
_AE_DetectHidden(true)
_AE_SetDelays(-1)
_AE_PerMonitor_DPIAwareness()
; --------------------------------------------------------------------------------
;@Ahk2Exe-IgnoreBegin
/**
 * Function: Includes
 */
#Include <App\Autohotkey>
#Include <Extensions\Array>
#Include <Extensions\Gui>
#Include <Extensions\Initializable>
#Include <Extensions\Json>
#Include <Extensions\Map>
#Include <Extensions\Sort>
#Include <Extensions\String>
#Include <Tools\Info>
;@Ahk2Exe-IgnoreEnd

#HotIf WinActive(A_ScriptName)
	~^s:: Run(A_ScriptName)
#HotIf
; --------------------------------------------------------------------------------
_AE_DetectHidden(bool?)
{
    bool := true
	DetectHiddenText(bool)
    DetectHiddenWindows(bool)
}
; --------------------------------------------------------------------------------
_AE_SetDelays(n?) {
	n := -1
	SetControlDelay(n)
	SetMouseDelay(n)
	SetWinDelay(n)
}
; --------------------------------------------------------------------------------
_AE_PerMonitor_DPIAwareness()
{
	MaximumPerMonitorDpiAwarenessContext := VerCompare(A_OSVersion, ">=10.0.15063") ? -4 : -3
	Global DefaultDpiAwarenessContext := MaximumPerMonitorDpiAwarenessContext, A_DPI := DefaultDpiAwarenessContext
	try
		DllCall("SetThreadDpiAwarenessContext", "ptr", MaximumPerMonitorDpiAwarenessContext, "ptr")
	catch 
		DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
	else
		DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
	return A_DPI
}
__AE_CopyLib() {
	local Lib := A_MyDocuments '\AutoHotkey\Lib'
	If !(DirExist(Lib)) {
		DirCreate(Lib)
	}
	FileCopy(A_ScriptName, Lib A_ScriptName, 1)
}

; $^c:: clip_it() ; Clip hotkey
; $^b:: clip_it(1) ; Paste last clip hotkey

clip_it(send_clip := 0) {
	Static last_clip := "" ; Track last clipboard
	If send_clip ; If send_clip is true
	{
		bak := ClipboardAll() ; Backup current clipboard
		A_Clipboard := last_clip ; Put last_clip onto clipboard
		Send('^v') ; Paste
		While DllCall("GetOpenClipboardWindow") { ; If clipboard still in use (long paste)
			Sleep(50) ; Sleep for a bit
		}
		A_Clipboard := bak ; Restore original clipboard
	}
	Else ; Else if send_clip false
	{
		last_clip := A_Clipboard ; Update last_clip with current clipboard
		While DllCall("GetOpenClipboardWindow") { ; If clipboard still in use (long paste)
			Sleep(50) ; Sleep for a bit
		}
		Send('^c') ; And then copy new contents to active clipboard
	}
}

AE_SelectAll(*)
{
	Static Msg := EM_SETSEL := 177, wParam := 0, lParam := -1
	hCtl := ControlGetFocus('A')
	DllCall('SendMessage', 'UInt', hCtl, 'UInt', Msg, 'UInt', wParam, 'UIntP', lParam)
	return
}
AE_Select_End(*)
{
	Static Msg := EM_SETSEL := 177, wParam := -1, lParam := -1
	hCtl := ControlGetFocus('A')
	DllCall('SendMessage', 'UInt', hCtl, 'UInt', Msg, 'UInt', wParam, 'UInt', lParam)
	return
}
AE_Select_Beginning(*)
{
	Static Msg := EM_SETSEL := 177, wParam := 0, lParam := 0
	hCtl := ControlGetFocus('A')
	DllCall('SendMessage', 'UInt', hCtl, 'UInt', Msg, 'UInt', wParam, 'UInt', lParam)
	return
}
AE_Get_TEXTLIMIT(*)
{
	; Static Msg := EM_GETLIMITTEXT := 1061, wParam := 0, lParam := 0
	; Static Msg := EM_GETTEXTLENGTH := 0x000E, wParam := 0, lParam := 0
	; Static Msg := WM_GETFONT := 0x0031, wParam := 0, lParam := 0
	; text := StrPtr('hznRTE ')
	; Static Msg := WM_SETTEXT := 0x000C, wParam := 0, lParam := text

	hCtl := ControlGetFocus('A')
	; Limit := DllCall('SendMessage', 'UInt', hCtl, 'UInt', Msg, 'UInt', wParam, 'UInt', lParam)
	; Limit := SendMessage(Msg,wParam, lParam, hCtl, hCtl)
	buff_size := 64000
	VarSetStrCapacity(&buff, buff_size)
	Static Msg := WM_GETTEXT := 0x000D, wParam := buff_size, lParam := &buff
	Text := SendMessage(Msg,wParam, lParam, hCtl, hCtl)
	afont := []
	afont := GuiCtrlTextSize(hCtl,text)
	for each, value in afont {
		font := ''
		font .= value . '`n'
	}
	MsgBox(font)
	GuiCtrlTextSize(GuiCtrlObj, Text)
	{
		Static WM_GETFONT := 0x0031, DT_CALCRECT := 0x400
		hDC := DllCall('GetDC', 'Ptr', GuiCtrlObj.Hwnd, 'Ptr')
		hPrevObj := DllCall('SelectObject', 'Ptr', hDC, 'Ptr', SendMessage(WM_GETFONT, , , GuiCtrlObj), 'Ptr')
		height := DllCall('DrawText', 'Ptr', hDC, 'Str', Text, 'Int', -1, 'Ptr', buf := Buffer(16), 'UInt', DT_CALCRECT)
		width := NumGet(buf, 8, 'Int') - NumGet(buf, 'Int')
		DllCall('SelectObject', 'Ptr', hDC, 'Ptr', hPrevObj, 'Ptr')
		DllCall('ReleaseDC', 'Ptr', GuiCtrlObj.Hwnd, 'Ptr', hDC)
		Return { Width: Round(width * 96 / A_ScreenDPI), Height: Round(height * 96 / A_ScreenDPI) }
	}
	; Return Limit
}




Class AE {

	; --------------------------------------------------------------------------------
	_AE_DetectHidden(bool?){
        bool := true
        DetectHiddenText(bool)
        DetectHiddenWindows(bool)
	}
	; --------------------------------------------------------------------------------

	_AE_SetDelays(n?) {
		n := -1
		SetControlDelay(n)
		SetMouseDelay(n)
		SetWinDelay(n)
	}
	; --------------------------------------------------------------------------------
	_AE_PerMonitor_DPIAwareness() {
        MaximumPerMonitorDpiAwarenessContext := VerCompare(A_OSVersion, ">=10.0.15063") ? -4 : -3
        Global DefaultDpiAwarenessContext := MaximumPerMonitorDpiAwarenessContext, A_DPI := DefaultDpiAwarenessContext
        try
            DllCall("SetThreadDpiAwarenessContext", "ptr", MaximumPerMonitorDpiAwarenessContext, "ptr")
        catch 
            DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
        else
            DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
        return A_DPI
	}
}