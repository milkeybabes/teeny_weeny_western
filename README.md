# teeny_weeny_western
# 🎮 Unreleased SNES game, which was never completed.

This repository contains the original source code and recovered development assets for an unfinished Super Nintendo Entertainment System (SNES) game project developed in early 1993.

The project was commercially commissioned but never completed or released.
This archive preserves the code and structure exactly as originally written, without modern refactoring, to maintain historical authenticity.

---

## 📜 Historical Context

- Developed during the early SNES era
- Written entirely in 65816 assembly
- Built using period development hardware and DOS-based tools
- Assembler was Crash Barrier METAi Assembler 7.00 and associated hardware
- Custom graphics and map pipeline, assets were designed by Dokk using CRISP2 and DPAINT
- Commercially funded by Tenny Weeny Games, designed by Angela Sutherland, but unfinished

This repository exists as a **historical preservation project**, not as a modernised remake.

---

## 🧠 Technical Overview

**Target Platform**
- Super Nintendo Entertainment System (SNES)
- 65816 CPU

**Engine Features**
- Inro LOGO & Animation, and a bit of a MODE7 Logo spin!
- Game menu, and also a level code entry using shooting ducks
- Mode 1 background configuration
- 8×8 character tile system, but the full map uses 2x2 meta tiles
- Map size: 224 × 115 tiles (not implemented)
- Strip-based scrolling engine
- DMA-driven VRAM updates
- Full-screen redraw routine
- Simple Custom RLE/LZ-style `.PAK` compression format. 
- WRAM-based decompressed map storage
- Debug status panel utilities
- All original supplied game assets, not all added to the working demo code
The architecture reflects development practices and hardware constraints of the time.

---

## 🗂 Repository Folder Structure

SOURCE  - This is all the.ASM code and pak binaries used in the demo. and the build source file for the crash barrier assembly/linker

META  - Contain the DOS .exe's for the CRASH Barrier assembler and linker. Note, this will run on DOSBox

GRAPHICS  - All the original graphics in folders, for BG1 - 3 and SPRITES, some were not implemented (a lot actually)
GRAPHICS ->  CHICKEN	- Some little feathered friends
GRAPHICS ->  COW	- Moo cow images
GRAPHICS ->  HORSE	- Player horse, of course, of course
GRAPHICS ->  PLAYER	- Player character with no name! (see what I did there)
GRAPHICS ->  TRAIN	- Choo choo, I'm a little train with a carriage

CRISP - This is several licensed tools written by Carl Muller that support map/character/conversion utilities. Note: in a DOS box (recomment dosbox-x set the date before 31/12/1999

ROM - This is an SMC binary; you can run it on any SNES Emulator. Works best with a controller
  - The menu lets you select sound stuff. (No sounds or music were implemented or provided)
  - Password: this was the concept to go to a particular game or level stat using a magic-generated code.
  - Start the game/demo scene
  -   Buttons move the player around using normal keypad directions. If you get to the rear of the horse and use B, you can then mount the horse to move around
  -   The start button will bring up a high-resolution game map level
  -   Pad R1 would bring up a crosshair, where you can then move about and shoot a bullet (FYI, there was no designed bullet)
  -   Pad L1 was a debug to scroll about the map in a defined window area.

GAME_MAP - This was not originally provided (of course), but I generated the file "Entire map.bmp", which shows the game map.
  -  The original design had three character sets, which were to be used in different portions of the game, but still used the same 2x2 meta tile map data!
  - Using Photoshop and a bit of grey matter, I generated each map as an overlay and merged them to fix what would have been the complete map.
  - 3584 x 1840 pixels would have been big on a SNES. It's not perfect, but it gives you an idea of what it would have looked like live.
  - There were to be some priority elements where you could walk behind buildings and trees, not implemented, of course.

## 🛠 Building

This project preserves its original assembly structure.

To build:

1. I recommend using DOSBox.com software; you could use a DOS VM if you are hardcore.
2. You need at least the BIN and SOURCE folder contents to assemble the binary.
3. Best to set the path as. PATH = %PATH%;C:\BIN  (this is the CRASH Barrier Binary .EXE files)
3. Goto the SOURCE folder. and run from the command line
	>METAMAKE GAME

	>OBSEND GAME,F,SNES-ROM.SMC,,
 
The build system has not been modernised intentionally. The Metamake will generate a .COD file, which you need, and then the OBSEND command is generated into the expanded raw ROM, ie a filled-out binary SNES rom format.

## ⚠ Preservation Notice

This codebase is presented as a historical archive.

- The code has not been refactored.
- Structural decisions reflect early 1990s hardware constraints.
- Unfinished systems remain as originally implemented.
- No gameplay or architectural revisions have been made.

The intent is preservation, not revision.

---

## 📄 Licensing & Rights

If you are a rights holder associated tool .exe with this project and wish to discuss its presence here, please open an issue.

This repository is shared in good faith as an archive of historical development.

---

## 🧾 Acknowledgement

This archive exists thanks to the recovery of original source materials and development assets after several decades.

It is preserved to document a small piece of early SNES development history.

