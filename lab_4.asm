.model small
.stack 512
.data

    strerr db "Bad input$"
    i dw ?
    j dw ?
    mas dw 10000 dup (0)
   

    max db 20
    len db 0
    string db 200 dup (0)
;error string
    
.code
    main:
        mov ax,@data
        mov ds,ax

        mov ax, 1
        mov bx, 2
        mov dx, offset i
        call fill_array

        mov ax, i
        mov bx, j
        mov dx, offset mas
        call fill_array



        
        xor ax,ax
        mov cx, i ;для внешнего цикла чтобы переходить по строкам(кол-во раз)
        xor bx,bx
         

    for1:
        push cx
        xor di, di
        mov cx, j  ; для внутреннего чтобы переходить по всем столбцам одной строки
        mov dx, mas[bx][di] ; первый в регистр, где минимальный
       
    for2:
        cmp dx, mas[bx][di] ; сравн следующй с первым
        jge nextelement
        mov dx, mas[bx][di]
    nextelement:
        add di,2 ; на два байта чтоб на некст элемент строки перейти
        loop for2

        add ax,dx
        add bx,j ; чтобы перейти на новую строку
        add bx,j ; чтобы перейти на новую строку
        pop cx
        loop for1



    mov cx, j
    xor di,di  ; аналогично только идем по элемам столбца 
    for3:
        push cx
        xor bx,bx
        mov cx, i
        mov dx, mas[bx][di]
       
    for4:
        cmp dx, mas[bx][di]
        jge nextelement2
        mov dx, mas[bx][di]
    nextelement2:
        add bx, j
        add bx, j
        loop for4

        add ax,dx
        add di,2
        pop cx
        loop for3

    printnumber:
	    cmp ax, 0
	    jz printifzero
	    jnl printpositive
	    mov dl, '-'
	    push ax
	    mov ah, 02h
	    int 21h
	    pop ax
        not ax 
	    inc ax


    printpositive:
	    cmp ax, 0
	    jz zero
	    mov dx, 0
	    mov bx, 10
	    div bx    
	    add dl, 48
	    push dx
        call printpositive
	    pop dx
	    push ax
	    mov ah, 02h
	    int 21h
	    pop ax
        ret
           
    zero:
	    ret

    printifzero:
	    mov dl, 30h
	    mov ah, 02h
	    int 21h
	    ret
        
    exit:    
        mov ah, 04Ch
        mov al, 0
        int 21h

    error:
        mov ah, 09h
        mov dx, offset strerr
        int 21h
        jmp exit 


    checkstr:
        ; pushing registers
        push ax
        push si

        mov si, ax

    checksym:
        mov al, [si]
        inc si

        cmp al, 0dh
        je endcheck

        cmp al, 20h; al < ' '
        jl error

        cmp al, 39h; al > '9'
        ja error

        sub al, 21h;
        cmp ax, 03h; '!' <= al <= '/'
        jl error

        jmp checksym
    endcheck:
        ; popping registers
        pop si
        pop ax
        ret


    space_count:
        ; ax - string
        push si
        mov si, ax
        mov ax, 0
    check:
        mov al, [si]
        inc si
        cmp al, 0dh
        je end_sc
        cmp al, 20h; al != ' '
        jne notspace
        inc ah
    notspace:
        jmp check
    end_sc:
        mov al, ah
        mov ah, 0
        pop si
        ret


    fill_array:
        mov cx, ax
        push ax
    array_loop:
        call get_string
        push ax
        call space_count
        inc ax
        cmp bx, ax
        jne error
        pop ax
        push bx
        mov bx, dx
        call str_to_arr
        pop bx
        add dx, bx
        add dx, bx
        loop array_loop
        pop ax
        ret


    str_to_arr:
        ; ax - string
        ; bx - array

        ; pushing registers
        push ax
        push bx
        push si
        mov si, ax
    cycle:
        call atoi
        mov [bx], ax
    checkspaces:
        mov al, [si]
        inc si
        cmp al, 0dh  ; \n
        je end_sta
        cmp al, 20h; al != ' '
        jne checkspaces
        mov ax, si
        inc si
        add bx, 2
        jmp cycle
    end_sta:
        pop si
        pop bx
        pop ax
        ret

    atoi:
    ; pushing registers
        push bx
        push si
        push dx; uses in multiplication
        
        mov bx, 0
        mov si, ax
        mov ah, 0
    gpos:
        mov al, [si]
        inc si
        cmp al, 20h; space is also endn
        je endn
        cmp al, 0dh
        je endn
        sub al, 48 ; asci code
        push ax
        mov ax, 10 ; mul10
        mul bx
        mov bx, ax
        pop ax
        add bx, ax
        jmp gpos
    endn:
        mov ax, bx
        pop dx
        pop si
        pop bx
        ret


    get_string:
        push dx
        mov ah, 0Ah
        mov dx, offset max
        int 21h

        mov dl, 10
        mov ah, 02h
        int 21h
        mov dl, 13
        mov ah, 02h
        int 21h

        mov ax, offset string
        call checkstr
        pop dx
        ret
    end main

