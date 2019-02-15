!a::Send {ä}
+!a::Send {Ä}
<^>!a::Send {ä}
+<^>!a::Send {Ä}
!u::Send {ü}
+!u::Send {Ü}
<^>!u::Send {ü}
+<^>!u::Send {Ü}
!o::Send {ö}
+!o::Send {Ö}
<^>!o::Send {ö}
+<^>!o::Send {Ö}
!s::Send {ß}
<^>!s::Send {ß}

CurrentDesktop = 1
DesktopCount = 1
mapDesktopsFromRegistry() {
 global CurrentDesktop, DesktopCount
 ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
 IdLength := 32
 SessionId := getSessionId()
 if (SessionId) {
 RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
 if (CurrentDesktopId) {
 IdLength := StrLen(CurrentDesktopId)
 }
 }
 ; Get a list of the UUIDs for all virtual desktops on the system
 RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
 if (DesktopList) {
 DesktopListLength := StrLen(DesktopList)
 ; Figure out how many virtual desktops there are
 DesktopCount := DesktopListLength / IdLength
 }
 else {
 DesktopCount := 1
 }
 ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
 i := 0
 while (CurrentDesktopId and i < DesktopCount) {
 StartPos := (i * IdLength) + 1
 DesktopIter := SubStr(DesktopList, StartPos, IdLength)
 OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
 ; Break out if we find a match in the list. If we didn't find anything, keep the
 ; old guess and pray we're still correct :-D.
 if (DesktopIter = CurrentDesktopId) {
 CurrentDesktop := i + 1
 OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
 break
 }
 i++
 }
}

getSessionId()
{
 ProcessId := DllCall("GetCurrentProcessId", "UInt")
 if ErrorLevel {
 OutputDebug, Error getting current process id: %ErrorLevel%
 return
 }
 OutputDebug, Current Process Id: %ProcessId%
 DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
 if ErrorLevel {
 OutputDebug, Error getting session id: %ErrorLevel%
 return
 }
 OutputDebug, Current Session Id: %SessionId%
 return SessionId
}

showLabel:
	Thread, interrupt, 50
	func_left() 
	Gui, Destroy
	global CurrentDesktop
    mapDesktopsFromRegistry()
    Gui -Caption +AlwaysOnTop +Owner
    Gui, Color, EEAA99
	Gui +LastFound  ; 让 GUI 窗口成为 上次找到的窗口 以用于下一行的命令.
	WinSet, TransColor, EEAA99
    Gui, Add, Text,, Please enter your name: %CurrentDesktop%
    Gui, Show, NA, xCenter y0 AutoSize, %file%
    Sleep, 10000
	Gui, Destroy

Return

FileInstall, p.jpg, p.jpg
show_index(dir)
{
	global CurrentDesktop, DesktopCount
	CurrentIndex := CurrentDesktop+dir
	if(CurrentIndex < 1){
		CurrentIndex := 1
	}
	else if (CurrentIndex > DesktopCount){
		CurrentIndex := Floor(DesktopCount)
	}
	CustomColor = 000000
	TransColor=000000
	
    
    Gui -Caption +AlwaysOnTop +Owner
    ;Gui, Add, Picture, w300 h-1, p.jpg
    Gui, Color, 333333 ;背景颜色
	Gui +LastFound  ; 让 GUI 窗口成为 上次找到的窗口 以用于下一行的命令.
	;WinSet, TransColor, 000000
	Gui, Font, s100, Courier New Bold ;设置字体格式
    ;Gui, Add, Text,, %CurrentDesktop%
    WinSet, TransColor, %CustomColor% 2000 ;设置背景半透明
    Gui, Add, Text, cffffff BackGroundTrans, %CurrentIndex% ;当前的桌面号
    ;Gui, Add, Text, cffffff BackGroundTrans, %dir%
    ;Gui, Add, Text, x4 y4 w384 h80 Center  c000000 BackgroundTrans, %CurrentDesktop%
    
    Gui, Show, NA
    Sleep, 300
    Gui, Destroy
}

func_left() 
{ 
	mapDesktopsFromRegistry()
    Send ^#{Left}
    show_index(-1)
} 

func_right() 
{ 
	mapDesktopsFromRegistry()
    Send ^#{Right}
    show_index(1)
} 
#If MouseIsOver("ahk_class Shell_TrayWnd")
WheelLeft::func_left()
WheelRight::func_right()
MouseIsOver(WinTitle) {  
    MouseGetPos,,, Win  
    return WinExist(WinTitle . " ahk_id " . Win)  
}  
