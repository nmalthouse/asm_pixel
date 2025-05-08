%define max_snake_len 100

global my_func
global assemblyLoop
global assemblyInit

extern drawRect
extern getRand
extern keymask

; called on program start
assemblyInit:
    mov byte[direction], 0b10
    mov dword[snake_len], 0
    mov dword[sn_x], 20
    mov dword[sn_y], 20
    ret

; called every frame by driver program
; in rdi: width of window
; in rsi; height of window
assemblyLoop: 
    call update_direction
    call update_position
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

    ;call draw_rand_rect


    ;rdi rsi rdx, rcx r8 r9
    mov edi, dword[sn_x]
    mov esi, dword[sn_y]
    mov rdx, 20
    mov rcx, 20
    mov r8, 0xff00ff;
    call drawRect


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

update_direction:
    call keymask
    mov r8, rax
    and r8, 0b1 ; w
    cmp r8, 0
    mov r8, 0b1
    jne UD_set

    mov r8, rax
    and r8, 0b10 ; a
    cmp r8, 0
    mov r8, 0b10
    jne UD_set

    mov r8, rax
    and r8, 0b100 ; s
    cmp r8, 0
    mov r8, 0b100
    jne UD_set

    mov r8, rax
    and r8, 0b1000 ; d
    cmp r8, 0
    mov r8, 0b1000
    jne UD_set

    jmp UD_done
    UD_set:
        mov byte [direction], r8b
        
    UD_done:

    ret


; reads : direction
; writes: sn_x, sn_y
; direction:
;    1 +y
;   10 -x
;  100 -y
; 1000 +x
update_position:
    mov r8d, dword[sn_x]
    mov r9d, dword[sn_y]
    mov al, byte[direction]
    cmp rax, 1
    je up_negy
    cmp rax, 0b10
    je up_negx
    cmp rax, 0b100
    je up_posy
    cmp rax, 0b1000
    je up_posx

    jmp up_done
        up_posx:
            add r8d, 1
            jmp up_done
        up_negx:
            sub r8d, 1
            jmp up_done
        up_posy:
            add r9d, 1
            jmp up_done
        up_negy:
            sub r9d, 1
            jmp up_done

    up_done:
    mov dword[sn_x], r8d
    mov dword[sn_y], r9d
    ; clamp the x and y
    mov eax, dword[sn_x]
    cmp eax, 40
    jle UP_no_set0
    mov dword[sn_x], 0
    UP_no_set0: 

    mov eax, dword[sn_y]
    cmp eax, 40
    jle UP_no_set1
    mov dword[sn_y], 0
    UP_no_set1: 
    ret


section .bss
snake: resb max_snake_len
sn_x: resb 4
sn_y: resb 4
direction: resb 1
snake_len: resb 4
board_size: resb 4
my_g_int: resb 4

