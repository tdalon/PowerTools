; Converted with v2converted 11:39 Thursday, May 16, 2024
; Battery notification
;
; When the battery is charged, a notification
; will appear to tell the user to remove the charger
;
; When the battery is below 30%, a notification
; will appear to tell the user to plug in the charger

; Idea for core battery monitoring: https://github.com/GorvGoyl/Autohotkey-Scripts-Windows/blob/master/battery_alert.ahk


#Requires Autohotkey v2+

; #Warn  ; Enable warnings to assist with detecting common errors.


#SingleInstance Force


; Parameters
P_ReadPeriod := 60 * 5 ; in s
P_ChargedPercentage := 95
P_LowBatteryPercentage := 20
P_NotifPeriod := 60 * 2 ; in s

; Settings
NotifSound := 0 ; or 1

sleepTime := P_ReadPeriod

Loop{ ;Loop forever

; From https://www.autohotkey.com/boards/viewtopic.php?t=128527 for v2
buf := Buffer(12, 0) 
If (DllCall("GetSystemPowerStatus", "Ptr", buf.Ptr)) {
		ACLineStatus := NumGet(buf, 0, "UChar") ; 0 if Discharging, 1 if Charging
	;BatteryFlag := NumGet(SYSTEM_POWER_STATUS, 1, "UChar")
	BatteryLifePercent := NumGet(buf, 2, "UChar")
	;SystemStatusFlag := NumGet(SYSTEM_POWER_STATUS, 3, "UChar")
	;BatteryLifeTime := NumGet(SYSTEM_POWER_STATUS, 4, "UInt")
	;BatteryFullLifeTime := NumGet(SYSTEM_POWER_STATUS, 8, "UInt")	
}


;Is the battery charged higher than P_ChargedPercentage
if (BatteryLifePercent > P_ChargedPercentage){  

	if (ACLineStatus == 1){ ; Charging Only notify me once
		if (BatteryLifePercent == 255){ ; Error
			sleepTime := 60
			}
		else{
			text := "Battery charded to " . BatteryLifePercent . "%"
			TrayTip text,"Remove Charger", 2+ NotifSound*16 ; Warning Icon 2 + Mute 16
			sleepTime := P_NotifPeriod ; do not check for sleepTime after battery charged
		}
	}
	else{ ; Discharging
		sleepTime := P_ReadPeriod
	}
}

if (BatteryLifePercent < P_LowBatteryPercentage){ ;Yes. 

	if (ACLineStatus == 0){ ;Discharging Only notify me once
		;Format the message box
		; output=PLUG IN THE CHARGING CABLE.`nBattery Life: %BatteryLifePercent%%percentage%
		text := "Battery discharged to " . BatteryLifePercent . "%"
		SoundBeep(1500, 200)
		; MsgBox, %output% ;Notify me.
		TrayTip text,"Plug-in Charger", 2+NotifSound*16 ; Warning Icon 2 + Mute 16
		sleepTime := P_NotifPeriod
	}
	else{
		sleepTime := P_ReadPeriod
	}
}

Sleep(sleepTime*1000) ;sleep in ms
}