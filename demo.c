#include <stdio.h>
//these are defined in stream.c, there should really be a header file for them instead
void drawRect(int, int, int, int ,int);
int keymask();

#define KEY_W 0b1
#define KEY_A 0b10
#define KEY_S 0b100
#define KEY_D 0b1000


//This is called when the program is started
void assemblyInit(){
    printf("Init was called!\n");
}

int posx = 0;
int posy = 0;

//This function is called 60 times every second
//w and h hold the width and height of the window in pixels
void assemblyLoop(int w, int h){
    const int key_mask = keymask();

    if(key_mask & KEY_W){
        posy -= 4;
    }

    if(key_mask & KEY_S){
        posy += 4;
    }

    if(key_mask & KEY_A)
        posx -= 4;
    
    if(key_mask & KEY_D)
        posx += 4;

    //Draw our red 20x20 rectangle at posx and posy
    unsigned int red_color = 0xff0000; //rgb
    drawRect(posx, posy, 20,20, red_color);

}
