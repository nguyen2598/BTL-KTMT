
PUTC    MACRO   char
        PUSH    AX; day gia tri thanh ax vao stack
        MOV     AL, char; chuyen bien char vao al
        MOV     AH, 0Eh; gan ah = 0eh
        INT     10h     ; 
        POP     AX     ; lay ra gia tri cua ax
ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





org 100h

jmp start

msg1 db 0Dh,0Ah, 0Dh,0Ah, 'Nhap so dau tien: $'
msg2 db "Nhap phep tinh:    +  -  *  /  %  ^ ! : $"
msg3 db "Nhap so thu hai: $"
msg4 db  0dh,0ah , 'Ket qua cua phep tinh la : $' 
msg5 db  0dh,0ah ,'Nhap phim bat ki de ket thuc chuong trinh... ', 0Dh,0Ah, '$'
err1 db  "Nhap du lieu loi!", 0Dh,0Ah , '$'
smth db  " va so du la $"
mgs6 db  0dh,0ah , 'Nhan phim 'y' de hien thi ket qua so thap phan phep chia so dau tien cho so thu hai $'
mgs7 db  0dh,0ah , 'Ket qua la: $'
     ; cac nhan dan (thong bao) khi chay truong trinh

opr db '?'

; first and second number:
num1 dw ?   ; khai bao bien
num2 dw ?   ; khai bao bien
mod dw ?     

start:    ; bat dau truong trinh

lea dx, msg1    ; chuyen mgs1   vao dx
mov ah, 09h    ; output string at ds:dx
int 21h        ; ham ngat 9


; get the multi-digit signed number
; from the keyboard, and store
; the result in cx register:

call scan_num   ; goi ham nhap so

; store first number:
mov num1, cx       ; gan gtri cx vao   num1



; new line:
putc 0Dh     ; xuong dong va lui dau dong
putc 0Ah




lea dx, msg2    ; in ra thong bao msg2
mov ah, 09h     ; output string at ds:dx
int 21h  


; get operator:
mov ah, 1   ; single char input to AL.
int 21h           ; ham ngat 1: nhap 1 ky tu tu ban phim
mov opr, al        ; chuyen ki tu vua nhap vao opr



; new line:
putc 0Dh        ; xuong dong va lui dau dong
putc 0Ah


cmp opr, 'q'      ; q - exit in the middle.         ; so sanh opr voi ki tu q
je exit           ; neu opr == q nhay den ham exit
cmp opr, '%'
je mo_rong
cmp opr, '^'
je mo_rong
cmp opr, '!'
je giai_thua
cmp opr, '*'      ;so sanh opr voi ki tu *
jb wrong_opr      ;  nhay toi ham wrong_opr neu opr < *
cmp opr, '/'      ; so sanh opr voi ki tu /
ja wrong_opr      ;  nhay toi ham wrong_opr neu opr > /





mo_rong:
lea dx, msg3
mov ah, 09h       ; ham ngat 9: in ra chuoi thong bao msg3
int 21h  




call scan_num      ; goi ham nhap
mov num2, cx        ; luu cx vao num2



lea dx, msg4
mov ah, 09h      ; output string at ds:dx
int 21h          ; ham ngat 9 in ra chuoi msg4






; calculate:


cmp opr, '+'     ; so sanh opr voi +
je do_plus       ; neu opr == + nhay den ham do_plus

cmp opr, '-'     ; so sanh opr voi -
je do_minus      ; neu opr == - nhay den ham do_minus

cmp opr, '*'     ; so sanh opr voi *
je do_mult       ; neu opr == * nhay den ham do_mult

cmp opr, '/'     ; so sanh opr voi /
je do_div        ; neu opr == / nhay den ham do_div

cmp opr, '%'
je do_mod

cmp opr, '^'
je luy_thua


; none of the above....
wrong_opr:
lea dx, err1    ; thong bao sai toan tu
mov ah, 09h     ; output string at ds:dx
int 21h  


exit:
; output of a string at ds:dx
lea dx, msg5    ; ham ngat 9 in ra chuoi thong bao msg5
mov ah, 09h
int 21h  


; wait for any key...  
;INT 16h / AH = 00h - nhan to hop tu ban phim
;tro ve:
;AH = mã quét BIOS.
;AL = ký tu ASCII.
;(neu co hien tuong tu ban phim, no se bi xoa khoi bo dem bàn phim).
mov ah, 0
int 16h


ret  ; return back to os.






giai_thua:    ; ham tinh giai thua
mov ax, 1
mov cx, 1
tinh_giai_thua:
imul cx
inc cx
cmp cx, num1
jna tinh_giai_thua
call print_num
jmp exit

;------------------------------





luy_thua:     ; ham tinh luy thua
mov cx, num2
mov ax, 1
tinh_luy_thua:
imul num1
loop tinh_luy_thua
call print_num
jmp exit

;------------------------------





do_mod:       ; ham mod chia du
mov dx, 0     ; gan dx = 0;
mov ax, num1  ; gan ax = num1
idiv num2  ; ax = (dx ax) / num2.
mov mod, dx    
call print_num    ; print ax value.
lea dx, smth   ; chuyen gia tri smth vao dx 
mov ah, 09h    ; output string at ds:dx
int 21h        ; ham ngat 9 thong bao smth
mov ax, mod
call print_num
lea dx, mgs6   ; chuyen gia tri smth vao dx 
mov ah, 09h    ; output string at ds:dx
int 21h
mov ah, 1
int 21h
cmp al, 'y'
je so_thap_phan
jmp exit

;------------------------------





so_thap_phan: ; tinh phep chia ra so thap phan
lea dx, mgs7   ; chuyen gia tri smth vao dx 
mov ah, 09h    ; output string at ds:dx
int 21h        ; ham ngat 9 thong bao smth
mov dx, 0     ; gan dx = 0;
mov ax, num1  ; gan ax = num1
idiv num2  ; ax = (dx ax) / num2.   
mov mod, dx    
call print_num    ; print ax value.
PUTC '.'
mov cx, 5
thap_phan:
mov ax, mod
mov bx, 10
imul bx
idiv num2
call print_num
cmp dx, 0
je exit

loop thap_phan
jmp exit

;------------------------------





do_plus:  ; ham cong
mov ax, num1   ; chuyen num1 vao thanh gi ax;
add ax, num2   ; cong gia tri ax voi num2 va luu vao ax
call print_num    ; print ax value.
jmp exit  ; nhay den ham thoat

;------------------------------





do_minus:     ; ham tru
mov ax, num1  ; chuyen num1 vao thanh gi ax
sub ax, num2  ; tru ax cho num2 va luu vao ax
call print_num    ; print ax value.
jmp exit      ; nhay den ham thoat


;------------------------------





do_mult:       ; ham nhan
mov ax, num1   ; chuyen num1 vao ax
imul num2 ; (dx ax) = ax * num2. 
call print_num    ; print ax value.
jmp exit    ; nhay den ham thoat

;------------------------------





do_div:     ; ham chia
mov dx, 0     ; gan dx = 0;
mov ax, num1  ; gan ax = num1
idiv num2  ; ax = (dx ax) / num2.
call print_num    ; print ax value.
jmp exit     ; nhay toi ham thoat


;------------------------------




                               
SCAN_NUM        PROC    NEAR      ; nhap du toan hang tu ban phim
        PUSH    DX         ; day du lieu dx vao stack;
        PUSH    AX       ; day du lieu ax vao stack
        PUSH    SI       ; day du lieu si vao stack;
        
        MOV     CX, 0    ; gan cx = 0;

        ; reset flag:
        MOV     CS:make_minus, 0

;------------------------------
    
next_digit: ; ham nhap ki tu tiep theo

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h       ; ham nhap to hop tu ban phim
        INT     16h
        ; and print it:
        MOV     AH, 0Eh  ; dau ra teletype: chuc nang hien thi mot ki tu tren man hinh
                          ; di chuyen con tro va cuon man hinh khi can thiet.
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'     ; so du lieu tai al voi ki tu -;
        JE      set_minus    ; neu == nhay den ham set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr    ; neu du lieu al != enter nhay den ham not_cr
        JMP     stop_input ; nhay den stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked        ; neu khong bang nhay den backspcace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX                  ; chuyen ax vao cx
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit              ; nhay den next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'           ; so sanh al voi ki tu 0
        JAE     ok_AE_0            ;  nhay den ok_AE_0 neu al >= '0'
        JMP     remove_not_digit   ; nhay den ham remove_not_digit
ok_AE_0:        
        CMP     AL, '9'      ; so sanh al voi '9'
        JBE     ok_digit     ;  nhay den ok_digit neu al <= '9'
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:  


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX       ; day ax vao stack
        MOV     AX, CX   ; chuyen du lieu cx vao ax
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX     ; gan cx = ax
        POP     AX       ; lay ra du lieu 

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0      ; so sanh gtri tai dx voi 0
        JNE     too_big    ; neu khac 0 nhay toi too_big

        ; convert from ASCII code:
        SUB     AL, 30h    ; tru al cho 30h va luu vao al 
                           ; (chuyen al tu ki tu sang gia tri)
        ; add AL to CX:
        MOV     AH, 0       ; gan ah = 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX      ; cong gia tri tai cx voi gia tri tai ax va luu vao cx
        JC      too_big2    ; jump if the number is too big. (neu gia tri tai cx vuot qua 256 thi nhay)

        JMP     next_digit  ; nhay toi next_digit

set_minus:
        MOV     CS:make_minus, 1  ; dia chi o [cs:make_minus] = 1
        JMP     next_digit  ; nhay toi next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX  ; gan ax = cx
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX  ; gan cx = ax
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0     ; so sanh [cs:make_minus] voi 0
        JE      not_minus         ; neu bang thi nhay toi not_minus
        NEG     CX              ; lay bu 2 cua cx
not_minus:

        POP     SI    ; lay ra gia tri tai si
        POP     AX    ; lay ra gia tri tai ax
        POP     DX    ; lay ra gia tri tai dx
        RET           ; return
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP  ; ket thuc ham nhap

;------------------------------





PRINT_NUM       PROC    NEAR       ; ham in ra so
        PUSH    DX    ;day gia tri tai dx vao stack
        PUSH    AX    ; day gia tri tai ax vao stack

        CMP     AX, 0   ; so ax voi 0
        JNZ     not_zero  ; neu ax <= 0 thi nhay toi not_zero

        PUTC    '0'
        JMP     printed  ; nhay toi ham printed

not_zero:
        CMP     AX, 0    ; so sanh gia tri cua ax voi 0
        JNS     positive  ; neu co sf = 0 thi nhay toi ham positive
        NEG     AX    ; lay bu 2 cua ax

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS     ; goi ham
printed:
        POP     AX      ; lay ra gia tri ax
        POP     DX      ; lay ra gia tri dx
        RET             ; return
PRINT_NUM       ENDP    ; ket thuc ham in so


PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX       ; day ax vao stack
        PUSH    BX       ;     bx
        PUSH    CX       ;     cx
        PUSH    DX       ;     dx

        ; flag to prevent printing zeros before number:
        MOV     CX, 1    ; gan cx = 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider. gan bx = 10000

        ; AX is zero?
        CMP     AX, 0       ; so sanh ax voi 0
        JZ      print_zero  ; nhay toi print_zero neu ax = 0

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0         ; so sanh bx voi 0
        JZ      end_print    ; nhay toi ham end_print neu bx == 0

        ; avoid printing zeros before number:
        CMP     CX, 0     ; so sanh cx voi 0
        JE      calc      ; neu == nhay den calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX  ; so sanh ax va bx
        JB      skip    ; neu ax < bx nhay toi skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0   ; gan dx = 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ADD     AL, 30h    ;doi tu so sang ki tu
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX      ; day ax vao stack
        MOV     DX, 0   ; gan dx = 0
        MOV     AX, BX  ; gan ax = bx
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX  ; gan bx = ax
        POP     AX      ; lay ra gia tri ax

        JMP     begin_print ; nhay toi begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX       ; lay ra gia tri dx
        POP     CX       ;                cx
        POP     BX       ;                bx
        POP     AX       ;                ax
        RET              ; return
PRINT_NUM_UNS   ENDP     



ten             DW      10      










