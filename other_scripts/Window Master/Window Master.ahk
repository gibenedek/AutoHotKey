/*
License: GNU GENERAL PUBLIC LICENSE v2 -- See License.txt
	Feel free to modify and improve upon the work herein, but be certain to give credit me (Verdlin) when using my scripts.

Credits
	AutoHotkey
		tinku99 @ AutoHotkey	http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=6056
		HotKeyIt @ AutoHotkey	http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=9238
		Lexikos @ AutoHotkey	http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=3754
		Amnesiac @ AutoHotkey	http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=47646
		HotkeyIt @ AutoHotkey_H	http://www.autohotkey.net/~HotKeyIt/AutoHotkey/files/AutoHotkey-txt.html
		Tidbit: st.ahk lib -- http://www.autohotkey.net/~tidbit/StringThings/ST.ahk
		Just Me: LV_Colors.ahk -- http://www.autohotkey.com/board/topic/88699-class-lv-colors-coloured-rowscells-in-gui-listviews/
		Just Me: GuiTabEx.ahk -- http://www.autohotkey.com/board/topic/79963-class-guitabex-additional-features-for-tabtab2/
		tkoi: ILButton.ahk -- http://www.autohotkey.com/board/topic/37147-ilbutton-image-buttons-with-text-states-alignment/
		Polythene: Anchor.ahk -- https://raw.github.com/polyethene/AutoHotkey-Scripts/master/Anchor.ahk
		Polythene: xpath.ahk -- http://www.autohotkey.com/board/topic/16137-xpath-v3-read-and-write-xml-documents-with-xpath-syntax/
		Lexikos:WindowPad -- http://www.autohotkey.com/board/topic/19990-windowpad-window-moving-tool/
		Lexikos: IsResizable()
		Shinywong: GetMonitorIndexFromWindow() -- http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/#entry440355
		Hoppfrosch: WindowPaxX --https://github.com/hoppfrosch/WindowPadX
		RobertCollier4: CornerNotify (with some minor modifictions by me) -- http://www.autohotkey.com/board/topic/94458-msgbox-replacement-monolog-non-modal-transparent-message-box-cornernotify/
		Maestrith: Dlg.ahk (Specifically the color picker dlg) -- http://www.autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/
		Jballi: Fnt.ahk -- http://www.autohotkey.com/board/topic/90481-library-fnt-v05-preview-do-stuff-with-fonts/
		JoeDF: Simple Volume OSD: http://www.autohotkey.com/board/topic/94165-simple-volume-osd/

	Visual
		Taytel for Orb icon set: http://taytel.deviantart.com/
		Ahmad Hania for Spherical icon set: (Creative Commons 3.0 - http://creativecommons.org/licenses/by-nc/3.0/legalcode)
			-- Some icons were modified to have transparent background and a broader range of resolutions.

	Other
		Leap Motion: https://www.leapmotion.com/

	Special Thanks
		Lexikos and Chris Mallet for AutoHotkey.
		HotkeyIt for his amazing work with AutoHotkey_H, and also his helpful answers to my many questions in the AutoHotkey forum.
		Lexikos and Hoppfrosch for WindowPad and WindowPadX, respectively. Numerous functions herein are based off of those open-source AHK files.

	If you see your work and you are not credited, this is not deliberate. Notify me and I will credit you ASAP.

For Me: Current LOC written by me (Including AutoLeap.exe): 10,098
	TODO:
		Virtual desktops -- http://www.autohotkey.com/board/topic/50154-virtual-desktops-extras-for-win7/
		Detect and refresh monitor info whenever the display configuration changes.
*/

#SingleInstance Force

SetBatchLines -1 ; Needed for StartHotkeyThread().
SetWinDelay, -1
SendMode, Input
SetWorkingDir, %A_ScriptDir%

; Start Splash Screen.
SplashImage, images\Splash.png, B W832 H624 ZW832 ZH624

if (!FileExist("images"))
	FileCreateDir, images

If 0 ; When compiled, AhkDllThread.ahk assumes AutoHotkey[Mini].dll is installed in the executable
	FileInstall,..\..\AutoHotkey.dll,-
FileInstall, ..\CFlyout\CFMH_res.dll, CFMH_res.dll, 1

; Images are brought over with make.ahk.
; Also FileInstalls are created dynamically from make.ahk.
; v1.0
FileInstall, images\Default Wnd.png, images\Default Wnd.png, 1
FileInstall, images\Default Flyout Menu.jpg, images\Default Flyout Menu.jpg, 1
FileInstall, images\Monitor Frame.png, images\Monitor Frame.png, 1
FileInstall, images\Sequence.ico, images\Sequence.ico, 1
FileInstall, images\Menu Settings.ico, images\Menu Settings.ico, 1
FileInstall, images\Snap.ico, images\Snap.ico, 1
FileInstall, images\Main.ico, images\Main.ico, 1
FileInstall, images\Add.ico, images\Add.ico, 1
FileInstall, images\Close.ico, images\Close.ico, 1
FileInstall, images\Edit.ico, images\Edit.ico, 1
FileInstall, images\Delete.ico, images\Delete.ico, 1
FileInstall, images\Save.ico, images\Save.ico, 1
FileInstall, images\Refresh.ico, images\Refresh.ico, 1
FileInstall, images\Resize.ico, images\Resize.ico, 1
FileInstall, images\Window.ico, images\Window.ico, 1
FileInstall, images\Info.ico, images\Info.ico, 1
FileInstall, images\Close.ico, images\Close.ico, 1
FileInstall, images\Open.ico, images\Open.ico, 1
FileInstall, images\Import.ico, images\Import.ico, 1
FileInstall, images\Pause.ico, images\Pause.ico, 1
FileInstall, images\Play.ico, images\Play.ico, 1
; License and other help files.
FileInstall, License.txt, License.txt, 1
FileInstall, ReadMe.txt, ReadMe.txt, 1

; Tray icon
Menu, TRAY, Icon, images\Main.ico,, 1

Menu, TRAY, NoStandard
Menu, TRAY, MainWindow ; For compiled scripts
Menu, TRAY, Add, &Open, LaunchMainDlg
Menu, TRAY, Icon, &Open, images\Open.ico,, 16
Menu, TRAY, Default, &Open
Menu, TRAY, Click, 1

if (!A_IsCompiled)
{
	Menu, TRAY, Add, &Reload, Window_Master_Reload
	Menu, TRAY, Icon, &Reload, images\Refresh.ico,, 16

	Hotkey, IfWinActive
		Hotkey, #+R, Window_Master_Reload
}

; If the Leap Module is used, then an option is added to the tray menu. That is why InitEverything is called here
InitEverything()

Menu, TRAY, Add, E&xit, Window_Master_Exit
Menu, TRAY, Icon, E&xit, AutoLeap\Exit.ico,, 16

; Dismiss Splash screen.
SplashImage, Off
gosub LaunchMainDlg

return ; End Autoexecute

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: InitEverything
		Purpose: All Initialize functions should be called from this master functions. Used to improve readability
	Parameters
		None
*/
InitEverything()
{
	InitLeap()

	InitGlobals()

	; Inis are used in and MakeMainDlg InitThreads
	InitAllInis()
	InitMonInfo()

	VolumeOSD_Init()

	; Initialize hotkeys. Do this before MakeMainDlg so that the hotkey assigned to launching the dialog will appear responsive
	InitThreads()

	MakeMainDlg()

	OnMessage(WM_DISPLAYCHANGE:=126, "Window_Master_OnDisplayChange")
	OnMessage(WM_SETTINGCHANGE:=26, "Window_Master_OnSettingChange")

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Window_Master_OnDisplayChange
		Purpose: To update monitor information stored in memory whenever the display configuration changes
	Parameters
		wParam
		lParam
		msg
		hWnd
*/
Window_Master_OnDisplayChange(wParam, lParam, msg, hWnd)
{
	Sleep 1000 ; On my computer, at least, Windows take FOREVER to figure out the new display configuration.
	InitMonInfo()
	VolumeOSD_Init()
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
InitGlobals()
{
	global

	; GUIs
	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa511453.aspx#sizing
	g_iMSDNStdBtnW := 75
	g_iMSDNStdBtnH := 23
	g_iMSDNStdBtnSpacing := 6
	g_iMyStdImgBtnRect := 40

	g_bShouldSave := false ; for main dlg.
	g_bIsDev := FileExist("$dev")

	g_sClassesNotToUse := "Shell_TrayWnd,Shell_SecondaryTrayWnd,EdgeUiInputTopWndClass,WorkerW,Progman"

	g_sModParse := "Ctrl|Alt|Shift|Win"
	g_sAbbrModParse := "^|!|+|#" ; For parsing hotkey modifiers in the HK dlg.

	; Master object for Window Master dialogs.
	g_vDlgs := new WM_Dlg()

	; Leap
	if (g_bHasLeap)
	{
		g_vLeapMsgProcessor := {					m_bUseTriggerGesture:0
			, m_bCallbackNeedsGestures:0,	m_bGestureUsesPinch:0
			, m_bCallbackCanStop:0,					m_hTriggerGestureFunc:0,	m_bActionHasStarted:0
			, m_sTriggerAction:0,						m_bMoveAlongXOnly:0,		m_bMoveAlongYOnly:0
			, m_bFistMadeDuringThreshold:0,	m_iFrameCnt:0,						m_iMSSinceLastFrame:0}
	}

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Only initializes leap module if the machine has leap motion software installed.
InitLeap()
{
	RegRead, sKey, HKCR, airspace\shell\open\command
	if (InStr(sKey, "Leap Motion"))
	{
		global g_vLeap := new AutoLeap("Window_Master_LeapMsgHandler")

		; Merge Gestures.ini with our defaults.
		g_vLeap.MergeGesturesIni(GetDefaultLeapGesturesIni())

		if (g_vLeap)
		{
			Menu, TRAY, Add, &Gestures, Window_Master_ShowControlCenterDlg
			Menu, TRAY, Icon, &Gestures, AutoLeap\Leap.ico,, 16
			Menu, TRAY, Add, % "&Pause " g_vLeap.m_sLeapTM, Window_Master_PlayPauseLeap
			Menu, TRAY, Icon, % "&Pause " g_vLeap.m_sLeapTM, images\Pause.ico,, 16

			; In case ini data has been modified externally.
			RemoveUnreferencedGestures()
		}
	}

	global g_bHasLeap := IsObject(g_vLeap)

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
InitAllInis()
{
	global

	; For custom hotkeys and sequences
	g_SequencesIni := class_EasyIni(A_ScriptDir "\sequences.ini")

	; For hotkey mappings
	g_VKsIni := class_EasyIni("", GetVKsIni())

	; "Static" hotkeys
	; Given the delicate relationship between labels and hotkeys, this requires some special handling.
	local vDefaultHotkeysIni := class_EasyIni(A_ScriptDir "\hotkeys.ini", GetDefaultHotkeysIni())
	g_HotkeysIni := class_EasyIni(A_ScriptDir "\hotkeys.ini")
	; To allow removal of old settings and additions of new settings, merge vDefaultHotkeysIni and g_HotkeysIni.
	; bRemoveNonMatching: If true, removes sections and keys that do not exist in both inis.
	; bOverwriteMatching: If true, any key that exists in both objects will use the val from g_HotkeysIni.
	local vExceptionsForHotkeysIni := class_EasyIni("", GetExceptionsForHotkeysIni())
	vDefaultHotkeysIni.Merge(g_HotkeysIni, true, true, vExceptionsForHotkeysIni)
	g_HotkeysIni := vDefaultHotkeysIni ; Seems like merge should handle this or something, but I am too tired to think this one through right now.
	g_HotkeysIni.Save() ; This effectively updates the local ini with new, internal settings from GetDefaultHotkeysIni()

	; Save to ensure that, if new options were added, keys were renamed, or keys were removed
	; we will load this options into their appropriate ListView
	g_HotkeysIni.Save()

	; "Precision" hotkeys
	;~ g_PrecisionIni := class_EasyIni(A_ScriptDir "\precision.ini")

	; Leap actions. Handling is quite similar to g_HotkeysIni.
	local vDefaultLeapActionsIni := class_EasyIni(A_ScriptDir "\leap actions.ini", GetDefaultLeapActionsIni())
	g_LeapActionsIni := class_EasyIni(A_ScriptDir "\leap actions.ini")
	local vExceptionsForLeapActionsIni := class_EasyIni("", GetExceptionsForLeapActionsIni())
	; Merge in similar fashion as g_HotkeysIni.
	vDefaultLeapActionsIni.Merge(g_LeapActionsIni, true, true, vExceptionsForLeapActionsIni)
	g_LeapActionsIni := vDefaultLeapActionsIni
	g_LeapActionsIni.Save() ; This effectively updates the local ini with new, internal settings from GetDefaultLeapActionsIni()

	if (!FileExist("Sequences.ini"))
	{
		g_SequencesIni := class_EasyIni(A_ScriptDir "\sequences.ini", GetDefaultSequencesIni())
		g_SequencesIni.Save()
	}

	;~ g_sInisForParsing := "g_SequencesIni|g_PrecisionIni|g_HotkeysIni|g_LeapActionsIni"
	g_sInisForParsing := "g_SequencesIni|g_HotkeysIni|g_LeapActionsIni"

	return
}

InitMonInfo()
{
	global g_DictMonInfo := {}
	global g_aMapOrganizedMonToSysMonNdx := []

	SysGet, iVirtualScreenLeft, 76
	SysGet, iVirtualScreenTop, 77
	SysGet, iVirtualScreenRight, 78
	SysGet, iVirtualScreenBottom, 79

	g_DictMonInfo.Insert("VirtualScreenLeft", iVirtualScreenLeft)
	g_DictMonInfo.Insert("VirtualScreenTop", iVirtualScreenTop)
	g_DictMonInfo.Insert("VirtualScreenRight", iVirtualScreenRight)
	g_DictMonInfo.Insert("VirtualScreenBottom", iVirtualScreenBottom)

	SysGet, iMonCnt, MonitorCount

	SysGet, iPrimaryMon, MonitorPrimary
	SysGet, iPrimaryMon, Monitor, %iPrimaryMon%
	g_DictMonInfo.Insert("PrimaryMon", iPrimaryMon)
	g_DictMonInfo.Insert("PrimaryMonLeft", iPrimaryMonLeft)
	g_DictMonInfo.Insert("PrimaryMonRight", iPrimaryMonRight)
	g_DictMonInfo.Insert("PrimaryMonTop", iPrimaryMonTop)
	g_DictMonInfo.Insert("PrimaryMonBottom", iPrimaryMonBottom)

	;~ st :="
	;~ (LTrim
		;~ left;
		;~ Right;
		;~ Top;
		;~ Bottom;
		;~ w;
		;~ h;
	;~ )"

	;~ vTempMonInfo1 := struct(st)
	;~ vTempMonInfo2 := struct(st)
	;~ vTempMonInfo3 := struct(st)
	;~ vTempMonInfo4 := struct(st)
	;~ vTempMonInfo5 := struct(st)
	;~ vTempMonInfo6 := struct(st)

	;~ vTempMonInfo1.w := vTempMonInfo2.w := vTempMonInfo3.w := vTempMonInfo4.w := vTempMonInfo5.w := vTempMonInfo6.w := 1920
	;~ vTempMonInfo1.h := vTempMonInfo2.h := vTempMonInfo3.h := vTempMonInfo4.h := vTempMonInfo5.h := vTempMonInfo6.h := 1080

	;~ vTempMonInfo1.left := vTempMonInfo5.left := 1920
	;~ vTempMonInfo3.left := vTempMonInfo6.left := 3840

	;~ vTempMonInfo2.right := vTempMonInfo4.right := 1920
	;~ vTempMonInfo1.right := vTempMonInfo5.right := 3840
	;~ vTempMonInfo3.right := vTempMonInfo6.right := 5760

	;~ vTempMonInfo1.bottom := 1080
	;~ vTempMonInfo2.bottom := 1080
	;~ vTempMonInfo3.bottom := 1080

	;~ vTempMonInfo4.top := 1080
	;~ vTempMonInfo5.top := 1080
	;~ vTempMonInfo6.top := 1080

	;~ Loop 6
	;~ {
		;~ s1 := vTempMonInfo%A_Index%.left
		;~ s2 := vTempMonInfo%A_Index%.right
		;~ s3 := vTempMonInfo%A_Index%.top
		;~ s4 := vTempMonInfo%A_Index%.bottom
		;~ s5 := vTempMonInfo%A_Index%.w
		;~ s6 := vTempMonInfo%A_Index%.h
	;~ }

	aDictMonInfo := []
	Loop, %iMonCnt%
	{
		vDictMonInfo := {}

		SysGet, Mon, MonitorWorkArea, %A_Index%

		vDictMonInfo.Insert("Left", MonLeft)
		vDictMonInfo.Insert("Right", MonRight)
		vDictMonInfo.Insert("Top", MonTop)
		vDictMonInfo.Insert("Bottom", MonBottom)
		vDictMonInfo.Insert("W", Abs(MonRight-MonLeft))
		vDictMonInfo.Insert("H", Abs(MonTop-MonBottom))
		vDictMonInfo.Insert("Ndx", A_Index)
		aDictMonInfo.Insert(vDictMonInfo)

		;~ DictMonInfo.Insert("MonLeft", vTempMonInfo%A_Index%.left)
		;~ DictMonInfo.Insert("MonRight", vTempMonInfo%A_Index%.right)
		;~ DictMonInfo.Insert("MonTop", vTempMonInfo%A_Index%.top)
		;~ DictMonInfo.Insert("MonBottom", vTempMonInfo%A_Index%.bottom)
		;~ DictMonInfo.Insert("MonW", Abs(vTempMonInfo%A_Index%.right-vTempMonInfo%A_Index%.left))
		;~ DictMonInfo.Insert("MonH", Abs(vTempMonInfo%A_Index%.top-vTempMonInfo%A_Index%.bottom))
		;~ aDictMonInfo.Insert(DictMonInfo)
	}

	Loop % aDictMonInfo.MaxIndex()
	{
		iBottomLeftMon := GetBottomLeftMon(aDictMonInfo)
		if (iBottomLeftMon == 0)
		{
			Msgbox("An error occured when trying to calibrate monitor positions")
			return
		}

		g_aMapOrganizedMonToSysMonNdx.Insert(aDictMonInfo[iBottomLeftMon]["Ndx"])
		g_DictMonInfo.Insert(ObjClone(aDictMonInfo[iBottomLeftMon]))

		; Until I can figure out a better way to do this, set coordinates
		; to blank so that we won't return the same monitor.
		; Not the most efficient method, but this algorithm is confusing.
		aDictMonInfo[iBottomLeftMon]["Left"] := ""
		aDictMonInfo[iBottomLeftMon]["Bottom"] := ""
	}

	;~ Loop % g_aMapOrganizedMonToSysMonNdx.MaxIndex()
	;~ {
		;~ Msgbox % "A_Index:`t" A_Index "`nMap:`t" g_aMapOrganizedMonToSysMonNdx[A_Index] "`nLeft:`t" g_DictMonInfo[A_Index]["Left"] "`nBottom:`t" g_DictMonInfo[A_Index]["Bottom"] "`nTop:`t" g_DictMonInfo[A_Index]["Top"]
	;~ }

	return
}

GetBottomLeftMon(aDictMonInfo)
{
	a:= []
	Loop % aDictMonInfo.MaxIndex()
		a.Insert(aDictMonInfo[A_Index]["Bottom"])

	; Find bottom monitors first...
	iBottom := max(a*) ; As monitors get lower, their bottoms increase *snickers*
	Loop % aDictMonInfo.MaxIndex()
	{
		if (aDictMonInfo[A_Index]["Bottom"] == iBottom)
			sBottomList .= sBottomList == A_Blank ? A_Index : "|" A_Index
	}

	; and, of those bottom monitors, the leftmost monitor
	a := []
	Loop, Parse, sBottomList, |
		a.Insert(aDictMonInfo[A_LoopField]["Left"])
	iLeft := min(a*)

	;~ Msgbox %sBottomList%`n%iBottom%`n%iLeft%

	Loop, Parse, sBottomList, |
	{
		; Assume that there is only one leftmost monitor in the list of bottom monitors
		;~ Msgbox % "A_Index:`t" A_Index "`nNum:`t" A_LoopField "`nLeft:`t" aDictMonInfo[A_LoopField]["MonLeft"] "`nBottom:`t" aDictMonInfo[A_LoopField]["MonBottom"] "`nTargetLeft:`t" iLeft "`nTargetBottom:`t" iBottom
		if (aDictMonInfo[A_LoopField]["Left"] == iLeft && aDictMonInfo[A_LoopField]["Bottom"] == iBottom)
			return A_LoopField
	}
	return 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: VolumeOSD_Init
		Purpose:
	Parameters
		
*/
VolumeOSD_Init()
{
	global

	g_sVolumeOSD_ProgOpts := "CW1A1A1A CTFFFFFF CB666666 x" (A_ScreenWidth/2)-165 " y" (A_ScreenHeight/2)-26 " w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11"
	Progress Hide %g_sVolumeOSD_ProgOpts%,,Volume,, Tahoma

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
InitThreads()
{
	global g_dll, g_vMH

	g_dll.ahklabel["ExitApp"] ; Because sometimes the destructor does not work.
	g_vMH:=ahklabel["ExitApp"]
	g_dll:=g_vMH:=

	InitMenuHandler()
	StartHotkeyThread()
	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
SuspendThreads(sOnOrOff)
{
	global g_dll, g_vMH

	g_dll.ahkFunction["Suspend", sOnOrOff]
	g_vMH.Suspend(sOnOrOff)

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitMenuHandler()
{
	global

	if (g_HotkeysIni["Quick Menu"].Hotkey && g_HotkeysIni["Quick Menu"].Activate = "true")
	{
		local vTmp := class_EasyIni("Flyout_config.ini", GetMenuConfigSettingsIni())
		if (!FileExist("Flyout_Config.ini"))
		{
			; Effectively the first time running.
			vTmp.Save()
		}

		g_vMH := new CFlyoutMenuHandler(A_IsCompiled ? "..\..\AutoHotkey.dll" : SubStr(A_AhkExe(),1,-3) "dll", vTmp.Flyout.X, vTmp.Flyout.Y, 0, 0, GetMenuConfigIni(), "Left")

		;~ SetTimer, Window_Master_HotCorner, 350
		g_iActivatedSince := 11
	}
	return
}

QuickMenu_EditSettings:
{
	; Note: Not calling g_vMH.GUIEditSettings(g_hWindowMaster) because that causes a lockup.
	CFlyout.GUIEditSettings(g_hWindowMaster)
	return
}

Window_Master_HotCorner:
{
	Critical

	CoordMode, Mouse
	MouseGetPos, iX, iY

	g_iActivatedSince += 0.350

	if ((iX - 5 < 6 || iX == 0) && (iY - 5 < 6 || iY == 0) && g_iActivatedSince > 10 && g_iActivatedAtX != iX && g_iActivatedAtY != iY)
	{
		WinGetActiveTitle, sTitle
		if (InStr(sTitle, "GUI_Flyout"))
			g_vMH.ExitMenu()
		else g_vMH.ShowMenu()

		g_iActivatedSince :=
		g_iActivatedAtX := iX
		g_iActivatedAtY := iY
	}
	return
}

LaunchMainDlg:
{
	if (WinActive("ahk_id" g_hWindowMaster) || !DllCall("IsWindowEnabled", uint, g_hWindowMaster))
		return ; If this window is disabled, then that is because another dialog, owned by g_hWindowMaster, is active.

	if (g_bFirstLaunch)
	{
		GUI Window_Master_: Show, w890 h494
		g_bFirstLaunch := false

		; TODO: For first launch ever, MsgBox which directs to help video + docs.
		
	}
	else GUI Window_Master_: Show

	gosub Window_Master_TabProc
	return
}

MakeMainDlg()
{
	global

	g_bFirstLaunch := true
	GUI Window_Master_: New, hwndg_hWindowMaster MinSize Resize, Window Master

	Menu, WM_Menu_Import, Add, Import WinSplit* &Settings`tCtrl + W, ConvertWinSplitXMLSettingsToInis
	Menu, WM_ImportMenu, Add, I&mport, :WM_Menu_Import
	Menu, WM_ImportMenu, Icon, I&mport, images\Import.ico,, 16
	Menu, WM_ImportMenu, Add, E&xit, Window_Master_GUIClose
	Menu, WM_ImportMenu, Icon, E&xit, AutoLeap\Exit.ico,, 16

	if (g_bIsDev)
	{
		Menu, WM_Menu_Settings, Add, &Quick Menu`tCtrl + M, QuickMenu_EditSettings
		Menu, WM_Menu_Settings, Icon, &Quick Menu`tCtrl + M, images\Menu Settings.ico,, 16
	}

	if (g_bHasLeap)
	{
		Menu, WM_Menu_Settings, Add, % "&" g_vLeap.m_sLeapTM " Settings`tCtrl + L", Window_Master_ShowControlCenterDlg
		Menu, WM_Menu_Settings, Icon,% "&" g_vLeap.m_sLeapTM " Settings`tCtrl + L", AutoLeap\Leap.ico,, 16
	}

	Menu, WM_Menu_Help, Add, &Using Window Master`tF1, Window_Master_Help
	Menu, WM_Menu_Help, Icon, &Using Window Master`tF1, images\Info.ico,, 16
	Menu, WM_Menu_Help, Add, &About, Window_Master_About
	Menu, WM_Menu_Help, Icon, &About, AutoLeap\Info.ico,, 16

	Menu, WM_MainMenu, Add, &File, :WM_ImportMenu
	Menu, WM_MainMenu, Add, Se&ttings, :WM_Menu_Settings
	Menu, WM_MainMenu, Add, &Help, :WM_Menu_Help
	GUI, Menu, WM_MainMenu

	;~ g_asTabs := ["Se&quencing", "&Resizing", "S&napping", "&Precision", "Other Action&s"]
	; Note: The Precision feature is dubious.
	; Airspace prefers fewer features with greater reliability than many features with nominal reliability.
	g_asTabs := ["Se&quencing", "&Resizing", "S&napping", "Other Action&s"]
	if (g_bHasLeap)
		g_asTabs.Insert("&" g_vLeap.m_sLeapTM)

	GUI, Font, s18 ; c83B8G7
	GUI, Add, Tab2, x5 y5 w215 Buttons +Theme -Background hwndhWMTab Choose1 gWindow_Master_TabProc vvWMTab, % st_glue(g_asTabs, "|")

	Hotkey, IfWinActive, ahk_id %g_hWindowMaster%
	{
		; Tabs
		Loop % g_asTabs.MaxIndex()
		{
			local sTab := g_asTabs[A_Index]
			sHK := "!" SubStr(sTab, InStr(sTab, "&") + 1, 1)
			if (A_Index == 1)
				Hotkey, %sHK%, Window_Master_GoToSequencingTab
			else if (A_Index == 2)
				Hotkey, %sHK%, Window_Master_GoToResizingTab
			else if (A_Index == 3)
				Hotkey, %sHK%, Window_Master_GoToSnapTab
			;~ else if (A_Index == 4)
				;~ Hotkey, %sHK%, Window_Master_GoToPrecisionTab
			else if (A_Index == 4)
				Hotkey, %sHK%, Window_Master_GoToOtherActionsTab
			else if (A_Index == 5)
				Hotkey, %sHK%, Window_Master_GoToLeapTab
		}

		; ListViews
		Hotkey, !A, Window_Master_Add
		Hotkey, !=, Window_Master_Add
		Hotkey, !E, Window_Master_Edit ; F2 works, too!
		Hotkey, !D, Window_Master_Delete
		Hotkey, !-, Window_Master_Delete
		Hotkey, Delete, Window_Master_Delete
	}

	local iNumIcons := 4+g_bHasLeap
	hIL := IL_Create(iNumIcons, 1, true)
	IL_Add(hIL, "images\Sequence.ico", 1)
	IL_Add(hIL, "images\Resize.ico", 1)
	IL_Add(hIL, "images\Snap.ico", 1)
	;~ IL_Add(hIL, "images\Target.ico", 1)
	IL_Add(hIL, "images\Window.ico", 1)
	if (g_bHasLeap)
		IL_Add(hIL, "AutoLeap\Leap.ico", 1)

	g_vWMMainTab := new GuiTabEx(hWMTab)
	g_vWMMainTab.SetPadding(20, 3)
	g_vWMMainTab.SetImageList(HIL)
	Loop %iNumIcons%
		g_vWMMainTab.SetIcon(A_Index, A_Index)

	GUI, Tab

	GUI, Add, GroupBox, x220 y-10 w664 h474 vvMainBorder

	GUI, Font, s8 cBlack
	GUI, Add, Button, % "x728 y468 w" g_iMSDNStdBtnW " h" g_iMSDNStdBtnH " vg_vWindow_Master_OKBtn gWindow_Master_Ok", &OK
	GUI, Add, Button, % "xp+" g_iMSDNStdBtnW+g_iMSDNStdBtnSpacing " yp wp hp vg_vWindow_Master_CancelBtn gWindow_Master_GUICancel", &Cancel

	AddAllControls()

	return
}

AddAllControls()
{
	global
	static WM_NOTIFY:=78

	GUI, Tab, 1

	local iTab1LVX := 230
	local iTab1LVY := 23
	local iTab1LVW := 317
	local iTab1LVH := 170

	; HK LV
	GUI, Add, GroupBox, x225 y6 w655 h235 Center vvSeqHKGroupBox, Sequence Editor
	sHKLVCols := "Hotkey"
	if (g_bHasLeap)
		sHKLVCols .= "|Gesture"
	local iTmpX := iTab1LVX
	GUI, Add, ListView, x%iTab1LVX% y%iTab1LVY% w%iTab1LVW% h%iTab1LVH% hwndg_hHKList vvHotkeysLV gHKList AltSubmit Checked Grid -Multi, %sHKLVCols%

	iBtnY := iTab1LVY+iTab1LVH+3
	GUI, Add, Button, xp y%iBtnY% w%g_iMyStdImgBtnRect% h%g_iMyStdImgBtnRect% vvEditHK hwndg_hEditHK gEditHK
	ILButton(g_hEditHK, "images\Edit.ico", 32, 32, 4)
	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing " yp wp hp vvAddHKForSequence hwndg_hAddHKForSequence gAddHKForSequence"
	ILButton(g_hAddHKForSequence, "images\Add.ico", 32, 32, 4)
	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing " yp wp hp vvDelHK hwndg_hDeleteHK gDeleteHK"
	ILButton(g_hDeleteHK, "images\Delete.ico", 32, 32, 4)

	iTmpX += iTab1LVW+g_iMSDNStdBtnSpacing
	GUI, Add, ListView, x%iTmpX% y%iTab1LVY% w%iTab1LVW% h%iTab1LVH% hwndg_hSequence vvSequenceLV gSequence AltSubmit Grid -Multi, Sequence in percent (`%)
	GUI, Add, Button, xp y%iBtnY% w%g_iMyStdImgBtnRect% h%g_iMyStdImgBtnRect% hwndg_hEditSeq vvEditSeq gEditSeq
	ILButton(g_hEditSeq, "images\Edit.ico", 32, 32, 4)
	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing "yp wp hp hwndg_hAddSeq vvAddSeq gAddSeq"
	ILButton(g_hAddSeq, "images\Add.ico", 32, 32, 4)
	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing "yp wp hp hwndg_hDelSeq vvDelSeq gDeleteSeq"
	ILButton(g_hDelSeq, "images\Delete.ico", 32, 32, 4)

	InitSequenceControls()
	g_vWMMainTab.Highlight(1)

	GUI, Add, GroupBox, x225 yp+44 w655 h220 hwndhGroupPreview vvGroupPreview Center, Preview
	GUI, Add, Picture, xp+195 yp+20 w251 h175 hwndhMonitorFramePic vvMonitorFramePic, images\Monitor Frame.png
	RegRead, sCurBgd, HKEY_CURRENT_USER, Control Panel\Desktop, Wallpaper
	if (sCurBgd == "")
		sCurBgd := "images\Default Flyout Menu.jpg"

	GUI, Add, Picture, xp+8 yp+7 w235 h124 hwndhDesktopPic vvDesktopPic, %sCurBgd%
	GUI, Add, Picture, xp yp+75 w125 h50 hwndhWndPic vvWndPic, images\Default Wnd.png

	GUI, Add, Text, xp+245 yp-70 w79 h13 hwndhXText vsXText, %A_Space%x: 100.00`%  ; X becomes truncated, slightly, without A_Space.
	GUI, Add, Text, xp yp+33 wp hp hwndhYText vsYText, %A_Space%y: 100.00`%
	GUI, Add, Text, xp yp+33 wp hp hwndhWText vsWText, %A_Space%width: 100.00`%
	GUI, Add, Text, xp yp+33 wp hp hwndhHText vsHText, %A_Space%height: 100.00`%

	GUI, Tab
	; Init generic controls that will be used in different contexts.
	g_vMapTabToDesc := {g_asTabs[2]: "Window Resizing Actions"
	, g_asTabs[3]: "Window Snapping Actions"
	;~ , g_asTabs[4]: "Precision Window Placement:"
	, g_asTabs[4]: "Miscellaneous Actions"
	, g_asTabs[5]: "Interactive, " g_vLeap.m_sLeapTM " Controlled Actions`n(When using, keep fingers apart until you are ready to stop)."}

	GUI, Font, s15 c83B8G7
	GUI, Add, Text, x230 y13 w646 h50 hwndg_hGenericText vvGenericText Center Hidden
	GUI, Font, s8 cBlack

	local sGenericLVCols := "Action|Hotkey"
	if (g_bHasLeap)
		sGenericLVCols .= "|Gesture"
	GUI, Add, ListView, xp yp+50 wp h354 vvGenericLV hwndg_hGenericLV gGenericLVProc AltSubmit Checked Grid -Multi Hidden, %sGenericLVCols%

	GUI, Add, Button, xp yp+357 w%g_iMyStdImgBtnRect% h%g_iMyStdImgBtnRect% hwndg_hGenericLVEditBtn vvGenericLVEdit gGenericLVModify Hidden
	ILButton(g_hGenericLVEditBtn, "images\Edit.ico", 32, 32, 4)

	GUI, Font, s12 c83B8G7
	GUI, Add, Text, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing "yp w605 hp vvGenericLVHelpTxt Center Hidden"
	GUI, Font, s8 cBlack

/*
Precision controls. TODO: Uncomment if/when this feature is re-added -- Verdlin: 3/11/14.

	GUI, Tab, 4
	; Precision controls.
	GUI, Add, Button, xp-1 yp wp hp hwndg_hGenericLVModifyPrecisionBtn vvPrecisionLVEdit gModifyPrecisionPlacement Hidden
	ILButton(g_hGenericLVModifyPrecisionBtn, "images\Edit.ico", 32, 32, 4)

	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing "yp wp hp hwndg_hPrecisionAddBtn vvPrecisionAdd gAddPrecisionPlacement Hidden"
	ILButton(g_hPrecisionAddBtn, "images\Add.ico", 32, 32, 4)

	GUI, Add, Button, % "xp+" g_iMyStdImgBtnRect+g_iMSDNStdBtnSpacing "yp wp hp hwndg_hPrecisionDeleteBtn vvPrecisionDelete gDeletePrecisionPlacement Hidden"
	ILButton(g_hPrecisionDeleteBtn, "images\Delete.ico", 32, 32, 4)
 */

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function:
		Purpose:
	Parameters
		
*/
Window_Master_Add:
{
	hFocused := Window_Master_GetCtrlFocusedHwnd()

	if (hFocused == g_hSequence)
		gosub AddSeq
	else if (hFocused = g_hHKList)
		gosub AddHKForSequence
	else if (PrecisionTabIsActive() && hFocused == g_hGenericLV)
		gosub AddPrecisionPlacement

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Window_Master_Edit
		Purpose: Hotkey handler to edit rows in List Views.
	Parameters
		None
*/
Window_Master_Edit:
{
	hFocused := Window_Master_GetCtrlFocusedHwnd()

	if (hFocused == g_hSequence)
	{
		ControlGet, bEnabled, Enabled,,, ahk_id %g_hEditSeq%
		if (bEnabled)
			gosub EditSeq
	}
	else if (hFocused = g_hHKList)
	{
		ControlGet, bEnabled, Enabled,,, ahk_id %g_hEditHK%
		if (bEnabled)
			gosub EditHK
	}
	else if (hFocused == g_hGenericLV)
	{
		bEnabled := true ; Except for the precision tab, data will always in this LV.
		if (PrecisionTabIsActive())
			ControlGet, bEnabled, Enabled,,, ahk_id %g_hGenericLVModifyPrecisionBtn%

		if (bEnabled)
			gosub GenericLVModify
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Window_Master_Delete
		Purpose: Hotkey handler to delete rows in ListViews
	Parameters
		None
*/
Window_Master_Delete:
{
	hFocused := Window_Master_GetCtrlFocusedHwnd()

	if (hFocused == g_hSequence)
		gosub DeleteSeq
	else if (hFocused = g_hHKList)
		gosub DeleteHK
	else if (PrecisionTabIsActive() && hFocused == g_hGenericLV)
		DeletePrecisionItem()

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Window_Master_GetCtrlFocusedHwnd
		Purpose: To get the hWnd of the currently focused control.
	Parameters
		None
*/
Window_Master_GetCtrlFocusedHwnd()
{
	GUI, Window_Master_:Default
	GUIControlGet, sFocused, Focus
	ControlGet, hFocused, hwnd,, %sFocused%
	return hFocused
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Window_Master_TabProc:
{
	if (SequencingTabIsActive())
		InitSequenceControls()
	else if (ResizingTabIsActive())
		InitResizingControls()
	else if (SnapTabIsActive())
		InitSnapControls()
	;~ else if (PrecisionTabIsActive())
		;~ InitPrecisionControls()
	else if (OtherActionsTabIsActive())
		InitSettingsControls()
	else if (LeapTabIsActive())
		InitLeapControls()

	MoveGenericButtons()

	iHighlight := g_vWMMainTab.GetSel()
	Loop % g_asTabs.MaxIndex()
		g_vWMMainTab.Highlight(A_Index, A_Index == iHighlight)

	sThisTab := GUIControlGet("", "vWMTab")
	sShowHideGeneric := (sThisTab = g_asTabs[1]) ? "Hide" : "Show"
	GUIControl, %sShowHideGeneric%, vGenericText
	GUIControl, %sShowHideGeneric%, vGenericLVHelpTxt
	GUIControl, %sShowHideGeneric%, vGenericLV
	;~ GUIControl, %sShowHideGeneric%, vGenericLVEdit
	GUIControl, %sShowHideGeneric%, vPrecisionLVEdit

	if (PrecisionTabIsActive())
	{
		GUIControl, Show, vPrecisionLVEdit
		GUIControl, Hide, vGenericLVEdit

		GUIControl, Show, vPrecisionAdd
		GUIControl, Show, vPrecisionDelete
	}
	else
	{
		GUIControl, Hide, vPrecisionLVEdit
		GUIControl, %sShowHideGeneric%, vGenericLVEdit

		GUIControl, Hide, vPrecisionAdd
		GUIControl, Hide, vPrecisionDelete
	}

	GUIControl,, vGenericText, % g_vMapTabToDesc[sThisTab]

	return
}

Window_Master_GoToSequencingTab:
{
	GUI, Window_Master_:Default

	if (SequencingTabIsActive())
		return

	GUIControl, Choose, vWMTab, 1
	gosub Window_Master_TabProc
	return
}
Window_Master_GoToResizingTab:
{
	GUI, Window_Master_:Default

	if (ResizingTabIsActive())
		return

	GUIControl, Choose, vWMTab, 2
	gosub Window_Master_TabProc
	return
}
Window_Master_GoToSnapTab:
{
	GUI, Window_Master_:Default

	if (SnapTabIsActive())
		return

	GUIControl, Choose, vWMTab, 3
	gosub Window_Master_TabProc
	return
}
Window_Master_GoToPrecisionTab:
{
	GUI, Window_Master_:Default

	if (PrecisionTabIsActive())
		return

	GUIControl, Choose, vWMTab, 4
	gosub Window_Master_TabProc
	return
}
Window_Master_GoToOtherActionsTab:
{
	GUI, Window_Master_:Default

	if (OtherActionsTabIsActive())
		return

	GUIControl, Choose, vWMTab, 4
	gosub Window_Master_TabProc
	return
}
Window_Master_GoToLeapTab:
{
	GUI, Window_Master_:Default

	if (LeapTabIsActive())
		return

	GUIControl, Choose, vWMTab, 5
	gosub Window_Master_TabProc
	return
}

InitSequenceControls()
{
	GUI Window_Master_: Default

	LoadAllHKs()
	LoadSequencesForHK(GetFirstHK())

	GUIControl, Focus, vHotkeysLV ; Start focued here.
	SendInput {Up} ; Sloppy workaround, but its an easy way to trigger hkllist/sequence proc.

	return
}

InitResizingControls()
{
	GUI Window_Master_: Default

	LoadOpts("Resizing")
	SelectAndFocusGenericLV()

	return
}

InitSnapControls()
{
	GUI Window_Master_: Default

	LoadOpts("Snap")
	SelectAndFocusGenericLV()

	return
}

InitPrecisionControls()
{
	GUI Window_Master_: Default

	LoadPrecisionOpts()
	SelectAndFocusGenericLV()

	return
}

InitSettingsControls()
{
	GUI Window_Master_: Default

	LoadOpts("Settings")
	SelectAndFocusGenericLV()

	return
}

InitLeapControls()
{
	GUI Window_Master_: Default

	LoadLeapOpts()
	SelectAndFocusGenericLV()

	return
}

SelectAndFocusGenericLV()
{
	GUIControl, Window_Master_:Focus, vGenericLV
	LV_Modify(1, "Focus")
	LV_Modify(1, "Select")
	return
}

MoveGenericButtons()
{
	global g_iMSDNStdBtnSpacing

	if (SequencingTabIsActive())
		return

	GUIControlGet, iGenericLV, Pos, vGenericLV
	GUIControlGet, iBtn, Pos, vPrecisionAdd
	iGenericLVX-- ; It is more aesthetic to start the first button 1pixel before the ListView.
	iBtnW += g_iMSDNStdBtnSpacing

	if (PrecisionTabIsActive())
	{
		GUIControl, Move, vPrecisionLVEdit, % "X" iGenericLVX
		GUIControl, Move, vPrecisionAdd, % "X" iGenericLVX+iBtnW
		GUIControl, Move, vPrecisionDelete, % "X" iGenericLVX+(iBtnW*2)
	}
	else
	{
		GUIControl, Move, vGenericLVEdit, % "X" iGenericLVX
	}

	return
}

GenericLVModify:
{
	LV_SetDefault("Window_Master_", "vGenericLV")

	if (GetCurIniForSave() = "g_HotkeysIni" || GetCurIniForSave() = "g_LeapActionsIni")
	{
		sHK := LV_GetSelText(2)

		if (LeapTabIsActive())
		{
			sAppendToTitle := LV_GetSelText()
			sGestureID := g_LeapActionsIni[LV_GetSelText()].GestureName
			g_vDlgs.ShowHKDlg_ForLeap(g_hWindowMaster, sHK, sGestureID, sAppendToTitle)
		}
		else
		{
			LV_SetDefault("Window_Master_", "vGenericLV")
			sHK := LV_GetSelText(2)
			sAppendToTitle := LV_GetSelText()
			sGestureID := g_HotkeysIni[sAppendToTitle].GestureName
			g_vDlgs.ShowHKDlg_ForGenericLV(g_hWindowMaster, sHK, sGestureID, sAppendToTitle)
		}
	}
	else GenericLV_ModifyPrecision()

	return
}

GenericLVProc:
{
	Critical ; so that we receive checked and unchecked notifications.
	LV_SetDefault("Window_Master_", "vGenericLV")

	LV_CheckProc(ErrorLevel)

	if (PrecisionTabIsActive() && LV_GetCount() < 1)
	{
		GUIControl, Disable, vPrecisionLVEdit
		GUIControl, Disable, vGenericLVEdit
	}
	else
	{
		GUIControl, Enable, vPrecisionLVEdit
		GUIControl, Enable, vGenericLVEdit
	}

	sIni := GetCurIniForSave()
	sHelpDesc := %sIni%[LV_GetSelText()].HelpDesc
	GUIControl,, vGenericLVHelpTxt, %sHelpDesc%

	if (A_GuiEvent = "DoubleClick" || A_EventInfo == 113) ; 113 = F2
	{
		gosub GenericLVModify
		return
	}

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: LV_ModifyPrecision
		Purpose:
	Parameters
		
*/
GenericLV_ModifyPrecision()
{
	global
	LV_SetDefault("Window_Master_", "vGenericLV")

	if (LV_GetCount() > 0)
	{
		sHK := LV_GetSelText(2)
		sGesture := g_PrecisionIni[LV_GetSel()].GestureName
		GetSequenceValsForEditDlg(iX, iY, iW, iH)
		sAction := "Placement #" LV_GetSel()

		g_vDlgs.PrecisionDlg.ShowDlg(g_hWindowMaster, sHK, sGesture, iX, iY, iW, iH, sAction)
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GenericLV_ModifyHK
		Purpose: To modify an item in the GenericLV.
	Parameters
		sHK
		sGestureID=""
*/
GenericLV_ModifyHK(sHK, sGestureID="", bMustHaveHotkey=true)
{
	global g_HotkeysIni, g_bHasLeap, g_bShouldSave
	LV_SetDefault("Window_Master_", "vGenericLV")

	if (bMustHaveHotkey && !GenericLV_ValidateHK(sHK, sError))
	{
		Msgbox(sError)
		return false
	}

	; Note: Although the Precision tab is linked to g_HotkeysIni, precision editing is specially handled in Add/ModifyPrecisionItem()

	; Hotkey
	g_HotkeysIni[LV_GetSelText()].Hotkey := sHK

	; Gesture
	if (sGestureID && !SetGestureIDInIni(g_HotkeysIni, LV_GetSelText(), sGestureID, sError))
	{
		Msgbox(sError, 2)
		return false
	}

	if (g_bHasLeap)
		LV_Modify(LV_GetSel(), "", LV_GetSelText(), sHK, sGestureID)
	else LV_Modify(LV_GetSel(), "", LV_GetSelText(), sHK)

	g_bShouldSave := true
	return true
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GenericLV_ModifyLeap
		Purpose: To modify items in the GenericLV under the Leap tab.
	Parameters
		sHK: Actually can be blank, but paramters are not reversed due to the generic (and rightly so) code in class HKDlg.
		sGestureID
*/
GenericLV_ModifyLeap(sHK, sGestureID)
{
	global g_LeapActionsIni, g_bShouldSave
	LV_SetDefault("Window_Master_", "vGenericLV")

	sec := LV_GetSelText()

	if (sHK)
	{
		if (!GenericLV_ValidateHK(sHK, sError))
		{
			Msgbox(sError)
			return false
		}

		g_LeapActionsIni[sec].Hotkey := sHK
	}
	else g_LeapActionsIni[sec].Hotkey := "" ; Blank-out the hotkey.

	; Gesture
	if (!SetGestureIDInIni(g_LeapActionsIni, sec, sGestureID, sError))
	{
		Msgbox(sError, 2)
		return false
	}

	LV_Modify(LV_GetSel(), "", sec, sHK, sGestureID)

	g_bShouldSave := true
	return true
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GenericLV_ValidateHK
		Purpose: To validate an item in the GgenericLV.
	Parameters
		sHK
		rsError
*/
GenericLV_ValidateHK(sHK, ByRef rsError)
{
	rsError := ""

	LV_SetDefault("Window_Master_", "vGenericLV")
	return core_ValidateHK(sHK, 2, true, "Generic", rsError)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GenericLV_ClearAll
		Purpose: To remove all columns and rows from GenericLV.As a habit, we completely clear out ListView before loading any options.
			Note: The first column can not be deleted.
	Parameters
		
*/
GenericLV_ClearAll()
{
	LV_SetDefault("Window_Master_", "vGenericLV")
	LV_Delete()

	Loop % LV_GetCount("Column")
		LV_DeleteCol(A_Index)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: SizeLV
		Purpose:
	Parameters
		sLV: ListView to size
*/
SizeLV(sLV)
{
	global g_bHasLeap

	GUI, ListView, %sLV%
	GUIControlGet, iLV, Pos, %sLV%

	iRoomForVertScroll := 11 ; px
	; For non-leap users, this LV is too wide unless we use a 28px subtractor.
	if (sLV = "vSequenceLV" || (sLV = "vHotkeysLV" && !g_bHasLeap))
		iRoomForVertScroll := 28

	Loop % LV_GetCount("Column")
		LV_ModifyCol(A_Index, iLVW/LV_GetCount("Column")-iRoomForVertScroll)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadOpts(sOptionType)
{
	global g_HotkeysIni, g_bHasLeap, g_hGenericLV

	GenericLV_ClearAll()
	LV_ModifyCol(1, "", "Action")
	LV_InsertCol(2, "", "Hotkey")
	if (g_bHasLeap)
		LV_InsertCol(3, "", "Gesture")
	SizeLV("vGenericLV")

	for sec, aData in g_HotkeysIni
	{
		if (aData.Type = sOptionType)
		{
			iCurRow++

			sCheckState := GetCheckState(aData.Activate)
			if (g_bHasLeap)
				LV_Add(sCheckState, sec, aData.Hotkey, aData.GestureName)
			else LV_Add(sCheckState, sec, aData.Hotkey)
		}
	}

	return
}

LoadPrecisionOpts()
{
	global g_PrecisionIni, g_bHasLeap, g_hGenericLV

	GenericLV_ClearAll()
	LV_ModifyCol(1, "", "Placement")
	LV_InsertCol(2, "", "Hotkey")
	if (g_bHasLeap)
		LV_InsertCol(3, "", "Gesture")
	SizeLV("vGenericLV")

	for sec, aData in g_PrecisionIni
	{
		iCurRow++

		sCheckState := GetCheckState(aData.Activate)
		for key, val in aData
		{
			if (abs(key) >= 0) ; is number doesn't work
			{
				if (g_bHasLeap)
					LV_Add(sCheckState, FormatSequenceForLV(val), aData.Hotkey, aData.GestureName)
				else LV_Add(sCheckState, FormatSequenceForLV(val), aData.Hotkey)
			}
		}
	}

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: LoadLeapOpts
		Purpose: To load leap options into the Leap tab
	Parameters
		
*/
LoadLeapOpts()
{
	global g_LeapActionsIni

	GenericLV_ClearAll()
	LV_ModifyCol(1, "", "Action")
	LV_InsertCol(2, "", "Hotkey")
	LV_InsertCol(3, "", "Gesture")
	SizeLV("vGenericLV")

	for sec, aData in g_LeapActionsIni
	{
		if (InStr(sec, "Internal_"))
			continue

		sCheckState := GetCheckState(aData.Activate)
		LV_Add(sCheckState, sec, aData.Hotkey, aData.GestureName)
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Labels
HKList:
{
	Critical ; Needed for checking/unchecking
	LV_SetDefault("Window_Master_", "vHotkeysLV")

	iThisErrorLevel := ErrorLevel

	if (LV_GetCount() == 0)
		GUIControl, Disable, vEditHK
	else GUIControl, Enable, vEditHK

	if (!g_SequencesIni.HasKey(1))
	{	; No sequences exist
		LV_SetDefault("Window_Master_", "vSequenceLV")
		LV_Delete() ; Clear this out in case the last hotkey was just deleted.
		return
	}

	LV_CheckProc(iThisErrorLevel)

	if (A_GUIEvent = "DoubleClick" || A_EventInfo == 113) ; 113 = F2
	{
		gosub EditHK
		return
	}

	if (A_GUIEvent == "Normal"
		|| A_GUIEvent == "I"
		|| A_EventInfo == 33 ; PgUp
		|| A_EventInfo == 34 ; PgDn
		|| A_EventInfo == 38 ; ArrowUp
		|| A_EventInfo == 40 ; ArrowDown
		|| A_ThisHotkey == "Delete"
		|| A_ThisHotkey == "!-")
	{
		LV_SetDefault("Window_Master_", "vHotkeysLV")
		iCurSel := LV_GetSel()
		sCurSelHK := LV_GetSelText()

		if (iCurSel != g_iPrevSel || g_bFromDeleteBtn)
		{
			if (g_bFromDeleteBtn)
				g_bFromDeleteBtn := false

			DeleteSequence(-1, false) ; - 1 means delete all.

			LoadSequencesForHK(sCurSelHK)
			gosub Sequence ; This will update the window preview template
		}
	}

	g_iPrevSel := iCurSel
	return
}
AddHKForSequence:
{
	g_vDlgs.ShowHKDlg_ForSequence(g_hWindowMaster, false)
	return
}

EditHK:
{
	LV_SetDefault("Window_Master_", "vHotkeysLV")

	if (g_bHasLeap)
	{
		sAppendToTitle := "Sequence Hotkey #" LV_GetSel()
		sExistingGesture := g_SequencesIni[LV_GetSel()].GestureName
	}
	else sAppendToTitle := sExistingGesture := ""

	g_vDlgs.ShowHKDlg_ForSequence(g_hWindowMaster, true, LV_GetSelText(), sExistingGesture, sAppendToTitle)
	return
}
DeleteHK:
{
	DeleteHK()

	; Needed as a workaround for a problem with loading up sequences for the selected hotkey.
	g_bFromDeleteBtn := true
	gosub HKList
	g_bFromDeleteBtn := false
	return
}
Sequence:
{
	LV_SetDefault("Window_Master_", "vSequenceLV")

	if (LV_GetCount() == 0)
		GUIControl, Disable, vEditSeq
	else GUIControl, Enable, vEditSeq

	if (LV_GetSel() > 0 LV_GetSel() < LV_GetCount())
	{
		sXText := GUIControlGet("", "sXText")
		sYText := GUIControlGet("", "sYText")
		sWText := GUIControlGet("", "sWText")
		sHText := GUIControlGet("", "sHText")
		GetSequenceValsForEditDlg(iX, iY, iW, iH)
		GUIControl,, sXText, %A_Space%x: %iX% ; X becomes truncated, slightly, without A_Space.
		GUIControl,, sYText, %A_Space%y: %iY%
		GUIControl,, sWText, %A_Space%width: %iW%
		GUIControl,, sHText, %A_Space%height: %iH%
}

	if (A_GUIEvent = "DoubleClick" || A_EventInfo == 113) ; 113 = F2
	{
		gosub EditSeq
		return
	}

	if (A_GUIEvent == "Normal"
		|| A_GUIEvent == "I"
		|| A_GUIEvent == "f"
		|| A_EventInfo == 33 ; PgUp
		|| A_EventInfo == 34 ; PgDn
		|| A_EventInfo == 38 ; ArrowUp
		|| A_EventInfo == 40) ; ArrowDown
	{
		LV_SetDefault("Window_Master_", "vSequenceLV")

		GUIControlGet, iMonFrame, Pos, vDesktopPic
		GetDimsPctForSeq(FormatSequenceForIni(GetSequenceFromIni()), iXPct, iYPct, iWPct, iHPct)

		iX := Floor(iMonFrameW*iXPct)/100+iMonFrameX
		iY := Floor(iMonFrameH*iYPct)/100+iMonFrameY
		iW := Floor(iMonFrameW*iWPct)/100
		iH := Floor(iMonFrameH*iHPct)/100

		GUIControl, Move, vWndPic, x%iX% y%iY% w%iW% h%iH%
	}

	return
}
AddSeq:
{
	LV_SetDefault("Window_Master_", "vSequenceLV")

	g_vDlgs.SequenceDlg.ShowDlg(g_hWindowMaster, false)
	return
}
EditSeq:
{
	LV_SetDefault("Window_Master_", "vSequenceLV")

	GetSequenceValsForEditDlg(iX, iY, iW, iH)
	g_vDlgs.SequenceDlg.ShowDlg(g_hWindowMaster, true, iX, iY, iW, iH)
	return
}
DeleteSeq:
{
	DeleteSequence()
	return
}
Window_Master_GUISize:
{
	; This fixes a strang resizing bug, likely somewhere in my own code instead of in Anchor2(),
	; where the GUI height is 0 and the width is 890. This happens upon initialization,
	; so all anchoring going forward is screwed up using those values.
	if (A_GuiWidth < 890 && A_GuiHeight < 494)
		return

	gosub Sequence ; This places the sequence mini window accordingly

	ControlGetPos, iX, iY, iW, iH,, ahk_id %g_hSequence%

	Anchor2("Window_Master_:vMainBorder", "xwyh", "0, 1, 0, 1")
	Anchor2("Window_Master_:g_vWindow_Master_OKBtn", "xwyh", "1, 0, 1, 0")
	Anchor2("Window_Master_:g_vWindow_Master_CancelBtn", "xwyh", "1, 0, 1, 0")
	Anchor2("Window_Master_:vSeqHKGroupBox", "xwyh", "0, 1, 0, 1")
	; Hotkeys
	Anchor2("Window_Master_:vHotkeysLV", "xwyh", "0, 0.5, 0, 1")
	Anchor2("Window_Master_:vAddHKForSequence", "xwyh", "0, 0, 1, 0")
	Anchor2("Window_Master_:vEditHK", "xwyh", "0, 0, 1, 0")
	Anchor2("Window_Master_:vDelHK", "xwyh", "0, 0, 1, 0")
	; Sequence
	Anchor2("Window_Master_:vSequenceLV", "xwyh", "0.5, 0.5, 0, 1")
	Anchor2("Window_Master_:vAddSeq", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:vEditSeq", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:vDelSeq", "xwyh", "0.5, 0, 1, 0")
	; Preview
	Anchor2("Window_Master_:vGroupPreview", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:vMonitorFramePic", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:vDesktopPic", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:vWndPic", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:sXText", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:sYText", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:sWText", "xwyh", "0.5, 0, 1, 0")
	Anchor2("Window_Master_:sHText", "xwyh", "0.5, 0, 1, 0")
	; Generic LV/Other tabs
	Anchor2("Window_Master_:vGenericText", "xwyh", "0.5, 0, 0, 0")
	Anchor2("Window_Master_:vGenericLVHelpTxt", "xwyh", "0, 1, 1, 0")
	Anchor2("Window_Master_:vGenericLV", "xwyh", "0, 1, 0, 1")
	Anchor2("Window_Master_:vGenericLVEdit", "xwyh", "0, 0, 1, 0")
	; Precision
	;~ Anchor2("Window_Master_:vPrecisionAdd", "xwyh", "0, 0, 1, 0")
	;~ Anchor2("Window_Master_:vPrecisionLVEdit", "xwyh", "0, 0, 1, 0")
	;~ Anchor2("Window_Master_:vPrecisionDelete", "xwyh", "0, 0, 1, 0")

	sLVParse := "vHotkeysLV|vSequenceLV|vGenericLV"
	Loop, Parse, sLVParse, |
		SizeLV(A_LoopField)

	WinSet, Redraw,, ahk_id %g_hWindowMaster%
	return
}
Window_Master_GUICancel:
{
	; Don't save anything, just close.
	g_bShouldSave := false
	gosub Window_Master_GUIClose
	return
}

Window_Master_OK:
Window_Master_GUIEscape:
Window_Master_GUIClose:
{
	; If the user, Canceled, Escaped, Alt+F4'd, etc.
	if (g_bShouldSave
		&& (A_GuiControl = "&Cancel"
		|| A_GuiControl == A_Blank))
	{
		MsgBox, 8195, Close Window Master, Save your settings before closing?

		IfMsgBox Yes
		g_bShouldSave := true
		else IfMsgBox Cancel
			return
		else g_bShouldSave := false
	}

	gosub Window_Master_CloseProc

	GUI, Window_Master_:Hide

	; Note: The below block was originally placed in LaunchMainDlg; it has been moved because RegRead is VERY slow.
	; Also note how we do this AFTER we have hidden the GUI.
	{
		; Update the GUI picture control showing the desktop background, just in case that picture has changed.
		; Note: Not using WM_SettingChange because this does not get trigged when a desktop background
		; changes as a result of moving to a new slide (When multiple images are seleceted, this is slideshow mode).
		GUI, Window_Master_:Default
		RegRead, sCurBgd, HKEY_CURRENT_USER, Control Panel\Desktop, Wallpaper
		if (sCurBgd == "")
			sCurBgd := "images\Default Flyout Menu.jpg"
		GUIControl,, vDesktopPic, %sCurBgd%
	}

	return
}

Window_Master_Reload:
{
	IfWinActive, % "ahk_id" g_vLeap.m_hGesturesConfigDlg
		WinClose
	else IfWinActive, % "ahk_id" g_vLeap.m_hControlCenterDlg
		WinClose
	g_vLeap.__Delete() ; If one of the dlgs were active, then the proper __Delete routines will not fire.

	g_dll := g_vMH := g_vLeap := ""
	Reload
} ; Fall through
Window_Master_Exit:
{
	g_dll := g_vMH := g_vLeap := "" ; g_vLeap should be released since it is responsible for AutoLeap.exe
	ExitApp
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Window_Master_CloseProc
		Purpose: To handle saving/discard changes to inis, which also includes handling the various hotkey threads.
	Parameters
		None
*/
Window_Master_CloseProc:
{
	if (g_bShouldSave)
	{
		; Save all settings.
		Loop, Parse, g_sInisForParsing, |
			%A_LoopField%.Save()

		; Settings were changed, so our threads must be refreshed.
		InitThreads()

		g_bShouldSave := false
	}
	else
	{
		InitAllInis()
		; TODO: Fix problem in class_EasyIni.ahk. Until then, InitAllInis()
		;~ Loop, Parse, g_sInisForParsing, |
			;~ %A_LoopField%.Reload()
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadSequencesForHK(sHK)
{
	global g_SequencesIni

	LV_SetDefault("Window_Master_", "vSequenceLV")
	LV_Delete() ; As a habit, clear out listview before loading.

	for sec, aData in g_SequencesIni
		if (sHK = aData.Hotkey)
			for k, v in aData
				if (abs(k) >= 0) ; Numbers are sequences, anything else are internal keys.
				{	; If I don't set the default LV here, then, sometimes, the sequnces get loaded into the hotkeys.
					LV_SetDefault("Window_Master_", "vSequenceLV")
					LV_Add("", FormatSequenceForLV(v))
				}

	LV_Modify(1, "Focus")
	LV_Modify(1, "Select")

	; Refresh the preview window.
	gosub Sequence

	return
}

FormatSequenceForLV(seq)
{
	if (IsObject(seq))
		sSeq := FormatSequenceForIni(seq)
	else sSeq := " " seq

	; Replace "=" with ": ".
	StringReplace, sSeq, sSeq, `=,`:%A_Space%, All
	; Replace tabs with 3 spaces.
	StringReplace, sSeq, sSeq, %A_Tab%,%A_Space%%A_Space%%A_Space%, All

	return sSeq
}

FormatSequenceForIni(vSeq)
{
	return "x=" vSeq.m_iX "`ty=" vSeq.m_iY "`twidth=" vSeq.m_iW "`theight=" vSeq.m_iH
}

GetSequenceFromIni(sSeq="")
{
	global g_SequencesIni

	if (!sSeq)
	{
		LV_SetDefault("Window_Master_", "vHotkeysLV")
		sec := LV_GetSel()
		LV_SetDefault("Window_Master_", "vSequenceLV")
		iSeq := LV_GetSel()
		sSeq := g_SequencesIni[sec][iSeq]
	}

	vSeq := []
	Loop, Parse, sSeq, `t
	{
		LoopField := A_LoopField
		iPosOfEq := InStr(LoopField, "=")
		StringLeft, key, LoopField, iPosOfEq-1
		StringRight, val, LoopField, StrLen(LoopField)-iPosOfEq

		if (key = "x")
			sThisKey := "m_iX"
		else if (key = "y")
			sThisKey := "m_iY"
		else if (key = "width")
			sThisKey := "m_iW"
		else if (key = "height")
			sThisKey := "m_iH"

		vSeq[sThisKey] := val
	}

	return vSeq
}

GetSequenceValsForEditDlg(ByRef riX, ByRef riY, ByRef riW, ByRef riH, vSeq="")
{
	global g_SequencesIni

	if (!IsObject(vSeq))
		vSeq := GetSequenceFromIni()

	riX := vSeq.m_iX
	riY := vSeq.m_iY
	riW := vSeq.m_iW
	riH := vSeq.m_iH

	return
}

/*
	Author: Verdlin
	Label: To launch the Window Master help file.
		Purpose:
*/
Window_Master_Help:
{
	Run, Help.chm
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Label: Window_Master_Credits
		Purpose: To give credit to whom credit is due.
*/
Window_Master_About:
{
	FileRead, sFile, ReadMe.txt
	StringReplace, sFile, sFile, `t, %A_Space%%A_Space%%A_Space%%A_Space%, All
	FileRead, iVersion, version
	StringReplace, sFile, sFile, `%VERSION`%, %iVersion%, All

	GUI, AboutDlg_:New, hwndg_hCreditsDlg

	iFarRight := 850-g_iMSDNStdBtnW
	GUI, Add, Link, w%iFarRight%, %sFile%
	GUI, Add, Button, X%iFarRight% W%g_iMSDNStdBtnW% H%g_iMSDNStdBtnH% gAboutDlg_GUIEscape, &OK

	GUI, Show, x-32768 AutoSize
	CenterWndOnOwner(g_hCreditsDlg, g_hWindowMaster)

	iFarRight :=
	return

	AboutDlg_GUIEscape:
	AboutDlg_GUIClose:
	{
		GUI, AboutDlg_:Destroy
		return
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ConvertWinSplitXMLSettingsToInis:
{
	CreateAndShowImportDlg()
	return
}

CreateAndShowImportDlg()
{
	global

	; TODO: Idea of function to add an text, edit, and an ellipsis button (FIle selector edit)
	GUI, XMLImportDlg_:New, hwndg_hXMLImportDlg +Owner%g_hWindowMaster%, Import WinSplit* Settings
	GUI, Add, Text, x10 y5 h20 gXMLImportDlg_SelectHotkeysXML, Path to &Hotkeys.xml:
	GUI, Add, Edit, xp+100 yp-3 w300 hp vg_vXMLImportDlg_HotkeysXMLEdit -TabStop ReadOnly,
	GUI, Add, Button, xp+301 yp-1 w20 h22 gXMLImportDlg_SelectHotkeysXML, ...
	GUI, Add, Text, xp-401 yp+30 h20 gXMLImportDlg_SelectLayoutXML, Path to &Layout.xml:
	GUI, Add, Edit, xp+100 yp-3 w300 hp vg_vXMLImportDlg_LayoutXMLEdit -TabStop ReadOnly,
	GUI, Add, Button, xp+301 yp-1 w20 h22 gXMLImportDlg_SelectLayoutXML, ...
	GUI, Add, GroupBox, xp-401 yp+30 w420 h80 Center, If an imported setting matches an existing setting...
	GUI, Add, Radio, xp+2 yp+20, Igno&re imported setting
	GUI, Add, Radio, xp yp+30 vg_bXMLImportDlg_OverwriteExisting Checked, Over&write existing setting
	GUI, Add, Button, xp+265 yp+32 w75 h23 vg_vXMLImportDlg_OKBtn gXMLImportDlg_DoImport Disabled, &OK
	GUI, Add, Button, xp+79 yp wp hp gXMLImportDlg_GUIClose, &Cancel

	WinSet, Disable,, ahk_id %g_hWindowMaster%
	GUI, Show, x-32768 AutoSize
	CenterWndOnOwner(g_hXMLImportDlg, g_hWindowMaster)

	return

	XMLImportDlg_SelectHotkeysXML:
	{
		if (XMLImportDlg_SelectFile("Hotkeys.xml")
			&& GUIControlGet("", "g_vXMLImportDlg_LayoutXMLEdit"))
			GUIControl, Enable, g_vXMLImportDlg_OKBtn
		return
	}

	XMLImportDlg_SelectLayoutXML:
	{
		if (XMLImportDlg_SelectFile("Layout.xml")
			&& GUIControlGet("", "g_vXMLImportDlg_HotkeysXMLEdit"))
			GUIControl, Enable, g_vXMLImportDlg_OKBtn
		return
	}

	XMLImportDlg_DoImport:
	{
		sHotkeysXML				:= GUIControlGet("", "g_vXMLImportDlg_HotkeysXMLEdit")
		sLayoutXML				:= GUIControlGet("", "g_vXMLImportDlg_LayoutXMLEdit")
		bOverwriteExisting	:= GUIControlGet("", "g_bXMLImportDlg_OverwriteExisting")

		if (ConvertWinSplitXMLSettingsToInis(sHotkeysXML, sLayoutXML, bOverwriteExisting, sError))
			Msgbox("WinSplit* settings were imported successfully.")
		else
		{
			Msgbox(sError)
			return
		}

		; Refresh current tab
		gosub Window_Master_TabProc
		; Exit GUI
		gosub XMLImportDlg_GUIEscape
		return
	}

	XMLImportDlg_GUIEscape:
	XMLImportDlg_GUIClose:
	{
		WinSet, Enable,, ahk_id %g_hWindowMaster%
		GUI, XMLImportDlg_:Destroy

		return
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: XMLImportDlg_SelectFile
		Purpose: Localize logic for grabbing Win-Split xml files
	Parameters
		sFIleName: The file name to look for (i.e. Layout.xml or Hotkeys.xml).
*/
XMLImportDlg_SelectFile(sFileName)
{
	GUI, +OwnDialogs

	if (FileExist(A_ProgramFiles "\WinSplit Revolution"))
		sFolder := A_ProgramFiles "\WinSplit Revolution"

	FileSelectFile, sFile,, %sFolder%, Navigate to %sFileName% (located in your WinSplit installation directory), *.xml
	if (sFile)
	{
		if (sFileName = "Hotkeys.xml")
			GUIControl,, g_vXMLImportDlg_HotkeysXMLEdit, %sFile%
		else if (sFileName = "Layout.xml")
			GUIControl,, g_vXMLImportDlg_LayoutXMLEdit, %sFile%
	}

	return sFile
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ConvertWinSplitXMLSettingsToInis
		Purpose: Import Win-Splits Hotkeys.xml and Layout.xml, and metamorphose these settings into Window Master ini settings
	Parameters
		sHotkeysXML: Path to Hotkeys.xml
		sLayoutXML: Path to Layout.xml
		bOverwriteExisting: May need to get rid of
		rsError: Error message if the function failed
*/
ConvertWinSplitXMLSettingsToInis(sHotkeysXML, sLayoutXML, bOverwriteExisting, ByRef rsError)
{
	global g_HotkeysIni

	rsError :=

	vSequenceLVsIni := ConvertWinSplitLayoutXMLToIni(sLayoutXML, bOverwriteExisting, rsError)
	if (!IsObject(vSequenceLVsIni))
		return false

	xpath_load(vDoc, sHotkeysXML)
	sAllNodes := xpath(vDoc, "/WinSplit_HotKeys/*")

	if (sAllNodes == A_Blank)
	{
		rsError := "Error: " sHotkeysXML " is missing the element <WinSplit_HotKeys>"
		return false
	}

	vHotkeysLVIni := class_EasyIni()

	iSeq := 0
	StringSplit, sNodes, sAllNodes, `,
	; It is more friendly to loop in reverse order because this will make the Sequences
	; appear in the same order in the interface that they appeared in Win-Split's interface.
	iDec := sNodes0 + 1
	while (iDec-- > 0)
	{
		sCurNode := sNodes%iDec%
		sParNode := SubStr(sCurNode, 2, InStr(sCurNode, A_Space)-2)
		StringReplace, sCurNode, sCurNode, `", , All
		StringReplace, sCurNode, sCurNode, `<%sParNode% , , All
		StringReplace, sCurNode, sCurNode, `</%sParNode%, , All
		StringReplace, sCurNode, sCurNode, `>, , All
		sCurNode := Trim(sCurNode)
		vNode := ParseWinSplitNode(sCurNode)

		if (vSequenceLVsIni.HasKey(sParNode))
		{
			iSeq++
			if (!vSequenceLVsIni.RenameSection(sParNode, iSeq, rsError))
				return false

			if (!vSequenceLVsIni.AddKey(iSeq, "Hotkey", vNode.Hotkey, rsError)) ; TODO: No spaces for hotkeys in ALL inis.
				|| !vSequenceLVsIni.AddKey(iSeq, "Activate", vNode.Activate, rsError)
				return false
		}

		if (IsLabel(sParNode)
		|| sParNode = "WindowToRigthScreen" ; Win-Split misspelled this key, lol.
		|| sParNode = "WindowToLeftScreen"
		|| sParNode = "AlwaysOnTop")
		{
			if (sParNode = "WindowToRigthScreen")
				sParNode := "WindowToRightMonitor"
			else if (sParNode = "WindowToLeftScreen")
				sParNode := "WindowToLeftMonitor"
			else if (sParNode = "AlwaysOnTop")
				sParNode := "ToggleAlwaysOnTop"

			; Insert spaces between each capitalized key.
			aUps := []
			Loop % StrLen(sParNode)
			{
				sLetter := SubStr(sParNode, A_Index, 1)
				StringUpper, sLetterUp, sLetter
				if (sLetter == sLetterUp) ; is upper is not working here
					aUps.Insert((A_Index == 1 ? 1 : A_Index))
			}

			iTotalUps := aUps.MaxIndex()
			sSec :=
			Loop %iTotalUps%
			{
				iEndPos := aUps[A_Index+1] - aUps[A_Index]
				if (A_Index == iTotalUps)
					iEndPos := StrLen(sParNode) - StrLen(sSec) + iTotalUps

				sSec .= SubStr(sParNode, aUps[A_Index], iEndPos)
				if (A_Index < iTotalUps)
					sSec .= " "
			}

			if (!vHotkeysLVIni.AddSection(sSec, "Hotkey", vNode.Hotkey, rsError)
				|| !vHotkeysLVIni.AddKey(sSec, "Activate", vNode.Activate, rsError))
				return false
		}
	}

	/*
		If we do not need to overwrite existing settings, then don't even merge g_HotkeysIni.
		This is because the only sections from vHotkeysLVIni which would not exist in g_HotkeysIni are
		settings which are not supported.

		Note: There is a bug with merging either of these inis -- that is, the hotkeys are not validated upon import.
		Invalid hotkeys are possible, although not likely.
		More possible is the case where a hotkey will be imported and will conflict with a pre-existing hotkey.
	*/

	if (bOverwriteExisting)
		g_HotkeysIni.Merge(vHotkeysLVIni, false, bOverwriteExisting) ; bRemoveNonMatching = false
	MergeSequencesInis(vSequenceLVsIni, bOverwriteExisting)

	return true
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ParseWinSplitNode
		Purpose: Localize logic for parsing Win-Split XML nodes
	Parameters
		sNode: A node from a Win-Split XML
*/
ParseWinSplitNode(sNode)
{
	vInfo := {Hotkey:"", Activate:"false"}
	; Use the dict below because it seems that Win-Split hotkeys, such as Ctrl+Alt+Left gets imported as Ctrl+Alt+NumpadLeft.
	; Other Numpad permutations are excluded because Win-Split does not allow the use of them in hotkys, unlike us ;).
	vMapToAvoidNumpad := {NumpadLeft:"Left", NumpadRight:"Right", NumpadUp:"Up", NumpadDown:"Down", NumpadPgUp:"PgUp", NumpadPgDn:"PgDn"}

	Loop, Parse, sNode, %A_Space%
	{
		iPosOfKey := InStr(A_LoopField, "=")
		key := SubStr(A_LoopField, 1, iPosOfKey-1)
		val := SubStr(A_LoopField, iPosOfKey+1)

		if (key = "Modifier1")
			vInfo.Hotkey := val " + "
		else if(key = "Modifier2")
			vInfo.Hotkey .= val " + "
		else if (key = "VirtualHotkey")
		{
			SetFormat, Integer, hex
			val += 0
			sKey := GetKeyName("vk" val)
			SetFormat, Integer, d

			if (vMapToAvoidNumpad.HasKey(sKey))
				sKey := vMapToAvoidNumpad[sKey]
			vInfo.Hotkey .= sKey
		}
		else if (key = "Activate")
			vInfo.Activate := val
	}

	return vInfo
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ConvertWinSplitLayoutXMLToIni
		Purpose: To return an class_EasyIni object for use in ConvertWinSplitXMLSettingsToInis
	Parameters
		sLayoutXML: Path to Layout.xml
		bOverwriteExisting: May need to get rid of
		rsError: Error message if the function failed
*/
ConvertWinSplitLayoutXMLToIni(sLayoutXML, bOverwriteExisting, ByRef rsError)
{
	global g_SequencesIni

	rsError :=

	xpath_load(vDoc, sLayoutXML)
	sAllNodes := xpath(vDoc, "/LayoutManager/*")
	if (sAllNodes ==A_Blank)
	{
		rsError := "Error: " sLayoutXML " is missing the element <LayoutManager>"
		return false
	}

	aSeqsToWinSplitNode := ["RightTop", "Top", "LeftTop", "Right", "FullScreen", "Left", "RightBottom", "Bottom", "LeftBottom"]
	vLayoutIni := class_EasyIni()
	StringSplit, asNodes, sAllNodes, `,
	Loop %asNodes0%
	{
		iCurNode := A_Index
		iMapping := asNodes0 - iCurNode + 1
		if (!vLayoutIni.AddSection(aSeqsToWinSplitNode[iMapping], "", "", rsError))
			return false

		while(s := xpath(vDoc, "/LayoutManager/Sequence_" iCurNode "/Combo_" A_Index-1))
		{
			StringReplace, s, s, `", , All
			iNum := A_Index-1
			StringReplace, s, s, `<Combo_%iNum%, , All
			StringReplace, s, s, `</Combo_%iNum%, , All
			StringReplace, s, s, `>, , All
			StringReplace, s, s, %A_Space%, , All

			Loop, Parse, s, `.
			{
				if (A_Index == 1)
				{
					sCompound := A_LoopField
					continue
				}
				sCompound .= "." SubStr(A_LoopField, 1, 2) "`t" SubStr(A_LoopField, 3)
			}

			sVal := Trim(sCompound)

			if (!vLayoutIni.AddKey(aSeqsToWinSplitNode[iMapping], A_Index, sVal, rsError))
				return false
		}
	}

	return vLayoutIni
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: MergeSequencesInis
		Purpose: Merges g_SequencesIni with the sequences ini imported from ConvertWinSplitXMLSettingsToInis
	Parameters
		vOther: Other class_EasyIni object
*/
MergeSequencesInis(vOther, bOverwriteExisting)
{
	global g_SequencesIni

	if (g_SequencesIni.IsEmpty())
	{ ; Ini is empty, so just copy over and exit.
		g_SequencesIni := vOther
		g_SequencesIni.EasyIni_ReservedFor_m_sFile := A_ScriptDir "\sequences.ini"
		return
	}

	aHotkeysTranslated := []
	for otherSec, aOtherData in vOther
	{ ; Section names are ambiguous, so the real test is to match the hotkeys in each ini

		for sec, aData in g_SequencesIni
		{
			sTranslatedHK := TranslateHKForHotkeyCmd(aData.Hotkey)
			sOtherTranslatedHK := TranslateHKForHotkeyCmd(aOtherData.Hotkey)

			if (sTranslatedHK = sOtherTranslatedHK)
			{ ; This sequence has already been defined
				if (bOverwriteExisting && !IsInLinearArray(aHotkeysTranslated, sTranslatedHK))
				{
					aHotkeysTranslated.Insert(sTranslatedHK)
					sGestureToKeep := aData.Gesture ; Leap Motion is not supported in Win-Split, so we can be safe keeping the gesture for this sequences.
					g_SequencesIni[sec] := aOtherData ; TODO: Verify that this really does modify g_SequencesIni
					; Not using error handling because I cannot conceive an error happening here;
					; also, it would be difficult to recover from any error.
					g_SequencesIni.AddKey(sec, "GestureName", sGestureToKeep)
				}
				else continue
			}
		}
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: IsInLinearArray
		Purpose: To determine whether search is in linear array a
	Parameters
		a: array
		search: item to search for
		riNdx: index of item in array
*/
IsInLinearArray(a, search, ByRef riNdx="")
{
	riNdx :=

	Loop % a.MaxIndex()
		if (a[A_Index] = search)
		{
			riNdx := A_Index
			return true
		}

	return false
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AddSequence(vSeq, iSeqNum="")
{
	global g_SequencesIni, g_bShouldSave

	LV_SetDefault("Window_Master_", "vSequenceLV")

	; ValidateSequence(sSeq)

	if (iSeqNum == A_Blank)
		iSeqNum := LV_GetCount() + 1

	; Save to ini
	LV_SetDefault("Window_Master_", "vHotkeysLV") ; Needed to identify section number
	if (!g_SequencesIni.AddKey(LV_GetSel(), iSeqNum, FormatSequenceForIni(vSeq), sError))
	{
		Msgbox(sError, 2)
		return false
	}

	LV_SetDefault("Window_Master_", "vSequenceLV")
	LV_Insert(iSeqNum, "", FormatSequenceForLV(vSeq))
	LV_SetSel(iSeqNum)

	g_bShouldSave := true
	return true
}

ModifySequence(vSeq, iAt=0)
{
	global g_SequencesIni, g_bShouldSave

	LV_SetDefault("Window_Master_", "vSequenceLV")

	; ValidateSequence(vSeq)

	if (!iAt)
		iAt := LV_GetSel()

	LV_SetDefault("Window_Master_", "vHotkeysLV")
	iCurSec := LV_GetSel()
	LV_SetDefault("Window_Master_", "vSequenceLV")
	g_SequencesIni[iCurSec][iAt] := FormatSequenceForIni(vSeq)

	LV_Modify(iAt, "", FormatSequenceForLV(vSeq))

	g_bShouldSave := true
	return true
}

DeleteSequence(iSeq="", bRemoveFromIni=true)
{
	global g_SequencesIni, g_bShouldSave

	LV_SetDefault("Window_Master_", "vSequenceLV")

	if (iSeq == -1 && !bRemoveFromIni)
	{
		LV_Delete()
		return
	}

	if (iSeq == A_Blank)
		iSeq := LV_GetSel()
	LV_Delete(iSeq)

	LV_SetDefault("Window_Master_", "vHotkeysLV")
	iHK := LV_GetSel()

	if (bRemoveFromIni)
	{ ; Remove from ini.
		g_SequencesIni.DeleteKey(iHK, iSeq)
		LV_SetDefault("Window_Master_", "vSequenceLV")
	}

	if (iSeq > LV_GetCount())
		iSeq--
	LV_Modify(iSeq, "Select")
	LV_Modify(iSeq, "Focus")

	if (A_GUIControl = "vDelSeq")
		GUIControl, Focus, vSequenceLV
	gosub HKList

	g_bShouldSave := true
	return
}

AddPrecisionItem(vSeq, s2, sGestureID="")
{
	global g_PrecisionIni, g_bHasLeap, g_bShouldSave

	LV_SetDefault("Window_Master_", "vGenericLV")

	if (!ValidatePrecisionItem(s2, false))
		return false

	iAt := LV_GetCount() == 0 ? 1 : LV_GetCount() + 1

	; Save to ini
	if (!(g_PrecisionIni.AddSection(iAt, "Hotkey", s2, sError)
		&& g_PrecisionIni.AddKey(iAt, "Activate", "true", sError)
		&& g_PrecisionIni.AddKey(iAt, 1, FormatSequenceForIni(vSeq), sError)))
		{
			Msgbox(sError, 2)
			return false
		}

	if (sGestureID && !SetGestureIDInIni(g_PrecisionIni, iAt, sGestureID, sError))
	{
		Msgbox(sError, 2)
		return false
	}

	if (g_bHasLeap)
		LV_Insert(iAt, "-Checked", FormatSequenceForLV(vSeq), s2, sGestureID)
	else LV_Insert(iAt, "-Checked", FormatSequenceForLV(vSeq), s2)

	LV_SetSel(iInsertAt)

	g_bShouldSave := true
	return true
}

ModifyPrecisionItem(sNewPlacement, sNewHK, sGestureID="", bMustHaveHotkey=true)
{
	global g_PrecisionIni, g_bHasLeap, g_bShouldSave
	LV_SetDefault("Window_Master_", "vGenericLV")

	if (bMustHaveHotkey && !ValidatePrecisionItem(sNewHK, true))
		return false

	iAt := LV_GetSel()
	LV_GetText(sOldSec, iAt, 2)

	aData := g_PrecisionIni[iAt]
	aData.Hotkey := sNewHK
	aData[1] := FormatSequenceForIni(sNewPlacement) ; for the time being, at least, only 1 precision item is alloted per hotkey.

	if (sGestureID && !SetGestureIDInIni(g_PrecisionIni, iAt, sGestureID, sError))
	{
		Msgbox(sError, 2)
		return false
	}

	sCheckState := GetCheckState(aData.Activate)
	if (g_bHasLeap)
		LV_Modify(iAt, sCheckState, sNewPlacement, sNewHK, sGestureID)
	else LV_Modify(iAt, sCheckState, sNewPlacement, sNewHK)

	g_bShouldSave := true
	return true
}

ValidatePrecisionItem(sHK, bModifyExisting, ByRef rsError="")
{
	LV_SetDefault("Window_Master_", "vGenericLV")
	return core_ValidateHK(sHK, 2, bModifyExisting, "Precision", rsError)
}

AddPrecisionPlacement:
{
	g_vDlgs.PrecisionDlg.ShowDlg(g_hWindowMaster)
	return
}

ModifyPrecisionPlacement:
{
	GenericLV_ModifyPrecision()
	return
}

DeletePrecisionPlacement:
{
	DeletePrecisionItem()
	return
}

DeletePrecisionItem(iAt=0)
{
	global g_PrecisionIni, g_bShouldSave

	LV_SetDefault("Window_Master_", "vGenericLV")

	if (iAt == A_Blank || iAt == 0)
		iAt := LV_GetSel()
	LV_GetText(s, iAt)
	s2:=LV_GetSel()
	LV_Delete(iAt)

	; Save to ini
	g_PrecisionIni.DeleteSection(iAt)

	; Refocus snd select LV.
	if (iAt > LV_GetCount())
		iAt--
	LV_Modify(iAt, "Focus")
	LV_Modify(iAt, "Select")

	g_bShouldSave := true
	return
}

LoadAllHKs()
{
	global g_SequencesIni, g_bHasLeap

	LV_SetDefault("Window_Master_", "vHotkeysLV")
	LV_Delete() ; As a habit, clear out listview before loading

	for sec, aData in g_SequencesIni
	{
		LV_SetDefault("Window_Master_", "vHotkeysLV") ; If I don't put this here, then, sometimes, the hotkeys get loaded into the sequences.

		sCheckState := GetCheckState(aData.Activate)
		if (A_Index == 1)
			sCheckState1 := GetCheckState(aData.Activate)

		sHK := aData.Hotkey

		if (g_bHasLeap)
			LV_Add(sCheckState, aData.Hotkey, aData.GestureName)
		else LV_Add(sCheckState, aData.Hotkey)
	}

	LV_Modify(1, "Focus")
	LV_Modify(1, "Select")
	LV_Modify(1, sCheckState1)
	SizeLV("vHotkeysLV")

	return
}

GetFirstHK()
{
	global g_SequencesIni
	return g_SequencesIni.1.Hotkey
}

AddHKForSequence(sHK, sGestureID="")
{
	global g_SequencesIni, g_bHasLeap, g_bShouldSave

	LV_SetDefault("Window_Master_", "vHotkeysLV")

	if (!ValidateHK(sHK, false))
		return false

	iInsertAt := LV_GetCount() + 1
	if (iInsertAt = 0)
		iInsertAt = 1

	if (g_bHasLeap)
		LV_Insert(iInsertAt, "-Checked", sHK, sGestureID)
	else LV_Insert(iInsertAt, "-Checked", sHK)

	; No sequences to add, yet, so store this variable.
	if (!g_SequencesIni.AddSection(iInsertAt, "Hotkey", sHK, sError)
		|| !SetGestureIDInIni(g_SequencesIni, iInsertAt, sGestureID, sError))
	{
		Msgbox(sError, 2)
		return false
	}

	LV_SetSel(iInsertAt)

	g_bShouldSave := true
	return true
}

ModifyHKForSequence(sHK, sGestureID="")
{
	global g_SequencesIni, g_bHasLeap, g_bShouldSave

	if (!ValidateHK(sHK, true))
		return false

	iAt := LV_GetSel()
	sOldHK :=LV_GetSelText()

	if (g_bHasLeap)
		LV_Modify(iAt, s, sHK, sGestureID)
	else LV_Modify(iAt, "", sHK)

	g_SequencesIni[iAt].Hotkey := sHK
	if (!SetGestureIDInIni(g_SequencesIni, iAt, sGestureID, sError)) ; if the sGestureID is blank, no harm done
	{
		Msgbox(sError, 2)
		return false
	}

	g_bShouldSave := true
	return true
}

ValidateHK(sHK, bModifyExisting, ByRef rsError="")
{
	if (SequencingTabIsActive())
	{
		LV_SetDefault("Window_Master_", "vHotkeysLV")
		iHKCol := 1
	}
	else
	{
		LV_SetDefault("Window_Master_", "vGenericLV")
		iHKCol := 2
	}

	return core_ValidateHK(sHK, iHKCol, bModifyExisting, "Sequencing", rsError)
}

DeleteHK(iHK="")
{
	global g_SequencesIni, g_iPrevSel, g_bShouldSave

	LV_SetDefault("Window_Master_", "vHotkeysLV")

	if (iHK == A_Blank)
		iHK := LV_GetSel()

	LV_GetText(sHK, iHK)
	LV_Delete(iHK)

	; Save to ini
	g_SequencesIni.DeleteSection(iHK)
	g_iPrevSel--

	; Refocus and select hotkey.
	if (iHK > LV_GetCount())
		iHK--
	LV_Modify(iHK, "Focus")
	LV_Modify(iHK, "Select")

	GUIControl, Focus, vHotkeysLV

	g_bShouldSave := true
	return
}

/*
Caller is responsible for setting the default ListView.
Since we save ListView setting to ini each time the view is changed,
we only over need to loop through the current ListView to get its list of hotkeys.
All other hotkeys can reliably be retrieved from ini objects.
Logic for Left/Right/Either hotkeys outlined below

      Hotkey  | Either | Left  |  Right
      ______________________
      Either    | Yes     | No   |   No
      Left        | No       | Yes |   Yes
      Right     | No       | Yes |   Yes
      ______________________
*/
core_ValidateHK(sHK, iHotkeyCol, bModifyExisting, sFromLV, ByRef rsOptError="")
{
	global g_SequencesIni, g_PrecisionIni, g_HotkeysIni, g_asTabs

	rsOptError := ""

	; -------------------------- Possible Hotkey Enumerations --------------------------
	; sHK := Ctrl + Alt + NumPad1
	;	 No other legal combination of modifiers is possible!

	; sHK := LCtrl + Alt + NumPad1
	;	1. sHK := RCtrl + Alt + NumPad1 -- but NOT Ctrl + Alt + Numpad1

	; With any one of the following hotkeys, the other three combinations are possible
	; However, Ctrl + Alt + Numpad1 is NOT possible with any of the following combinations:
	; sHK := LCtrl + LAlt + NumPad1
	;	1. sHK := LCtrl + RAlt + NumPad1
	;	2. sHK := RCtrl + LAlt + NumPad1
	;	3. sHK := RCtrl + RAlt + NumPad1
	; ------------------------------------------------------------------------------------------------

	if (sHK = "FALSE")
		return false

	sGUI := "HLDlg"
	if (sFromLV = "Precision")
		sGUI := "PrecisionDlg"
	sParse := "g_SequencesIni|g_PrecisionIni"

	if (SequencingTabIsActive())
	{
		sSkipIni := "g_SequencesIni"
		sParse := "g_PrecisionIni"
	}
	else if (ResizingTabIsActive())
		sSkipType := "Resizing"
	else if (SnapTabIsActive())
		sSkipType := "Snap"
	else if (PrecisionTabIsActive())
	{
		sSkipIni := "g_PrecisionIni"
		sParse := "g_SequencesIni"
	}
	else if (OtherActionsTabIsActive())
		sSkipType := "Settings"

	if (sSkipIni = "g_SequencesIni")
		sAction := "Sequence Hotkey #"
	else if (sSkipIni = "g_PrecisionIni")
		sAction := "Precise Placement Hotkey #"

	bUseTextFromLV := sAction == A_Blank

	GetLRHKModifiers(sHK, sHKLRCtrl, sHKLRAlt, sHKLRShift, sHKLRWin)
	sTranslatedHKToValidate := TranslateHKForHotkeyCmd(sHK)

	aHotkeysToValidate := []
	iSkip := bModifyExisting ? LV_GetSel() : -1
	Loop % LV_GetCount()
	{
		if (A_Index != iSkip)
		{
			LV_GetText(sCurHK, A_Index, iHotkeyCol)
			if (sHK = sCurHk)
			{ ; found an exact match, so we may validate
				if (bUseTextFromLV)
					LV_GetText(sAction, A_Index, iHotkeyCol == 2 ? 1 : 2)
				else sAction .= A_Index

				rsOptError := Validate_Error_Msg({sHK:sHK, sAction:sAction})
				return false
			}
			else if (sTranslatedHKToValidate = TranslateHKForHotkeyCmd(sCurHK))
			{
				if (bUseTextFromLV)
					LV_GetText(sAction, A_Index, iHotkeyCol == 2 ? 1 : 2)
				aHotkeysToValidate.Insert({sHK:sCurHK, sAction:(bUseTextFromLV ? sAction : sAction A_Index)})
			}
		}
	}

	; [Action name]
	for sec, aData in g_HotkeysIni
	{
		if (bHasKey)
		{ ; found an exact match, so we may validate
			rsOptError := Validate_Error_Msg({sHK:g_HotkeysIni[sec].Hotkey, sAction:sec})
			return false
		}
		else bHasKey := g_HotkeysIni[sec].HasKey(sHK)

		; Activate=true
		; Hotkey=Ctrl + Alt + 4
		; Type=Settings
		if (aData.Type = sSkipType)
			continue


		if (sHK = aData.Hotkey)
		{
			rsOptError := Validate_Error_Msg({sHK:sHK, sAction:sec})
			return false
		}
		if (TranslateHKForHotkeyCmd(aData.Hotkey) = sTranslatedHKToValidate)
			aHotkeysToValidate.Insert({sHK:aData.Hotkey, sAction:sec})
	}

	Loop, Parse, sParse, |
	{
		if (A_LoopField = "g_SequencesIni")
			sAction := "Sequence Hotkey #"
		else if (A_LoopField = "g_PrecisionIni")
			sAction := "Precise Placement Hotkey #"

		for sec, aData in %A_LoopField%
		{
			if (sHK = aData.Hotkey)
			{
				rsOptError := Validate_Error_Msg({sHK:sHK, sAction:sAction A_Index})
				return false
			}

			if (sTranslatedHKToValidate = TranslateHKForHotkeyCmd(aData.Hotkey))
				aHotkeysToValidate.Insert({sHK:aData.Hotkey, sAction:sAction A_Index})
		}
	}

	Loop % aHotkeysToValidate.MaxIndex()
	{
		sThisHK := aHotkeysToValidate[A_Index].sHK
		GetLRHKModifiers(sThisHK, sLRCtrl, sLRAlt, sLRShift, sLRWin)
		sThisTranslatedHK := TranslateHKForHotkeyCmd(sThisHK)

		; if we have matching modifiers, and sHK specifies that both L/R modifiers may be used but an existing HK specified that only L or R may be used, do not allow
		; Note: It is unnecessary to check if the modifiers match exactly because bHasKey will catch those scenarios.
		b1 := (sHKLRCtrl && !sLRCtrl) || (!sHKLRCtrl && sLRCtrl)
		b2 := (sHKLRAlt && !sLRAlt) || (!sHKLRAlt && sLRAlt)
		b3 := (sHKLRShift && !sLRShift) || (!sHKLRShift && sLRShift)
		b4 := (sHKLRWin && !sLRWin) || (!sHKLRWin && sLRWin)
		;~ Msgbox %b1%`n%b2%`n%b3%`n%b4%`n`n%sHKLRCtrl%`t%sLRCtrl%`n%sHKLRAlt%`t%sLRAlt%`n%sHKLRShift%`t%sLRShift%`n%sHKLRWin%`t%sLRWin%`n`n%sThisHK%`n%sThisTranslatedHK%`n%sHK%`n%sTranslatedHKToValidate%
		if (b1 || b2 || b3 || b4)
		{
			rsOptError := Validate_Error_Msg(aHotkeysToValidate[A_Index])
			return false
		}
	}
	return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: core_ValidateGesture
		Purpose: To validate 
	Parameters
		sGestureID
		bFromEdit
		rsError: Error to output if the functions fails.
*/
core_ValidateGesture(sGestureID, bFromEdit, ByRef rsError)
{
	global g_SequencesIni, g_PrecisionIni, g_HotkeysIni, g_LeapActionsIni, g_sInisForParsing
	rsError:=

	if (sGestureID == A_Blank)
		return true

	if (bFromEdit)
	{	; then we have to make sure we don't validate the selected gesture!
		LV_SetDefault("Window_Master_", "vGenericLV")

		if (SequencingTabIsActive())
		{
			sSkipIni := "g_SequencesIni"

			LV_SetDefault("Window_Master_", "vHotkeysLV")
			sSecToSkip := LV_GetSel()
		}
		else if (PrecisionTabIsActive())
		{
			sSkipIni := "g_PrecisionIni"
			sSecToSkip := LV_GetSel()
		}
		else if (LeapTabIsActive())
		{
			sSkipIni := "g_LeapActionsIni"
			sSecToSkip := LV_GetSelText()
		}
		else
		{
			sSkipIni := "g_HotkeysIni"
			sSecToSkip := LV_GetSelText()
		}
	}

	Loop, Parse, g_sInisForParsing, |
	{
		for sec, aData in %A_LoopFIeld%
		{
			if (A_LoopField = sSkipIni && sec = sSecToSkip)
				continue ; we landed on the gesture being validated.

			if (sGestureID = aData.GestureName)
			{
				if (A_LoopField = "g_SequencesIni")
					sErrorPart := "Sequence Hotkey #" sec
				else if (A_LoopField = "g_PrecisionIni")
					sErrorPart := "Precision Hotkey #" sec
				else
					sErrorPart := sec

				rsError := "The selected gesture is already assigned to " sErrorPart "`n`nGesture:`t" sGestureID (aData.Hotkey == A_Blank ? "" : "`nHotkey`t`t" aData.Hotkey)
				return false
			}
		}
	}

	return true
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GetLRHKModifiers
		Purpose: To pass out modifiers if L or R is explicitly given.
	Parameters
		sHK: Should be in the following form: LCtrl+RAlt+LShift+RWin
*/
GetLRHKModifiers(sHK, ByRef sLRCtrl, ByRef sLRAlt, ByRef sLRShift, ByRef sLRWin)
{
	global g_sModParse

	Loop, Parse, g_sModParse, |
	{
		iPosOfMod := InStr(sHK, A_LoopField)
		sLR := SubStr(sHK, iPosOfMod-1, 1)
		if (iPosOfMod && (sLR = "L" || sLR = "R"))
			sLR%A_LoopField% := sLR
	}
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: TranslateHKForHotkeyCmd
		Purpose:
	Parameters
		
*/
TranslateHKForHotkeyCmd(sHK)
{
	StringReplace, sHK, sHK, `+, , All ; Remove all +s

	StringReplace, sHK, sHK, LCtrl%A_Space%, `^
	StringReplace, sHK, sHK, RCtrl%A_Space%, `^
	StringReplace, sHK, sHK, Ctrl%A_Space%, `^
	StringReplace, sHK, sHK, LAlt%A_Space%, `!
	StringReplace, sHK, sHK, RAlt%A_Space%, `!
	StringReplace, sHK, sHK, Alt%A_Space%, `!
	StringReplace, sHK, sHK, LShift%A_Space%, `+
	StringReplace, sHK, sHK, RShift%A_Space%, `+
	StringReplace, sHK, sHK, Shift%A_Space%, `+
	StringReplace, sHK, sHK, LWin%A_Space%, `#
	StringReplace, sHK, sHK, RWin%A_Space%, `#
	StringReplace, sHK, sHK, Win%A_Space%, `#

	StringReplace, sHK, sHK, %A_Space%, , All ; Remove all spaces

	return sHK
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Validate_Error_Msg
		Purpose: To localize logic for warning about hotkey conflicts.
	Parameters
		vHKInfo. This is a simple object with two keys
			1. sHK. This is the conflicted hotkey
			2. sAction. This is the action that the hotkey is assigned to
*/
Validate_Error_Msg(vHKInfo)
{
	return "Hotkey combination conflicts with an existing hotkey!`n`nAction:`t`t`t" vHKInfo.sAction "`nConflicting hotkey:`t" vHKInfo.sHK
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			Hotkey threading			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
*/
StartHotkeyThread()
{
	; Creates a thread handler for hotkeys/labels.
	global g_SequencesIni, g_PrecisionIni, g_HotkeysIni, g_LeapActionsIni, g_dll, g_bIsDev

	if (g_SequencesIni.HasKey(1))
		sInis := "g_SequencesIni"
	if (g_PrecisionIni.HasKey(1))
		sInis .= "|g_PrecisionIni"

	vDictLabelsCreated := {}
	Loop, Parse, sInis, |
	{
		; Store every hotkey in an array. When building the labels, if more than one action exists for this hotkey, create accordingly.
		avLabelInfo := {}
		sIni := A_LoopField
		for sec, aData in %sIni%
		{
			; If the hotkey was deactivated, don't even add it.
			; Also, if the hotkey is blank, then skip adding it because this will just result in an error anyway.
			if (aData.Activate = "false" || aData.Hotkey == A_Blank)
				continue

			vLabelInfo := {sRawHK: "", sExpr: "", sSec:""}
			sHK := "$" TranslateHKForHotkeyCmd(aData.Hotkey)
			sExpr:=
			sHKParse := aData.Hotkey
			Loop, Parse, sHKParse, +
			{
				LoopField := Trim(A_LoopField, A_Space)
				if (LoopField = "Win")
					sExpr .= " && (GetKeyState(""LWin"" , ""P"") " "|| GetKeyState(""RWin"" , ""P""))"
				else sExpr .= " && GetKeyState(""" LoopField """ , ""P"")"
			}
			sExpr := "(" LTrim(sExpr, " && ") ")"

			vLabelInfo.sRawHK := sHKParse
			vLabelInfo.sExpr := sExpr
			vLabelInfo.sSec := sec

			if (avLabelInfo.HasKey(sHK))
				avLabelInfo[sHK].Insert(vLabelInfo)
			else avLabelInfo.Insert(sHK, [vLabelInfo])
		}

		for sec, aData in %sIni%
		{
			if (aData.Activate = "false" || aData.Hotkey == A_Blank)
				continue

			sLabel := "$" TranslateHKForHotkeyCmd(aData.Hotkey)

			sExpr :=
			Loop % avLabelInfo[sLabel].MaxIndex()
			{
				sIfElse := A_Index == 1 ? "if" : "`nelse if"
				sExpr .= sIfElse "(" avLabelInfo[sLabel][A_Index].sExpr ")`n`t"
				if (sIni = "g_SequencesIni")
					sExpr .= "g_exe.ahkFunction[""SequenceWnd"", """ avLabelInfo[sLabel][A_Index].sSec """]"
				else if (sIni = "g_PrecisionIni")
					sExpr .= "g_exe.ahkFunction[""DoPrecisePlacement"", """ avLabelInfo[sLabel][A_Index].sSec """]"
			}

			if (!vDictLabelsCreated.HasKey(sLabel))
			{
				sLabelDefs .="
					(LTrim

					" sLabel ":
					{
						Critical

						" sExpr "
						return
					}

					)"

				sHKs .= "|" sLabel
				vDictLabelsCreated.Insert(sLabel, sLabel)
			}
		}
	}

	avLabelInfo := {}
	for sec in g_HotkeysIni
	{
		; Store every hotkey in an array. When building the labels, if more than one action exists for this hotkey, create accordingly.
		if (g_HotkeysIni[sec].Activate = "false" || g_HotkeysIni[sec].Hotkey == A_Blank)
			continue

		vLabelInfo := {sRawHK: "", sExpr: ""}
		sRawHK := g_HotkeysIni[sec].Hotkey
		sExpr:=

		Loop, Parse, sRawHK, +
		{
			LoopField := Trim(A_LoopField, A_Space)
			if (LoopField = "Win")
				sExpr .= " && (GetKeyState(""LWin"" , ""P"") " "|| GetKeyState(""RWin"" , ""P""))"
			else sExpr .= " && GetKeyState(""" LoopField """ , ""P"")"
		}
		sExpr := "(" LTrim(sExpr, " && ") ")"

		vLabelInfo.sRawHK := sRawHK
		vLabelInfo.sExpr := sExpr

		if (avLabelInfo.HasKey(sec))
			avLabelInfo[sec].Insert(vLabelInfo)
		else avLabelInfo.Insert(sec, [vLabelInfo])
	}

	for sec, aData in g_HotkeysIni
	{
		if (aData.Activate = "false" || aData.Hotkey == A_Blank)
			continue

		sLabel := "$" TranslateHKForHotkeyCmd(aData.Hotkey)

		sExpr :=
		Loop % avLabelInfo[sec].MaxIndex()
		{
			sIfElse := A_Index == 1 ? "if" : "`nelse if"
			sExpr .= sIfElse "(" avLabelInfo[sec][A_Index].sExpr ")`n`t"

			if (aData.RouteToLeapWhenAvailable = "true")
				sExpr .= "g_exe.ahkPostFunction[""Leap_ActionFromHotkey"", """ sec """]"
			else sExpr .= "g_exe.ahkLabel[""" CallableFromSec(sec) """]"
		}

		if (!vDictLabelsCreated.HasKey(sLabel))
		{
			sLabelDefs .="
				(LTrim

				" sLabel ":
				{
					Critical

					" sExpr "
					return
				}

				)"

			sHKs .= "|" sLabel
			vDictLabelsCreated.Insert(sLabel, sLabel)
		}
	}

	avLabelInfo := {}
	for sec, aData in g_LeapActionsIni
	{
		; Store every hotkey in an array. When building the labels, if more than one action exists for this hotkey, create accordingly.
		if (aData.Activate = "false" || aData.Hotkey == A_Blank || InStr(sec, "Internal_"))
			continue

		vLabelInfo := {sRawHK: "", sExpr: ""}
		sRawHK := aData.Hotkey
		sExpr:=

		Loop, Parse, sRawHK, +
		{
			LoopField := Trim(A_LoopField, A_Space)
			if (LoopField = "Win")
				sExpr .= " && (GetKeyState(""LWin"" , ""P"") " "|| GetKeyState(""RWin"" , ""P""))"
			else sExpr .= " && GetKeyState(""" LoopField """ , ""P"")"
		}
		sExpr := "(" LTrim(sExpr, " && ") ")"

		vLabelInfo.sRawHK := sRawHK
		vLabelInfo.sExpr := sExpr

		if (avLabelInfo.HasKey(sec))
			avLabelInfo[sec].Insert(vLabelInfo)
		else avLabelInfo.Insert(sec, [vLabelInfo])
	}

	for sec, aData in g_LeapActionsIni
	{
		if (aData.Activate = "false" || aData.Hotkey == A_Blank)
			continue

		sLabel := "$" TranslateHKForHotkeyCmd(aData.Hotkey)

		sExpr :=
		Loop % avLabelInfo[sec].MaxIndex()
		{
			sIfElse := A_Index == 1 ? "if" : "`nelse if"
			sExpr .= sIfElse "(" avLabelInfo[sec][A_Index].sExpr ")`n`t"

			sExpr .= "g_exe.ahkPostFunction[""Leap_ActionFromHotkey"", """ sec """]"
		}

		if (!vDictLabelsCreated.HasKey(sLabel))
		{
			sLabelDefs .="
				(LTrim

				" sLabel ":
				{
					Critical

					" sExpr "
					return
				}

				)"

			sHKs .= "|" sLabel
			vDictLabelsCreated.Insert(sLabel, sLabel)
		}
	}

	if (sLabelDefs)
	{
		sScript:="
		(LTrim

			SetBatchLines -1
			`#Persistent
			`#NoTrayIcon

			InitLabel:
			{
				Hotkey, IfWinActive
				sHKs := """ . LTrim(sHKs, "|") . """
				Loop, Parse, sHKs, |
					Hotkey, `%A_LoopField`%, `%A_LoopField`%
				return
			}

			Suspend(sOnOrOff)
			{
				Suspend, %sOnOrOff%
				return
			}

			ExitApp:
				ExitApp

		)" . sLabelDefs
	}

	if (g_bIsDev) ; For debugging
	{
		filedelete, test2.ahk
		fileappend, %sScript%, test2.ahk
	}

	if (sScript)
	{
		g_dll:=CriticalObject(AhkDllThread(A_IsCompiled ? "..\..\AutoHotkey.dll" : SubStr(A_AhkExe(),1,-3) "dll"))
		g_dll.ahktextdll[CreateScript("g_exe:=CriticalObject(" . &AhkExported() . ")"sScript)]
	}

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: CheckProc
		Purpose:
	Parameters
		iErrorLevelFromLV
*/
LV_CheckProc(iErrorLevelFromLV)
{
	if (A_GuiEvent == "I" && (GetKeyState("Space", "P") || GetKeyState("LButton", "P")))
	{
		if (iErrorLevelFromLV == "C")
			EnableDisableKeyInIni(true, A_EventInfo)
		else if (iErrorLevelFromLV == "c")
			EnableDisableKeyInIni(false, A_EventInfo)
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnableDisableKeyInIni(b, iRow)
{
	global

	sIni := GetCurIniForSave()

	if (sIni != "g_SequencesIni" && sIni != "g_PrecisionIni")
	{
		LV_SetDefault("Window_Master_", "vGenericLV")
		LV_GetText(sec, iRow)
	}
	else sec := iRow

	sTF := (b ? "true" : "false")
	if (%sIni%[sec].Activate = sTF)
		return ; Helps avoid needless prompts to save.

	%sIni%[sec].Activate := sTF
	g_bShouldSave := true

	return
}

GetCurIniForSave()
{
	if (SequencingTabIsActive())
		return "g_SequencesIni"
	else if (ResizingTabIsActive() || SnapTabIsActive() || OtherActionsTabIsActive())
		return "g_HotkeysIni"
	else if (PrecisionTabIsActive())
		return "g_PrecisionIni"
	else if (LeapTabIsActive())
		return "g_LeapActionsIni"
	else return "" ; Error. Perhaps this should be handled?
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
SetGestureIDInIni(vIni, sec, sGestureID, ByRef rsError)
{
	bRet := true

	if (vIni[sec].HasKey("GestureName"))
		vIni[sec].GestureName := sGestureID
	else bRet := vIni.AddKey(sec, "GestureName", sGestureID, rsError)

	return bRet
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
RemoveUnreferencedGestures()
{
	global

	; Gestures which have been mapped to actions in our inis may have been deleted.
	Loop, Parse, g_sInisForParsing, |
	{
		bSave := false
		for sec, aData in %A_LoopFIeld%
		{
			if (!g_vLeap.m_vGesturesIni.HasKey(aData.GestureName))
			{
				aData.GestureName := ""
				bSave := true
			}
		}

		if (bSave)
			%A_LoopField%.Save()
	}

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
SequencingTabIsActive()
{
	global g_vWMMainTab
	return (g_vWMMainTab.GetSel() == 1)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
ResizingTabIsActive()
{
	global g_vWMMainTab
	return (g_vWMMainTab.GetSel() == 2)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
SnapTabIsActive()
{
	global g_vWMMainTab
	return (g_vWMMainTab.GetSel() == 3)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
PrecisionTabIsActive()
{
	global g_vWMMainTab
	return false
	; TODO: Once the Precision feature is re-enabled, this function should return what is below.
	;~ return (g_vWMMainTab.GetSel() == 4)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
OtherActionsTabIsActive()
{
	global g_vWMMainTab
	; TODO: Once the Precision feature is re-enabled, this function should return 5
	return (g_vWMMainTab.GetSel() == 4)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
LeapTabIsActive()
{
	global g_vWMMainTab
	; TODO: Once the Precision feature is re-enabled, this function should return 6
	return (g_vWMMainTab.GetSel() == 5)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				BEGIN LEAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
Window_Master_LeapMsgHandler(sMsg, ByRef rLeapData, ByRef rasGestures, ByRef rsOutput)
{
	global g_SequencesIni, g_PrecisionIni, g_HotkeysIni, g_LeapActionsIni, g_sInisForParsing, g_vLeap, g_vLeapMsgProcessor

	bIsDataPost := (sMsg = "Post")

	; The below checks allows the hand(s) to go completely out of view without us ending the gesture.
	if (g_vLeapMsgProcessor.m_bUseTriggerGesture)
	{
		; When the hand is just coming into the FOV, there are usually no fingers immediately detected.
		g_vLeapMsgProcessor.m_iFrameCnt++
		if (g_vLeapMsgProcessor.m_iMSSinceLastFrame > 0)
		{
			if (A_TickCount-g_vLeapMsgProcessor.m_iMSSinceLastFrame > 1000
				|| ((g_vLeapMsgProcessor.m_sTriggerAction = "Scroll" || g_vLeapMsgProcessor.m_bGestureUsesPinch)
				&& A_TickCount-g_vLeapMsgProcessor.m_iMSSinceLastFrame > 1250))
			{
				g_vLeapMsgProcessor.m_iMSSinceLastFrame := 0
				g_vLeapMsgProcessor.m_iFrameCnt := 0
				g_vLeapMsgProcessor.m_bFistMadeDuringThreshold := g_vLeap.IsMakingFist(rLeapData)
			}
		}
		else g_vLeapMsgProcessor.m_iMSSinceLastFrame := (A_TickCount)
	}
	; End fist-checking.

	if (bIsDataPost && g_vLeapMsgProcessor.m_bCallbackNeedsGestures)
	{
		g_vLeapMsgProcessor.m_hTriggerGestureFunc.(rLeapData, rasGestures)
		return
	}

	; Leap_ functions stop getting called when g_vLeap.IsMakingFist(rLeapData)
	bActionHasStarted := g_vLeapMsgProcessor.m_bActionHasStarted
	bCallbackCanStop := g_vLeapMsgProcessor.m_bCallbackCanStop
	bCallbackWillStop := g_vLeapMsgProcessor.m_bCallbackWillStop

	if (!bCallbackWillStop && bActionHasStarted && bCallbackCanStop
		|| (bCallbackWillStop && g_vLeapMsgProcessor.m_bCallerHasFinished))
	{
		;~ if (g_vLeapMsgProcessor.m_bGestureUsesPinch)
			;~ g_vLeap.SendMessageToExe("Pinch=Stop")

		; Let the user know that and what we stopped tracking.
		g_vLeap.OSD_PostMsg("Stop " g_vLeapMsgProcessor.m_sTriggerAction)

		; If more functions like this are added, then another callback is in order.
		if (g_vLeapMsgProcessor.m_sTriggerAction = "Adjust Volume")
			VolumeOSD_Hide()

		ResetLeapMsgProcessor()
	}
	else if (sMsg = "Forward" && g_vLeapMsgProcessor.m_bUseTriggerGesture)
	{
		g_vLeapMsgProcessor.m_hTriggerGestureFunc.(rLeapData, rasGestures)

		; We have to start before we stop.
		if (!g_vLeapMsgProcessor.m_bActionHasStarted)
			g_vLeapMsgProcessor.m_bActionHasStarted := g_vLeapMsgProcessor.m_bCallbackCanStop

		if (g_vLeap.IsMakingFist(rLeapData) && g_vLeapMsgProcessor.m_bFistMadeDuringThreshold)
			g_vLeapMsgProcessor.m_bCallbackCanStop := true
	}

	sGesture := st_glue(rasGestures, ", ")
	if (sGesture == "")
		return

	for sec, aData in g_vLeap.m_vGesturesIni
	{
		if (sGesture = aData.Gesture)
		{
			bGestureExists := true
			break
		}
	}

	if (!bGestureExists)
		return

	if (bIsDataPost)
	{
		; Gesture is defined in Gestures.ini, so search to see if it is mapped to any action.
		Loop, Parse, g_sInisForParsing, |
		{
			for sec, aData in %A_LoopField%
			{
				bGestureIsMappedToAction := (sGesture = g_vLeap.m_vGesturesIni[aData.GestureName].Gesture)

				if (bGestureIsMappedToAction)
				{
					rsOutput := aData.GestureName
					break
				}
			}

			sCallable := CallableFromSec(sec)

			if (bGestureIsMappedToAction)
			{
				if (A_LoopField = "g_SequencesIni")
				{
					SequenceWnd(sec)
				}
				else if (A_LoopField = "g_PrecisionIni")
				{
					DoPrecisePlacement(sec)
				}
				else if (A_LoopField = "g_HotkeysIni")
				{
					if (aData.RouteToLeapWhenAvailable = "true")
						SetLeapMsgCallback(sCallable, g_LeapActionsIni["Internal_" sec], rsOutput)

					if (IsLabel(sCallable))
						gosub %sCallable%
					else rsOutput := "Error: Gesture not found"
				}
				else if (A_LoopField = "g_LeapActionsIni")
				{
					SetLeapMsgCallback(sCallable, aData, rsOutput)
				}

				break
			}
		}
	}

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ResetLeapMsgProcessor
		Purpose: To reset the Leap message processor.
	Parameters
		None
*/
ResetLeapMsgProcessor()
{
	global g_vLeap, g_vLeapMsgProcessor

	; There are gestures in the processor, and they will get forwarded to a mapped function upon data post unless we clear them now.
	if (g_vLeapMsgProcessor.m_bCallbackNeedsGestures)
		g_vLeap.ResetGestures()

	for k, v in g_vLeapMsgProcessor
		g_vLeapMsgProcessor[k] := 0 ; false for bools, and 0 for ints because you can't ++ A_Blank

	g_vLeap.m_vProcessor.m_bIgnoreGestures := false
	g_vLeap.m_vProcessor.m_bGestureSuggestions := true

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: SetLeapMsgCallback
		Purpose: When a chain of gestures is mapped to a Leap_* function, we must set up the appropriate vars here.
	Parameters
		sFunc: Partial function name derived from sec
		sec: Applicable sec within g_LeapActionsIni
		aData: Keys/vals data
		sTriggerAction: Identifer assigned to g_vLeapMsgProcessor.m_sTriggerAction
*/
SetLeapMsgCallback(sFunc, aData, sTriggerAction)
{
	global g_vLeap, g_vLeapMsgProcessor

	if (g_vLeapMsgProcessor.m_hTriggerGestureFunc := Func("Leap_" sFunc))
	{
		g_vLeapMsgProcessor.m_bUseTriggerGesture := true
		g_vLeapMsgProcessor.m_bCallbackNeedsGestures := (aData.UsesGestures = "true")
		g_vLeapMsgProcessor.m_bCallbackWillStop := (aData.CallbackWillStop = "true")
		g_vLeapMsgProcessor.m_bGestureUsesPinch := (aData.UsesPinch = "true")
		g_vLeapMsgProcessor.m_sTriggerAction := sTriggerAction

		g_vLeapMsgProcessor.m_bFistMadeDuringThreshold := false
		g_vLeapMsgProcessor.m_iFrameCnt := 0
		g_vLeapMsgProcessor.m_iMSSinceLastFrame := 0

		;~ if (g_vLeapMsgProcessor.m_bGestureUsesPinch)
			;~ g_vLeap.SendMessageToExe("Pinch=Start")
		if (!g_vLeapMsgProcessor.m_bCallbackNeedsGestures)
			g_vLeap.m_vProcessor.m_bIgnoreGestures := true ; Reduces noise and saves precious time in ProcessAutoLeapData.
		else g_vLeap.m_vProcessor.m_bGestureSuggestions := false ; We don't want gesture suggestions when are hooked to an action.
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
Window_Master_ShowControlCenterDlg:
{
	ShowControlCenterDlg(g_hWindowMaster)
	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
Window_Master_PlayPauseLeap:
{
	if (A_ThisMenuItem = "&Play " g_vLeap.m_sLeapTM)
	{
		g_vLeap.SetTrackState(true)
		Menu, TRAY, Rename, % "&Play " g_vLeap.m_sLeapTM, % "&Pause " g_vLeap.m_sLeapTM
		Menu, TRAY, Icon, % "&Pause " g_vLeap.m_sLeapTM, images\Pause.ico,, 16
	}
	else ; pause tracking.
	{
		g_vLeap.SetTrackState(false)
		Menu, TRAY, Rename, % "&Pause " g_vLeap.m_sLeapTM, % "&Play "g_vLeap.m_sLeapTM
		Menu, TRAY, Icon, % "&Play " g_vLeap.m_sLeapTM, images\Play.ico,, 16
	}

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_ActionFromHotkey
		Purpose: To trigger leap actions, such as Move Window, from a hotkey.
	Parameters
		sAction
*/
Leap_ActionFromHotkey(sAction)
{
	global g_SequencesIni, g_PrecisionIni, g_HotkeysIni, g_LeapActionsIni, g_sInisForParsing, g_vLeap, g_vMH

	Loop, Parse, g_sInisForParsing, |
	{
		for sec, aData in %A_LoopField%
		{
			if (sec = sAction)
			{
				bFoundMatch := true
				bRouteToLeap := aData.RouteToLeapWhenAvailable
				break
			}

		if (bFoundMatch)
			break
		}
	}

	if (bFoundMatch)
	{
		; When we redirect to LeapActionIni, we should be guaranteed that there is an identical section name prefixed with "Internal_"
		if (bRouteToLeap)
			aData := g_LeapActionsIni["Internal_" sAction]

		sFunc := CallableFromSec(sAction)
		SetLeapMsgCallback(sFunc, aData, sAction)
		; Post the action to the OSD.
		g_vLeap.OSD_PostMsg(sAction)

		; I hate hard-coding, but hopefully this is the only special case we need to handle.
		if (sAction = "Quick Menu")
			g_vMH.ShowMenu()
	}
	else Msgbox("Unable to determine function for action: " sAction, 2)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_MoveWindow
		Purpose: To move a window in real-time based upon a single-hand's palm position
	Parameters
		rLeapData
		rasGestures
		hWnd="A"
*/
Leap_MoveWindow(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	global g_vLeap, g_DictMonInfo
	;~ static s_bUsedTwoHanded, s_iTimeSinceTwoHandedCall := 0

	MakeValidHwnd(hWnd)

	; Tracking gets iffy at these points, and currently the interaction box class does not help with this problem.
	if (rLeapData.Hand1.PalmX > 290 || || rLeapData.Hand1.PalmX < -270 || rLeapData.Hand1.PalmY > 505)
		return

	; TODO: Two-handed resize?
	;~ ; There is an inconsistency in AutoLeap; namely, Hand2 *always* has fingers 6-10, regardless
	;~ ; of whether Hand1 has 1 or 5 fingers. I'll need to fix this sometime; for now, the check below is safe.
	;~ if (rLeapData.HasKey("Hand2") && rLeapData.HasKey("Finger6"))
	;~ {
		;~ s_iTimeSinceTwoHandedCall := (A_TickCount)
		;~ s_bUsedTwoHanded := true
		;~ return Leap_TwoHandResize(rLeapData, rasGestures, hWnd)
	;~ }
	;~ else if (s_bUsedTwoHanded && s_iTimeSinceTwoHandedCall > 0
		;~ && A_TickCount-s_iTimeSinceTwoHandedCall < 300)
	;~ {
		;~ ; May have lost tracking for a few frames; so give a 300ms buffer.
		;~ return
	;~ }
	;~ s_bUsedTwoHanded := false

	; Take into account the velocity.
	iVelocityX := abs(rLeapData.Hand1.VelocityX)
	iVelocityY := abs(rLeapData.Hand1.VelocityY)

	iVelocityXFactor := g_vLeap.CalcVelocityFactor(iVelocityX, 75)
	iVelocityYFactor := g_vLeap.CalcVelocityFactor(iVelocityY, 75)

/*
	Take into account the monitor the window is on
		1. When the window width is greater than 50% of the monitor's width, move the window's X less; otherwise, move it more.
		2. When the window height is greater than 50% of the monitor's height, move the window's Y less; otherwise, move it more.
*/
	GetWndPct(iWPct, iHPct, hWnd)

	iMonXFactor := (100-iWPct)/100
	iMonYFactor := (100-iHPct)/100

	if (iWPct < 49.99)
		iMonXFactor += 1
	if (iHPct < 49.99)
		iMonYFactor += 1

	; Get palm X and Y movement.
	g_vLeap.GetPalmDelta(rLeapData, iPalmXDelta, iPalmYDelta)
	iPalmXDelta *= -1 ; Movement should be reversed, in this particular case.

	WinGetPos, iCurX, iCurY,,, ahk_id %hWnd%

	; TODO: When skeletal tracking becomes available, we may be able to enable this or something like it.
	;~ bMoveAlongXOnly := (rLeapData.HasKey("Hand2") && rLeapData.HasKey("Finger8"))
	;~ bMoveAlongYOnly := (rLeapData.HasKey("Hand2") && rLeapData.HasKey("Finger7") && !rLeapData.HasKey("Finger8"))

	; Strip out noise from humanity's generable inability to stabilize their palms.
	if (abs(iPalmXDelta) > 0.35)
		iNewX := iCurX + (iPalmXDelta*(iVelocityXFactor+iMonXFactor))
	if (abs(iPalmYDelta) > 0.35)
		iNewY := iCurY + (iPalmYDelta*(iVelocityYFactor+iMonYFactor))

	bKeepOnMon := (iVelocityX < 500 && iVelocityY < 500)
	WndMove(iNewX, iNewY, "", "", hWnd, bKeepOnMon, false)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_TwoHandResize
		Purpose:
	Parameters
		rLeapData
		rasGestures
		hWnd="A"
*/
Leap_TwoHandResize(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	global g_vLeap

	MakeValidHwnd(hWnd)

	; TODO: Review GetPalmDiffDelta() to ensure that it is functioning properly.
	g_vLeap.GetPalmDiffDelta(rLeapData, iPalmDiffXDelta, iPalmDiffYDelta, iLastPalmDiffX, iLastPalmDiffY)

	bShrinkW := iPalmDiffXDelta<iLastPalmDiffX
	bShrinkH := iPalmDiffYDelta<iLastPalmDiffY

	; Take into account the velocity.
	iVelocityX := abs(rLeapData.Hand1.VelocityX)
	iVelocityY := abs(rLeapData.Hand1.VelocityY)

	iVelocityXFactor := g_vLeap.CalcVelocityFactor(iVelocityX, 150)
	iVelocityYFactor := g_vLeap.CalcVelocityFactor(iVelocityY, 150)

	WinGetPos, iCurX, iCurY, iCurW, iCurH, ahk_id %hWnd%
	if (abs(iPalmDiffXDelta) > 0.05)
	{
		iPixelsToMove := iPalmDiffXDelta*iVelocityXFactor
		iX	:=	Round(bShrinkW ? iCurX+(iPixelsToMove/2) : iCurX-(iPixelsToMove/2))
		iW	:=	Round(bShrinkW ? iCurW-iPixelsToMove: iCurW+iPixelsToMove)
	}
	if (abs(iPalmDiffYDelta) > 0.05)
	{
		iPixelsToMove := iPalmDiffYDelta*iVelocityYFactor
		iY	:=	Round(bShrinkH ? iCurY+(iPixelsToMove/2) : iCurY-(iPixelsToMove/2))
		iH	:=	Round(bShrinkH ? iCurH-iPixelsToMove : iCurH+iPixelsToMove)
	}

	bKeepOnMon := (iVelocityX < 700 && iVelocityY < 700)
	WndMove(iX, iY, iW, iH, hWnd, bKeepOnMon, false)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_PinchWindow
		Purpose: To resize a window based up a single hand's finger positioning.
	Parameters
		rLeapData
		hWnd="A"
*/
Leap_ResizeWindow(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	; TODO: Different function or remove when pinch is supported.
	Leap_PinchWindow(rLeapData, rasGestures, hWnd)
	return
}
Leap_PinchWindow(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	global g_DictMonInfo, g_vLeap
	static s_iRadiusFactor_c := 0.25, s_iProgressFactor_c := 4.00, s_iLastProgress
		, s_iMinW := 161, s_iMinH := 243 ; Values were determined by making an explorer window as small as Windows would allow.

	if (s_iLastProgress == A_Blank)
	{
		s_iLastProgress := rLeapData.Circle.Progress
		return
	}

	MakeValidHwnd(hWnd)

	; Use the last gesture in the array; that way the user doesn't have to worry about accidentally
	; triggering another gesture, such as a forward swipe, when they really want to start circling.
	sGesture := rasGestures[rasGestures.MaxIndex()]

	if (sGesture = "Circle Right")
		bPinchIn := true
	else if (sGesture = "Circle Left")
		bPinchIn := false
	else return ; Unsupported gesture.
	bPinchOut := !bPinchIn

	; Avoid resizing when circular movements are nominal.
	iProgressDiff := abs(rLeapData.Circle.Progress-s_iLastProgress)
	if (iProgressDiff < 0.05)
		return

	; Monitor variables.
	iMon := GetMonitorFromWindow(hWnd)
	iMonW := g_DictMonInfo[iMon].W
	iMonH := g_DictMonInfo[iMon].H

	; hWnd variables.
	WinGetPos, iCurX, iCurY, iCurW, iCurH, ahk_id %hWnd%
	iRadiusScaled := rLeapData.Circle.Radius*s_iRadiusFactor_c
	iPixelsToMove := (iProgressDiff*s_iProgressFactor_c)+iRadiusScaled
	; New dimensions.
	iX	:=	Round(bPinchIn ? iCurX+(iPixelsToMove/2): iCurX-(iPixelsToMove/2))
	iY	:=	Round(bPinchIn ? iCurY+(iPixelsToMove/2): iCurY-(iPixelsToMove/2))
	iW	:=	Round(bPinchIn ? iCurW-iPixelsToMove		: iCurW+iPixelsToMove)
	iH	:=	Round(bPinchIn ? iCurH-iPixelsToMove		: iCurH+iPixelsToMove)

	; Don't allow the window to expand beyond the active monitor's dimensions.
	if (bPinchOut)
	{
		if (iW > iMonW)
			iW := iMonW
		if (iH > iMonH)
			iH := iMonH
	}

	; Return if we are pinching in and the window cannot be made any smaller or
	; if we are pinching out and the window cannot be made any bigger.
	if ((bPinchIn && iW <= s_iMinW && iH <= s_iMinH)
		|| (bPinchOut && iCurX == g_DictMonInfo[iMon].Left && iCurY == g_DictMonInfo[iMon].Top
		&& iCurW == g_DictMonInfo[iMon].Right && iCurH == g_DictMonInfo[iMon].Bottom))
	{
		; TODO: Multi-monitor support?
		return
	}

	WndMove(iX, iY, iW, iH, hWnd, true, false) ; TODO:conditionally set bKeepOnMon.
	s_iLastProgress := rLeapData.Circle.Progress

	return
}
; Old method which uses scale factor...
;~ {
	;~ global g_DictMonInfo, g_vLeap
	;~ static s_iRadiusFactor_c := 0.5, s_iProgressFactor_c := 1.5

	;~ MakeValidHwnd(hWnd)

	;~ iScaleFactor := g_vLeap.GetScaleFactor(rLeapData, iLastScaleFactor)

	;~ if (iScaleFactor == iLastScaleFactor)
	;~ {
		;~ if (iScaleFactor == 1) ; Comment here...
			;~ g_vLeap.SendMessageToExe("Pinch=GetNextFrame")

		;~ return
	;~ }

	; Remove noise from small hand movements.
	;~ if (abs(iLastScaleFactor - iScaleFactor) <= 0.009)
		;~ return

	;~ WinGetPos, iX, iY, iW, iH, ahk_id %hWnd%
	;~ bPinchIn := (iScaleFactor < iLastScaleFactor)
	;;~ iPixelsPerHundreth := (g_DictMonInfo[GetMonitorFromWindow(hWnd)].W/((s_iProgressFactor_c-s_iRadiusFactor_c)*100))
	;;~ iPixelsPerHundreth := 1
	;;~ iPixelsToMove := iPixelsPerHundreth*(abs(iScaleFactor)*100)

	;~ if (bPinchIn)
	;~ {	; Shrink window.
		;~ iPixelsToMove := 10 ; While we still use the ScaleFactor, that number tends to get smaller and smaller.
		;~ iX	+=	iPixelsToMove/2
		;~ iY	+=	iPixelsToMove/2
		;~ iW	-=	iPixelsToMove
		;~ iH	-=	iPixelsToMove
	;~ }
	;~ else ; expand window.
	;~ {
		;~ iPixelsToMove := 20
		;~ iX	-=	iPixelsToMove/2
		;~ iY	-=	iPixelsToMove/2
		;~ iW	+=	iPixelsToMove
		;~ iH	+=	iPixelsToMove
	;~ }

	;~ WndMove(iX, iY, iW, iH, hWnd, true, false) ; TODO:conditionally set bKeepOnMon.

	;~ return
;~ }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_Scroll
		Purpose: To scroll up, down, left, or right based upon palm directions.
	Parameters
		rLeapData
		rasGestures
		hWnd="A"
*/
Leap_Scroll(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	global g_vLeap
	static s_bFingersWereOutOfTouchZone
		, WM_HSCROLL:=276, WM_VSCROLL:=277
		, SB_LINELEFT:=0, SB_LINERIGHT:=1, SB_LINEUP:=0, SB_LINEDOWN:=1
		, SB_PAGELEFT:=2, SB_PAGERIGHT:=3, SB_PAGEUP:=2, SB_PAGEDOWN:=3

	; Prevent scrolling when no fingers are less than halfway within the virtual touch zone.
	bFingersOutOfTouchZone := true
	while (bFingersOutOfTouchZone && rLeapData.HasKey("Finger" A_Index))
		bFingersOutOfTouchZone := (rLeapData["Finger" A_Index].TouchDistance > 0.40)

	if (bFingersOutOfTouchZone)
	{
		s_bFingersWereOutOfTouchZone := true
		return
	}

	bHasReset := s_bFingersWereOutOfTouchZone
	s_bFingersWereOutOfTouchZone := false

	;~ if (hWnd != "A")
		;~ Msgbox
	MakeValidHwnd(hWnd)
	;~ WinGetTitle, sTitle, ahk_id %hWnd%
	;~ ToolTip hWnd:`t%hWnd%`nTitle:`t%sTitle%

	iVelocityX := abs(rLeapData.Hand1.VelocityX)
	iVelocityY := abs(rLeapData.Hand1.VelocityY)

	iVelocityXFactor := g_vLeap.CalcVelocityFactor(iVelocityX, 120)
	iVelocityYFactor := g_vLeap.CalcVelocityFactor(iVelocityY, 120)

	; Get palm X and Y movement.
	g_vLeap.GetPalmDelta(rLeapData, iPalmXDelta, iPalmYDelta)

	; Here's the deal: If the finger(s) started low and re-entered high, we would glitch upward.
	if (bHasReset)
		return

	bScrollLeft := (iPalmXDelta > 0)
	bScrollRight := !bScrollLeft
	bScrollDown := (iPalmYDelta > 0)

	if (iVelocityX > 800)
	{
		iScrollXs := 1
		SB_LR := (bScrollRight ? SB_PAGERIGHT : SB_PAGELEFT)
	}
	else
	{
		iScrollXs := abs((iPalmXDelta*iVelocityXFactor))*0.1
		if (iScrollXs < 1 && iScrollXs > 0.05)
			iScrollXs := 1
		SB_LR := (bScrollRight ? SB_LINERIGHT : SB_LINELEFT)
	}
	if (iVelocityY > 800)
	{
		iScrollYs := 1
		SB_UD := (bScrollDown ? SB_PAGEDOWN : SB_PAGEUP)
	}
	else
	{
		iScrollYs := abs((iPalmYDelta*iVelocityYFactor))*0.1
		if (iScrollYs < 1 && iScrollYs > 0.05)
			iScrollYs := 1
		SB_UD := (bScrollDown ? SB_LINEDOWN : SB_LINEUP)
	}

	ControlGetFocus, ActiveControl, A
	Loop %iScrollXs%
		SendMessage, WM_HSCROLL, %SB_LR%, 0, %ActiveControl%, A
	Loop %iScrollYs%
		SendMessage, WM_VSCROLL, %SB_UD%, 0, %ActiveControl%, A

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Leap_Zoom
		Purpose: To zoom in our out based upon circulate motion; however, once the new Leap SDK is released, this will be pinch-based.
	Parameters
		rLeapData
		hWnd="A"
		hWnd
*/
Leap_Zoom(ByRef rLeapData, ByRef rasGestures, hWnd="A")
{
	static s_iRadiusFactor_c := 0.005, s_iProgressFactor_c := 22.00, s_iLastProgress
	; Old values
	; static s_iRadiusFactor_c := 0.025, s_iProgressFactor_c := 1.75, s_iLastProgress

	if (s_iLastProgress == A_Blank)
	{
		s_iLastProgress := rLeapData.Circle.Progress
		return
	}

	MakeValidHwnd(hWnd)

	; Use the last gesture in the array; that way the user doesn't have to worry about accidentally
	; triggering another gesture, such as a forward swipe, when they really want to start circling.
	sGesture := rasGestures[rasGestures.MaxIndex()]

	if (sGesture = "Circle Right")
		bZoomIn := true
	else if (sGesture = "Circle Left")
		bZoomIn := false
	else ; unsupported gesture.
	{
		s_iLastProgress := rLeapData.Circle.Progress
		return
	}

	iProgressDiff := abs(rLeapData.Circle.Progress-s_iLastProgress)
	iRadiusScaled := rLeapData.Circle.Radius*s_iRadiusFactor_c
	iZooms := (iProgressDiff*s_iProgressFactor_c)+iRadiusScaled
	;~ if (iZooms > 0.80 && iZooms < 1)
		;~ iZooms := iProgressDiff ; 1 Progress = 1 zoom

	WinGetTitle, sTitle, ahk_id %hWnd%
	WinGetClass, sClass

	sSendZoom := "^" (bZoomIn ? "{WheelUp}" : "{WheelDown}")
	if ((sClass = "MozillaWindowClass" || sClass = "IEFrame" || sClass = "Chrome_WidgetWin_0" || sClass = "{1C03B488-D53B-4a81-97F8-754559640193}") ; Chrome and Safari
		&& (SubStr(sTitle, 1, 12) = "Google Earth"
		|| SubStr(sTitle, 1, 11) = "Google Maps"
		|| SubStr(sTitle, 1, 9) = "Bing Maps"))
	{
		sSendZoom := (bZoomIn ? "{WheelUp}" : "{WheelDown}")
	}

	Loop %iZooms%
		Send %sSendZoom%

	s_iLastProgress := rLeapData.Circle.Progress
	return
}

; Old zoom
;~ Leap_Zoom(ByRef rLeapData, ByRef rasGestures, hWnd="A")
;~ {
	;~ static s_iRadiusFactor_c := 0.025, s_iProgressFactor_c := 1.75, s_iLastProgress

	;~ if (s_iLastProgress == A_Blank)
	;~ {
		;~ s_iLastProgress := rLeapData.Circle.Progress
		;~ return
	;~ }

	;~ MakeValidHwnd(hWnd)

	;~ ; Use the last gesture in the array; that way the user doesn't have to worry about accidentally
	;~ ; triggering another gesture, such as a forward swipe, when they really want to start circling.
	;~ sGesture := rasGestures[rasGestures.MaxIndex()]

	;~ if (sGesture = "Circle Right")
		;~ bZoomIn := true
	;~ else if (sGesture = "Circle Left")
		;~ bZoomIn := false
	;~ else ; unsupported gesture.
	;~ {
		;~ s_iLastProgress := rLeapData.Circle.Progress
		;~ return
	;~ }

	;~ ; Avoid resizing when circular movements are nominal.
	;~ iProgressDiff := abs(rLeapData.Circle.Progress-s_iLastProgress)
	;~ if (iProgressDiff < 0.05)
		;~ return

	;~ iRadiusScaled := rLeapData.Circle.Radius*s_iRadiusFactor_c
	;~ iZooms := (iProgressDiff*s_iProgressFactor_c)+iRadiusScaled
	if (iZooms > 0.80 && iZooms < 1)
		iZooms := iProgressDiff ; 1 Progress = 1 zoom

	;~ WinGetTitle, sTitle, ahk_id %hWnd%
	;~ WinGetClass, sClass

	;~ sSendScroll := "^" (bZoomIn ? "{WheelUp}" : "{WheelDown}")
	;~ if ((sClass = "MozillaWindowClass" || sClass = "IEFrame" || sClass = "Chrome_WidgetWin_0" || sClass = "{1C03B488-D53B-4a81-97F8-754559640193}") ; Chrome and Safari
		;~ && (SubStr(sTitle, 1, 12) = "Google Earth"
		;~ || SubStr(sTitle, 1, 11) = "Google Maps"
		;~ || SubStr(sTitle, 1, 9) = "Bing Maps"))
	;~ {
		;~ sSendScroll := (bZoomIn ? "{WheelUp}" : "{WheelDown}")
	;~ }

	;~ Loop %iZooms%
		;~ Send %sSendScroll%

	;~ s_iLastProgress := rLeapData.Circle.Progress
	;~ return
;~ }

; Pinch zoom
;~ {
	;~ global g_vLeap
	;~ static s_iZoomFactor := 25

	;~ MakeValidHwnd(hWnd)

	;~ iScaleFactor := g_vLeap.GetScaleFactor(rLeapData, iLastScaleFactor)

	;~ if (iScaleFactor == iLastScaleFactor)
	;~ {
		;~ if (iScaleFactor == 1) ; Comment here...
			;~ g_vLeap.SendMessageToExe("Pinch=GetNextFrame")

		;~ return
	;~ }

	; Remove noise from small hand movements.
	;~ if (abs(iLastScaleFactor - iScaleFactor) <= 0.009)
		;~ return

	;~ bZoomIn := (iScaleFactor < iLastScaleFactor)
	;~ iZooms := abs(iLastScaleFactor - iScaleFactor)*s_iZoomFactor
	;~ Loop %iZooms%
		;~ Send % "^" (bZoomIn ? "{WheelUp}" : "{WheelDown}")

	;~ return
;~ }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: Volume_Adjust
		Purpose: To increase or decrease volume based upon the distance between a single hand and the Leap controller.
			Note: Once the Leap SDK supports pinching, this will be a pinch-based function.
	Parameters
		rLeapData
		rasGestures
*/
Leap_AdjustVolume(ByRef rLeapData, ByRef rasGestures)
{
	global g_vLeap
	static s_iVolumeAdjsPerMM  := 0.1
		, EVolumeType_Up := 1, EVolumeType_Down := 2

	; Get palm X and Y movement.
	g_vLeap.GetPalmDelta(rLeapData, iPalmXDelta, iPalmYDelta)
	bVolumeUp := (iPalmYDelta < 0) ; Otherwise, volume down.

	iVelocityY := abs(rLeapData.Hand1.VelocityY)
	if (iVelocityY > 350)
		iHowMuch := 2*g_vLeap.CalcVelocityFactor(iVelocityY, 550)
	else iHowMuch := 1

	iLoop := abs(Round(iPalmYDelta*s_iVolumeAdjsPerMM))
	if (iLoop < 1 && iLoop > 0.04)
	{
		iLoop := 1
		iHowMuch := 1
	}

	Loop %iLoop%
		VolumeOSD_Adj(bVolumeUp ? EVolumeType_Up : EVolumeType_Down, iHowMuch)

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function:
		Purpose:
	Parameters
		rLeapData: Various information from Leap API
		rasGestures: A chain of gestures. May be blank.
*/
Leap_QuickMenu(ByRef rLeapData, ByRef rasGestures)
{
	global g_vLeap, g_vLeapMsgProcessor, g_vMH
	static s_iLeftRightFactor := 0.1, s_iUpDownFactor := 0.1
		, s_bLastMoveWasSubmit, s_bLastMoveWasEscape

	if (!g_vMH.MainMenuExists())
	{
		g_vLeapMsgProcessor.m_bCallerHasFinished := true
		return
	}

	; Get palm info.
	iPalmX := rLeapData.Hand1.PalmX
	iPalmY := rLeapData.Hand1.PalmY
	; Get palm X and Y movement.
	iPalmXDelta := rLeapData.Hand1.TransX
	iPalmYDelta := rLeapData.Hand1.TransY

	; Velocity.
	iVelocityX := abs(rLeapData.Hand1.VelocityX)
	iVelocityY := abs(rLeapData.Hand1.VelocityY)

	; Movement should be *very* deliberate.
	iVelocityXFactor := g_vLeap.CalcVelocityFactor(iVelocityX, 400)
	if (iVelocityY < 400)
		iVelocityYFactor := 0.75
	else iVelocityYFactor := g_vLeap.CalcVelocityFactor(iVelocityY, 900)

	; Strip out noise from humanity's generable inability to stabilize their palms.
	if (abs(iPalmXDelta) > 0.10)
		iScrollXs := abs(iPalmXDelta*iVelocityXFactor*s_iLeftRightFactor)
	if (abs(iPalmYDelta) > 0.10)
		iScrollYs := abs(iPalmYDelta*iVelocityYFactor*s_iUpDownFactor)
	Tooltip %iScrollYs%`n%iPalmYDelta%`n%iVelocityYFactor%`n%iVelocityY%

	; 1. Scroll right is submit.
	; 2. Scroll left is escape.
	; 3. Scroll down moves the menu down.
	; 4. Scroll up moves the menu up.
	; Note: Since right/left are submit/escape, we only allow one per call;
	; however, since scrolling up/down takes more work, we allow multiple.
	bScrollRight := (iPalmX > iLastPalmX)
	bScrollUp := (iPalmY > iLastPalmY)

	bMainMenuExists := true

	if (iScrollXs > 1)
	{
		if (bScrollRight && !s_bLastMoveWasSubmit)
		{
			g_vMH.Submit(bMainMenuExists)
			s_bLastMoveWasSubmit := true
		}
		else if (!bScrollRight && !s_bLastMoveWasEscape)
		{
			g_vMH.Escape(bMainMenuExists)
			s_bLastMoveWasEscape := true
		}
	}
	else s_bLastMoveWasSubmit := s_bLastMoveWasEscape := false

	Loop %iScrollYs%
		g_vMH.Move(bScrollUp)

	;~ if (s_bMenuIsActive)
	;~ {
		;~ g_vMH.ShowMenu()
		;~ s_bMenuIsActive := false
		;~ return
	;~ }

	;~ if (asGestures.MaxIndex() > 1)
		;~ return

	;~ bMainMenuExists := true
	;~ sGesture := asGestures[1]

	;~ if (sGesture = "KeyTap" || sGesture = "ScreenTap" || sGesture = "Swipe Right")
		;~ g_vMH.Submit(bMainMenuExists)
	;~ else if (sGesture = "Swipe Left")
		;~ g_vMH.Escape(bMainMenuExists)
	;~ else if (sGesture = "Swipe Up")
		;~ g_vMH.Move(true)
	;~ else if (sGesture = "Swipe Down")
		;~ g_vMH.Move(false)

	;~ if (bMainMenuExists)
		;~ g_vLeap.OSD_Init()
	;~ else
	;~ {
		;~ g_vLeapMsgProcessor.m_bCallerHasFinished := true
	;~ }

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ShowControlCenterDlg
		Purpose:
	Parameters
		hOwner
		sGestureToSelect
		sGUI
		sCtrl
*/
ShowControlCenterDlg(hOwner=0, sGestureToSelect="", sGUI="", sCtrl="")
{
	global g_vLeap

	sSelect := g_vLeap.ShowControlCenterDlg(hOwner, sGestureToSelect, false)
	; For some reason, reloading on the class side doesn't work -- we got old or lose new gestures, so we have to reload here.
	g_vLeap.m_vGesturesIni := g_vLeap.m_vGesturesIni.Reload()
	RemoveUnreferencedGestures()

	if (sGUI && sCtrl)
	{
		GUI, %sGUI%:Default
		GUIControl,, %sCtrl%, % "||" g_vLeap.m_vGesturesIni.GetSections("|", "C") ; Update DDL with new gesture(s)
		GUIControl, ChooseString, %sCtrl%, % (sSelect == A_Blank ? sGestureToSelect : sSelect)
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				END LEAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SequenceWnd(sec)
{
	global g_SequencesIni

	hActive := WinExist("A")

	if (!IsResizable(hActive))
	{
		ShowResizableError(hActive)
		return false
	}

	WinGetPos, iWndX, iWndY, iWndW, iWndH, ahk_id %hActive%
	iSeq := 1
	if (g_SequencesIni.HasKey(sec))
	{
		for key, val in g_SequencesIni[sec]
		{
			if (abs(key) >= 0) ; is number doesn't work
			{
				iSeqCnt++
				GetDimsPctForSeq(val, iXPct, iYPct, iWPct, iHPct)
				GetDimFromPct(iXPct, iYPct, iWPct, iHPct, iX, iY, iW, iH, hActive)
				if (iX == iWndX && iY == iWndY && iW == iWndW && iH == iWndH)
					iSeq := iSeqCnt + 1
			}
		}
	}
	else
	{
		CornerNotify(1.5, "Error", "Could not locate Sequence #" sSec, "x" iX " y" iY)
		return
	}

	; If we didn't match a sequence or we finished the sequence, treat this wnd as the first sequence.
	if (iSeq > iSeqCnt)
		iSeq := 1

	GetDimsPctForSeq(g_SequencesIni[sec][iSeq], iXPct, iYPct, iWPct, iHPct)
	GetDimFromPct(iXPct, iYPct, iWPct, iHPct, iX, iY, iW, iH, hActive)

	if (GetMinMaxState() == 1)
		WinRestore ; TODO: Toggle it without moving?

	WinMove, ahk_id %hActive%, , %iX%, %iY%, %iW%, %iH%
	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: DoPrecisePlacement
		Purpose: Wrapper for precision hotkeys
	Parameters
		sSectionInIni = unique section in g_PrecisionIni which holds the data needed to place the window properly
*/
DoPrecisePlacement(sSectionInIni, hWnd="A")
{
	global g_PrecisionIni

	MakeValidHwnd(hWnd)
	bIsResizeable := IsResizable(hWnd)

	if (g_PrecisionIni.HasKey(sSectionInIni))
	{
		for key, val in g_PrecisionIni[sSectionInIni]
		{
			if (abs(key) >= 0) ; is number doesn't work
			{
				if (key == 1) ; Currently only one sequence precise placement is supported
				{
					Loop, Parse, val, `t
					{
						iDim := SubStr(A_LoopField, InStr(A_LoopField, "=") + 1)
						if (A_Index == 1)
							iX := iDim
						else if (A_Index == 2)
							iY := iDim
						else if (A_Index == 3)
							iW := iDim
						else if (A_Index == 4)
							iH := iDim
						else break
					}

					if (bIsResizeable)
						WinMove, ahk_id %hWnd%,, %iX%, %iY%, %iW%, %iH%
					else WinMove, ahk_id %hWnd%,, %iX%, %iY%

					break
				}
			}
		}
	}
	else CornerNotify(1.5, "Error", "Could not locate Precise Placement #." sSectionInIni, "x" iX " y" iY)

	if (!bIsResizeable)
	{
		CornerNotify(1.5, "Warning", "This window is not resizable.`nWindow has been moved, but the orignal width and height have been retained.", "x" iX " y" iY)
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MaximizeHorizontally(hWnd="A")
{
	global g_DictMonInfo

	MakeValidHwnd(hWnd)

	if (!IsResizable(hWnd))
	{
		ShowResizableError(hWnd)
		return false
	}

	iMon := GetMonitorFromWindow(hWnd)
	WinMove, ahk_id %hWnd%, ,% g_DictMonInfo[iMon].Left, , % g_DictMonInfo[iMon].W
	return
}

MaximizeVertically(hWnd="A")
{
	global g_DictMonInfo

	MakeValidHwnd(hWnd)

	if (!IsResizable(hWnd))
	{
		ShowResizableError(hWnd)
		return false
	}

	iMon := GetMonitorFromWindow(hWnd)
	WinMove, ahk_id %hWnd%, , , % g_DictMonInfo[iMon]["Top"], , % g_DictMonInfo[iMon]["H"]
	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: To use Win-Split Logic to maximize hWnd:
			1. If the window is minimized, maximize it.
			2. If the window is maximized, set it to it's default, non-maximized position
			3. If the window is neither minimzed or maximized, minimze it.
		Purpose:
	Parameters
		
*/
MaximizeWindow(hWnd="A")
{
	MakeValidHwnd(hWnd)

	if (!IsResizable(hWnd))
	{
		ShowResizableError(hWnd)
		return false
	}

	iMinMaxState := GetMinMaxState(hWnd)
	WinActivate, ahk_id %hWnd%

	; Minmized
	if (iMinMaxState = -1)
		WinRestore, ahk_id %hWnd%
	; Maximized
	else if (iMinMaxState = 1)
		WinRestore, ahk_id %hWnd%
	; Neither
	else if (iMinMaxState = 0)
		WinMaximize, ahk_id %hWnd%
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function:
		Purpose: To use Win-Split Logic to minimize hWnd:
			1. If the window is minimized, maximize it.
			2. If the window is maximized, set it to it's default, non-maximized position
			3. If the window is neither minimzed or maximized, minimze it.
	Parameters
		hWnd
*/
MinimizeWindow(hWnd="A")
{
	MakeValidHwnd(hWnd)

	iMinMaxState := GetMinMaxState(hWnd)
	WinActivate, ahk_id %hWnd%

	; Minmized
	if (iMinMaxState = -1)
		WinRestore, ahk_id %hWnd%
	; Maximized
	else if (iMinMaxState = 1)
		WinRestore, ahk_id %hWnd%
	; Neither
	else if (iMinMaxState = 0)
		WinMinimize, ahk_id %hWnd%

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: MakeMosaic
		Purpose: Fits all windows matching sWinTitle onto the current monitor.
	Parameters
		hWnd: Needed to determine which monitor the mosaic should be produced on.
		sWinTitle
*/
MakeMosaic(hWnd="A", sWinTitle="")
{
	global g_DictMonInfo, g_sClassesNotToUse

	;~ Msgbox MosaicMode`nFits all windows of the same type onto the current monitor. The algorithm is repetitive except for these cases: 2x2, 3x3, and 4x4. Given the nature of the algorithm, any great number of window matrixes that can be created will line up accordingly. This also means that I am not sure of how smart WinSplits algorithm is: does it handle 4, 9, and 16 window specifically? Or does the algorithm account for any matrixes? Either way, I am thinking I can make mine smart enough by using a function like WinCanBeMatrix. Maybe I am overthinking this. When I starting writing the algorithm, perhaps what I should do will be much easier than I am thinking.

	MakeValidHwnd(hWnd)
	iMonToActUpon := GetMonitorFromWindow(hWnd)

	WinGet, aHwnds, List
	aHwndsToUse := []
	Loop %aHwnds%
	{
		hCurWnd := aHwnds%A_Index%

		WinGetClass, sClass, ahk_id %hCurWnd%
		if sClass in %g_sClassesNotToUse%
			continue

		iMonCurWndIsOn := GetMonitorFromWindow(hCurWnd)

		if (iMonToActUpon != iMonCurWndIsOn
			|| WindowIsMinimized(hCurWnd))
			continue
		else if (WindowIsMaximized(hCurWnd))
			WinRestore

		aHwndsToUse.Insert(hCurWnd)
	}

	; Determine if we can make a matrix out of these windows. Requires a minimum of 4.
	; If we can't make a matrix etermine if there is an odd or even number of windows.
	; If odd, we have to do some special handling; if even, then just fit all windows to rect accordingly.
	iMatrix := iAllHwnds := aHwndsToUse.MaxIndex()
	Loop %iAllHwnds%
	{
		if (Sqrt(iAllHwnds) == A_Index)
			iMatrix := A_Index
	}

	iLeftover := 0
	if (iMatrix > 3 && iMatrix == iAllHwnds)
	{
		iMatrix := 0 ; The loop below guarantees a valid value for iMatrix.
		iNdx := iAllHwnds-1
		while (iNdx > 0)
		{
			iNdx := iAllHwnds-A_Index
			iPossibleMatrix := Sqrt(iNdx)
			;~ Msgbox % iAllHwnds "`n" iNdx "`n" iPossibleMatrix "`n" A_Index
			if (iPossibleMatrix == Round(iPossibleMatrix)) ; if this is a whole number.
			{
				iMatrix := iPossibleMatrix ; then we have a valid matrix.
				break
			}
		}
		iLeftover := iAllHwnds-(iMatrix*iMatrix)
	}

	; Matrices makes me think of spreadsheets, so talk in terms of spreadsheets.
	; Think of the monitor vars are the spreadsheet rect.
	iMonX := g_DictMonInfo[iMonToActUpon].Left
	iMonY := g_DictMonInfo[iMonToActUpon].Top
	iMonW := g_DictMonInfo[iMonToActUpon].W
	iMonH := g_DictMonInfo[iMonToActUpon].H
	iMonRight := g_DictMonInfo[iMonToActUpon].Right

	iCellW := Round(iMonW/iMatrix)
	iCellH := Round(iMonH/(iMatrix+iLeftover))

	iRow := 0
	iThisX := iMonX
	iThisY := iMonY
	for i, hWnd in aHwndsToUse
	{
		if (iThisX+iCellW > iMonRight)
		{
			iRow++

			; If this is the last row, and there are an odd number of hWnds left..
			if (iLeftover && iRow == iMatrix+1)
				iCellW := Round(iMonW/iLeftover)

			iThisX := iMonX
			iThisY := iCellH*iRow
		}

		;~ Msgbox A_Index:`t%A_Index%`nMatrix:`t%iMatrix%`niLeftover:`t%iLeftover%`nRow:`t%iRow%`n`niMonX:`t%iMonX%`niMonY:`t%iMonY%`niMonW:`t%iMonW%`niMonH:`t%iMonH%`n`niCellX:`t%iThisX%`niCellY:`t%iThisY%`niCellW:`t%iCellW%`niCellH:`t%iCellH%
		WinMove, ahk_id %hWnd%,, %iThisX%, %iThisY%, %iCellW%, %iCellH%

		iThisX += iCellW
	}

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SnapWnd(sDir, hWnd="A")
{
	global g_DictMonInfo

	hWndToSnap := hWnd == "A" ? WinExist(hWnd) : hWnd

	if (GetMinMaxState(hWndToSnap) == 1)
		WinRestore ; TODO: Toggle it without moving?
	WinGetPos, iX, iY, iW, iH, ahk_id %hWndToSnap%

	iXRight := 100 - ((iW * 100) / (g_DictMonInfo[GetMonitorFromWindow(hWndToSnap)]["W"]))
	iYBottom := 100 - ((iH * 100) / (g_DictMonInfo[GetMonitorFromWindow(hWndToSnap)]["H"]))

	if (sDir = "BottomLeft")
		GetDimFromPct(0, iYBottom, 0, 0, iX, iY, iW, iH, hWndToSnap)
	else if (sDir = "BottomRight")
		GetDimFromPct(iXRight, iYBottom, 0, 0, iX, iY, iW, iH, hWndToSnap)
	else if (sDir = "BottomCenter")
		GetDimFromPct(iXRight * 0.5, iYBottom, 0, 0, iX, iY, i, i, hWndToSnap)
	else if (sDir = "TopLeft")
		GetDimFromPct(0, 0, 0, 0, iX, iY, iW, iH, hWndToSnap)
	else if (sDir = "TopRight")
		GetDimFromPct(iXRight, 0, 0, 0, iX, iY, iW, iH, hWndToSnap)
	else if (sDir = "TopCenter")
		GetDimFromPct(iXRight * 0.5, 0, 0, 0, iX, iY, i, i, hWndToSnap)
	else if (sDir = "Center")
		GetDimFromPct(iXRight * 0.5, iYBottom * 0.5, 0, 0, iX, iY, i, i, hWndToSnap)
	else if (sDir = "CornerLeft")
		GetDimFromPct(0, 0, 0, 0, iX, i, i, i, hWndToSnap)
	else if (sDir = "CornerRight")
		GetDimFromPct(iXRight, 0, 0, 0, iX, i, i, i, hWndToSnap)
	else if (sDir = "CornerTop")
		GetDimFromPct(0, 0, 0, 0, i, iY, i, i, hWndToSnap)
	else if (sDir = "CornerBottom")
		GetDimFromPct(0, iYBottom, 0, 0, i, iY, i, i, hWndToSnap)

	WinMove, ahk_id %hWndToSnap%, , %iX%, %iY%
	return
}

;~ TODO:
;~ SnapChildWnd(sDir, hWnd="A")
;~ {
	;~ ; Snap a window to a location using the parent window as the bounding rect
	;~ return
;~ }

ResizeWnd(sResize, hWnd="A")
{
	global g_DictMonInfo, g_aMapOrganizedMonToSysMonNdx

	hWndToResize := hWnd == "A" ? WinExist(hWnd) : hWnd
	iMon := GetMonitorFromWindow(hWndToResize)

	if (!IsResizable(hWndToResize))
	{
		ShowResizableError(hWndToResize)
		return false
	}

	if (GetMinMaxState(hWndToResize) == 1)
		WinRestore ; TODO: Toggle it without moving?
	WinGetPos, iX, iY, iW, iH, ahk_id %hWndToResize%

	iXRight := 100 - ((iW * 100) / (g_DictMonInfo[g_aMapOrganizedMonToSysMonNdx[iMon]]["W"]))
	iYBottom := 100 - ((iH * 100) / (g_DictMonInfo[g_aMapOrganizedMonToSysMonNdx[iMon]]["H"]))

	if (sResize = "LeftHalf")
		GetDimFromPct(0, 0, 50, 100, iX, iY, iW, iH, hWndToResize)
	else if (sResize = "RightHalf")
		GetDimFromPct(50, 0, 50, 100, iX, iY, iW, iH, hWndToResize)
	else if (sResize = "TopHalf")
		GetDimFromPct(0, 0, 100, 50, iX, iY, iW, iH, hWndToResize)
	else if (sResize = "BottomHalf")
		GetDimFromPct(0, 50, 100, 50, iX, iY, iW, iH, hWndToResize)
	else if (sResize = "CenterHalf")
		GetDimFromPct(25, 25, 50, 50, iX, iY, iW, iH, hWndToResize)
	else if (sResize = "CenterThreeFourths")
		GetDimFromPct(12.5, 12.5, 75, 75, iX, iY, iW, iH, hWndToResize)

	WinMove, ahk_id %hWndToResize%, , %iX%, %iY%, %iW%, %iH%
	return
}

ToggleWindowBorder(hWnd="A")
{
	MakeValidHwnd(hWnd)

	iMinMaxState := GetMinMaxState(hWnd)
	WinGet Style, Style, ahk_id %hWnd%
	if (Style & 0xC40000)
	{
		WinSet, Style, -0xC40000, ahk_id %hWnd%
		; Roundabout way to force a proper redraw
		WinMinimize, ahk_id %hWnd%
		WinRestore, ahk_id %hWnd%
		if (iMinMaxState = 1)
			WinMaximize, ahk_id %hWnd%
	}
	else
	{
		WinSet, Style, +0xC40000, ahk_id %hWnd%
		; Roundabout way to force a proper redraw
		if (iMinMaxState = 1)
		{
			WinRestore, ahk_id %hWnd%
			WinMaximize, ahk_id %hWnd%
		}
		else if (iMinMaxState = 0)
		{
			WinMaximize, ahk_id %hWnd%
			WinRestore, ahk_id %hWnd%
		}
	}

	return

	; Interesting stuff
	; WinSet, Region, 50-0 W200 H250, A  ; Make all parts of the window outside this rectangle invisible.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: WndMove
		Purpose: To move window is an intelligent fashion as outlined by bAllowCrossover and bSmartMove.
	Parameters
		iX=""
		iY=""
		iW=""
		iH=""
		hWnd="A"
		bKeepOnMon=false: Allow moving past monitor corners.
		bSmartMove=true: For exmaple, if iX==""&&iCurX+iW > MonitorWidth,
			window X will be reduced by the amount needed to make iX+iW==MonitorWidth;
			Also, if X < iMonLeft, then iX will be set to iMonLeft.
		bMove: If false, the window is not moved, but the new coordinates are still returned.
*/
WndMove(iX="", iY="", iW="", iH="", hWnd="A", bKeepOnMon=true, bSmartMove=true, bMove=true)
{
	global g_DictMonInfo
	static s_iMinW := 161, s_iMinH := 243 ; Values were determined by making an explorer window as small as Windows would allow.

	MakeValidHwnd(hWnd)

	iMon := GetMonitorFromWindow(hWnd)
	WinGetPos, iCurX, iCurY, iCurW, iCurH, ahk_id %hWnd%

	if (iX == A_Blank)
		iX := iCurX
	if (iY == A_Blank)
		iY := iCurY
	if (iW == A_Blank)
		iW := iCurW
	if (iH == A_Blank)
		iH := iCurH

	if (bSmartMove)
	{
		if (iX < g_DictMonInfo[iMon].Left)
			iX := g_DictMonInfo[iMon].Left
		if (iY < g_DictMonInfo[iMon].Top)
			iY := g_DictMonInfo[iMon].Top

		if (iX > g_DictMonInfo[iMon].Left && iX+iW > g_DictMonInfo[iMon].Right)
			iX := g_DictMonInfo[iMon].Right-iW
		if (iY > g_DictMonInfo[iMon].Top && iY+iH > g_DictMonInfo[iMon].Bottom)
			iY := g_DictMonInfo[iMon].Bottom-iY
	}

	if (iX + iW > g_DictMonInfo[g_DictMonInfo.MaxIndex()].Right) ; we are trying to move the right corner of the wnd past the rightmost corner of the rightmost monitor.
		iX := g_DictMonInfo[iMon].Right-iW
	else if (iX < g_DictMonInfo.1.Left) ; we are trying to move the left corner of the wnd past the leftmost corner of the leftmost monitor.
		iX := g_DictMonInfo[iMon].Left

	if (iY + iH > g_DictMonInfo.1.Bottom) ; we are trying to move the bottom past the bottom-most monitor
		iY := g_DictMonInfo[iMon].Bottom-iH
	else if (iY < g_DictMonInfo[g_DictMonInfo.MaxIndex()].Top) ; we are trying to move the top past the top-most monitor
		iY := g_DictMonInfo[iMon].Top

	if (bKeepOnMon)
	{
		; Handle iX and iW.
		if ((iX + iW > g_DictMonInfo[iMon].Right) ; we are trying to move the window past the right corner.
			&& (iCurX + iCurW <= g_DictMonInfo[iMon].Right)) ; the right corner of the wnd is not already past the monitor's right corner.
		{
			iX := g_DictMonInfo[iMon].Right-iW
		}
		else if ((iCurX >= g_DictMonInfo[iMon].Left) ; the left corner of the wnd is not already past the monitor's left corner.
			&& (iX < g_DictMonInfo[iMon].Left)) ; we are trying to move the window past the left corner.
		{
			iX := g_DictMonInfo[iMon].Left
		}

		; Handle iY and iH.
		if ((iCurY >= g_DictMonInfo[iMon].Top) ; the top of the wnd is not already past the monitor's top corner.
			&& (iY < g_DictMonInfo[iMon].Top)) ; we are trying to move the window past the top of the wnd.
		{
			iY := g_DictMonInfo[iMon].Top
		}
		else if ((iCurY + iCurH <= g_DictMonInfo[iMon].Bottom) ; the bottom corner of the wnd is not already past the monitor's bottom corner.
			&& (iY + iH > g_DictMonInfo[iMon].Bottom)) ; we are trying to move the window past the bottom of the wnd.
		{
			iY := g_DictMonInfo[iMon].Bottom-iH
		}
	}

	if (bSmartMove)
	{
		if (iW < s_iMinW)
			iW := iCurW
		if (iH < s_iMinH)
			iH := iCurH
	}

	; TODO: Special handling for windows that span more than one monitor.

	if (bMove)
		WinMove, ahk_id %hWnd%,, iX, iY, iW, iH

	return {iX:iX, iY:iY, iW:iW, iH:iH}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: CenterWndOnOwner
		Purpose:
	Parameters
		hWnd: Window to center.
		hOwner=0: Owner of hWnd with which to center hWnd upon. If 0 or WinGetPos fails,
			window is centered on primary monitor.
*/
CenterWndOnOwner(hWnd, hOwner=0)
{
	WinGetPos,,, iW, iH, ahk_id %hWnd%

	WinGetPos, iOwnerX, iOwnerY, iOwnerW, iOwnerH, ahk_id %hOwner%
	if (iOwnerX == A_Blank)
	{
		iOwnerX := 0
		iOwnerY := 0
		iOwnerW := A_ScreenWidth
		iOwnerH := A_ScreenHeight
	}

	iXPct := (100 - ((iW * 100) / (iOwnerW)))*0.5
	iYPct := (100 - ((iH * 100) / (iOwnerH)))*0.5

	iX := Round((iXPct / 100) * iOwnerW + iOwnerX)
	iY := Round((iYPct / 100) * iOwnerH + iOwnerY)

	WinMove, ahk_id %hWnd%,, iX, iY

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Hotkey labels
; IMPORTANT: *NEVER* Use Critical within these labels. It will cause the program to lock up.
ActivateApp:
{
	gosub LaunchMainDlg
	return
}
AutomaticPlacement:
{
	Msgbox Automatic Placement
	return
}
CloseAllButCurrentWindow:
{
	sListOfProgramsToKeep := "Startup,Windows Task Manager"
	WinGetActiveTitle, sTitleOfWndToKeep
	WinGet, ID, List, , , Program Manager
	Loop, %ID%
	{
		StringTrimRight, This_ID, ID%A_Index%, 0
		WinGetTitle, This_Title, ahk_id %This_ID%
		If This_Title in %sTitleOfWndToKeep%
			continue
		if This_Title in %sListOfProgramsToKeep%
			 continue
		WinClose, %This_Title%
	}

	return
}
CloseAllWindows:
{
	WinGet, ID, List, , , Program Manager
	Loop, %ID%
	{
		StringTrimRight, This_ID, ID%A_Index%, 0
		WinGetTitle, This_Title, ahk_id %This_ID%
		WinClose, %This_Title%
	}

	return
}
CloseWindow:
{
	WinKill, A
	return
}
SwitchWindow:
{
	Send !{Tab}
	return
}
DecrementTransparency:
{
	DetectHiddenWindows, on
	WinGet, CurWndTrans, Transparent, A
	if (Not CurWndTrans)
		CurWndTrans := 0
	NewWndTrans := CurWndTrans + 13
	if (NewWndTrans < 256)
	{
		; Decrement transparency
		WinSet, Transparent, %NewWndTrans%, A
	}
	else
	{
		; Window is not transparent. Reset.
		WinSet, Transparent, 13, A
	}
	return
}
DisableTransparency:
{
	WinSet, Transparent, OFF, A
	return
}
;~ FusionMode: ; Not using because the returned values from GetTopWindow and GetWindow are not really windows or something
;~ {
	;~ SetFormat, Integer, hex
	;~ hTopmost := DllCall("GetTopWindow", uint, 0)
	;~ hNext := DllCall("GetWindow", uint, hTopmost, uint, 2)

	;~ WinMove, ahk_id %hTopmost%,, 0, 0, 960, 540
	;~ WinMove, ahk_id %hNext%,, 0, 0, 960, 540
	;~ Msgbox Fusion Mode!`nTakes the two most recent active windows of the same type, and outputs a dialog with a slider that allows you to size windows accordingly. Not that important of a feature, imho. MosaicMode is much more important.`n`n%hTopMost%`n%hNext%
	;~ SetFormat, Integer, d
	;~ return
;~ }
IncrementTransparency:
{
	DetectHiddenWindows, on
	WinGet, CurWndTrans, Transparent, A
	if (Not CurWndTrans)
		CurWndTrans = 255
	NewWndTrans := CurWndTrans - 13
	if NewWndTrans > 0
	{
		; Increment transparency
		WinSet, Transparent, %NewWndTrans%, A
	}
	else
	{
		; Window is 100% transparent. Reset.
		WinSet, Transparent, 255, A
		WinSet, Transparent, OFF, A
	}
	return
}
MaximizeAcrossAllMonitors:
{
	hActive := WinExist("A")
	if (IsResizable(hActive))
		WinMove, % "ahk_id" hActive,, g_DictMonInfo.VirtualScreenLeft, g_DictMonInfo.VirtualScreenTop, g_DictMonInfo.VirtualScreenRight, g_DictMonInfo.VirtualScreenBottom
	else ShowResizableError(hActive)

	return
}
MaximizeHorizontally:
{
	MaximizeHorizontally()
	return
}
MaximizeVertically:
{
	MaximizeVertically()
	return
}
MaximizeWindow:
{
	MaximizeWindow()
	return
}
;~ MinimizeAllButForemost
;~ {
	;~ MinimizeAllButForemost()
	;~ return
;~ }
MinimizeWindow:
{
	MinimizeWindow()
	return
}
MosaicMode:
{
	MakeMosaic()
	return
}
QuickMenu:
{
	g_vMH.ShowMenu()
	return
}
ResizeToBottomHalf:
{
	ResizeWnd("BottomHalf")
	return
}
ResizeToCenterHalf:
{
	ResizeWnd("CenterHalf")
	return
}
ResizeToCenterThreeFourths:
{
	ResizeWnd("CenterThreeFourths")
	return
}
ResizeToLeftHalf:
{
	ResizeWnd("LeftHalf")
	return
}
ResizeToRightHalf:
{
	ResizeWnd("RightHalf")
	return
}
ResizeToTopHalf:
{
	ResizeWnd("TopHalf")
	return
}
SnapToBottomLeft:
{
	SnapWnd("BottomLeft")
	return
}
SnapToBottomRight:
{
	SnapWnd("BottomRight")
	return
}
SnapToCenter:
{
	SnapWnd("Center")
	return
}
SnapToCornerBottom:
{
	SnapWnd("CornerBottom")
	return
}
SnapToCornerLeft:
{
	SnapWnd("CornerLeft")
	return
}
SnapToCornerRight:
{
	SnapWnd("CornerRight")
	return
}
SnapToCornerTop:
{
	SnapWnd("CornerTop")
	return
}
SnapToTopLeft:
{
	SnapWnd("TopLeft")
	return
}
SnapToTopRight:
{
	SnapWnd("TopRight")
	return
}
ToggleAlwaysOnTop:
{
	WinExist("A")
	WinGet, ExStyle, ExStyle
	if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
		Winset, AlwaysOnTop, off
	else WinSet, AlwaysOnTop, on
	return
}
ToggleWindowBorder:
{
	ToggleWindowBorder()
	return
}
WindowToAboveMonitor:
{
	Msgbox Window To Above Monitor
	return
}
WindowToBelowMonitor:
{
	Msgbox Window To Below Screen
	return
}
WindowToLeftMonitor:
{
	MoveWndToMonitor("Left")
	return
}
WindowToRightMonitor:
{
	MoveWndToMonitor("Right")
	return
}
EnterKey:
{
	Send {Enter}
	return
}
EscapeKey:
{
	Send {Esc}
	return
}
BrowserBackward:
{
	Send {Browser_Back}
	return
}
BrowserForward:
{
	Send {Browser_Forward}
	return
}
BrowserTabForward:
{
	Send ^{Tab}
	return
}
BrowserTabBackward:
{
	Send ^+{Tab}
	return
}
BrowserRefresh:
{
	Send {Browser_Refresh}
	return
}
NextTrack:
{
	Send {Media_Next}
	return
}
PreviousTrack:
{
	Send {Media_Prev}
	return
}
PlayOrPauseTrack:
{
	Send {Media_Play_Pause}
	return
}
ToggleMuteVolume:
{
	Send {Volume_Mute}
	return
}
; End Hotkey labels

/* 
#MButton::
	MouseGetPos,,, targetID
	targetID := "ahk_id " . targetID
	WinGet, list, List
	winList := []
	Loop % list
	{
		id := "ahk_id " . list%A_Index%
		If (id == targetID)
			continue
		WinGet, state, MinMax, % id
		If (state == 1) ; Maximized, ignore all windows below it because the user can't see them
			break
		If (state == -1) ; Minimized, ignore it entirely
			continue
		WinGetClass, class, % id
		If class in %ignoreClasses%
			continue
		WinGetTitle, title, % id
		If title in %ignoreTitles%
			continue
		WinGetPos, x, y, width, height, % id
		winList.insert({"id": id, "x": x, "y": y
						,"right": x + width, "bottom": y + height, "title": title})
	}
	WinRestore, % targetID ; Resizing maximized windows causes size issues with manual restoring
	Hotkey, LWin Up, BreakStartMenu, On
	While GetKeyState("MButton", "P")
	{
		MouseGetPos, mouseX, mouseY
		For each, window in winList ; wait until the mouse isn't over another window
			If (window.X <= mouseX and mouseX <= window.right)
				and (window.Y <= mouseY and mouseY <= window.bottom)
					continue 2
		
		
		rect := monitorDimensionsAtMouse()
		mouse := {x: mouseX, y: mouseY}
		If GetKeyState("LWin", "P")
			xy1 := "Y", xy2 := "X", s1 := "top", s2 := "left", s3 := "bottom", s4 := "right"
		Else
			xy1 := "X", xy2 := "Y", s1 := "left", s2 := "top", s3 := "right", s4 := "bottom"
		
		; Search either horizontally from the mouse for the closest rights and lefts of windows
		; (These will become the left and right of the new window position, respectively)
		; Or vertically for the nearest bottoms and tops -> top and bottom of the new position
		For each, window in winList
			If (window[xy1] <= mouse[xy1] and mouse[xy1] <= window[s3])
				If (mouse[xy2] < window[xy2] and window[xy2] < rect[s4])
					rect[s4] := window[xy2]
				Else If (mouse[xy2] > window[s4] and window[s4] > rect[s2])
					rect[s2] := window[s4]
		
		; Now that we have two opposing sides - a line - we fill the line out into a rectangle
		; by finding the other sides. This is trickier because a window can bound anywhere
		; on the line, rather than just in a straight line from the mouse.
		For each, window in winList
			If (window[xy2] <= rect[s2] and rect[s2] <= window[s4]) 
				or (rect[s2] <= window[xy2] and window[xy2] <= rect[s4])
					If (mouse[xy1] < window[xy1] and window[xy1] < rect[s3])
						rect[s3] := window[xy1]
					Else If (mouse[xy1] > window[s3] and window[s3] > rect[s1])
						rect[s1] := window[s3]
		
		WinMove, % targetID,, % rect.left, % rect.top
				, % rect.right - rect.left, % rect.bottom - rect.top
	}
	Hotkey, LWin Up, Off
return

BreakStartMenu:
return

monitorDimensionsAtMouse(){
	VarSetCapacity(monitorInfo, 40, 0)
	NumPut(40, monitorInfo)
	VarSetCapacity(point, 8, 0)
	DllCall("GetCursorPos", "UPtr", &point)
	hmonitor := DllCall("MonitorFromPoint", "int64", point, "Uint", 2)
	DllCall("GetMonitorInfo"
		, "UPtr", hmonitor
		, "UPtr", &monitorInfo)
	return {left: NumGet(monitorInfo, 4, "int")
		, top: NumGet(monitorInfo, 8, "int")
		, right: NumGet(monitorInfo, 12, "int")
		, bottom: NumGet(monitorInfo, 16, "int")}
}
*/

MoveWndToMonitor(sDir, hWnd="A", iMonToMoveTo=0)
{
	global g_aMapOrganizedMonToSysMonNdx, g_DictMonInfo

	MakeValidHwnd(hWnd)

	GetWndPct(iSourceWPct, iSourceHPct, hWnd)

	if (!iMonToMoveTo)
		iMonToMoveTo := GetMonitorFromWindow(hWnd)

	if (sDir == "Left")
		iMonToMoveTo--
	else if (sDir == "Right")
		iMonToMoveTo++

	; When dealing with multi-monitor configurations greater than 2, it is nice to
	; "wrap around" window movement from right-to-left monitor and vice versa.
	bWrapAround := g_aMapOrganizedMonToSysMonNdx.MaxIndex() > 2

	; If the window is on the far right monitor, so move it to the far left.
	if (iMonToMoveTo > g_aMapOrganizedMonToSysMonNdx.MaxIndex())
	{
		if (bWrapAround)
			iMonToMoveTo := 1
		else return ; The window is on the far right monitor, and we don't want to wrap around.
	}
	; else if the window is on the far left monitor, so move it to the far right.
	else if (iMonToMoveTo < 1)
	{
		if (bWrapAround)
			iMonToMoveTo := g_aMapOrganizedMonToSysMonNdx.MaxIndex()
		else return ; The window is on the far left monitor, and we don't want to wrap around.
	}

	if (!iMon)
		iMon := GetMonitorFromWindow(hWnd)

	WinGetPos, iX, iY, iW, iH, ahk_id %hWnd%

	iMonX := g_DictMonInfo[iMon]["Left"]
	iMonY := g_DictMonInfo[iMon]["Top"]
	iMonW := g_DictMonInfo[iMon]["W"]
	iMonH := g_DictMonInfo[iMon]["H"]

	iDestMonX := g_DictMonInfo[iMonToMoveTo]["Left"]
	iDestMonY := g_DictMonInfo[iMonToMoveTo]["Top"]
	iDestMonW := g_DictMonInfo[iMonToMoveTo]["W"]
	iDestMonH := g_DictMonInfo[iMonToMoveTo]["H"]

	; Use resolution difference to scale X and Y
	iX := iDestMonX + (iX-iMonX) * (iDestMonW/iMonW)
	iY := iDestMonY + (iY-iMonY) * (iDestMonH/iMonH)
	iNewW := iW
	iNewH := iH

	GetDimFromPct(iIgnored, iIgnored, iSourceWPct, iSourceHPct, iIgnored, iIgnored, iNewW, iNewH, hWnd, iMonToMoveTo)

	if (!IsResizable(hWnd))
	{
		; TODO: Scale W and H, somehow?
		iNewW := iW
		iNewH := iH
	}

	WinMove, ahk_id %hWnd%,, iX, iY, iNewW, iNewH

	return
}

GetWndPct(ByRef riWPct, ByRef riHPct, hWnd = "A", iMon = "")
{
	global g_DictMonInfo

	MakeValidHwnd(hWnd)

	if (!iMon)
		iMon := GetMonitorFromWindow(hWnd)
	WinGetPos, iX, iY, iW, iH, ahk_id %hWnd%

	iMonW := g_DictMonInfo[iMon]["W"]
	iMonH := g_DictMonInfo[iMon]["H"]

	riWPct := Round((iW * 100) / iMonW, 2)
	riHPct := Round((iH * 100) / iMonH, 2)

	return
}

GetDimFromPct(iXPct, iYPct, iWPct, iHPct, ByRef riX, ByRef riY, ByRef riW, ByRef riH, hWnd = "A", iMon = "")
{
	global g_DictMonInfo

	MakeValidHwnd(hWnd)

	if (!iMon)
		iMon := GetMonitorFromWindow(hWnd)

	iMonX := g_DictMonInfo[iMon]["Left"]
	iMonY := g_DictMonInfo[iMon]["Top"]
	iMonW := g_DictMonInfo[iMon]["W"]
	iMonH := g_DictMonInfo[iMon]["H"]

	riX := Round((iXPct / 100) * iMonW + iMonX)
	riY := Round((iYPct / 100) * iMonH + iMonY)
	riW := Round((iWPct / 100) * iMonW)
	riH := Round((iHPct / 100) * iMonH)

	return
}

GetDimsPctForSeq(sSeq, ByRef riXPct, ByRef riYPct, ByRef riWPct, ByRef riHPct)
{
	vSeq := GetSequenceFromIni(sSeq)

	riXPct := vSeq.m_iX
	riYPct := vSeq.m_iY
	riWPct := vSeq.m_iW
	riHPct := vSeq.m_iH

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Shinywong -- modified by me (Verdlin).
	Function: GetMonitorIndexFromWindow-->GetMonitorFromWindow
		Purpose: To retrieve which monitor number hWnd is on.
	Parameters
		hWnd
	See http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/#entry440355
*/
GetMonitorFromWindow(hWnd)
{
	global g_DictMonInfo, g_aMapOrganizedMonToSysMonNdx

	VarSetCapacity(monitorInfo, 40)
	NumPut(40, monitorInfo)

	if (monitorHandle := DllCall("MonitorFromWindow", "uint", hWnd, "uint", 0x2))
		&& DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo)
	{
		; Only use monitor work areas.
		;~ iWndMonLeft   := NumGet(monitorInfo,  4, "Int")
		;~ iWndMonTop    := NumGet(monitorInfo,  8, "Int")
		;~ iWndMonRight  := NumGet(monitorInfo, 12, "Int")
		;~ iWndMonBottom := NumGet(monitorInfo, 16, "Int")
		iWorkLeft			:= NumGet(monitorInfo, 20, "Int")
		iWorkTop			:= NumGet(monitorInfo, 24, "Int")
		iWorkRight		:= NumGet(monitorInfo, 28, "Int")
		iWorkBottom	:= NumGet(monitorInfo, 32, "Int")
		isPrimary			:= NumGet(monitorInfo, 36, "Int") & 1

		Loop, % g_aMapOrganizedMonToSysMonNdx.MaxIndex()
		{
			iThisMonLeft := g_DictMonInfo[A_Index]["Left"]
			iThisMonRight := g_DictMonInfo[A_Index]["Right"]
			iThisMonTop := g_DictMonInfo[A_Index]["Top"]
			iThisMonBottom := g_DictMonInfo[A_Index]["Bottom"]

			; Compare location to determine the monitor index.
			if ((iWorkLeft== iThisMonLeft) && (iWorkTop == iThisMonTop)
				&& (iWorkRight == iThisMonRight) && (iWorkBottom == iThisMonBottom))
			{
				return A_Index
			}
		}
	}

	return g_DictMonInfo.PrimaryMon
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GetMinMaxState
		Purpose: Nice wrapper fro WinGet...MinMax, etc.
	Parameters
		hWnd

		MinMaxState: (from http://l.autohotkey.net/docs/commands/WinGet.htm)
		-1: The window is minimized (WinRestore can unminimize it).
		1: The window is maximized (WinRestore can unmaximize it).
		0: The window is neither minimized nor maximized.
*/
GetMinMaxState(hWnd="A")
{
	MakeValidHwnd(hWnd)

	WinGet, iMinMaxState, MinMax, ahk_id %hWnd%
	return iMinMaxState
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: WindowIsMinimized
		Purpose: To help avoid forgetfulness for minmax states
	Parameters
		hWnd
*/
WindowIsMinimized(hWnd="A")
{
	return (GetMinMaxState(hWnd) == -1)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: WindowIsMaximized
		Purpose: To help avoid forgetfulness for minmax states
	Parameters
		hWnd
*/
WindowIsMaximized(hWnd="A")
{
	return (GetMinMaxState(hWnd) == 1)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: ShowResizableError
		Purpose: To display an error message for non-resizeable windows that we try to resize.
	Parameters
		hWnd
*/
ShowResizableError(hWnd)
{
	WinGetPos, iX, iY, iW, iH, ahk_id %hWnd%
	; Hard-coded values comes from CornerNotify wnd -- W is 700, H is 90
	iX += (iW/2)-350
	iY += (iH/2)-45.5

	CornerNotify(1.5, "Error", "Sorry. This window is not resizable.", "x" iX " y" iY)
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function:
		Purpose:
	Parameters
		
*/
Msgbox(sMsg, iStdMsg=1)
{
	static aStdMsg := ["", "An internal error occured:`n`n"]

	Msgbox 8192,, % aStdMsg[iStdMsg] sMsg
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: GetCheckState
		Purpose: To return "+Checked" or "-Checked", dependant upon bCheck
	Parameters
		bCheck: if true, "-Checked" is returned to that the caller will check the LV row.
			True if blank, "true", or 1
*/
GetCheckState(b)
{
	if (b == A_Blank || b = "true" || b == 1)
		return "-Checked"
	return "+Checked"
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: IsEven
		Purpose: To determine whether a number is odd or even
	Parameters
		i: number
*/
IsEven(i)
{
	return (Mod(i, 2) == 0)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: CallableFromSec
		Purpose: To return a label or function name derived from a section name in an ini
			Currently the format in each ini is such that each section name corresponds to a
			label/function name in this file (just without spaces hyphens, and "_Internal").
	Parameters
		sec
*/
CallableFromSec(sec)
{
	StringReplace, sLabel, sec, %A_Space%,, All
	StringReplace, sLabel, sLabel, -,, All
	return sLabel
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: MakeValidHwnd
		Purpose: hWnd="A" is passed around in many functions. They all need to validate the hWnd when it is *not* valid.
			That logic happens here.
	Parameters
		hWnd
*/
MakeValidHwnd(ByRef rhWnd)
{
	if (rhWnd = "A" || !rhWnd)
		rhWnd := WinExist("A")
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
Volume OSD
	Based upon JoeDF's Simple Volume OSD (linked at the top)
	His is based on the example from: http://l.autohotkey.net/docs/commands/_If.htm
	parts "forked" from Update.ahk
	----------------------------------------
	This version, joedf, April 8th, 2013
	- Update  May  23rd, 2013 [r1] - Added Tooltip to display volume %
	- Update June   4th, 2013 [r2] - Added Volume OSD
	- Update June   6th, 2013 [r3] - Added Hotkeys & over_tray options, Suggested by DataLife

	Author: Verdlin and JoeDF
	Function: VolumeOSD_Adj
		Purpose: To adjust volume in an aesthetic fashion (Although this isn't necessary with Win8+)
			Note: Caller is responsible to dismiss the OSD!
			Note: In Windows 8, the OSD is ignored.
	Parameters:
		EVolumeType
			1. Volume_Up
			2. Volume_Down
			3. Volume_Mute
		iHowMuch: How much to adjust the volume for SoundSet.
*/
VolumeOSD_Adj(EVolumeType, iHowMuch)
{
	static EVolumeType_Up := 1, EVolumeType_Down := 2, EVolumeType_Mute := 3

	;~ ; Windows 8 provides it's own volume progress bar.
	;~ if (A_OSVersion = "WIN_8")
	;~ {
		;~ if (EVolumeType == EVolumeType_Up)
			;~ sSendStr := "{Volume_Up}"
		;~ else if (EVolumeType == EVolumeType_Down)
			;~ sSendStr := "{Volume_Down}"
		;~ else if (EVolumeType == EVolumeType_Mute)
		;~ {
			;~ Send {Volume_Mute}
			;~ return
		;~ }

		;~ Loop %iHowMuch%
			;~ Send %sSendStr%

		;~ return
	;~ }

	if (EVolumeType == EVolumeType_Up)
		SoundSet +%iHowMuch%
	else if (EVolumeType == EVolumeType_Down)
		SoundSet -%iHowMuch%
	else if (EVolumeType == EVolumeType_Mute)
		Send {Volume_Mute}

	SoundGet, Volume
	Progress Show,, % (EVolumeType == EVolumeType_Mute ? "X" : "")
	Progress % Volume := Round(Volume), %Volume% `%

	return
}

VolumeOSD_Hide()
{
	global g_sVolumeOSD_ProgOpts

	Progress Hide %g_sVolumeOSD_ProgOpts%,,Volume,,Tahoma
	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
===============================================================================
Function:   Similar to wp_IsResizable
    Determine if we should attempt to resize the last found window.

Returns:
    True or False
     
Author(s):
    Original - Lexikos - http://www.autohotkey.com/forum/topic21703.html
===============================================================================
*/
IsResizable(hwnd="A")
{
	MakeValidHwnd(hWnd)

	WinGetClass, Class, ahk_id %hwnd%
	if Class in Chrome_XPFrame,MozillaUIWindowClass,MozillaWindowClass,wndclass_desked_gsk,QPasteClass,Notepad++,SciTEWindow
	{
		return true
	}
	WinGet, CurStyle, Style, ahk_id %hwnd%
	return (CurStyle & 0x40000) ; WS_SIZEBOX
}

;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Polythene
	Function: Functions.ahk
		Purpose: Wraps Commands into Functions
	Parameters
		
*/
GuiControlGet(Subcommand = "", ControlID = "", Param4 = "") {
	GuiControlGet, v, %Subcommand%, %ControlID%, %Param4%
	Return, v
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Begin miscellaneous data stored in memory.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetMenuConfigSettingsIni()
{
	return "
		(LTrim
			[Flyout]
			Background=images\Default Flyout Menu.jpg
			Font=Kozuka Mincho Pr6N R, s26 italic underline
			FontColor=0x5AAC7
			MaxRows=10
			TextAlign=Center
			W=400
			X=0
			Y=0
			ReadOnly=0
			ShowInTaskbar=0
		)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetMenuConfigIni()
{
	return "
		(LTrim
			[MainMenu]
			1. Snap >=Snap To
			2. Move >=Move To
			3. Resize >=Resize
			4. Window >=Window
			5. Open App=Label:LaunchMainDlg
			6. Exit (Esc)=ExitMainMenu

			[Snap To]
			1. To Top >=Snap To Top
			2. To Bottom >=Snap To Bottom
			3. To Corner >=Snap To Corner
			4. To Center=Func:SnapWnd(""Center"", g_hActiveWndBeforeMenu)

			[Snap To Top]
			1. Left=Func:SnapWnd(""TopLeft"", g_hActiveWndBeforeMenu)
			2. Right=Func:SnapWnd(""TopRight"", g_hActiveWndBeforeMenu)
			3. Center=Func:SnapWnd(""TopCenter"", g_hActiveWndBeforeMenu)

			[Snap To Bottom]
			1. Left=Func:SnapWnd(""BottomLeft"", g_hActiveWndBeforeMenu)
			2. Right=Func:SnapWnd(""BottomRight"", g_hActiveWndBeforeMenu)
			3. Center=Func:SnapWnd(""BottomCenter"", g_hActiveWndBeforeMenu)

			[Snap To Corner]
			1. Left=Func:SnapWnd(""CornerLeft"", g_hActiveWndBeforeMenu)
			2. Right=Func:SnapWnd(""CornerRight"", g_hActiveWndBeforeMenu)
			3. Top=Func:SnapWnd(""CornerTop"", g_hActiveWndBeforeMenu)
			4. Bottom=Func:SnapWnd(""CornerBottom"", g_hActiveWndBeforeMenu)

			[Move To]
			1. Left Monitor=Func:MoveWndToMonitor(""Left"", g_hActiveWndBeforeMenu)
			2. Right Monitor=Func:MoveWndToMonitor(""Right"", g_hActiveWndBeforeMenu)

			[Resize]
			1. Left 1/2=Func:ResizeWnd(""LeftHalf"", g_hActiveWndBeforeMenu)
			2. Right 1/2=Func:ResizeWnd(""RightHalf"", g_hActiveWndBeforeMenu)
			3. Top 1/2=Func:ResizeWnd(""TopHalf"", g_hActiveWndBeforeMenu)
			4. Bottom 1/2=Func:ResizeWnd(""BottomHalf"", g_hActiveWndBeforeMenu)
			5. Center 1/2=Func:ResizeWnd(""CenterHalf"", g_hActiveWndBeforeMenu)
			6. Center 3/4=Func:ResizeWnd(""CenterThreeFourths"", g_hActiveWndBeforeMenu)

			[Window]
			1. Toggle Border=Func:ToggleWindowBorder(g_hActiveWndBeforeMenu)
			2. Minimize Window=Func:MinimizeWindow(g_hActiveWndBeforeMenu)
			3. Maximize Window=Func:MaximizeWindow(g_hActiveWndBeforeMenu)
			4. Maximize Vertically=Func:MaximizeVertically(g_hActiveWndBeforeMenu)
			5. Maximize Horizontally=Func:MaximizeHorizontally(g_hActiveWndBeforeMenu)
			6. Close All Windows=ExitMainMenu
			7. Close All but Curent Window=ExitMainMenu

	)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetDefaultSequencesIni()
{
	return "
		(LTrim
			[1]
			Hotkey=LCtrl + LAlt + Numpad1
			1=x=0.00	y=50.00	width=66.67	height=50.00
			2=x=0.00	y=50.00	width=50.00	height=50.00
			3=x=0.00	y=50.00	width=33.33	height=50.00
			4=x=0.00	y=13.50	width=55.00	height=86.50
			5=x=0.00	y=26.90	width=50.00	height=73.10
			GestureName=
			Activate=true
			[2]
			Hotkey=LCtrl + LAlt + Numpad2
			1=x=0.00	y=50.00	width=100	height=50.00
			2=x=33.00	y=50.00	width=33.00	height=50.00
			3=x=0.00	y=68.25	width=100	height=31.75
			GestureName=
			Activate=true
			[3]
			Hotkey=LCtrl + LAlt + Numpad3
			1=x=33.33	y=50.00	width=66.67	height=50.00
			2=x=50.00	y=50.00	width=50.00	height=50.00
			3=x=66.67	y=50.00	width=33.33	height=50.00
			4=x=45.00	y=13.50	width=55.00	height=86.50
			5=x=50.00	y=26.94	width=50.00	height=73.06
			GestureName=
			Activate=true
			[4]
			Hotkey=LCtrl + LAlt + Numpad4
			1=x=0.00	y=0.00	width=66.67	height=100.00
			2=x=0.00	y=0.00	width=56.77	height=100.00
			3=x=0.00	y=0.00	width=50.00	height=100.00
			4=x=0.00	y=0.00	width=33.33	height=100.00
			GestureName=
			Activate=true
			[5]
			Hotkey=LCtrl + LAlt + Numpad5
			1=x=16.67	y=0.00	width=66.67	height=100.00
			2=x=0.00	y=0.00	width=100.00	height=100.00
			3=x=33.33	y=0.00	width=33.33	height=100.00
			4=x=13.50	y=25.00	width=86.50	height=75.00
			GestureName=
			Activate=true
			[6]
			Hotkey=LCtrl + LAlt + Numpad6
			1=x=11.75	y=0.00	width=88.25	height=100.00
			2=x=33.33	y=0.00	width=66.67	height=100.00
			3=x=50.00	y=0.00	width=50.00	height=100.00
			4=x=56.77	y=0.00	width=43.23	height=100.00
			5=x=66.67	y=0.00	width=33.33	height=100.00
			GestureName=
			Activate=true
			[7]
			Hotkey=LCtrl + LAlt + Numpad7
			1=x=0.00	y=0.00	width=66.67	height=50.00
			2=x=0.00	y=0.00	width=50.00	height=50.00
			3=x=0.00	y=0.00	width=33.33	height=50.00
			4=x=0.00	y=0.00	width=41.50	height=100.00
			GestureName=
			Activate=true
			[8]
			Hotkey=LCtrl + LAlt + Numpad8
			1=x=0.00	y=0.00	width=100.00	height=50.00
			2=x=33.33	y=0.00	width=33.33	height=50.00
			3=x=0.00	y=0.00	width=100.00	height=31.75
			GestureName=
			Activate=true
			[9]
			Hotkey=LCtrl + LAlt + Numpad9
			1=x=33.33	y=0.00	width=66.67	height=50.00
			2=x=50.00	y=0.00	width=50.00	height=50.00
			3=x=66.67	y=0.00	width=33.33	height=50.00
			GestureName=
			Activate=true

		)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetDefaultHotkeysIni()
{
	return "
		(LTrim
			;~ [Automatic Placement]
			;~ Activate=true
			;~ Hotkey=Ctrl + Alt + 0
			;~ Type=Settings
			;~ GestureName=
			;~ HelpDesc=

			;~ [Fusion Mode]
			;~ Activate=true
			;~ Hotkey=Win + Ctrl + F
			;~ Type=Resizing
			;~ GestureName=

			;~ [Mosaic Mode]
			;~ Activate=false
			;~ Hotkey=RCtrl + RAlt + S
			;~ Type=Resizing
			;~ GestureName=
			;~ HelpDesc=Arranges windows of the same type into a logical arrangement.

			;~ [Window To Above Monitor]
			;~ Activate=true
			;~ Hotkey=Win + Shift + Ctrl + Alt + Up
			;~ Type=Settings
			;~ GestureName=

			;~ [Window To Below Monitor]
			;~ Activate=true
			;~ Hotkey=Win + Shift + Ctrl + Alt + Down
			;~ Type=Settings
			;~ GestureName=

			[Activate App]
			Activate=true
			Hotkey=Ctrl + Alt + 4
			Type=Settings
			GestureName=
			HelpDesc=Activates this main configuration window.

			[Browser Backward]
			Activate=true
			Hotkey=Win + Alt + Left
			Type=Settings
			GestureName=Browser Backwards
			HelpDesc=Go backward one page (Note: This also works in non-web browser applications such as Windows Explorer).

			[Browser Forward]
			Activate=true
			Hotkey=Win + Alt + Right
			Type=Settings
			GestureName=Browser Forwards
			HelpDesc=Go forward one page (Note: This also works in non-web browser applications such as Windows Explorer).

			[Browser Refresh]
			Activate=true
			Hotkey=
			Type=Settings
			GestureName=Browser Refresh
			HelpDesc=Refreshes the page (Note: This also works in non-web browser applications such as Windows Explorer).

			[Browser Tab Backward]
			Activate=true
			Hotkey=Alt + Shift + Up
			Type=Settings
			GestureName=Browser Tab Backwards
			HelpDesc=Go backward one tab (Note: This should work in any tabbed application, such as this one).

			[Browser Tab Forward]
			Activate=true
			Hotkey=Alt + Shift + Down
			Type=Settings
			GestureName=Browser Tab Forwards
			HelpDesc=Go forward one tab (Note: This should work in any tabbed application, such as this one).

			[Close All But Current Window]
			Activate=false
			Hotkey=LShift + LCtrl + RAlt + C
			Type=Settings
			GestureName=
			HelpDesc=Closes every other window.

			[Close All Windows]
			Activate=false
			Hotkey=Ctrl + Alt + C
			Type=Settings
			GestureName=
			HelpDesc=Closes every window.

			[Close Window]
			Activate=true
			Hotkey=Alt + F4
			Type=Settings
			GestureName=Close Window
			HelpDesc=Closes window.

			[Switch Window]
			Activate=true
			Hotkey=
			Type=Settings
			GestureName=Switch Window
			HelpDesc=Uses Alt + Tab to switch to the previous window.

			[Decrement Transparency]
			Activate=true
			Hotkey=Win + Shift + Alt + T
			Type=Settings
			GestureName=
			HelpDesc=Decreases transparency on window (Note: Some windows, such as Firefox, do not support this feature).

			[Disable Transparency]
			Activate=true
			Hotkey=Win + Shift + O
			Type=Settings
			GestureName=
			HelpDesc=Makes window completely opaque.

			[Enter Key]
			Activate=true
			Hotkey=
			Type=Settings
			GestureName=Enter Key
			HelpDesc=The enter key is usually used to press a focused button.

			[Escape Key]
			Activate=true
			Hotkey=
			Type=Settings
			GestureName=Escape Key
			HelpDesc=The escape key is usually used to exit or minimize a window.

			[Increment Transparency]
			Activate=true
			Hotkey=Win + Alt + T
			Type=Settings
			GestureName=
			HelpDesc=Increases transparency on window (Note: Some windows, such as Firefox, do not support this feature).

			[Maximize Across All Monitors]
			Activate=true
			Hotkey=Ctrl + Shift + Alt + PgUp
			Type=Resizing
			GestureName=
			HelpDesc=Maximizes window across every monitor.

			[Maximize Horizontally]
			Activate=true
			Hotkey=Ctrl + Alt + H
			Type=Resizing
			GestureName=Maximize Horizontally
			HelpDesc=Horizontally maximizes window.

			[Maximize Vertically]
			Activate=true
			Hotkey=Ctrl + Alt + V
			Type=Resizing
			GestureName=Maximize Vertically
			HelpDesc=Vertically maximizes window.

			[Maximize Window]
			Activate=true
			Hotkey=Ctrl + Alt + PgUp
			Type=Resizing
			GestureName=Maximize Window
			HelpDesc=Maximizes window.

			[Minimize Window]
			Activate=true
			Hotkey=Ctrl + Alt + PgDn
			Type=Resizing
			GestureName=Minimize Window
			HelpDesc=Minimizes window.

			[Next Track]
			Activate=true
			Hotkey=Shift + Alt + Right
			Type=Settings
			GestureName=Next Track
			HelpDesc=Goes forward one track.

			[Play or Pause Track]
			Activate=true
			Hotkey=Shift + Alt + P
			Type=Settings
			GestureName=Play/Pause Track
			HelpDesc=Toggles playing/pausing the track.

			[Previous Track]
			Activate=true
			Hotkey=Shift + Alt + Left
			Type=Settings
			GestureName=Previous Track
			HelpDesc=Goes backward one track.

			[Quick Menu]
			Activate=true
			Hotkey=Win + A
			Type=Settings
			GestureName=Launch Quick Menu
			HelpDesc=Activates a menu which provides shortcuts for the most useful window actions.
			RouteToLeapWhenAvailable=false

			[Resize To Bottom Half]
			Activate=true
			Hotkey=LShift + LCtrl + LAlt + S
			Type=Resizing
			GestureName=Window to Bottom Half
			HelpDesc=Resizes window to the bottom half of the monitor.

			[Resize To Center Half]
			Activate=true
			Hotkey=LCtrl + LAlt + Q
			Type=Resizing
			GestureName=Window to Center Half
			HelpDesc=Resizes window to half the size of the monitor and centers it accordingly.

			[Resize To Center Three-fourths]
			Activate=true
			Hotkey=LCtrl + LAlt + C
			Type=Resizing
			GestureName=Window to Center 3/4
			HelpDesc=Resizes window to three-fourths the size of the monitor and centers it accordingly.

			[Resize To Left Half]
			Activate=true
			Hotkey=LShift + LCtrl + LAlt + A
			Type=Resizing
			GestureName=Window to Left Half
			HelpDesc=Resizes window to the left half of the monitor.

			[Resize To Right Half]
			Activate=true
			Hotkey=LShift + LCtrl + LAlt + D
			Type=Resizing
			GestureName=Window to Right Half
			HelpDesc=Resizes window to the right half of the monitor.

			[Resize To Top Half]
			Activate=true
			Hotkey=LShift + LCtrl + LAlt + W
			Type=Resizing
			GestureName=Window to Top Half
			HelpDesc=Resizes window to the top half of the monitor.

			[Snap to Bottom Left]
			Activate=true
			Hotkey=Win + Ctrl + Alt + Left
			Type=Snap
			GestureName=Snap to Bottom Left
			HelpDesc=Snaps window to the bottom left corner of the monitor.

			[Snap to Bottom Right]
			Activate=true
			Hotkey=Win + Ctrl + Alt + Right
			Type=Snap
			GestureName=Snap to Bottom Right
			HelpDesc=Snaps window to the bottom right corner of the monitor.

			[Snap to Center]
			Activate=true
			Hotkey=Win + Ctrl + Alt + C
			Type=Snap
			GestureName=Snap to Center
			HelpDesc=Snaps window to the center of the monitor.

			[Snap to Corner Bottom]
			Activate=true
			Hotkey=Win + Ctrl + Alt + Down
			Type=Snap
			GestureName=Snap to Corner Bottom
			HelpDesc=Snaps window to the bottom corner of the monitor.

			[Snap to Corner Left]
			Activate=true
			Hotkey=Win + Ctrl + Alt + L
			Type=Snap
			GestureName=Snap to Corner Left
			HelpDesc=Snaps window to the left corner of the monitor.

			[Snap to Corner Right]
			Activate=true
			Hotkey=Win + Ctrl + Alt + R
			Type=Snap
			GestureName=Snap to Corner Right
			HelpDesc=Snaps window to the right corner of the monitor.

			[Snap to Corner Top]
			Activate=true
			Hotkey=Win + Ctrl + Alt + Up
			Type=Snap
			GestureName=Snap to Corner Top
			HelpDesc=Snaps window to the top corner of the monitor.

			[Snap to Top Left]
			Activate=true
			Hotkey=Win + Ctrl + Left
			Type=Snap
			GestureName=Snap to Top Left
			HelpDesc=Snaps window to the top left corner of the monitor.

			[Snap to Top Right]
			Activate=true
			Hotkey=Win + Ctrl + Right
			Type=Snap
			GestureName=Snap to Top Right
			HelpDesc=Snaps window to the top right corner of the monitor.

			[Toggle Always On Top]
			Activate=true
			Hotkey=Ctrl + Alt + O
			Type=Settings
			GestureName=
			HelpDesc=Makes window always frontmost or else makes it normal again (Note: Some windows, such as Firefox, do not support this feature).

			[Toggle Mute Volume]
			Activate=true
			Hotkey=Shift + Alt + M
			Type=Settings
			GestureName=Mute/Unmute Volume
			HelpDesc=Toggles muting/unmuting volume.

			[Toggle Window Border]
			Activate=true
			Hotkey=Shift + Ctrl + Alt + B
			Type=Settings
			GestureName=Toggle Window Border
			HelpDesc=Removes standard Windows border or else replaces it (Note: Some windows will not be resizable after their border has been removed).

			[Window To Left Monitor]
			Activate=true
			Hotkey=Ctrl + Alt + Left
			Type=Settings
			GestureName=Window to Left Monitor
			HelpDesc=Moves window to the monitor on the left. Window is wrapped to the rightmost monitor when there are 2 or more monitors present.

			[Window To Right Monitor]
			Activate=true
			Hotkey=Ctrl + Alt + Right
			Type=Settings
			GestureName=Window to Right Monitor
			HelpDesc=Moves window to the monitor on the right. Window is wrapped to the leftmost monitor when there are 2 or more monitors present.

	)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetExceptionsForHotkeysIni()
{
	global g_HotkeysIni

	for sec in g_HotkeysIni
		sExceptionsIni .= "[" sec "]`nType`nHelpDesc`nRouteToLeapWhenAvailable`n"

	return sExceptionsIni
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetDefaultLeapActionsIni()
{
	return "
		(LTrim
			[Move Window]
			Activate=true
			GestureName=Move Window
			UsesPinch=false
			UsesGestures=false
			CallbackWillStop=false
			Hotkey=LWin + LAlt + M
			HelpDesc=Moves window relative to palm motion. Use greater velocity to move between two monitors. For best results, lay palm relatively flat.

			;~ [Pinch Window]
			;~ Activate=true
			;~ GestureName=Pinch Window
			;~ UsesPinch=true
			;~ UsesGestures=false
			;~ CallbackWillStop=false
			;~ Hotkey=LWin + LAlt + P
			;~ HelpDesc=Shrinks/expands window relative to circular motion. Circle right to shrink and left to expand. For best results, use one or two fingers.

			[Resize Window]
			Activate=true
			GestureName=Resize Window
			UsesPinch=false
			UsesGestures=true
			CallbackWillStop=false
			Hotkey=LWin + LAlt + P
			HelpDesc=Shrinks/expands window relative to circular motion. Circle right to shrink and left to expand. For best results, use one or two fingers.

			[Adjust Volume]
			Activate=true
			GestureName=Adjust Volume
			UsesPinch=false
			UsesGestures=false
			CallbackWillStop=false
			Hotkey=LWin + LAlt + V
			HelpDesc=Increases/decreases volume relative to upward/downward palm motion. For best results, lay palm relatively flat.

			[Scroll]
			Activate=true
			GestureName=Scroll
			UsesPinch=false
			UsesGestures=false
			CallbackWillStop=false
			Hotkey=LWin + LAlt + S
			HelpDesc=Scrolls up, down, left, and right relative to palm motion. For best results, use two fingers.

			[Zoom]
			Activate=true
			GestureName=Zoom
			UsesPinch=false
			UsesGestures=true
			CallbackWillStop=false
			Hotkey=LWin + LAlt + Z
			HelpDesc=Zooms in/out of window relative to circular motion. Circle right to zoom in and left to zoom out. For best results, use one or two fingers.

			[Internal_Quick Menu]
			Activate=false
			GestureName=
			UsesPinch=false
			UsesGestures=false
			CallbackWillStop=true
			Hotkey=
	)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetExceptionsForLeapActionsIni()
{
	global g_LeapActionsIni

	for sec in g_LeapActionsIni
		sExceptionsIni .= "[" sec "]`nUsesPinch`nUsesGestures`nCallbackWillStop`nHelpDesc`n"

	return sExceptionsIni
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetDefaultLeapGesturesIni()
{
	return "
		(LTrim
			[Activate App]
			Gesture=Swipe Down, Swipe Up
			[Adjust Volume]
			Gesture=Swipe Forward, Circle Left
			[Browser Backwards]
			Gesture=KeyTap, Swipe Left
			[Browser Forwards]
			Gesture=KeyTap, Swipe Right
			[Browser Refresh]
			Gesture=KeyTap, Circle Right
			[Browser Tab Backwards]
			Gesture=KeyTap, Swipe Up
			[Browser Tab Forwards]
			Gesture=KeyTap, Swipe Down
			[Close Window]
			Gesture=Circle Right, Swipe Down
			[Switch Window]
			Gesture=Circle Right, Swipe Right
			[Enter Key]
			Gesture=KeyTap
			[Escape Key]
			Gesture=KeyTap, Swipe Backward
			[Launch Quick Menu]
			Gesture=Swipe Up, Circle Left, KeyTap
			[Maximize Horizontally]
			Gesture=Circle Left, Swipe Right
			[Maximize Vertically]
			Gesture=Circle Left, Swipe Left
			[Maximize Window]
			Gesture=Circle Left, Swipe Up
			[Minimize Window]
			Gesture=Circle Left, Swipe Down
			[Move Window]
			Gesture=Swipe Forward, Swipe Backward
			[Mute/Unmute Volume]
			Gesture=Swipe Backward, Swipe Down
			[Next Track]
			Gesture=Swipe Backward, Swipe Right
			[Play/Pause Track]
			Gesture=Swipe Backward, KeyTap
			[Previous Track]
			Gesture=Swipe Backward, Swipe Left
			[Resize Window]
			Gesture=Swipe Backward, Circle Left
			[Scroll]
			Gesture=Swipe Up, Swipe Down
			[Snap to Bottom Left]
			Gesture=Swipe Down, Swipe Left
			[Snap to Bottom Right]
			Gesture=Swipe Down, Swipe Right
			[Snap to Center]
			Gesture=Circle Left
			[Snap to Corner Bottom]
			Gesture=Swipe Down, Circle Left
			[Snap to Corner Left]
			Gesture=Swipe Left, Circle Left
			[Snap to Corner Right]
			Gesture=Swipe Right, Circle Left
			[Snap to Corner Top]
			Gesture=Swipe Up, Circle Left
			[Snap to Top Left]
			Gesture=Swipe Up, Swipe Left
			[Snap to Top Right]
			Gesture=Swipe Up, Swipe Right
			[Toggle Mute Volume]
			Gesture=Circle Left, Circle Left
			[Toggle Window Border]
			Gesture=KeyTap, Circle Right, KeyTap
			[Window to Bottom Half]
			Gesture=Swipe Down, Circle Right
			[Window to Center 3/4]
			Gesture=Circle Left, Circle Right
			[Window to Center Half]
			Gesture=Circle Left, KeyTap
			[Window to Left Half]
			Gesture=Swipe Left, Circle Right
			[Window to Left Monitor]
			Gesture=Swipe Left
			[Window to Right Half]
			Gesture=Swipe Right, Circle Right
			[Window to Right Monitor]
			Gesture=Swipe Right
			[Window to Top Half]
			Gesture=Swipe Up, Circle Right
		)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
GetVKsIni()
{
	return "
	(LTrim
		[LButton]
		LButton=0x01
		[RButton]
		RButton=0x02
		;[Control-break processing]
		;Control-break processing=0x03
		[MButton]
		MButton=0x04
		[XButton1]
		XButton1=0x05
		[XButton2]
		XButton2=0x06
		[BACKSPACE]
		BACKSPACE=0x08
		[TAB]
		TAB=0x09
		[CLEAR]
		CLEAR=0xFC
		[ENTER]
		ENTER=0x0D
		;[SHIFT]
		;SHIFT=0x10
		;[CTRL]
		;CTRL=0x11
		;[ALT]
		;ALT=0x12
		[PAUSE]
		PAUSE=0x13
		;[CAPSLOCK]
		;CAPSLOCK=0x14
		[ESC]
		ESC=0x1B
		[SPACEBAR]
		SPACEBAR=0x20
		[PGUP]
		PGUP=0x21
		[PGDN]
		PGDN=0x22
		[END]
		END=0x23
		[HOME]
		HOME=0x24
		[LEFT]
		LEFT=0x25
		[UP]
		UP=0x26
		[RIGHT]
		RIGHT=0x27
		[DOWN]
		DOWN=0x28
		[SELECT]
		SELECT=0x29
		;[PRINT]
		;PRINT=0x2A
		;[EXECUTE]
		;EXECUTE=0x2B
		[PRINTSCREEN]
		PRINTSCREEN=0x2C
		[INS]
		INS=0x2D
		[DEL]
		DEL=0x2E
		;[HELP]
		;HELP=0x2F
		[0]
		0=0x30
		[1]
		1=0x31
		[2]
		2=0x32
		[3]
		3=0x33
		[4]
		4=0x34
		[5]
		5=0x35
		[6]
		6=0x36
		[7]
		7=0x37
		[8]
		8=0x38
		[9]
		9=0x39
		[A]
		A=0x41
		[B]
		B=0x42
		[C]
		C=0x43
		[D]
		D=0x44
		[E]
		E=0x45
		[F]
		F=0x46
		[G]
		G=0x47
		[H]
		H=0x48
		[I]
		I=0x49
		[J]
		J=0x4A
		[K]
		K=0x4B
		[L]
		L=0x4C
		[M]
		M=0x4D
		[N]
		N=0x4E
		[O]
		O=0x4F
		[P]
		P=0x50
		[Q]
		Q=0x51
		[R]
		R=0x52
		[S]
		S=0x53
		[T]
		T=0x54
		[U]
		U=0x55
		[V]
		V=0x56
		[W]
		W=0x57
		[X]
		X=0x58
		[Y]
		Y=0x59
		[Z]
		Z=0x5A
		;[LWin]
		;LWin=0x5B
		;[RWin]
		;RWin=0x5C
		[AppsKey]
		AppsKey=0x5D
		;[Computer Sleep]
		;Computer Sleep=0x5F
		[Numpad0]
		Numpad0=0x60
		[Numpad1]
		Numpad1=0x61
		[Numpad2]
		Numpad2=0x62
		[Numpad3]
		Numpad3=0x63
		[Numpad4]
		Numpad4=0x64
		[Numpad5]
		Numpad5=0x65
		[Numpad6]
		Numpad6=0x66
		[Numpad7]
		Numpad7=0x67
		[Numpad8]
		Numpad8=0x68
		[Numpad9]
		Numpad9=0x69
		[NumpadMult]
		NumpadMult=0x6A
		[NumpadAdd]
		NumpadAdd=0x6B
		;[Separator]
		;Separator=0x6C
		[NumpadSub]
		NumpadSub=0x6D
		[NumpadDot]
		NumpadDot=0x6E
		[NumpadDiv]
		NumpadDiv=0x6F
		[F1]
		F1=0x70
		[F2]
		F2=0x71
		[F3]
		F3=0x72
		[F4]
		F4=0x73
		[F5]
		F5=0x74
		[F6]
		F6=0x75
		[F7]
		F7=0x76
		[F8]
		F8=0x77
		[F9]
		F9=0x78
		[F10]
		F10=0x79
		[F11]
		F11=0x7A
		[F12]
		F12=0x7B
		[F13]
		F13=0x7C
		[F14]
		F14=0x7D
		[F15]
		F15=0x7E
		[F16]
		F16=0x7F
		[F17]
		F17=0x80
		[F18]
		F18=0x81
		[F19]
		F19=0x82
		[F20]
		F20=0x83
		[F21]
		F21=0x84
		[F22]
		F22=0x85
		[F23]
		F23=0x86
		[F24]
		F24=0x87
		[NUMLOCK]
		NUMLOCK=0x90
		[SCROLLOCK]
		SCROLLOCK=0x91
		;[LSHIFT]
		;LSHIFT=0xA0
		;[RSHIFT]
		;RSHIFT=0xA1
		;[LCONTROL]
		;LCONTROL=0xA2
		;[RCONTROL]
		;RCONTROL=0xA3
		;[Left MENU]
		;Left MENU=0xA2
		;[Right MENU]
		;Right MENU=0xA3
		;[Browser Back]
		;Browser Back=0xA4
		;[Browser Forward]
		;Browser Forward=0xA5
		;[Browser Refresh]
		;Browser Refresh=0xA6
		;[Browser Stop]
		;Browser Stop=0xA7
		;[Browser Search]
		;Browser Search=0xA8
		;[Browser Favorites]
		;Browser Favorites=0xA9
		;[Browser Start and Home]
		;Browser Start and Home=0xAA
		;[Volume_Mute]
		;Volume_Mute=0xAD
		;[Volume_Down]
		;Volume_Down=0xAE
		;[Volume_Up]
		;Volume_Up=0xAF
		;[Media_Next]
		;Media_Next=0xB0
		;[Media_Prev]
		;Media_Prev=0xB1
		;[Media_Stop]
		;Stop Media=0xB2
		;[Media_Play_Pause]
		;Media_Play_Pause=0xB3
		;[Start Mail]
		;Start Mail=0xB2
		;[Select Media]
		;Select Media=0xB3
		;[Start Application 1]
		;Start Application 1=0xB4
		;[Start Application 2]
		;Start Application 2=0xB5
		[Equals]
		Equals=0xBB
		[Semicolon]
		Semicolon=0xBA
		[,]
		,=0xBC
		[-]
		-=0xBD
		[.]
		.=0xBE
		;[Used for miscellaneous characters; it can vary byboard.]
		;Used for miscellaneous characters; it can vary byboard.=0xDD
		[OpenBracket]
		OpenBracket=0xDB
		[\]
		\=0xDC
		[']
		'=0xDE
		;[OEM specific]
		;OEM specific=0xE7
		[/]
		/=0xBF
		;[Attn]
		;Attn=0xE8
		;[CrSel]
		;CrSel=0xE9-F5
		;[ExSel]
		;ExSel=0xF6
		;[Erase EOF]
		;Erase EOF=0xF7
		;[Play]
		;Play=0xF8
		;[Zoom]
		;Zoom=0xF9
		;[PA1]
		;PA1=0xFB
		;[]
		;0xB7
		;0xFE
		;0xFD
		;[Undefined]
		;Undefined=0x3A-40
		;[Reserved]
		;Reserved=0xFA
		;[IME Kana mode]
		;IME Kana mode=0x15
		;[IME Hanguel mode (maintained for compatibility; use VK_HANGUL)]
		;IME Hanguel mode (maintained for compatibility; use VK_HANGUL)=0x15
		;[IME Hangul mode]
		;IME Hangul mode=0x15
		;[IME Junja mode]
		;IME Junja mode=0x17
		;[IME final mode]
		;IME final mode=0x18
		;[IME Hanja mode]
		;IME Hanja mode=0x19
		;[IME Kanji mode]
		;IME Kanji mode=0x19
		;[IME convert]
		;IME convert=0x1C
		;[IME nonconvert]
		;IME nonconvert=0x1D
		;[IME accept]
		;IME accept=0x1E
		;[IME mode change request]
		;IME mode change request=0x1F
		;[IME PROCESS]
		;IME PROCESS=0xE2
		;[Unassigned]
		;Unassigned=0xE6
		;[Used to pass Unicode characters as if they werestrokes. The VK_PACKET is the low word of a 32-bit Virtual value used for non-keyboard input methods. For more information, see Remark inBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP]
		;=0xE5
	)"
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;	Includes
#include <class_GUITabEx>
#Include %A_ScriptDir%\WM_Dlg.ahk
#Include %A_ScriptDir%\CFlyout.ahk ; Simply to get around lock-up bug where we cannot call GUIEditSettings from CFMH.
#Include %A_ScriptDir%\CFlyoutMenuHandler.ahk
#Include %A_ScriptDir%\AutoLeap\AutoLeap.ahk