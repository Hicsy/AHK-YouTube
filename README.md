# AHK-YouTube
Send keyboard shortcuts at YouTube, even while it's in a background window.
<br>
I made this so I can skip back & repeat what was just said I'm while gaming.

1. Set which program to control: Open it to a video, and tap a hotkey once.
2. Continue using other apps in the foreground, but don't minimise YouTube.
3. With multiple YouTube tabs open, it will control the first one it sees.
4. Set a different window/app by long-pressing the hotkey.
5. Usually, you can't long-press `MEDIA_*` keys. (eg `MEDIA_STOP`)<br>
      *As a work-around, I sometimes rebind my play/pause to `F21`>`F24` in iCue.*



 * [YouTube Keyboard Shortcuts](https://support.google.com/youtube/answer/7631406)
 * [My inspiration for this script](https://www.reddit.com/r/AutoHotkey/comments/4c6h42/YT/d1fqr72/)

## REQUIREMENTS:
[AutoHotKey Version: 2.0](https://www.autohotkey.com/v2/) (Tested on build a122)

## SETUP:

1. Use provided examples to add your hotkeys in the `Main` section (bottom).
2. Install [AutoHotKey v2](https://www.autohotkey.com/v2/) if you haven't already.
3. Set the .ah2 file to run in AutoHotKey. In windows: `right-click` > `properties` > `open with` .

## USAGE:
1. Run the AutoHotKey script, (or set it to run at OS startup).
2. Choose a window with a YouTube video in it. Tap your hotkey to remember it.
3. While in another app, use your hotkeys to control YouTube in the background.
4. If the browser changes: long-press a hotkey to reset the script to the new window.