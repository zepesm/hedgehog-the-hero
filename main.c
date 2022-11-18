#pragma link("main.ld")
#include <c64.h>
#include <c64-keyboard.h>

#include "_assets.c"
#include "_audio.c"
#include "_vfx.c"

void main() {

//        (*musicInit)();
//        (*musicPlay)();

    VICII->BORDER_COLOR = BLACK;
    VICII->BG_COLOR = BLACK;
    VICII->BG_COLOR2 = BLACK;

    *D011 = 0;

    initAsset(ASSET_BITMAP_WELL);

    *D011 = VICII_BMM|VICII_DEN|VICII_RSEL|3;
    *D016 = VICII_MCM;
    vicSelectGfxBank(0);
    *D018 = toD018(MEM_SCREENRAM, MEM_BITMAP);

    do {
        do {} while (VICII->RASTER != $fd);

        handlePlayer();
        handleOffIrqVfx();
    } while (true);
}


void handlePlayer() {
    if (keyboard_key_pressed(KEY_F1) !=0) {
        initExplosion(10, 10);
    }
}






   