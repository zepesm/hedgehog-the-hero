#import "libs/byteboozer/byteboozer.h"

__export char * const MEM_BITMAP = (char *)0x2000;
__export char * const MEM_SCREENRAM = (char *)0x0400;
__export char * const MEM_COLORRAM = (char *)0xd800;

__export const byte ASSET_BITMAP_WELL = 1;
__export const byte ASSET_BITMAP_HEDGEHOG = 2;

void initAsset(byte asset) {

    if (asset == ASSET_BITMAP_WELL) {
            byteboozer_decrunch(IMG_CRUNCHED_WELL_BITMAP);
            byteboozer_decrunch(IMG_CRUNCHED_WELL_SCREEN);
            byteboozer_decrunch(IMG_CRUNCHED_WELL_COLOR);
    } else if (asset == ASSET_BITMAP_HEDGEHOG) {
            byteboozer_decrunch(IMG_CRUNCHED_HEDGEHOG_BITMAP);
            byteboozer_decrunch(IMG_CRUNCHED_HEDGEHOG_SCREEN);
            byteboozer_decrunch(IMG_CRUNCHED_HEDGEHOG_COLOR);
    }
}

// --- below will be placed under Data segment

// WELL packed
 __export char IMG_CRUNCHED_WELL_BITMAP[] = kickasm(uses MEM_BITMAP, resource "assets/gfx/well.kla") {{
    .const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328"
    .var pic = LoadBinary("assets/gfx/well.kla", KOALA_TEMPLATE)        
    .modify B2() {
	    .pc = MEM_BITMAP
        .fill pic.getBitmapSize(), pic.getBitmap(i)
    }
 }};

 __export char IMG_CRUNCHED_WELL_SCREEN[] = kickasm(uses MEM_SCREENRAM) {{
    .modify B2() {
	    .pc = MEM_SCREENRAM
        .fill pic.getScreenRamSize(), pic.getScreenRam(i)
    }
 }};

  __export char IMG_CRUNCHED_WELL_COLOR[] = kickasm(uses MEM_COLORRAM) {{
    .modify B2() {
	    .pc = MEM_COLORRAM
        .fill pic.getColorRamSize(), pic.getColorRam(i)
    }
 }};

// HEDGEHOG packed
  __export char IMG_CRUNCHED_HEDGEHOG_BITMAP[] = kickasm(uses MEM_BITMAP, resource "assets/gfx/hedgehog.kla") {{
    .var pic2 = LoadBinary("assets/gfx/hedgehog.kla", KOALA_TEMPLATE)        
    .modify B2() {
	    .pc = MEM_BITMAP
        .fill pic2.getBitmapSize(), pic2.getBitmap(i)
    }
 }};

 __export char IMG_CRUNCHED_HEDGEHOG_SCREEN[] = kickasm(uses MEM_SCREENRAM) {{
    .modify B2() {
	    .pc = MEM_SCREENRAM
        .fill pic2.getScreenRamSize(), pic2.getScreenRam(i)
    }
 }};

  __export char IMG_CRUNCHED_HEDGEHOG_COLOR[] = kickasm(uses MEM_COLORRAM) {{
    .modify B2() {
	    .pc = MEM_COLORRAM
        .fill pic2.getColorRamSize(), pic2.getColorRam(i)
    }
 }};

