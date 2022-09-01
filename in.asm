; БИБЛИОТЕКА ВВОДА

; Ввод строки с эхом ###################################################################
PROC			Input
				mov		ax,cs
				mov		es,ax
				lea		di,[command]
				mov		cx,128
				xor		ax,ax
				rep		stosb
				
				lea		di,[command]
				mov		bh,[cs:mainy]
				mov		bl,[cs:mainx]
				xor		cx,cx
inp1:			push	cx
				xor		ax,ax
				int		16h
				pop		cx
				cmp		al,13		; Enter
				je		ipEnter
				cmp		al,8
				je		ipBackSpace	; BackSpace
				or		al,al
				je		inp1
				mov		[cs:di],al
				inc		di
				inc		cx
				cmp		cx,126
				jne		inp2
				dec		di
				dec		cx
inp2:			push	di
				mov		[Byte Ptr cs:di],0
				mov		[cs:mainy],bh
				mov		[cs:mainx],bl
				lea		si,[cs:command]
				push	cx
				call	Write
				pop		cx
				pop		di
				jmp		inp1
				; Заглушка для задержки ввода
				;xor		ax,ax
				;int		16h
ipEnter:		ret
ipBackSpace:	push	si
				lea		si,[command]
				cmp		si,di
				pop		si
				je		inp1
				dec		di
				push	di bx
				mov		[Byte Ptr cs:di],0
				mov		[cs:mainy],bh
				mov		[cs:mainx],bl
				lea		si,[cs:command]
				call	Write
				lea		si,[cs:space]
				call	Write
				mov		[cs:mainy],bh
				mov		[cs:mainx],bl
				lea		si,[cs:command]
				call	Write
				pop		bx di
				dec		cx
				jmp		inp1
ENDP			Input