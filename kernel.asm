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
				
color			DB 1Fh			; Цвет: белый символ на голубом фоне
windowx			DB 3			; Координаты левого верхнего угла голубого экрана вывода
windowy			DB 2			;	
windowHx		DB 15h
windowWx		DB 4Ah
mainx			DB 0
mainy			DB 5
space			DB 20h,0
string			DB "GOR.COM DOORS v.1.0",0
loading			DB "Kernel is loading... DONE",0
command			DB 128 DUP (?)	; Командная строка (128 символов)
				
				CODESEG
				ORG 100h		; Начало выполнения ядра здесь
Start:			; Очистка экрана
				call	doCLS		
				; Вывод рамки
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
				
				call	Input
				
				ret

				; Подключаем библиотеки
				include "out.asm"
				include "in.asm"
				END Start
				