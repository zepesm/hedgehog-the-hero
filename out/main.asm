  // Commodore 64 PRG executable file - with the cruncher plugin enabled
.plugin "se.triad.kickass.CruncherPlugins"
.file [name="main.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [start=$4000]
.segment Basic
:BasicUpstart(main)
//
  /// $D011 Control Register #1  Bit#5: BMM Turn Bitmap Mode on/off
  .const VICII_BMM = $20
  /// $D011 Control Register #1  Bit#4: DEN Switch VIC-II output on/off
  .const VICII_DEN = $10
  /// $D011 Control Register #1  Bit#3: RSEL Switch betweem 25 or 24 visible rows
  ///          RSEL|  Display window height   | First line  | Last line
  ///          ----+--------------------------+-------------+----------
  ///            0 | 24 text lines/192 pixels |   55 ($37)  | 246 ($f6)
  ///            1 | 25 text lines/200 pixels |   51 ($33)  | 250 ($fa)
  .const VICII_RSEL = 8
  /// $D016 Control register #2 Bit#4: MCM Turn Multicolor Mode on/off
  .const VICII_MCM = $10
  /// The colors of the C64
  .const BLACK = 0
  .const KEY_F1 = 4
  .const ASSET_BITMAP_WELL = 1
  .const ASSET_BITMAP_HEDGEHOG = 2
  .const OFFSET_STRUCT_MOS6526_CIA_PORT_A_DDR = 2
  .const OFFSET_STRUCT_MOS6526_CIA_PORT_B = 1
  .const OFFSET_STRUCT_MOS6569_VICII_BORDER_COLOR = $20
  .const OFFSET_STRUCT_MOS6569_VICII_BG_COLOR = $21
  .const OFFSET_STRUCT_MOS6569_VICII_BG_COLOR2 = $23
  .const OFFSET_STRUCT_MOS6569_VICII_RASTER = $12
  /// $D011 Control Register #1
  /// @see #VICII_CONTROL1
  .label D011 = $d011
  /// $D016 Control register 2
  /// @see #VICII_CONTROL2
  .label D016 = $d016
  /// $D018 VIC-II base addresses
  // @see #VICII_MEMORY
  .label D018 = $d018
  /// The VIC-II MOS 6567/6569
  .label VICII = $d000
  /// The CIA#1: keyboard matrix, joystick #1/#2
  .label CIA1 = $dc00
  /// The CIA#2: Serial bus, RS-232, VIC memory bank
  .label CIA2 = $dd00
  .label MEM_BITMAP = $2000
  .label MEM_SCREENRAM = $400
  .label MEM_COLORRAM = $d800
  .label musicInit = MEM_MUSIC
  .label musicPlay = MEM_MUSIC+3
.segment Code
main: {
    .const vicSelectGfxBank1_toDd001_return = 3
    .const toD0181_return = (>(MEM_SCREENRAM&$3fff)*4)|(>MEM_BITMAP)/4&$f
    //        (*musicInit)();
    //        (*musicPlay)();
    lda #BLACK
    sta VICII+OFFSET_STRUCT_MOS6569_VICII_BORDER_COLOR
    sta VICII+OFFSET_STRUCT_MOS6569_VICII_BG_COLOR
    sta VICII+OFFSET_STRUCT_MOS6569_VICII_BG_COLOR2
    lda #0
    sta D011
    jsr initAsset
    lda #VICII_BMM|VICII_DEN|VICII_RSEL|3
    sta D011
    lda #VICII_MCM
    sta D016
    lda #3
    sta CIA2+OFFSET_STRUCT_MOS6526_CIA_PORT_A_DDR
    lda #vicSelectGfxBank1_toDd001_return
    sta CIA2
    lda #toD0181_return
    sta D018
  __b1:
    lda #$fd
    cmp VICII+OFFSET_STRUCT_MOS6569_VICII_RASTER
    bne __b1
    jsr handlePlayer
    jsr handleOffIrqVfx
    jmp __b1
}
// void initAsset(char asset)
initAsset: {
    lda #<IMG_CRUNCHED_WELL_BITMAP
    sta.z byteboozer_decrunch.crunched
    lda #>IMG_CRUNCHED_WELL_BITMAP
    sta.z byteboozer_decrunch.crunched+1
    jsr byteboozer_decrunch
    lda #<IMG_CRUNCHED_WELL_SCREEN
    sta.z byteboozer_decrunch.crunched
    lda #>IMG_CRUNCHED_WELL_SCREEN
    sta.z byteboozer_decrunch.crunched+1
    jsr byteboozer_decrunch
    lda #<IMG_CRUNCHED_WELL_COLOR
    sta.z byteboozer_decrunch.crunched
    lda #>IMG_CRUNCHED_WELL_COLOR
    sta.z byteboozer_decrunch.crunched+1
    jsr byteboozer_decrunch
    rts
}
handlePlayer: {
    jsr keyboard_key_pressed
    cmp #0
    beq __breturn
    jsr initExplosion
  __breturn:
    rts
}
handleOffIrqVfx: {
    jsr animateExplosions
    rts
}
// Decrunch crunched data using ByteBoozer
// - crunched: Pointer to the start of the crunched data
// void byteboozer_decrunch(__zp(9) char * volatile crunched)
byteboozer_decrunch: {
    .label crunched = 9
    ldy crunched
    ldx crunched+1
    jsr b2.Decrunch
    rts
}
// Determines whether a specific key is currently pressed by accessing the matrix directly
// The key is a keyboard code defined from the keyboard matrix by %00rrrccc, where rrr is the row ID (0-7) and ccc is the column ID (0-7)
// All keys exist as as KEY_XXX constants.
// Returns zero if the key is not pressed and a non-zero value if the key is currently pressed
// __register(A) char keyboard_key_pressed(char key)
keyboard_key_pressed: {
    .const colidx = KEY_F1&7
    jsr keyboard_matrix_read
    and keyboard_matrix_col_bitmask+colidx
    rts
}
// void initExplosion(char xpos, char ypos)
initExplosion: {
    .const xpos = $a
    .const ypos = $a
    .label __11 = 4
    .label __13 = 6
    .label i = 7
    .label j = 2
    .label y = 5
    lda #1
    sta.z i
  __b2:
    dec.z i
    ldy.z i
    lda explosionIndexes,y
    cmp #0
    beq __b3
    tya
    cmp #0
    bpl __b2
  __b3:
    lda.z i
    cmp #0
    bpl __b1
    rts
  __b1:
    lda #8
    ldy.z i
    sta explosionIndexes,y
    lda #xpos
    sta explosionXorigin,y
    lda #ypos
    sta explosionYorigin,y
    lda #0
    sta.z j
    sta.z y
  __b4:
    lda.z y
    cmp #6
    bcc __b7
    rts
  __b7:
    ldx #0
  __b5:
    cpx #6
    bcc __b6
    inc.z y
    jmp __b4
  __b6:
    lda.z i
    asl
    asl
    asl
    clc
    adc.z i
    asl
    asl
    clc
    adc.z j
    sta.z __11
    lda.z y
    asl
    asl
    clc
    adc.z y
    asl
    asl
    asl
    stx.z $ff
    clc
    adc.z $ff
    sta.z __13
    tay
    lda MEM_SCREENRAM,y
    ldy.z __11
    sta explosionScreenSnapshots,y
    ldy.z __13
    lda MEM_COLORRAM,y
    ldy.z __11
    sta explosionColorSnapshots,y
    inc.z j
    inx
    jmp __b5
}
animateExplosions: {
    .label __11 = 4
    .label __26 = 3
    .label i = 7
    .label indexColor = 6
    .label indexLO = 8
    .label j = 2
    .label y = 5
    lda #0
    sta.z i
  __b1:
    lda.z i
    cmp #8
    bcc __b2
    rts
  __b2:
    ldy.z i
    lda explosionIndexes,y
    cmp #0
    bne __b5
  __b3:
    inc.z i
    jmp __b1
  __b5:
    lda #0
    sta.z j
    sta.z y
  __b4:
    lda.z y
    cmp #6
    bcc __b8
    ldx.z i
    dec explosionIndexes,x
    jmp __b3
  __b8:
    ldx #0
  __b6:
    cpx #6
    bcc __b7
    inc.z y
    jmp __b4
  __b7:
    lda.z i
    asl
    asl
    asl
    clc
    adc.z i
    asl
    asl
    clc
    adc.z j
    sta.z __11
    lda #$f
    ldy.z __11
    and explosionColorSnapshots,y
    asl
    asl
    asl
    ldy.z i
    clc
    adc explosionIndexes,y
    sta.z indexColor
    lda #$f
    ldy.z __11
    and explosionScreenSnapshots,y
    asl
    asl
    asl
    ldy.z i
    clc
    adc explosionIndexes,y
    sta.z indexLO
    lda #$f0
    ldy.z __11
    and explosionScreenSnapshots,y
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    ldy.z i
    clc
    adc explosionIndexes,y
    tay
    lda.z y
    asl
    asl
    clc
    adc.z y
    asl
    asl
    asl
    stx.z $ff
    clc
    adc.z $ff
    sta.z __26
    lda COLOR_FADES,y
    asl
    asl
    asl
    asl
    ldy.z indexLO
    ora COLOR_FADES,y
    ldy.z __26
    sta MEM_SCREENRAM,y
    ldy.z indexColor
    lda COLOR_FADES,y
    ldy.z __26
    sta MEM_COLORRAM,y
    inc.z j
    inx
    jmp __b6
}
// Read a single row of the keyboard matrix
// The row ID (0-7) of the keyboard matrix row to read. See the C64 key matrix for row IDs.
// Returns the keys pressed on the row as bits according to the C64 key matrix.
// Notice: If the C64 normal interrupt is still running it will occasionally interrupt right between the read & write
// leading to erroneous readings. You must disable the normal interrupt or sei/cli around calls to the keyboard matrix reader.
// __register(A) char keyboard_matrix_read(char rowid)
keyboard_matrix_read: {
    lda keyboard_matrix_row_bitmask
    sta CIA1
    lda CIA1+OFFSET_STRUCT_MOS6526_CIA_PORT_B
    eor #$ff
    rts
}
.segment Data
  // Keyboard row bitmask as expected by CIA#1 Port A when reading a specific keyboard matrix row (rows are numbered 0-7)
  keyboard_matrix_row_bitmask: .byte $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f
  // Keyboard matrix column bitmasks for a specific keybooard matrix column when reading the keyboard. (columns are numbered 0-7)
  keyboard_matrix_col_bitmask: .byte 1, 2, 4, 8, $10, $20, $40, $80
  // The byteboozer decruncher
BYTEBOOZER:
.const B2_ZP_BASE = $fc
    #import "byteboozer_decrunch.asm"

  // WELL packed
IMG_CRUNCHED_WELL_BITMAP:
.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328"
    .var pic = LoadBinary("assets/gfx/well.kla", KOALA_TEMPLATE)        
    .modify B2() {
	    .pc = MEM_BITMAP
        .fill pic.getBitmapSize(), pic.getBitmap(i)
    }
 
IMG_CRUNCHED_WELL_SCREEN:
.modify B2() {
	    .pc = MEM_SCREENRAM
        .fill pic.getScreenRamSize(), pic.getScreenRam(i)
    }
 
IMG_CRUNCHED_WELL_COLOR:
.modify B2() {
	    .pc = MEM_COLORRAM
        .fill pic.getColorRamSize(), pic.getColorRam(i)
    }
 
  // HEDGEHOG packed
IMG_CRUNCHED_HEDGEHOG_BITMAP:
.var pic2 = LoadBinary("assets/gfx/hedgehog.kla", KOALA_TEMPLATE)        
    .modify B2() {
	    .pc = MEM_BITMAP
        .fill pic2.getBitmapSize(), pic2.getBitmap(i)
    }
 
IMG_CRUNCHED_HEDGEHOG_SCREEN:
.modify B2() {
	    .pc = MEM_SCREENRAM
        .fill pic2.getScreenRamSize(), pic2.getScreenRam(i)
    }
 
IMG_CRUNCHED_HEDGEHOG_COLOR:
.modify B2() {
	    .pc = MEM_COLORRAM
        .fill pic2.getColorRamSize(), pic2.getColorRam(i)
    }
 
  explosionIndexes: .byte 0, 0, 0, 0, 0, 0, 0, 0
  explosionXorigin: .byte 0, 0, 0, 0, 0, 0, 0, 0
  explosionYorigin: .byte 0, 0, 0, 0, 0, 0, 0, 0
  explosionScreenSnapshots: .fill 6*6*8, 0
  explosionColorSnapshots: .fill 6*6*8, 0
  COLOR_FADES: .byte 0, 0, 2, 4, $c, 3, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 4, $c, 3, 7, 1, 3, 3, 3, 3, 3, 3, 7, 1, 4, 4, 4, 4, $c, 3, 7, 1, 5, 5, 5, 5, 5, $f, 7, 1, 6, 6, 6, 4, $e, 3, 7, 1, 7, 7, 7, 7, 7, 7, 7, 1, 8, 8, 8, 8, 8, $a, $f, 1, 9, 9, 2, 4, $c, 3, 7, 1, $a, $a, $a, $a, $a, $a, $f, 1, $b, $b, 2, 4, $e, 3, 7, 1, $c, $c, $c, $c, $c, 3, $d, 1, $d, $d, $d, $d, $d, $d, $d, 1, $e, $e, $e, $e, $e, 3, 7, 1, $f, $f, $f, $f, $f, $f, 7, 1
.pc = $1000 "MEM_MUSIC"
// SID tune at an absolute address
MEM_MUSIC:
.const music = LoadSid("assets/music/Hedgehog-the-Hero.sid")
    .fill music.size, music.getData(i)

