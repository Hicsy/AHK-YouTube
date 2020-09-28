#Persistent
SetTimer, WatchCursor, 100
return

WatchCursor:
  MouseGetPos, , , id, control
  WinGet, myPid, PID, ahk_id %id%
  ahkId := id+0
  WinGetTitle, title, ahk_id %id%
  WinGetClass, class, ahk_id %id%
  WinGet, ControlList, ControlList, A
  WinGet, ControlHWND, ControlListHwnd, A
  ToolTip, Under Cursor:`nahk_pid: %myPid%`nahk_id: %id% : %ahkId%`nahk_class: %class%`nTitle:%title%`nControl: %control%`n`nWindow Control List:`n%ControlList%`n`nControl HWNDs List:`n%ControlHWND%
return