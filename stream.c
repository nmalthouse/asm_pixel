/* streaming-textures.c ... */

/*
 * This example creates an SDL window and renderer, and then draws a streaming
 * texture to it every frame.
 *
 * This code is public domain. Feel free to use it for any purpose!
 */

#define SDL_MAIN_USE_CALLBACKS 1  /* use the callbacks instead of main() */
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "stdlib.h"
#include "stdio.h"
/* We will use this renderer to draw into this window every frame. */
static SDL_Window *window = NULL;
static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

#define TEXTURE_SIZE 400

#define WINDOW_WIDTH 400
#define WINDOW_HEIGHT 400

//#define DEBUG_PRINT 

//it is so awfull that this works.
//I can see why people hate the preprocessor
#ifdef DEBUG_PRINT
#define dprint printf
#else
#define dprint //
#endif

int getRand(int max){
    return rand() % max;
}

SDL_Surface *surface = NULL;
void drawRect(int x, int y, int w, int h, int color){
    dprint("draw rect %d %d %d %d\n", x,y,w,h);
    SDL_Rect r;
    r.x = x;
    r.y = y;
    r.w = w;
    r.h = h;
    SDL_FillSurfaceRect(surface, &r, SDL_MapRGB(SDL_GetPixelFormatDetails(surface->format), NULL, 
                color >> 16,  // red
                color << 16 >> (16 + 8),
                color << (24) >> (24))); 
}

int KEY_MASK = 0;
#define KEY_W 0b1;
#define KEY_A 0b10;
#define KEY_S 0b100;
#define KEY_D 0b1000;
//Return a bitmask representing wasd keystate
int keymask(){
    return KEY_MASK;
}

//END THE api

extern void assemblyLoop(int,int);
extern void assemblyInit();

/* This function runs once at startup. */
SDL_AppResult SDL_AppInit(void **appstate, int argc, char *argv[]) {
    srand(0);

    assemblyInit();

    SDL_SetAppMetadata("Example Renderer Streaming Textures", "1.0", "com.example.renderer-streaming-textures");

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    if (!SDL_CreateWindowAndRenderer("Asm Game", WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer)) {
        SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, TEXTURE_SIZE, TEXTURE_SIZE);
    if (!texture) {
        SDL_Log("Couldn't create streaming texture: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }
    SDL_SetHint(SDL_HINT_RENDER_VSYNC, "1");


    return SDL_APP_CONTINUE;  /* carry on with the program! */
}

/* This function runs when a new event (mouse input, keypresses, etc) occurs. */
SDL_AppResult SDL_AppEvent(void *appstate, SDL_Event *event) {
    if (event->type == SDL_EVENT_QUIT) {
        return SDL_APP_SUCCESS;  /* end the program, reporting success to the OS. */
    }
    switch(event->type){
        case SDL_EVENT_KEY_DOWN:
            {
                int sc = SDL_GetScancodeFromKey(event->key.key, NULL);
                switch(sc){
                    case SDL_SCANCODE_W:
                        KEY_MASK |= KEY_W;
                        break;
                    case SDL_SCANCODE_A:
                        KEY_MASK |= KEY_A;
                        break;
                    case SDL_SCANCODE_S:
                        KEY_MASK |= KEY_S;
                        break;
                    case SDL_SCANCODE_D:
                        KEY_MASK |= KEY_D;
                        break;
                }
                break;
            }
        case SDL_EVENT_KEY_UP:
            {
                int sc = SDL_GetScancodeFromKey(event->key.key, NULL);
                switch(sc){
                    case SDL_SCANCODE_W:
                        KEY_MASK &= ~KEY_W;
                        break;
                    case SDL_SCANCODE_A:
                        KEY_MASK &= ~KEY_A;
                        break;
                    case SDL_SCANCODE_S:
                        KEY_MASK &= ~KEY_S;
                        break;
                    case SDL_SCANCODE_D:
                        KEY_MASK &= ~KEY_D;
                        break;
                }
                break;
            }
    }
    return SDL_APP_CONTINUE;  /* carry on with the program! */
}



/* This function runs once per frame, and is the heart of the program. */
SDL_AppResult SDL_AppIterate(void *appstate) {
    SDL_FRect dst_rect;
    const Uint64 now = SDL_GetTicks();

    /* we'll have some color move around over a few seconds. */
    const float direction = ((now % 2000) >= 1000) ? 1.0f : -1.0f;
    const float scale = ((float) (((int) (now % 1000)) - 500) / 500.0f) * direction;

    if (SDL_LockTextureToSurface(texture, NULL, &surface)) {
        SDL_Rect r;
        SDL_FillSurfaceRect(surface, NULL, SDL_MapRGB(SDL_GetPixelFormatDetails(surface->format), NULL, 0, 0, 0));  /* make the whole surface black */
        dprint("begin\n");
        assemblyLoop(TEXTURE_SIZE, TEXTURE_SIZE);
        dprint("\n\n");

        SDL_UnlockTexture(texture);  /* upload the changes (and frees the temporary surface)! */
    }
    SDL_RenderClear(renderer);  /* start with a blank canvas. */
    dst_rect.x = ((float) (WINDOW_WIDTH - TEXTURE_SIZE)) / 2.0f;
    dst_rect.y = ((float) (WINDOW_HEIGHT - TEXTURE_SIZE)) / 2.0f;
    dst_rect.w = dst_rect.h = (float) TEXTURE_SIZE;
    SDL_RenderTexture(renderer, texture, NULL, &dst_rect);

    SDL_RenderPresent(renderer);  /* put it all on the screen! */

    SDL_Delay(150);

    return SDL_APP_CONTINUE;  /* carry on with the program! */
}

void SDL_AppQuit(void *appstate, SDL_AppResult result) {
    SDL_DestroyTexture(texture);
}

