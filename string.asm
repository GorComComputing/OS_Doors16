; БИБЛИОТЕКА РАБОТЫ СО СТРОКАМИ

; Делает все буквы строки заглавными (ds:di - строка) ##################################
PROC			UpperString
				push	di ax
us0:			mov		al,[ds:di]
				or		al,al
				je		us1
				cmp		al,'a'
				jc		us2
				cmp		al,'z'
				ja		us2
us00:			sub		al,20h
				mov		[ds:di],al
us01:			inc		di
				jmp		us0			
us2:			cmp		al,0A0h	; "а" русское
				jc		us3
				cmp		al,0AFh	; "п" русское
				ja		us3
				jmp		us00
us3:			cmp		al,0E0h
				jc		us01
				cmp		al,0EFh
				ja		us01
				sub		al,'p'-'P'
				mov		[ds:di],al
				jmp		us01
us1:			pop		ax di
				ret
ENDP			UpperString