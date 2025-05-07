global my_func
global assemblyLoop

extern drawRect

; called every frame by driver program
; in rdi: width of window
; in rsi; height of window
assemblyLoop: 

    mov rdi, 10 ; x
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
