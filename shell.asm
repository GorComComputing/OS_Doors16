; Оработчики команд Shell

; Выход из ОС ##########################################################################
PROC			doQuit
				mov		[quitFLG],1
				ret
ENDP			doQuit

; Страничка помощи #####################################################################
PROC			doHelp
				lea		di,[ctable]
doHelp0:		mov		si,di
				push	di
				mov		al,[di]
				or		al,al
				je		doHelp3
				call	Write
				lea		si,[plots]
				call	Write
				pop		di
doHelp1:		inc		di
				cmp		[Byte Ptr di],0
				jne		doHelp1
				inc		di
				push	di
				mov		si,di
				call	Write
				lea		si,[null]
				call	WriteLn
				pop		di
doHelp2:		inc		di
				cmp		[Byte Ptr di],0
				jne		doHelp2
				inc		di
				inc		di
				inc		di
				jmp		doHelp0
doHelp3:		pop	di				
				ret
ENDP			doHelp

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