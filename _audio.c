typedef void(*PROC_PTR)();
__export PROC_PTR musicInit = (PROC_PTR) MEM_MUSIC;
__export PROC_PTR musicPlay = (PROC_PTR) MEM_MUSIC+3;

// SID tune at an absolute address
__address($1000) char MEM_MUSIC[] = kickasm(resource "assets/music/Hedgehog-the-Hero.sid") {{
    .const music = LoadSid("assets/music/Hedgehog-the-Hero.sid")
    .fill music.size, music.getData(i)
}};


