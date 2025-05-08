%define max_snake_len 100

global my_func
global assemblyLoop
global assemblyInit
    


extern drawRect
extern getRand
extern keymask

; called on program start
assemblyInit:
    ret

; called every frame by driver program
; in rdi: width of window
; in rsi; height of window
assemblyLoop: 
    mov r8, rsi ; store height

    mov eax, dword [my_g_int]
    add eax, 10 ; add one to our global var
    mov dword [my_g_int], eax
    mov esi, eax ; use our global as the y value of rect


        cmp rax, r8
        jl wrap
        mov dword [my_g_int], 0
        wrap:
        

    call keymask
    and  rax, 0b1 ; is W down
    
    cmp rax, 0
    mov rdi, 10 ; x
    je set
    mov rdi, 100
set:

    ;mov rsi, 10 ; y
    mov rdx, 100 ; w 
    mov rcx, 300 ; h

    mov r8, 0x60ba34 ; a nice green color
    ;call drawRect

    call draw_rand_rect

    ret


; arg order is
;rdi rsi rdx, rcx r8 r9
draw_rand_rect:
    push rbp
    mov rbp, rsp
    sub rsp, 8; two u32, for pos


    mov rdi, 400
    call getRand
    mov dword -4[rbp], eax
    mov rdi, 400
    call getRand
    mov dword -8[rbp], eax 
    ; we have two randints on stack, < 100

    mov edi, dword -4[rbp]
    mov esi, dword -8[rbp]
    mov rdx, 20
    mov rcx, 20
    mov r8, 0xff00ff
    call drawRect
    
done:

    mov rsp, rbp
    pop rbp
    ret

my_func:
    mov rax, rdi
    add rax, rsi
    ; result in rax, no need to move
    ret


section .bss
snake: resb max_snake_len
snake_len: resb 8
board_size: resb 8
my_g_int: resb 4

