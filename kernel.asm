%TITLE 			"��� DOORS"
				IDEAL
				MODEL	TINY	; ������ ����� ��� COM-䠩���. 64�, �� ᥣ����� � �����
				DATASEG

; ��� ��⠭���� ���� ����������
BytesPerRowa=80*2
rowa=0				
LABEL	ScRow 	Word
REPT	25
DW	(rowa*BytesPerRowa)
rowa=rowa+1
ENDM

quitFLG			DB 0			; ���� ��室� �� ��		
color			DB 070h			; ����: ���� ᨬ��� �� ���㡮� 䮭� 1Fh		
windowx			DB 3			; ���न���� ������ ���孥�� 㣫� ���㡮�� �࠭� �뢮��
windowy			DB 2			;	
windowHx		DB 15h			; ������� ࠡ�祩 ������ �࠭� 74x21 (80x25)
windowWx		DB 4Ah			;
mainx			DB 0			; ���न���� ����� ��� Write � WriteLn
mainy			DB 5			;
space			DB 20h,0
null			DB 0
plots			DB ".........",0	; ��� ������� Help
entr			DB "$ ",0		; �ਣ��襭�� ��� �����
string0			DB "DOORS v.1.0 (c) 2022 Gor.Com",0
string1			DB "Type 'help' for help.",0
error1			DB "Syntax error.",0
string			DB "GOR.COM DOORS v.1.0",0
loading			DB "Kernel is loading... DONE",0
				include "data.inc"
command			DB 128 DUP (?)	; ��������� ��ப� (128 ᨬ�����)
				
				CODESEG
				ORG 100h		; ��砫� �믮������ �� �����
Start:			; �뢮� ࠬ��
				mov		cx,0101h
				mov		dx,164Dh
				call 	Ramka
				; �뢮� ��ப�
				lea		si,[string]
				mov		dx,011Ah	; ���न����
				call	Print
				; �뢮� ��ப�
				lea		si,[loading]
				mov		dx,0300h	; ���न����
				call	Print
				
				; �뢮� ��ப�
				lea		si,[string0]
				call	WriteLn
				; �뢮� ��ப�
				lea		si,[string1]
				call	WriteLn
				; �뢮��� �ਣ��襭�� �� ����� - $ � ���� ���� ��ப�
opros:			lea		si,[entr]
				call	Write
opr1:			call	Input
				; ������� �� �������� ᨬ���� � ��������� ��ப� �������묨
				lea		di,[command]
				call	UpperString
				; �஢��塞 �� ������ ��ப� �����
				mov		al,[command]
				or		al,al
				je		opr1
				; �믮��塞 ��������� �������
				call	doCommand
				mov		al,[quitFLG]
				or		al,al
				je		opros
				
				
				ret
				
				
				
; �믮������ ������� ####################################################################				
PROC			doCommand
				lea		di,[ctable]
dCmd3:			lea		si,[command]
dCmd0:			mov		al,[si]
				cmp		al,[di]
				jne		dCmd1		; ������� �� ��������
				or		al,al
				je		dCmd2		; ����� �������, ������� ��������
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
				jmp		dCmd3		; �஢��塞 ᫥������ �������
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

				; ������砥� ������⥪�
				include "out.asm"
				include "in.asm"
				include "string.asm"
				include "shell.asm"
				
				include "sqlite.asm"
				include "basic.asm"
				END Start
				