; Интерпретатор BASIC

vars			EQU 7E00h	; Переменные (a-z)
running			EQU 7E7Eh	; Указатель на строчку, которая сейчас выполняется
line			EQU 7E80h	; Строчка программы, которую напечатал программист
program			EQU 7F00h	; Указатель на буфер для исходника программы
;stack			EQU 0FF00h	; Адрес стека
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
				DB 3,"cls"
				DW cls_handler
				DB 4,"help"
				DW help_handler
				DB 0
EXIT_CMD		DB "exit"

basic1			DB "BASIC v.1.0 (c) 2022 Gor.Com",0
entr_bas		DB ">",0		; Приглашение для ввода ">"
entr2_bas		DB "?",0		; Приглашение для ввода "?"
error_message	DB "Error!",0
char			DB "@",0

; BASIC #############################################################################
PROC			doBasic
				call	Initialization	; Инициализация
; Главный цикл интерпретатора
main_loop_bas:	
				xor		ax,ax			; Обнуляем счетчик команд
				mov		[running],ax	;
				
				lea		si,[entr_bas]	; Выводим приглашение ко вводу ">" и ждем ввод строки
				call	Write
				call	Input
				
				lea 	si,[command]
				call	Dec_str_to_number	; Строчка начинается с числа?
				or		ax,ax			; (в AX число, если есть)
				je		no_save			; если нет, не сохраняем и выполняем сразу.
				call	Find_address	; Вычисляем адрес, куда сохранить строчку
				xchg	ax,di			; Помещаем адрес из AX в DI
				mov		cx,max_length	; читаем 20 символов в строке
				rep		movsb			; Сохраняем введенную строчку в программу
				
				call	Enter_line		;переводим строку
				jmp		main_loop_bas
				
no_save:								; Интерактивная обработка
				; Проверяем на команду EXIT
				push	si
				mov		cx,0004				; Количество символов в команде EXIT (4)
				lea		di,[EXIT_CMD]		; Указатель на строку "exit"
				rep		cmpsb				; и сравниваем символ за символом
				pop		si
				jne		no_exit	
				call	Enter_line		;переводим строку
				ret
no_exit:								; Если не EXIT
				call	Enter_line		;переводим строку
				call	execute_statement
				jmp		main_loop_bas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
if_handler:	
				call	process_expr
				or		ax,ax
				je		to_ret
execute_statement:
				call	Skip_spaces			; Пропускаем пробелы
				cmp		[Byte Ptr si],0Dh	; Если пустая строка, то завершаем выполнение строки
				je		to_ret				;
				
				lea		di,[statements]		; Указатель на таблицу команд
next_entry:
				mov		cl,[di]				; Количество символов в команде
				mov		ch,0
				test	cx,cx				; Если 0, то достигнут конец таблицы,
				je		to_get_var			; значит это переменная
				
				push	si					; Сохраняем адрес введенной строки в стеке
				
				inc		di					; Переводим указатель на имя команды в таблице
				rep		cmpsb				; и сравниваем символ за символом
				jne		no_equal			; Если не совпала, проверяем следующую команду в таблице
				
				pop		ax					; в AX адрес строки ввода
				call	Skip_spaces			; Пропускаем пробелы, перемещаем указатель на операнды
				
				jmp		[Word Ptr di]		; Передаем управление обработчику команды
no_equal:
				add		di,cx				; Перемещаем указатель к следующей команде в таблице
				inc		di					;
				inc		di					;
				pop		si					;
				jmp		next_entry			;
to_get_var:				
				call	get_var
				push	ax
				lodsb
				cmp		al,'='
				je		assign2
output_error:
				call	ErrorMsg				; Вывод сообщения об ошибке
				jmp		main_loop_bas			
to_ret:
				ret		
assign2:
				call	process_expr	; Вычисляем введенное выражение
				pop		di
				stosw					; Сохраняем результат в переменную
				ret				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_var:
				lodsb
get_var_2:
				and		al,1Fh
				add		al,al
				mov		ah,7Eh
				jmp		Skip_spaces
			
				
				
				
				
output_number:
				xor		dx,dx
				mov		cx,10
				div		cx
				or		ax,ax
				push	dx
				je		to_output_char
				call	output_number
to_output_char:
				pop		ax
				add		al,'0'
				jmp		output_char
ENDP			doBasic


; Выполнение команды RUN и GOTO
PROC			run_handler
				xor		ax,ax
				jmp		to_goto
goto_handler:
				call	process_expr
to_goto:
				call	Find_address
				cmp		[Word Ptr running],0
				je		to_next_line
				mov		[running],ax
				ret
to_next_line:
				push	ax
				pop		si
				add		ax,max_length
				mov		[running],ax
				call	execute_statement
				mov		ax,[running]
				cmp		ax,program+max_size
				jne		to_next_line
				ret
ENDP			run_handler


; Вынимаем номер из строки и помещаем его в AX (SI указывает на строку)				
PROC			Dec_str_to_number
				xor		bx,bx
to_next_digit:
				lodsb
				sub		al,'0'
				cmp		al,10
				cbw
				xchg	ax,bx
				jnc		not_digit
				mov		cx,10
				mul		cx
				add		bx,ax
				jmp		to_next_digit
not_digit:
				dec		si
				ret
ENDP			Dec_str_to_number

; По номеру вычисляет адрес строки в исходнике
PROC			Find_address
				mov		cx,max_length	; в AX хранится номер строки
				mul		cx				; умножаем его на длину строки (20)
				add		ax,program		; прибавляем адрес первой строки программы
				ret						; в AX возвращает адрес
ENDP			Find_address

; Обработчик оператора PRINT
PROC			print_handler
				lodsb
				cmp		al,0Dh			; Если PRINT без аргумента,
				je		new_line		; то переводим строку
				cmp		al,'"'			; Если ", то читаем символ за символом
				jne		no_quote
next_char1:
				lodsb
				cmp		al,'"'
				je		to_semicolon
				call	output_char
				cmp		al,0Dh
				jne		next_char1
				ret		
no_quote:
				dec		si				
				call	process_expr	; вычисляем выражение
				call	output_number	; выводим число
to_semicolon:
				lodsb
				cmp		al,';'			; Проверяем на ;
				jne		new_line
				ret
				
output_char:
				cmp		al,0Dh
				jne		to_show
new_line:		
				call	Enter_line		;переводим строку
				ret
to_show:
				push	si
				mov		char,al
				lea		si,[char]
				call	Write
				pop		si
				ret
ENDP			print_handler


; Обработчик оператора INPUT
PROC			input_handler
				call	get_var			; Вычисляет адрес переменной
				push	ax				; Сохраняет его в стек
				
				; Выводим приглашение ко вводу "?" и ждем ввод строки
				push	si
				lea		si,[entr2_bas]
				call	Write
				pop		si
				push	si
				call	Input
				pop		si
				
				; Присваиваем в переменную
				call	process_expr	; Вычисляем введенное выражение
				pop		di
				stosw					; Сохраняем результат в переменную
				
				call	Enter_line		; переводим строку
				
				ret
ENDP			input_handler


; Обработчик оператора "="
PROC			assign
				call	process_expr	; Вычисляем введенное выражение
				pop		di
				stosw					; Сохраняем результат в переменную
				ret
ENDP			assign


; Выполнение команды LIST
PROC			list_handler
				xor		ax,ax			; Сбрасываем в 0 номер текущей строки в программе
next_line:
				push	ax				; Сохраняем номер строки в стеке
				call	Find_address	; Вычисляем адрес, откуда считывать программу
				xchg	ax,si
				cmp		[Byte Ptr si],0Dh	; Проверка на пустую строку
				je		empty_line
				pop		ax
				push	ax
				call	output_number	; Выводим номер строки
next_char:
				lodsb
				call	output_char		; Выводим посимвольно строку, пока не конец строки (0Dh)
				cmp		al,0Dh
				jne		next_char
empty_line:
				pop		ax				; Если строка пустая, увеличиваем счетчик строк AX
				inc		ax
				cmp		ax,max_line
				jne		next_line		; Если достигли максимальной строки, завершаем вывод
				ret
ENDP			list_handler


; Инициализация интерпретатора
PROC			Initialization
				lea		si,[basic1]		; Вывод строки приветствия
				call	WriteLn
start_bas:				
				cld						; Флаг направления DF = 0, чтобы строки обрабатывались слева направо
				mov		di,program		; Буфер исходника программы, заполняем символом 0Dh (Enter)
				mov		al,0Dh			;
				mov		cx,max_size		;
				rep		stosb			;
				ret
ENDP			Initialization


; Пропускает все пробелы
PROC			Skip_spaces
				cmp		[Byte Ptr si],' '
				jne		skip_complete
skip_spaces_2:
				inc		si				; инкремент SI, если пробел
				jmp		Skip_spaces
				
skip_complete:
				ret	
ENDP			Skip_spaces


; Перевод строки
PROC			Enter_line
				push	si
				lea		si,[null]		;переводим строку
				call	WriteLn
				pop		si
				ret
ENDP			Enter_line


; Вывод сообщения об ошибке
PROC			ErrorMsg
				push	si
				lea		si,[error_message]		; Вывод сообщения об ошибке
				call	WriteLn
				pop		si
				ret
ENDP			ErrorMsg


; Очистка экрана
PROC			cls_handler
				call	doCLS
				ret
ENDP			cls_handler


; Справка о командах Basic
PROC			help_handler
				lea		si,[basic1]		; Вывод строки приветствия
				call	WriteLn
				ret
ENDP			help_handler


; Вычисление выражения
PROC			process_expr
				call	expr2_left
next_sub_add:
				cmp		[Byte Ptr si],'-'
				je		to_op_sub
				cmp		[Byte Ptr si],'+'
				jne		to_ret2
				push	ax
				call	expr2_right
				
				pop		cx
				add		ax,cx
				jmp		next_sub_add
to_op_sub:
				push	ax
				call	expr2_right
				pop		cx
				xchg	ax,cx
				sub		ax,cx
				jmp		next_sub_add
				
expr2_right:
				inc		si
expr2_left:
				call	expr3_left
next_div_mul:
				cmp		[Byte Ptr si],'/'
				je		to_op_div
				cmp		[Byte Ptr si],'*'
				jne		to_ret2
				
				push	ax
				call	expr3_right
				
				pop		cx
				imul	cx
				jmp		next_div_mul
to_op_mul:
				push	ax
				call	expr3_right
				pop		cx
				imul	cx
				jmp		next_div_mul
to_op_div:
				push	ax
				call	expr3_right
				pop		cx
				xchg	ax,cx
				cwd
				idiv	cx
				jmp		next_div_mul
				
expr3_right:
				inc		si
expr3_left:	
				call	Skip_spaces
				lodsb
				cmp		al,'('
				jne		not_par
				call	process_expr
				cmp		[Byte Ptr si],')'
				jne		output_error_2
				jmp		skip_spaces_2
				
output_error_2:	
				call	ErrorMsg				; Вывод сообщения об ошибке
				jmp		main_loop_bas
				
not_par:
				cmp		al,40h
				jnc		yes_var
				dec		si
				
				call	Dec_str_to_number
				jmp		Skip_spaces
yes_var:
				call	get_var_2
				xchg	ax,bx
				mov		ax,[bx]
to_ret2:				
				ret
ENDP			process_expr