# DoubleXP

**NOTE: 
Starting with patch 2.6.0 WoW Mania has it's own in-game double XP week-end notification system. This addon is not needed anymore!**


This is and addon for WoW 3.3.5 (WOTLK) on woW-Mania private server.

Its purpose is to give time before the next double XP Weekend, or time left before the double XP Weekend ends.

It's standalone, that means it does not need any external library.

As WoW API for 3.3.5 doesn't give an accurate Server time, you need to manually adjust the offset of your timezone. It's not the real offset but the offset compared to server time. There's a slash command for that (/dxp offset <value>).

## Install

### Downloading ZIP file

1. On Github, download project as a ZIP file (https://github.com/vexira/DoubleXP then `Clone or download` then `Download ZIP`).
2. Unpack ZIP and place content in the `Interface\AddOns\` folder of you WoW installation. You need to put the directory there, not the files. And there must only have one directory called DoubleXP-master.
3. (Optionnal) Rename the directory to `DoubleXP`

In the end, the directory structure should looks like this:

```
WoW\
   |
   .- Interface\
       |
       .- AddOns\
           |
	   .- DoubleXP\
	       |
	       |- DoubleXP.lua
	       |- DoubleXP.toc
	       |- DoubleXP.xml
	       |- LICENSE.txt
	       .- README.md
```

### Cloning repository

If you have Git installed on your computer, you can clone this repository to your `Interface\Addon\`  folder.

## Notes

This is my first addon, I hope it might be of some help even if I known it's limited by nature.

Remarks and bug reports are to be sent via Github.
