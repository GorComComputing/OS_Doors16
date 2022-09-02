; СУБД SQLite для DOORS

quitFLG_sql		DB 0				; Флаг выхода из SQLite
sql_entr		DB "db > ",0		; Приглашение для ввода
sqlite1			DB "SQLite v.1.0 (c) 2022 Gor.Com",0
error1_sql		DB "Unrecognized command ",0

; SQLite #############################################################################
PROC			doSQLite
				; Вывод строки
				lea		si,[sqlite1]
				call	WriteLn
				; Выводим приглашение ко вводу - db> и ждем ввод строки
opros_sql:		lea		si,[sql_entr]
				call	Write
opr_sql1:		call	Input
				; Сделать все введенные символы в командной строке заглавными
				lea		di,[command]
				call	UpperString
				; Проверяем на пустую строку ввода
				mov		al,[command]
				or		al,al
				je		opr_sql1
				; Выполняем введенную команду
				call	doCommand_SQLite
				mov		al,[quitFLG_sql]
				or		al,al
				je		opros_sql
				
				mov		[quitFLG_sql],0
				ret
ENDP			doSQLite

; Выполнение команды SQLite ###############################################################				
PROC			doCommand_SQLite
				lea		di,[ctable_sql]
dCmd3_sql:		lea		si,[command]
dCmd0_sql:		mov		al,[si]
				cmp		al,[di]
				jne		dCmd1_sql		; Команда не опознана
				or		al,al
				je		dCmd2_sql		; Конец команды, команда опознана
				inc		di
				inc		si
				jmp		dCmd0_sql
dCmd1_sql:		inc		di
				cmp		[Byte Ptr di],0
				jne		dCmd1_sql
				inc		di
				inc		di
				inc		di
				cmp		[Byte Ptr di],0
				je		dCmd4_sql
				jmp		dCmd3_sql		; Проверяем следующую команду
dCmd2_sql:		inc		di
				cmp		[Byte Ptr di],0
				jne		dCmd2_sql
				inc		di
				push	di
				lea		si,[null]
				call	WriteLn
				pop		di
				mov		si,[di]
				call	si
				ret
dCmd4_sql:		lea		si,[null]
				call	WriteLn
				lea		si,[error1_sql]
				call	Write
				lea		si,[command]
				call	WriteLn
				ret
ENDP			doCommand_SQLite

; Выход из SQLite #######################################################################
PROC			doQuit_SQLite
				mov		[quitFLG_sql],1
				ret
ENDP			doQuit_SQLite

; Страничка помощи #####################################################################
PROC			doHelp_SQLite
				lea		di,[ctable_sql]
doHelp0_sql:	mov		si,di
				push	di
				mov		al,[di]
				or		al,al
				je		doHelp3_sql
				call	Write
				lea		si,[plots]
				call	Write
				pop		di
doHelp1_sql:	inc		di
				cmp		[Byte Ptr di],0
				jne		doHelp1_sql
				inc		di
				push	di
				mov		si,di
				call	Write
				lea		si,[null]
				call	WriteLn
				pop		di
doHelp2_sql:	inc		di
				cmp		[Byte Ptr di],0
				jne		doHelp2_sql
				inc		di
				inc		di
				inc		di
				jmp		doHelp0_sql
doHelp3_sql:	pop	di				
				ret
ENDP			doHelp_SQLite

