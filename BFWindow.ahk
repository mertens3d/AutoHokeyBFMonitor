; Example #1: Maximize the active window and report its unique ID:
#SingleInstance force

LControl & Numpad6::MoveWindow(1,0)
LControl & Numpad8::MoveWindow(0,-1)
LControl & Numpad2::MoveWindow(0,1)
LControl & Numpad4::MoveWindow(-1,0)

Alt & Numpad6::SizeWindow(1,0)
Alt & Numpad8::SizeWindow(0,-1)
Alt & Numpad2::SizeWindow(0,1)
Alt & Numpad4::SizeWindow(-1,0)

;--- work window
LControl & Numpad5::PlaceWindow("Numpad5",4,3,3,3, false) ; center work window
LControl & Numpad7::PlaceWindow("Numpad7",4,2,2,3, false)

LControl & NumpadDiv::PlaceWindow("NumpadDiv",2,1,1,3, false) ;mobile
LControl & NumpadMult::PlaceWindow("NumpadMult",3,1,2,3, false) ;Tablet
LControl & NumpadSub::PlaceWindow("NumpadSub",5,1,2,3, false) ;Desktop

LControl & Numpad1::PlaceWindow("Numpad1",1,4,3,3, true) ;Left bottom Storage
LControl & Numpad3::PlaceWindow("Numpad3",7,4,2,3, true) ;Right Bottom Storage
LControl & Numpad0::PlaceWindow("Numpad0",4,4,3,3, true) ;Bottom Center work window
LControl & NumpadDot::RestoreAllLastKnown()  
LControl & Numpad9::CycleWindowsWithInCells("Numpad9",1,4,3,3) ;Matching Windows


;----------------------------------------
CycleWindowsWithInCells(kpKey,coordX, coordY, widthUnits, heightUnits){
	
	
	windowsWithinTargetAr := GetAllWindowsWithInCells(coordX, coordY, widthUnits, heightUnits)
	
	winCount := windowsWithinTargetAr.MaxIndex()
	;MsgBox, %winCount%
	
	IniPath := GetIniPath()
	IniRead, lastCycleIndex, %IniPath%, "SectionLastCycleIndex", %kpKey%
	
	;MsgBox, %lastCascadeIndex%
	nextCycleIndex := lastCycleIndex + 1
	maxIndex := windowsWithinTargetAr.MaxIndex()
	
	;skip if it's the active window
	WinGet, active_id, ID, A
	candidateValue := windowsWithinTargetAr[nextCycleIndex]
	;MsgBox, %candidateValue% xx %active_id%
	if (active_id = candidateValue){
		;MsgBox, active
		nextCycleIndex := nextCycleIndex + 1
	}
	
	
	if(nextCycleIndex > maxIndex){
		nextCycleIndex := 1
	}
		
	candidateValue := windowsWithinTargetAr[nextCycleIndex]
	WinActivate, ahk_id %candidateValue%
	
	
	IniWrite, %nextCycleIndex%, %IniPath%, "SectionLastCycleIndex", %kpKey%
	
}
;----------------------------------------
GetIniPath(){
	return "C:\Projects\Code\McCombs\AutoHokeyBFMonitor\BFWindowSettings.ini"
}
;----------------------------------------
IsSlotAvailable(pixelX, pixelY, candidateWindowsAr){
	returnValue := true
	;--- the slot is available if there is not an existing window with location within the fuzz distance
	fuzzDistance := 5
	
	Loop, %candidateWindowsAr%
	{
		StringTrimRight, candidateId, candidateWindowsAr%a_index%, 0
		WinGetPos , candidateX, candidateY, , , ahk_id %candidateId%
		if (candidateX < pixelX + fuzzDistance
		&& candidateX > pixelX - fuzzDistance
		&& candidateY < pixelY + fuzzDistance
		&& candidateY > pixelY - fuzzDistance){
			returnValue := false
		}
	}
	return returnValue
}
;----------------------------------------
GetAllWindowsWithInCells(coordX, coordY, widthUnits, heightUnits){
	WinGet, id, list,,,
	matchingWindows := Object()
	
	colAr := GetColumnArray()
	rowAr := GetRowArray()
	fuzz := 5
	
	minX := colAr[coordX] - fuzz
	minY := rowAr[coordY] - fuzz
	
	maxX := colAr[coordX + widthUnits] + fuzz
	maxY := rowAr[coordY + heightUnits] + fuzz
	
	
	
	Loop, %id%
	{
		;this_id := id%A_Index%
		StringTrimRight, this_id, id%a_index%, 0
		//MsgBox, %this_id%
		WinGetPos , candidateMinX, candidateMinY, Width, Height, ahk_id %this_id%
		candidateMaxX := candidateMinX + Width
		candidateMaxY := candidateMinY + Height
		
		;MsgBox, %candidateMinX% | %minX%  %candidateMinY% | %minY%  %minY% | %maxX%  %candidateMaxY% | %maxY%
		if (candidateMinX > minX && candidateMinY > minY &&  candidateMaxX < maxX && candidateMaxY < maxY){
			
			matchingWindows.Insert(this_id)
					
		}
		
		

		IfMsgBox, NO, break
	}
	
	
	return matchingWindows
}
;----------------------------------------
GetIniValue(kpKey, section){
	IniPath := GetIniPath()
	;MsgBox, %IniPath%
	;read the ini value to find out what the last offset value was
	IniRead, OutputVar, %IniPath%, %section%, %kpKey%
	;MsgBox, %OutputVar%
	return %OutputVar%
}
;----------------------------------------
SetIniValue(kpKey, value, section){
	IniPath := GetIniPath()
	;MsgBox, [%kpKey%] [%value%] [%section%] [%iniPath%]
	IniWrite, %value%, %iniPath%, %section% , %kpKey%
}
;----------------------------------------
RestoreLocationGeneric(existingValue, windowId){
	if (existingValue != "ERROR"){
		;MsgBox, %windowId% " " %existingValue%	
		
		ValuesArray := StrSplit(existingValue, "|")
		
		
		maxIndexFound := ValuesArray.MaxIndex()
		;MsgBox, %ValuesArray% " " %maxIndexFound%
		
		if (maxIndexFound = 5){
			newX := ValuesArray[1]
			newY := ValuesArray[2]
			newWidth := ValuesArray[3]
			newheight := ValuesArray[4]
		
			;MsgBox, %newX% %newY% %newWidth% %newHeight%
			WinRestore , ahk_id %windowId%
			WinMove, ahk_id %windowId%,,%newX%,%newY%,%newWidth%, %newHeight%
		
		}
	}
}

;----------------------------------------
RestoreAllLastKnown(){
	WinGet,AllWinList,List
	
	
	Loop, %AllWinList%
	{
		
		StringTrimRight, this_id, AllWinList%a_index%, 0
		//look for it in the ini
		keyToUse := "last"this_id
		existingValue := GetIniValue(keyToUse, "SectionLastKnownCoordsAndSize")
		;MsgBox, [%keyToUse%] [%existingValue%]
				
		if (existingValue != "ERROR"){
			RestoreLocationGeneric(existingValue,this_id)
		}else {
			;--- try from exe and title
			keyToUse := CalculateProcessTitleString(this_id)
			;MsgBox, [%keyToUse%]
			existingValue := GetIniValue(keyToUse, "LastKnownCoordsAndSizeByTitle")
			
			if(existingValue != "ERROR"){
				;MsgBox, [%existingValue%]
				RestoreLocationGeneric(existingValue, this_id)
			}else{
				;--- use just the process name
				keyToUse := CalculateProcessString(this_id)
				existingValue := GetIniValue(keyToUse, "LastKnownCoordsByProcess")
				if(existingValue != "ERROR"){
					RestoreLocationGeneric(existingValue, this_id)
				}
				;MsgBox, [%keyToUse%]
			}
		
		}
		
	}
}
;----------------------------------------
PlaceWindow(kpKey, coordX, coordY, unitsWide, unitsHigh, cascade){
	
	colAr := GetColumnArray()
	rowAr := GetRowArray()
	WinGetPos, currentX, currentY, currentWidth, CurrentHeight, A
		
	newX := colAr[coordX]	
	newY := rowAr[coordY]
	
	offset := 3
	
	
	newWidth := colAr[coordX + unitsWide] - newX
	newHeight := rowAr[coordY + unitsHigh] - newY
	
	
	if %cascade% {
		maxCascadeIndex := 4
		lastCascadeIndex := GetIniValue(kpKey, "SectionLastKey")
		
		If (lastCascadeIndex = "ERROR"){
			lastCascadeIndex := 0
		}
	
		;MsgBox, ccc %lastCascadeIndex%
		cascadeOffset := 30
		xOffset := cascadeOffset * lastCascadeIndex
		
		newX := newX + xOffset
		newY := newY + xOffset
		;MsgBox, bbb %newX%
		
		sizeDelta := maxCascadeIndex * cascadeOffset
		newWidth := newWidth - sizeDelta
		newHeight := newHeight - sizeDelta
		
		newCascadeOffset := lastCascadeIndex + 1
		if (newCascadeOffset > maxCascadeIndex){
			newCascadeOffset = 0
		}
		
		SetIniValue(kpKey, newCascadeOffset, "SectionLastKey")
	}
	
	
	WinMove, A,,%newX%,%newY%, %newWidth%, %newHeight%
	WinGet, active_id, ID, A
	;MsgBox, ggg %newX%
	
	passString := newX "|" newY
	
	if (%newWidth% != "ERROR"){
		passString := passString "|" newWidth
		
		if (%newHeight% != "ERROR"){
			passString := passString "|" newHeight "|" A_Now
		}
	}

	;MsgBox, %passString%
	;MsgBox, aaa [%active_id%] [%passString%] "SectionLastKnownCoordsAndSize"
	SetIniValue("last" active_id, passString, "SectionLastKnownCoordsAndSize")
	
	Title := CalculateProcessTitleString(active_id)
		
	SetIniValue(Title, passString, "LastKnownCoordsAndSizeByTitle")
	
	ProcessName := CalculateProcessString(active_id)
	SetIniValue(ProcessName, passString, "LastKnownCoordsByProcess")
	
}
;----------------------------------------
CalculateProcessString(targetWindowId){
	WinGet, activeprocess, ProcessName, ahk_id %targetWindowId%
	Title := activeprocess
	Title := RegExReplace(Title, "[^a-zA-Z]", "_")
	return Title
}
;----------------------------------------
CalculateProcessTitleString(targetWindowId){
	WinGet, activeprocess, ProcessName, ahk_id %targetWindowId%
	WinGetTitle, Title, ahk_id %targetWindowId%
	Title := activeprocess "_" Title
	Title := RegExReplace(Title, "[^a-zA-Z]", "_")
	return Title
}
;----------------------------------------
MoveWindow(dirX, dirY){
	
	colAr := GetColumnArray()
	rowAr := GetRowArray()
	WinGetPos, currentX, currentY, currentWidth, CurrentHeight, A
		
	closestCoordX := GetClosestCoord(currentX, colAr)
	closestCoordY := GetClosestCoord(currentY, rowAr)
	
	closestCoordX := closestCoordX + dirX
	closestCoordY := closestCoordY + dirY
	
	if (closestCoordX >= colAr.MaxIndex()){
		closestCoordX := 1
	}
	if (closestCoordY >= rowAr.MaxIndex()){
		closestCoordY := 1
	}
	
	if(closestCoordX < 1){
		closestCoordX := colAr.MaxIndex() - 1
	}
	
	if(closestCoordY < 1){
		closestCoordY := rowAr.MaxIndex() - 1
	}
	
	newX := colAr[closestCoordX]	
	newY := rowAr[closestCoordY]
	
	newWidth := colAr[closestCoordX + 1] - newX
	newHeight := rowAr[closestCoordY + 1] - newY
	
	WinMove, A,,%newX%,%newY%
	
}
;----------------------------------------
SizeWindow(dirX, dirY){
	
	colAr := GetColumnArray()
	rowAr := GetRowArray()
	WinGetPos, currentX, currentY, currentWidth, CurrentHeight, A
		
	closestCoordX := GetClosestCoord(currentX + currentWidth, colAr)
	closestCoordY := GetClosestCoord(currentY + CurrentHeight, rowAr)
	
	closestCoordX := closestCoordX + dirX
	closestCoordY := closestCoordY + dirY
	
	if (closestCoordX > colAr.MaxIndex()){
		closestCoordX := colAr.MaxIndex()
	}
	if (closestCoordY > rowAr.MaxIndex()){
		closestCoordY := rowAr.MaxIndex()
	}
	
	if(closestCoordX <= 1){
		closestCoordX := 1
	}
	
	if(closestCoordY <= 1){
		closestCoordY := 1
	}

	
	newWidth := colAr[closestCoordX ] - currentX
	newHeight := rowAr[closestCoordY] - currentY
	
	WinMove, A,,,,%newWidth%, %newHeight%
	
}
;----------------------------------------

^j::
WinGet, active_id, ID, A
;WinMaximize, ahk_id %active_id%
	
WinActivate, ahk_id %active_id%
WinGetClass, this_class, ahk_id %active_id%
WinGetTitle, this_title, ahk_id %active_id%




;    MsgBox, ahk_class %this_class%`n%this_title% "%active_id%"
;---------------------------------------
GetClosestCoord(currentValue, candidateArray){
	minDist:= 1000000
	minCoord:= 0
	
	for coord, value in candidateArray
		{
			candidateValue := candidateArray[coord]
			candidateDist := Abs(candidateValue - currentValue)
			
			if (candidateDist < minDist){
				minDist := candidateDist
				minCoord := coord
			}
			
			 ;MsgBox, %coord% %candidateValue% %candidateDist% %minDist% %minCoord%
		}
		
	
	return minCoord
}
;----------------------------------------
GetRowArray(){
	Row := Object()
	Row.Insert(0)
	Row.Insert(400)
	Row.Insert(600) ; top of work window
	Row.Insert(850)
	Row.Insert(1200)
	Row.Insert(1700)
	Row.Insert(2160 - 50) ;2160 less taskbar height
	
	return Row
}
;----------------------------------------
GetColumnArray(){
	
	Column := Object()
	Column.Insert(   0)
	Column.Insert( 200)
	Column.Insert( 650) ; 650 - 200 = 450 (iphone 6 414)
	Column.Insert( 900)
	Column.Insert(1800) ; 1700 - 650 = 1,150 - ipadpro 1024
	Column.Insert(1920) ; 3840 / 2 - half - 
	Column.Insert(3050) ; 1800 + 1250 = 3050 - 1200 desktop break point
	Column.Insert(3640) ; 3840 - 200 - symmetry
	Column.Insert(3840)
	
	return Column
}
;----------------------------------------
SizeAndLocateWindow(){
	WinX_A := 0
	Win_x := 200
	Win_y := WinY_B
	Win_width := 200
	Win_height := 400
	
	;WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
}