global my_func
global assemblyLoop

extern drawRect
extern keymask

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
    call drawRect

    ret

my_func:
    mov rax, rdi
    add rax, rsi
    ; result in rax, no need to move
    ret


section .bss
my_g_int: resb 4

