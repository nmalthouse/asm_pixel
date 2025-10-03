#include <stdio.h>
//these are defined in stream.c, there should really be a header file for them instead
void drawRect(int, int, int, int ,int);
int keymask();

#define KEY_W 0b1
#define KEY_A 0b10
#define KEY_S 0b100
#define KEY_D 0b1000


void assemblyInit(){
    printf("Init was called!\n");
}

int posx = 0;
int posy = 0;

void assemblyLoop(int w, int h){
    const int key_mask = keymask();

    if(key_mask & KEY_W){
        posy -= 20;
    }

    if(key_mask & KEY_S){
        posy += 20;
    }

    drawRect(posx, posy, 20,20, 0xffffffff);
}
