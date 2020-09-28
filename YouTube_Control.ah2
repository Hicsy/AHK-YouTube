/**
 * Send keyboard shortcuts at YouTube, even while it's in a background window.
 * I made this so I can skip back & repeat what was just said i'm while gaming.
 *
 * 1/ Set which program to control: Open it to a video, and tap a hotkey once.
 * 2/ Coninue using other apps in the foreground, but don't minimise YouTube.
 * 3/ With multiple YouTube tabs open, it will control the first one it sees.
 * 4/ Set a different window/app by long-pressing the hotkey.
 * 5/ Usually, you can't long-press MEDIA_* keys.
 *      As a work-around, I sometimes rebind my play/pause to F21>F24 in iCue.
 *
 * @author Hicsy
 * @link https://github.com/Hicsy/AHK-YouTube | ReadMe + Installation.
 * @link https://support.google.com/youtube/answer/7631406 | Keyboard Shortcuts
 * @inspiration https://www.reddit.com/r/AutoHotkey/comments/4c6h42/YT/d1fqr72/
 *
 * @requires AutoHotKey Version: 2.0 (Tested on build a122)
 */

;region ====================== Initialisation =================================

; Keep running. https://lexikos.github.io/v2/docs/commands/_Persistent.htm
#Persistent
; https://lexikos.github.io/v2/docs/commands/_SingleInstance.htm
#SingleInstance force

; https://lexikos.github.io/v2/docs/commands/SetWorkingDir.htm
;SetWorkingDir A_ScriptDir

; Set title-matching = "contains".
; https://lexikos.github.io/v2/docs/commands/SetTitleMatchMode.htm
SetTitleMatchMode("regex")
DetectHiddenWindows(True)
; If the searchTitle finds wrong tabs, you can make it more specific eg:
;global searchTitle := ".* - YouTube - Google Chrome"
global searchTitle := ".* - YouTube.*"

; A timeout for looping through browser tabs to find YouTube player.
global MaxTabs := 20

; The Window-Handle for YouTube.
global youTubeHWND := 0

; Sets how long (seconds) a key needs to be held down for a long-press:
global shortHold := "T0.35"
global longerHold := "T1.5"

; You can define your own sounds here or remove to silence alerts.
global soundAck := "C:\Windows\Media\Windows Pop-up Blocked.wav"
global soundWarn := "C:\Windows\Media\Speech On.wav"
global soundRecord := "C:\Windows\Media\Speech Sleep.wav"
global soundCancel := "C:\Windows\Media\Recycle.wav"
global soundError := "C:\Windows\Media\Windows Default.wav"


;region ---------------------- Helper Functions -------------------------------
/**
 * Set youTubeHWND to current window (if it appears to be on a YouTube video).
 * @return {int} Returns HWND if set... otherwise return 0.
 */
ResetHWND() {
	global searchTitle
	global soundRecord
	global soundError
	global youTubeHWND
	If WinActive(searchTitle){
		youTubeHWND := WinGetID("A")
		SoundPlay(soundRecord)
		Return youTubeHWND
	} Else {
		; This app doesnt have the desired tab open.
		SoundPlay(soundError)
		Return 0
	}
}

/**
 * Check the set youTubeHWND still exists.
 * Optionally resets youTubeHWND if current recorded HWND doesnt exist.
 * If it still can't find a suitable HWND, returns 0.
 * @param {boolean=} resetOnFail Run ResetHWND now, if HWND doesnt exist?
 * @return {int} Returns HWND if found, otherwise 0.
 */
CheckHWND(resetOnFail := False) {
	global youTubeHWND
	global soundError
	If (WinExist("ahk_id " youTubeHWND)) {
		return youTubeHWND
	} Else {
		if (resetOnFail) {
			youTubeHWND := ResetHWND()
		} else {
			youTubeHWND := 0
		}
		return youTubeHWND
	}
}

/**
 * Brings background-focus to the correct tab for sending keyboard commands.
 * Move your YouTube tab to the first tab for fastest background-control.
 * @link https://lexikos.github.io/v2/docs/commands/ControlFocus.htm
 * @link https://lexikos.github.io/v2/docs/commands/ControlSend.htm
 * @return {boolean} True on success, otherwise False.
 */
FocusYouTube() {
	global maxTabs
	global searchTitle
	global youTubeHWND
	If (CheckHWND()) {
		ControlFocus(youTubeHWND)
		If (WinExist(searchTitle)) {
			Return True
		} Else {
			; Start searching at tab 1...
			ControlSend("^1", youTubeHWND, searchTitle)
			Loop maxTabs{
				If (WinExist(searchTitle)) {
					Return True
				} Else {
					; Try the next tab...
					switchTab := "{Control Down}{Tab}{Control Up}"
					ControlSend(switchTab, youTubeHWND, searchTitle)
					; Wait >30 milliseconds to load tab before trying again.
					Sleep(50)		;1000 ms = 1 sec.
				}
			}
			SoundPlay(soundError)
			Return False
		}
	}
}

/**
 * Sends the hotkey at the YouTube tab.
 * If it can't find your YouTube tab, try to remember the current one instead.
 * This will work in the background once set, but not minimised (due to tabs).
 * @link https://lexikos.github.io/v2/docs/commands/ControlSend.htm
 * @link https://support.google.com/youtube/answer/7631406 | Keyboard Shortcuts
 * @param {string} myCommand The keyboard shortcut to send at the YouTube tab.
 */
ControlYouTube(myCommand) {
	global searchTitle
	global soundAck
	global youTubeHWND
	If (CheckHWND(True)) {
		If (FocusYouTube()) {
			; YouTube tab located; sending your command...
			ControlFocus(youTubeHWND)
			ControlSend(myCommand, youTubeHWND, searchTitle)
			SoundPlay(soundAck)
			Return
		} Else {
			; Couldn't find YouTube in the designated window; trying again...
			ResetHWND()
		}
	}
}

/**
 * Times how long a key has been held down for:
 * 		[TAP]: Send the chosen keyboard command @YT.
 * 		[HOLD]: Reset HWND to current active window.  (Keep holding to abort).
 * MEDIA_PLAY (etc) usually cannot be HELD, only TAP (see my keymaps).
 * @link https://support.google.com/youtube/answer/7631406 | Keyboard Shortcuts
 * @param {string} keyDown The key being held down. MediaKeys usually dont work.
 * @param {string} myCommand The keyboard shortcut to send at the YouTube tab.
 */
KeyDownTimer(keyDown, myCommand) {
	global shortHold
	global longerHold
	global soundWarn
	global soundCancel
	If (KeyWait(keyDown, shortHold)) {
		;key released early          << [TAP] Commands go here
		ControlYouTube(myCommand)
		Return
	} Else {
		SoundPlay(soundWarn)
		If (KeyWait(keyDown, longerHold)) {
			;shortHold (1>3sec)      << [HOLD] Commands go here
			if (ResetHWND()) {
				ControlYouTube(myCommand)
			}
			Return
		} Else {
			;Still being held (3sec+) << [LONG-PRESS] Commands (good for abort)
			SoundPlay(soundCancel)

			;finally, do nothing until key is released, to avoid looping.
			KeyWait(keyDown)
		}
	}
}
;endregion --------------------------------------------------------------------
;endregion ============== END: Initialisation =================================



;region ====================== Main ===========================================
;region ---------------------- Keyboard Bindings ------------------------------
/**
 * Put any keybindings you want to use, in this section.
 * If you want to support the LONG-PRESS actions:
 * 		Send the KeyCode, and the YT-Shortcut to KeyDownTimer()
 * Otherwise [for tap only]: Just send the YT-Shortcut to ControlYouTube()
 */
F21:: {
	; Send "k" (play/pause) at YouTube Window
	KeyDownTimer("F21", "k")
}

F22:: {
	; Send "j" (Seek-) at YouTube Window
	KeyDownTimer("F21", "j")
}


;endregion --------------------------------------------------------------------
;endregion ============== END: Main ===========================================