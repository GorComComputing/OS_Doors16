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
				
color			DB 1Fh			; ����: ���� ᨬ��� �� ���㡮� 䮭�
windowx			DB 3			; ���न���� ������ ���孥�� 㣫� ���㡮�� �࠭� �뢮��
windowy			DB 2			;	
windowHx		DB 15h
windowWx		DB 4Ah
mainx			DB 0
mainy			DB 5
space			DB 20h,0
string			DB "GOR.COM DOORS v.1.0",0
loading			DB "Kernel is loading... DONE",0
command			DB 128 DUP (?)	; ��������� ��ப� (128 ᨬ�����)
				
				CODESEG
				ORG 100h		; ��砫� �믮������ �� �����
Start:			; ���⪠ �࠭�
				call	doCLS		
				; �뢮� ࠬ��
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
				
				call	Input
				
				ret

				; ������砥� ������⥪�
				include "out.asm"
				include "in.asm"
				END Start
				