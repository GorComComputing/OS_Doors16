%TITLE          "Загрузчик DOORS"
                IDEAL
                MODEL   tiny
                DATASEG
KernelSeg       EQU 01000h

color           DB 01Fh
string          DB "Welcome to DOORS v.01",0
loading         DB "System now loading... please wait...",0

BytesPerRowa=80*2
rowa=0
LABEL   ScRow Word
REPT    25
DW      (rowa*BytesPerRowa)
rowa=rowa+1
ENDM

QuitFLG         DB 0
mainx           DB 0
mainy           DB 5
space           DB 20h,0
windowwx        DB 4Ah
windowx         DB 3
windowy         DB 2
windowhx        DB 15h
entr            DB "$ ",0
command         DB 128 DUP (?)             ; Командная строка

                CODESEG
                ORG     100h    ; Данные из boot сектора грузятся по адрессу
Start:          jmp     Start1  ; 0000:7C00, следовательно мы должны писать
                ORG     07C00h  ; под этот адрес.
Start1:         ;jmp     Begin


Begin:          
                ; Вывод строки
                lea     si,[String]
                mov     dx,031Ch
                call    print
                ; Вывод строки
                lea     si,[loading]
                mov     dx,0503h
                call    print

opros:          lea     si,[entr]
                call    write
opr1:           call    input
                lea     di,[command]
                ;call    UpperString
                mov     al,[command]         ;┐
                or      al,al                ;│ Если строка пустая
                je      opr1                 ;┘
                ;call    doCmd
                mov     al,[QuitFLG]
                or      al,al
                je      opros
				
				
                ret

; Вывод строки ds:di #########################################################
PROC            print
                mov   ax,0B800h
                mov   es,ax
                call  SetVidAddr
print1:         mov   ah,[Color]
                mov   al,[ds:si]
                or    al,al
                je    prnend
                mov   [es:di],ax
                inc   di
                inc   di
                inc   si
                jmp   print1
prnend:         ret
ENDP            print


; Ввод строки с эхом #########################################################
PROC            input
                mov     ax,cs              ;┐
                mov     es,ax              ;│
                lea     di,[command]       ;│ Обнулим командную строку
                mov     cx,128             ;│
                xor     ax,ax              ;│
                rep     stosb              ;┘

                lea     di,[command]
                mov     bh,[cs:mainy]
                mov     bl,[cs:mainx]
                xor     cx,cx
inp1:           push    cx
                xor     ax,ax
                int     16h
                pop     cx
                cmp     al,13              ; Enter
                je      ipEnter
                cmp     al,8               ; BackSpace
                je      ipBackSpace
                or      al,al
                je      inp1
                mov     [cs:di],al
                inc     di
                inc     cx
                cmp     cx,126
                jne     inp2
                dec     di
                dec     cx
inp2:           push    di
                mov     [Byte Ptr cs:di],0
                mov     [cs:mainy],bh
                mov     [cs:mainx],bl
                lea     si,[cs:command]
                push    cx
                call    write
                pop     cx
                pop     di
                jmp     inp1
ipEnter:        ret
ipBackSpace:    push    si
                lea     si,[command]
                cmp     si,di
                pop     si
                je      inp1
                dec     di
                push    di bx
                mov     [Byte Ptr cs:di],0
                mov     [cs:mainy],bh
                mov     [cs:mainx],bl
                lea     si,[cs:command]
                call    write
                lea     si,[cs:space]
                call    write
                mov     [cs:mainy],bh
                mov     [cs:mainx],bl
                lea     si,[cs:command]
                call    write
                pop     bx di
                dec     cx
                jmp     inp1
ENDP            input


; Вывод строки с общими координатами #########################################
PROC            write
                push    ds es
                mov     ax,0B800h
                mov     es,ax
                call    GetCurentVideoAddr
                mov     dl,[mainx]
                mov     dh,[mainy]
write1:         mov     ah,[Color]
                mov     al,[ds:si]
                or      al,al
                je      writeend
                mov     [es:di],ax
                inc     di
                inc     di
                inc     si
                inc     dl
                cmp     dl,[windowwx]
                je      wxcarry
                jmp     write1
writeend:       mov     [mainx],dl
                mov     [mainy],dh
                add     dh,[windowy]
                add     dl,[windowx]
                push    bx
                xor     bx,bx
                mov     ax,0200h
                int     10h
                pop     bx
                pop     es ds
                ret
                ; Перенос строки
wxcarry:        xor     dl,dl
                inc     dh
                push    dx
                call    WindowSetVidAddr
                pop     dx
                cmp     dh,[windowhx]
                jne     write1
                dec     dh
                push    dx
                push    bx
                mov     ch,[windowy]             ;┐
                mov     cl,[windowx]             ;│
                dec     cl                       ;│
                mov     dh,[windowHx]            ;│
                inc     dh                       ;│
                mov     dl,[windowWx]            ;│ Сдвиг окна вверх
                inc     dl                       ;│
                inc     dl                       ;│
                mov     ax,0601h                 ;│
                mov     bh,[color]               ;│
                int     10h                      ;┘
                call    WindowSetVidAddr
                pop     bx
                pop     dx
                dec     bh
                jmp     write1
ENDP            write

; Получаем текущий адресс в видеопамяти ######################################
PROC            GetCurentVideoAddr
                mov     dl,[mainx]
                mov     dh,[mainy]
ENDP            GetCurentVideoAddr

PROC            WindowSetVidAddr
                add     dl,[windowx]
                add     dh,[windowy]
ENDP            WindowSetVidAddr

; Установить адресс видеопамяти ##############################################
PROC            SetVidAddr                 ;подготовить адресс видеопамяти.
                push    bx
                xor     bh, bh             ;dx - координаты
                mov     bl, dh             ;Возвращяет в di адресс
                shl     bx, 1
                mov     di, [ScRow+bx]
                xor     dh, dh
                shl     dx, 1
                add     di, dx
                pop     bx
                ret
ENDP            SetVidAddr

                END     Start

