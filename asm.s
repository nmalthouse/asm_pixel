global my_func
global assemblyLoop

extern drawRect
extern keymask

; called every frame by driver program
; in rdi: width of window
; in rsi; height of window
assemblyLoop: 
    call keymask
    and  rax, 0b1 ; is W down
    
    cmp rax, 0
    mov rdi, 10 ; x
    je set
    mov rdi, 100
set:

    mov rsi, 10 ; y
    mov rdx, 100 ; w 
    mov rcx, 300 ; h

    call drawRect

    ret

my_func:
    mov rax, rdi
    add rax, rsi
    ; result in rax, no need to move
    ret
