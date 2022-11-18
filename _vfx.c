
byte explosionIndexes[] = { 0,0,0,0,0,0,0,0 };
byte explosionXorigin[] = { 0,0,0,0,0,0,0,0 };
byte explosionYorigin[] = { 0,0,0,0,0,0,0,0 };
byte explosionScreenSnapshots[6 * 6 * 8];
byte explosionColorSnapshots[6 * 6 * 8];

void initExplosion(byte xpos, byte ypos) {

    signed char i = 1;
    do {
        i--;
    } while (explosionIndexes[i] && i>=0);

    if (i < 0) {
        // no place for explosion
        return;
    }

    explosionIndexes[i] = 8;
    explosionXorigin[i] = xpos;
    explosionYorigin[i] = ypos;

    byte j = 0;
    for (byte y = 0; y < 6; y++) {
        for (byte x = 0; x < 6; x++) {
            explosionScreenSnapshots[i * 36 + j] = MEM_SCREENRAM[y * 0x28 + x];
            explosionColorSnapshots[i * 36 + j] = MEM_COLORRAM[y * 0x28 + x];
            j++;
        }
    }
}
    

void handleOffIrqVfx() {
    animateExplosions();
}

void animateExplosions() {
    for (byte i = 0; i < 8; i++) {
        if (!explosionIndexes[i]) {
            continue;
        }

    byte j = 0;
    for (byte y = 0; y < 6; y++) {
        for (byte x = 0; x < 6; x++) {

            byte indexColor = ((explosionColorSnapshots[i * 36 + j] & %00001111) * 8) + explosionIndexes[i];
            byte indexLO = ((explosionScreenSnapshots[i * 36 + j] & %00001111) * 8) + explosionIndexes[i];
            byte indexHI = ((((explosionScreenSnapshots[i * 36 + j] & %11110000) >> 4)) * 8) + explosionIndexes[i];

            MEM_SCREENRAM[y * 0x28 + x] = COLOR_FADES[indexLO] | (COLOR_FADES[indexHI] << 4);
            MEM_COLORRAM[y * 0x28 + x] = COLOR_FADES[indexColor];
            j++;
        }
    }
        


        explosionIndexes[i]--;
    }
}

char COLOR_FADES[] = {
    $00,$00,$02,$04,$0c,$03,$07,$01,
    $01,$01,$01,$01,$01,$01,$01,$01,
    $02,$02,$02,$04,$0c,$03,$07,$01,
    $03,$03,$03,$03,$03,$03,$07,$01,
    $04,$04,$04,$04,$0c,$03,$07,$01,
    $05,$05,$05,$05,$05,$0f,$07,$01,
    $06,$06,$06,$04,$0e,$03,$07,$01,
    $07,$07,$07,$07,$07,$07,$07,$01,
    $08,$08,$08,$08,$08,$0a,$0f,$01,
    $09,$09,$02,$04,$0c,$03,$07,$01,
    $0a,$0a,$0a,$0a,$0a,$0a,$0f,$01,
    $0b,$0b,$02,$04,$0e,$03,$07,$01,
    $0c,$0c,$0c,$0c,$0c,$03,$0d,$01,
    $0d,$0d,$0d,$0d,$0d,$0d,$0d,$01,
    $0e,$0e,$0e,$0e,$0e,$03,$07,$01,
    $0f,$0f,$0f,$0f,$0f,$0f,$07,$01
};