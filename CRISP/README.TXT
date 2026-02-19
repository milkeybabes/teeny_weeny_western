----------------------
New features in CRISP2
----------------------

V2.05
-----
Palette handling for invalid palettes improved (yet again)
Beep on replacing sprites with bad objects
Bad defns option added to Purge sprites command
Outline command added to drawing windows.
# key is autogroupinc for FRK windows (use with place mode) (Esc cancels)

V2.04
-----
RGB palette handling changed to be separate from pixels/blocks.
Pixels, Blocks and RGB are different in the brush. POS turns pixels into Blocks.
Draw and place for FRKs copies HEX data as well as sprite number.
Speed up loading FRK definitions from BOX files.
Make double-clicking on FRK objects easier
Character grid shown in charsets as well as LBMs
ENTER on FRK uses HEX or TEXT edit. Also T for text, H for hex.
Speed up paste of object.
BLKs load with POS mode as default.
FRKs and MAPs load with better colours if they invalidate the palette.
Background obeys preferences when palette is invalidated.
-Viper option changed to -VESA
Error and warning messages can be set to close automatically after a time.
HexEdit children of FRK and BOX windows can be cancelled with ESC
  or completed with ENTER
HexEdit sets position up with first INS keypress and with startup.

V2.03
-----
Relative filenames can have # in them (current filename)
  CRISP2 PIX2MAP CONVERT MAPMAN REMAP [FRK2CHAV - Gary]
PIX2MAP has -COLUMNS option
Preferences are rearranged
FRK uses HEX on double-click option added to preferences
Viper card supported


V2.02
-----
Viper card acknowledged
FRK files load palette in when loading box files.
Same Transparent option added to preferences
  Causes MAP files to set all transparent colours to the first one.
FRK windows treat box files as paletted (i.e. multiple transparent colours)
Palette allocation for FRK files improved

V2.01
-----
Match with brush sets attributes to show where the pixels are.
EXTRACT handles index specifiers for chunk commands.
PIX2MAP handles palettes with -DOUBLEW better

V2.00
-----
PIX2MAP handles palettes with -SPR 2 better
Att+Check = show attributes but pickup blocks for maps
Remap to Brush Palette added for 16/256 colour picture windows.
Highlight select for NESPAL windows.
EXTRACT handles GAMEGEAR palette correctly
Translate window for drawings (16 colour palettes) ESC, ENTER, CTRL-ENTER.

V1.99
-----
PIX2MAP input file limit raised to 16000 with memory savings
MAPMAN handles comments better
PIX2MAP has -SPR 4,1 option
CONVERT has -BOXTYPE option
BOX2ASM has -POSTYPE option
ALT-comma, ALT-dot, ALT-slash for group animation in FRK files.
Onionskin for FRK groups.
ALT-plus and ALT-minus for insert and delete group in FRK files.

V1.98
-----
Rotate brush command added to CRISP2
PIX2MAP has -MAX option to set max characters for big charsets
PIX2MAP has -LBM block/charset output (not input) for Amiga blocks
FRK windows can be over 1024 characters in width.
VLBM can have comments in script files (using semi-colons)
PIX2MAP input file limit increased from 1000 to 2000
PIX2MAP block limit increased from 1000 to 2000

V1.97
-----
"Dim Attributes" option added to preferences to make attributes more readable
PIX2MAP -BIG handles more characters.

V1.96
-----
F12 = redraw screen added
PIX2MAP - loading block files performs character checking (but not removal).
Clock windows can have their borders removed. ("No Frame" window menu command)

V1.95
-----
PBMs loaded aligned to words rather than bytes
VLBM has script files and wildcards
VLBM supports -auto and -fade options
VLBM correctly reads PBMs


V1.94
-----
PIX2MAP handles -SCH -SIZE xxx yyy option now
Map info displays map pixel size values > 32768

V1.93
-----
File sizes added to file lists
Preferences reorganised
PBMs aligned to bytes rather than 8 bytes
PIX2MAP handles -SCH -SIZE 2 2 option better (block file output)

V1.92
-----
BOX2ASM bug fixed
PIX2MAP handles more files (1000 rather than 500)
MAP2MAT handles more files (1000 rather than 500)
MAT file format changed to include colour data
MAP file format changed to include extra data
PIX2MAP has -BIG option
MAP2MAT has -BIG option
IFFEDIT added to CRISP2 for filelists, icon windows and find file windows
Documentation split up from CRISP2.DOC to several files,
  all in Word for Windows format.
  CR2BUYME.DOC - advert
  CR2QUICK.DOC - quick reference guide
  CR2USER.DOC  - User guide
  CR2PROG.DOC  - programmers guide
  CR2UTILS.DOC - utilities reference
  CR2FILE.DOC  - File formats.
and CR2FILE2.DOC - Same as CR2FILE.DOC but without Nintendo/Sega information.
PIX2MAP handles -SCH -SIZE 2 2 option


V1.91
-----
FRK2ASM bug with positions fixed
REMAP handles GBC character set
IFF handles RIFF format data as well as IFF and MIDI
EXTRACT handles reading RIFF format data

V1.90
-----
Microsoft C++ support (compiles but crashes on overlay calls)
FRK files can edit Text (double click or 'CR' or menu) for object data.
  Hex edit is still available via 'H' or menu.
-NOSORTBOX option for CONVERT
DRAW and ALL icons added to FRK windows
CRISP2 Preference for sorting BOX files

V1.89
-----
< and > keys for going through MAP/MAT/FRK files.
   , and . keys still do normal function for FRK files.
FRK files can use MAT files for object defns
   (as well as BOX and drawing files)
PIX2MAP allocates memory for blocks as needed rather than at the start.
CRISP2 handles super-matrices - MAPs of MAPs
In MAP windows, ALT-P toggles preview mode.
Added map size data to Map info dialog box.
PIX2MAP can link directly to uncompressed PBMs with the -temp option.
Save As LBM dialog can save PBMs.
SAVEASPBM batch command added to CRISP2 command line.
TAB in BOX windows gives size of box if one is selected.

V1.88
-----
CRISP2 handles multiple maps in MAP and MAT files.
Load PBMs improved.
MAP2MAT relative filenames improved.
Animation option for MAP/MAT files.

V1.87
-----
Groups for FRK files.

V1.86
-----
Info mode for maps - word rather than byte
User control over colours for grid, attributes, block numbers
Expand anims function for FRK files

V1.85
-----
Sort function for BOX and FRK windows

V1.84
-----
Box files plot weird offsets better
CONVERT handles new IMG format
CRISP2 handles new IMG format
CONVERT handles BDD format

V1.83
-----
Longer directories allowed in icon windows (>300 files)
REMAP can renumber blocks: -noblk and -remap options added.
Show option for maps - shows block numbers ("Check" icon)
Tool icon order changed for drawing windows.

V1.82
-----
RGB edit has palette numbers at top
Less chance of running out of memory on Resize Picture
Crash fixed for BOX windows when using wrong size picture
More memory available
Right click on place icon in BOX files = Set Offsets command
Boxes sorted when used by FRK files
Character counting commands enabled for 16 colour windows
Character count commands improved - overlaid hex numbers rather
  than a black palette.
Character count includes number of chars and number of unique chars
Save As LBM saves system type information
Character count for 16 colour LBMs which are NES ignores palette
CONVERT reads the CRISP2.COP file

V1.81
-----
Attributes for 16 colour pictures
Undo for 16 colour pictures
Box offset editing made faster
MAP and BLK files created by New File now have data

V1.80
-----
Bug in resize attributes of LBM fixed.
Bug in gameboy system setting fixed.
Relative filenames improved

V1.79
-----
FRK file format changed to handle offsets in defns.
CRISP2, CONVERT updated to handle this.
ANIM chunk added to FRK file format.
CRISP2 modified to handle animation within FRK files
Anim icon added to CRISP2
Animation speed dialog box added to FRK windows

V1.78
-----
BOX file data extended to handle Xoffset, Yoffset
BOX2ASM, CONVERT, CRISP2 updated to handle new BOX data
CRISP2 supports offset editing for boxes
Set Offset command added for Box windows
MAP and LBM file data extended to handle Xoffset, Yoffset
PIX2MAP, MAP2MAT, CONVERT, CRISP2 updated to handle new MAP and LBM data
Fixed PIX2MAP bug in -SIZE option
Fixed CRISP2 bug in SaveSF8

V1.77
-----
Support for NCR video card

V1.76
-----
Place tool implemented for FRK files.
Oak technology video card support improved
GCH gamegear character set format added (4096 colours)
MAT file format changed
Calculator supports binary output
Divide by zero in calculator checked for.

V1.75
-----
Icon docks for FRK, BOX and MAP windows.
FRK files can use box files as children.

V1.74
-----
Icons - can drag an icon from an icon window by dragging with left
button and clicking with right button.

V1.73
-----
Big Icons - drag another icon onto a big icon to set its command.
  then you can double click on the big icon to do the command.
New tool icons for box files - resize. Sets size of boxes that
  are left-clicked on to size of box you last selected.

V1.72
-----
Big Icons - turn a drawing into an icon and then press I.
  This loads the drawing without a frame around it.


V1.71
-----
Sorting for icon directories and file lists
 - selectable from the Filespec command on the System menu.
New tool icons for box files - lasso and snap.
FRK2ASM tool written.
FRK files can have additional data stored with each object
  - CRISP2 can edit these using a hex editor - simply select the
    object and press H for HexEdit
PIX2MAP can read in BLK and character set files
PIX2MAP does not ignore attributes by default when making blocks.
MAPMAN supports additional operators
EXTRACT supports additional commands
Fixed box and text cursor colours
  - selectable from the Prefs command on the System menu.
PIX2MAP and CRISP2 support GBC format for gameboy character sets

V1.70 and before
----------------
Revision data not available.

