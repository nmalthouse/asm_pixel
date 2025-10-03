%define max_snake_len 100
%define W 20

global my_func
global assemblyLoop
global assemblyInit

extern drawRect
extern getRand
extern keymask

; called on program start
assemblyInit:
    enter 0,0
    
    mov byte[direction], 0b10
    mov dword[snake_len], 0
    mov dword[sn_x], 3
    mov dword[sn_y], 3

    leave
    ret

; called every frame by driver program
; in rdi: width of window
; in rsi; height of window
assemblyLoop: 
    enter 0,0
    call update_direction
    call update_position
    call try_spawn_apple
    call draw_apples



    ;rdi rsi rdx, rcx r8 r9

    mov edi, dword[sn_x]
    mov esi, dword[sn_y]
    mov eax, W
    mul edi
    mov edi, eax

    mov eax, W
    mul esi
    mov esi, eax

    mov rdx, W
    mov rcx, W
    mov r8, 0xff00ff;
    call drawRect


    leave
    ret

try_spawn_apple:
    enter 8, 0
    mov rdi, 2
    call getRand
    cmp eax, 1 ; 5 percent chance 1/20
    jne SPAWN_APPLE_FAIL

    mov edi, W
    call getRand
    mov dword -4[rbp], eax

    mov edi, W
    call getRand
    mov dword -8[rbp], eax

    xor r8, r8
    mov eax, W
    mov r8d, dword -4[rbp]; calc the row
    mul r8d

    add r8d, dword -8[rbp]; add the column
    add r8, apples ;offset
    mov byte [r8], 1


    SPAWN_APPLE_FAIL:
    leave
    ret

draw_apples:
    enter 32,0
    mov dword -4[rbp], 0
    APPLE_LOOP_START:
        xor r8,r8
        mov r8d, dword -4[rbp]
        add r8, apples
        cmp byte [r8], 1
        jne DRAW_FIN
        ;; otherwise we draw it
        
        
        
        xor rdx ,rdx
        mov eax, dword -4[rbp]
        mov bx, W
        div bx ; edx contains mod, eax contains div
        
        mov r9d, edx ; mul clobbers edx
        mov r10d, eax

        
        mov eax, W
        mul r9d
        mov r9d, eax
        ;
        mov eax, W
        mul r10d
        mov r10d, eax
        
        ;mov r8d, W
        ;mul r8d
        ;mov esi, eax; ; store the y value
        ;
        ;mov rax, W
        ;mul edx
        ;mov edi, eax ; store the x value
        
        mov edi, r9d ; xpos
        mov rsi, r10; ypos

        mov rdx, W
        mov rcx, W  ; the width and height
        
        mov r8, 0x00ffff; color
        call drawRect

        
        DRAW_FIN:
        

        add dword -4[rbp], 1
        cmp dword -4[rbp], W * W
        jl APPLE_LOOP_START

    leave
    ret



; arg order is
;rdi rsi rdx, rcx r8 r9
draw_rand_rect:
    enter 8,0

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
    leave
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
    ; todo it underflows on negative

    mov eax, dword[sn_x]
    mov ebx, 20
    call MOD
    mov dword[sn_x], eax

    mov eax, dword[sn_y]
    mov ebx, 20
    call MOD
    mov dword[sn_y], eax

    ret

MOD: ;  rax % ebx
    xor rdx ,rdx
    div ebx 
    mov eax, edx
    ret


; clamp value in rax, between zero and rdi
CLAMP:
    cmp rax, rdi
    jge CLAMP_MAX
    cmp rax, 0
    jle CLAMP_MIN

    jmp CLAMP_END
    CLAMP_MAX:
        mov rax, rdi
        jmp CLAMP_END
    CLAMP_MIN:
        mov rax, 1
        jmp CLAMP_END
    CLAMP_END:

    ret

section .bss
snake: resb max_snake_len
sn_x: resb 4
sn_y: resb 4
direction: resb 1
snake_len: resb 4
board_size: resb 4
my_g_int: resb 4
apples: resb (W * W)
