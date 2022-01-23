.model tiny
.386
.stack 100h

data segment use16
    text_first db 'Enter a letter: $'
    text_second db 10, 'The interrupt handler has been changed.', 10, 'Enter a letter: $'
    buffer_seg dw 0
    buffer_set_off dw 0
    flag_active dw 0
    global_param db 0
data ends

    
code segment use16
    assume cs: code, ds: data
resident:
    org 100h 
    jmp install

custom_input proc
    mov cx, 37h
    mov si, word ptr cs:[old_interupt]
    mov di, word ptr cs:[old_interupt + 2]
    push si di ds cx bx ax
    pushf
    cmp ah, 02h
    jne skip_my_interrupt

    mov cl, global_param
    mov cs:[param], cl

    cmp dl, 97
    jb skip_my_interrupt
    cmp dl, 122
    ja skip_my_interrupt
    add dl, cs:[param] 
    cmp dl, 123
    jle skip_my_interrupt
    sub dl, 26
skip_my_interrupt:
    popf
    pop ax bx cx ds di si
    jmp cs:[old_interupt]
    ret
    old_interupt dd ? 
    param db 0
custom_input endp

install:
main proc
initialize_ds:
    mov ax, data
    mov ds, ax

    mov si,80h
    mov ah,es:[si]
    xor al,al
    cmp ah,0
    jne L1
          
    mov al, 13
    mov global_param, al
    jmp L2

L1: 
    mov si, 82h
    mov al, es:[si]
    sub al, 48
    mov global_param, al
    jmp L2

L2:
    mov dx, offset text_first
    call cout_string

    mov ah, 01h
    int 21h

    mov dl, al
    call cout_char

    cmp cx, 37h
    je return_handler
    push ds
    mov ax, code
    mov ds, ax
    mov ah, 35h 
    mov al, 21h
    int 21h
    mov word ptr old_interupt, bx 
    mov word ptr old_interupt + 2, es 
    mov ah, 25h 
    mov al, 21h
    mov dx, offset custom_input 
    int 21h 
    pop ds
    jmp proces_program

return_handler:
    xor cx, cx
    push ds
    mov ax, di
    mov ds, ax
    mov ah, 25h
    mov al, 21h
    mov dx, si
    int 21h
    pop ds

            
    mov dx, offset text_second
    call cout_string


    mov ah, 01h
    int 21h

    mov dl, al
    call cout_char

return_from_main:
    mov ah, 04ch
    int 21h

proces_program:  
    mov dx, offset text_second
    call cout_string

    xor dl, dl
    xor dx, dx

    mov ah, 01h
    int 21h
            
    mov dl, al
    call cout_char

    mov ax, byte [flag_active]
    mov ax, word ptr[buffer_seg]
    mov ax, word ptr[buffer_set_off]

Close:
    mov ax, 3100h
    mov dx, (Resident - install + 10Fh) / 16
    int 27h 
main endp

cout_char proc
    mov ah, 02h
    int 21h
    ret
cout_char endp
    
cout_string proc 
    mov ah, 09h
    int 21h
    ret
cout_string endp 
code ends
end main