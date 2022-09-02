; Интерпретатор BASIC

vars			EQU 7E00h	; Переменные (a-z)
running			EQU 7E7Eh	; Указатель на строчку, которая сейчас выполняется
line			EQU 7E80h	; Строчка программы, которую напечатал программист
program			EQU 7F00h	; Указатель на буфер для исходника программы
stack			EQU 0FF00h	; Адрес стека
max_line		EQU 1000	; Максимальное количество строчек в программе
max_length		EQU 20		; Максимальная длина строчки программы
max_size		EQU max_line*max_length

statements		DB 3,"new"
				DW start_bas
				DB 4,"list"
				DW list_handler
				DB 3,"run"
				DW run_handler
				DB 5,"print"
				DW print_handler
				DB 5,"input"
				DW input_handler
				DB 2,"if"
				DW if_handler
				DB 4,"goto"
				DW goto_handler
				DB 0

basic1			DB "BASIC v.1.0 (c) 2022 Gor.Com",0

; BASIC #############################################################################
PROC			doBasic
				; Вывод строки
				lea		si,[basic1]
				call	WriteLn
start_bas:				
				cld
				mov		di,program
				mov		al,0Dh
				mov		cx,max_size
				rep		stosb
main_loop_bas:	
				xor		ax,ax
				mov		[running],ax	; Обнуляем счетчик команд
				mov		al,'>'			; Рисуем приглашение ввода ">"
				call	input_line		; Ждем команду от пользователя
				call	dec_str_to_number
				or		ax,ax			; Строчка начинается с числа?
				je		no_save
				call	find_address	; Вычисляем адрес, куда сохранить строчку
				xchg	ax,di
				mov		cx,max_length
				rep		movsb			; Сохраняем введенную строчку в программу
				jmp		main_loop_bas
				
no_save:								; Интерактивная обработка
				call	execute_statement
				jmp		main_loop_bas
				
				;lea		si,[program]
				;call	WriteLn
				ret
ENDP			doBasic