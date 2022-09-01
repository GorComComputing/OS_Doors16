; БИБЛИОТЕКА ВЫВОДА

; Вывод строки с общими координатами #################################################
PROC			Write

				ret
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
				mov		al,"+"
				stosw
				mov		al,"-"
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,"+"
				stosw
				pop		di
				mov		cl,dh
				xor		ch,ch
Ramka_1:		add		di,160
				push	di
				push	cx
				mov		al,"|"
				stosw
				mov		al," "
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,"|"
				stosw
				pop		cx
				pop		di
				loop	Ramka_1
				add		di,160
				mov		al,"+"
				stosw
				mov		al,"-"
				xor		ch,ch
				mov		cl,dl
				rep		stosw
				mov		al,"+"
				stosw				
RamkaEnd:		ret
ENDP			Ramka

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

; Очистка экрана #######################################################################
PROC			doCLS
				mov		ch,[windowy]
				mov		cl,[windowx]
				dec		cl
				mov		dh,[windowHx]
				inc		dh
				mov		dl,[windowWx]
				inc		dl
				inc		dl
				mov		ax,0600h
				mov		bh,[color]
				int		10h
				mov		[Byte Ptr mainx],0
				mov		[Byte Ptr mainy],0
				ret
ENDP			doCLS