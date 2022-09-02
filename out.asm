; БИБЛИОТЕКА ВЫВОДА

; Вывод строки с переносом и общими координатами #####################################
PROC			WriteLn
				push	ds es
				call	Write
				mov		[Byte Ptr mainx],0
				mov		al,[mainy]
				inc		al
				cmp		al,[windowHx]
				jne		wln
				dec		al
				push	ax
				mov		ch,[windowy]
				mov		cl,[windowx]
				dec		cl
				mov		dh,[windowHx]
				inc		dh
				mov		dl,[windowWx]
				inc		dl
				inc		dl
				mov		ax,0601h
				mov		bh,[color]
				int		10h
				pop		ax
wln:			mov		[mainy],al
				mov		dh,[mainy]
				mov		dl,[mainx]
				add		dh,[windowy]
				add		dl,[windowx]
				xor		bx,bx
				mov		ax,0200h
				int		10h
				pop		es ds				
				ret
ENDP			WriteLn

; Вывод строки с общими координатами #################################################
PROC			Write
				push	ds es
				mov		ax,0B800h
				mov		es,ax
				call	GetCurrentVideoAddress
				mov		dl,[mainx]
				mov		dh,[mainy]
write1:			mov		ah,[color]
				mov		al,[ds:si]
				or		al,al
				je		writeend
				mov		[es:di],ax
				inc		di
				inc		di
				inc		si
				inc		dl
				cmp		dl,[windowWx]
				je		wxcarry
				jmp		write1
writeend:		mov		[mainx],dl
				mov		[mainy],dh
				add		dh,[windowy]
				add		dl,[windowx]
				push	bx
				xor		bx,bx
				mov		ax,0200h
				int		10h
				pop		bx
				pop		es ds
				ret
				; Перенос строки
wxcarry:		xor		dl,dl
				inc		dh
				push	dx
				call	WindowSetVideoAddress
				pop		dx
				cmp		dh,[windowHx]
				jne		write1
				dec		dh
				push	dx
				push	bx
				mov		ch,[windowy]
				mov		cl,[windowx]
				dec		cl
				mov		dh,[windowHx]
				inc		dh
				mov		dl,[windowWx]
				inc		dl
				inc		dl
				mov		ax,0601h
				mov		bh,[color]
				int		10h
				call	WindowSetVideoAddress
				pop		bx
				pop		dx
				dec		bh
				jmp		write1
ENDP			Write

; Вывод строки ds:di ##################################################################				
PROC			Print
				mov		ax,0B800h		; Устанавливаем адрес видеопамяти
				mov 	es,ax
				add		dh,[windowy]	; Прибавляем координаты верхнего левого угла
				add		dl,[windowx]
				call	SetVideoAddress
print1:			mov		ah,[color]		; Цвет
				mov		al,[ds:si]		; Символ
				or		al,al			; Проверка на 0 - конец строки
				je		prnend
				mov		[es:di],ax		; Копируем символ и атрибут в видеопамять
				inc		di
				inc		di
				inc		si
				jmp		print1	
prnend:			ret
ENDP			Print

; Вывод рамки #########################################################################
PROC			Ramka
				mov		ax,0B800h
				mov		es,ax
				or		dl,dl
				je		RamkaEnd
				or		dh,dh
				je		RamkaEnd
				mov		ah,[color]
				dec		dl
				dec		dh
				xor		bh,bh
				mov		bl,ch
				push	dx ax
				 mov	dx,160
				 mov	ax,bx
				 mul	dx
				 mov	bx,ax
				pop		ax dx
				xor		ch,ch
				shl		cx,1
				add		bx,cx
				mov		di,bx
				push 	di
				mov		al,0C9h	;"+"
				stosw
				mov		al,0CDh	;"-"
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,0BBh	;"+"
				stosw
				pop		di
				mov		cl,dh
				xor		ch,ch
Ramka_1:		add		di,160
				push	di
				push	cx
				mov		al,0BAh	;"|"
				stosw
				mov		al," "
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,0BAh	;"|"
				stosw
				pop		cx
				pop		di
				loop	Ramka_1
				add		di,160
				mov		al,0C8h	;"+"
				stosw
				mov		al,0CDh	;"-"
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,0BCh	;"+"
				stosw				
RamkaEnd:		ret
ENDP			Ramka


; Получаем текущий адрес в видеопамяти #################################################
PROC			GetCurrentVideoAddress
				mov		dl,[mainx]
				mov		dh,[mainy]
ENDP			GetCurrentVideoAddress
PROC			WindowSetVideoAddress
				add		dl,[windowx]
				add		dh,[windowy]		
ENDP			WindowSetVideoAddress
; Установить адрес видеопамяти #########################################################
PROC			SetVideoAddress
				push	bx
				xor		bh,bh
				mov		bl,dh
				shl		bx,1
				mov		di,[ScRow+bx]
				xor		dh,dh
				shl		dx,1
				add		di,dx
				pop		bx
				ret
ENDP			SetVideoAddress

