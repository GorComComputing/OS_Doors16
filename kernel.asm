%TITLE 			"Ядро DOORS"
				IDEAL
				MODEL	TINY	; Модель памяти для COM-файлов. 64К, все сегменты в одном
				DATASEG

; Для установки адреса видеопамяти
BytesPerRowa=80*2
rowa=0				
LABEL	ScRow 	Word
REPT	25
DW	(rowa*BytesPerRowa)
rowa=rowa+1
ENDM

quitFLG			DB 0			; Флаг выхода из ОС		
color			DB 070h			; Цвет: белый символ на голубом фоне 1Fh		
windowx			DB 3			; Координаты левого верхнего угла голубого экрана вывода
windowy			DB 2			;	
windowHx		DB 15h			; Размеры рабочей области экрана 74x21 (80x25)
windowWx		DB 4Ah			;
mainx			DB 0			; Координаты курсора для Write и WriteLn
mainy			DB 5			;
space			DB 20h,0
null			DB 0
plots			DB ".........",0	; для команды Help
entr			DB "$ ",0		; Приглашение для ввода
string0			DB "DOORS v.1.0 (c) 2022 Gor.Com",0
string1			DB "Type 'help' for help.",0
error1			DB "Syntax error.",0
string			DB "GOR.COM DOORS v.1.0",0
loading			DB "Kernel is loading... DONE",0
				include "data.inc"
command			DB 128 DUP (?)	; Командная строка (128 символов)
				
				CODESEG
				ORG 100h		; Начало выполнения ядра здесь
Start:			; Вывод рамки
				mov		cx,0101h
				mov		dx,164Dh
				call 	Ramka
				; Вывод строки
				lea		si,[string]
				mov		dx,011Ah	; Координаты
				call	Print
				; Вывод строки
				lea		si,[loading]
				mov		dx,0300h	; Координаты
				call	Print
				
				; Вывод строки
				lea		si,[string0]
				call	WriteLn
				; Вывод строки
				lea		si,[string1]
				call	WriteLn
				; Выводим приглашение ко вводу - $ и ждем ввод строки
opros:			lea		si,[entr]
				call	Write
opr1:			call	Input
				; Сделать все введенные символы в командной строке заглавными
				lea		di,[command]
				call	UpperString
				; Проверяем на пустую строку ввода
				mov		al,[command]
				or		al,al
				je		opr1
				; Выполняем введенную команду
				call	doCommand
				mov		al,[quitFLG]
				or		al,al
				je		opros
				
				
				ret
				
				
				
; Выполнение команды ####################################################################				
PROC			doCommand
				lea		di,[ctable]
dCmd3:			lea		si,[command]
dCmd0:			mov		al,[si]
				cmp		al,[di]
				jne		dCmd1		; Команда не опознана
				or		al,al
				je		dCmd2		; Конец команды, команда опознана
				inc		di
				inc		si
				jmp		dCmd0
dCmd1:			inc		di
				cmp		[Byte Ptr di],0
				jne		dCmd1
				inc		di
				inc		di
				inc		di
				cmp		[Byte Ptr di],0
				je		dCmd4
				jmp		dCmd3		; Проверяем следующую команду
dCmd2:			inc		di
				cmp		[Byte Ptr di],0
				jne		dCmd2
				inc		di
				push	di
				lea		si,[null]
				call	WriteLn
				pop		di
				mov		si,[di]
				call	si
				ret
dCmd4:			lea		si,[null]
				call	WriteLn
				lea		si,[error1]
				call	WriteLn			
				ret
ENDP			doCommand

				; Подключаем библиотеки
				include "out.asm"
				include "in.asm"
				include "string.asm"
				include "shell.asm"
				
				include "sqlite.asm"
				include "basic.asm"
				END Start
				