DATA SEGMENT
  MENU           DB "1. Count characters in string.", 0AH
                 DB "2. Update String.", 0AH
                 DB "3. Exit program.", 0AH, "$"
  NOW_STR        DB "Current string: $"
  ALREADY_RESD   DB "The string has been updated to: $"
  PROMPT         DB "Please enter the menu item number: $"
  INPUT          DB 100 DUP ('?')
  SPACE          DB "Space: $"
  LOWERCASE      DB "Lowercase: $"
  UPPERCASE      DB "Uppercase: $"
  NUMBER         DB "Number: $"
  OTHER          DB "Other: $"
  MY_STR         DB "Hello, World$", 100 DUP (?)
  DEBUG_INFO     DB "Debug info: $"
  DIVID_LOOP_     DB "Divid loop: $"
  MEET_END       DB "Meet end: $"
  space_count    DW 0
  lowercase_count DW 0
  uppercase_count DW 0
  number_count    DW 0
  blank_count     DW 0
  other_count     DW 0
DATA ENDS

MY_STACK SEGMENT
           DW 128 DUP(0)
MY_STACK ENDS

CODE SEGMENT
  ASSUME CS:CODE, DS:DATA, SS:MY_STACK

START:              
  ; 设置数据段
  MOV    AX, DATA
  MOV    DS, AX

  ; 打印菜单
  MOV    DX, OFFSET MENU
  CALL   PrintString
  
  ; 打印当前的字符串
  MOV    DX, OFFSET NOW_STR
  CALL   PrintString
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  
  ; 打印换行
  CALL   PrintNewLine

REPEAT:             
  ; 提示输入
  MOV    DX, OFFSET PROMPT
  CALL   PrintString
    
  ; 读取用户输入
  CALL   ReadChar
  CALL   PrintNewLine

  CMP    AL, '1'
  JE     STATISTICS
  CMP    AL, '2'
  JE     UPDATE_STRING
  CMP    AL, '3'
  JE     EXIT

STATISTICS:
  ; 统计字符
  MOV    SI, OFFSET MY_STR
  
  ; 初始化计数器
  MOV   space_count, 0
  MOV   lowercase_count, 0
  MOV   uppercase_count, 0
  MOV   number_count, 0
  MOV   blank_count, 0
  MOV   other_count, 0

; 统计
Count_char:
  MOV   AL, [SI]
  CMP   AL, '$'
  JE    Print_statistics

  CMP   AL, ' '
  JE    is_space
  CMP   AL, 'a'
  JB    is_not_lowercase
  CMP   AL, 'z'
  JA    is_not_lowercase
  INC   lowercase_count
  JMP   Next_char

is_not_lowercase:
  CMP   AL, 'A'
  JB    is_not_aphabet
  CMP   AL, 'Z'
  JA    is_not_aphabet
  INC   uppercase_count
  JMP   Next_char

is_not_aphabet:
  CMP  AL, '0'
  JB    is_not_number
  CMP   AL, '9'
  JA    is_not_number
  INC   number_count
  JMP   Next_char

is_space:
  INC   space_count
  JMP   Next_char

is_not_number:
  INC  other_count
  JMP  Next_char

Next_char:
  INC  SI
  JMP  Count_char

UPDATE_STRING:
  JMP  UPDATE_STRING_
EXIT:
  JMP  EXIT_

Print_statistics:
  MOV   DX, OFFSET SPACE
  CALL  PrintString
  MOV   AX, space_count
  CALL  Print_Number
  CALL  PrintNewLine

  MOV   DX, OFFSET LOWERCASE
  CALL  PrintString
  MOV   AX, lowercase_count
  CALL  Print_Number
  CALL  PrintNewLine

  MOV   DX, OFFSET UPPERCASE
  CALL  PrintString
  MOV   AX, uppercase_count
  CALL  Print_Number
  CALL  PrintNewLine

  MOV   DX, OFFSET NUMBER
  CALL  PrintString
  MOV   AX, number_count
  CALL  Print_Number
  CALL  PrintNewLine

  MOV   DX, OFFSET OTHER
  CALL  PrintString
  MOV   AX, other_count
  CALL  Print_Number
  CALL  PrintNewLine
  JMP   REPEAT

UPDATE_STRING_:      
  ; 读取到 INPUT 缓冲区
  MOV    DX, OFFSET INPUT
  MOV    AH, 0AH
  INT    21H
    
  ; 重复输入的字符串作为确认
  CALL   PrintNewLine
  MOV    DX, OFFSET ALREADY_RESD
  CALL   PrintString

  MOV    SI, OFFSET INPUT + 1
  MOV    CX, [SI]
  INC    SI
  MOV    DI, OFFSET MY_STR

  ; 拷贝内容到 MY_STR
Copy_char:          
  MOV    AL, [SI]
  CMP    AL, 0DH
  JE     Meet_LF

  MOV    [DI], AL
  INC    DI

  INC    SI
  LOOP   Copy_char
    
Meet_LF:            
  MOV    BYTE PTR [DI], '$'
  CALL   PrintNewLine
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT

EXIT_:               
; 退出程序
  MOV    AX, 4C00H
  INT    21H

; 打印字符串子程序
PrintString PROC
  PUSH   AX
  PUSH   DX
  MOV    AH, 09H
  INT    21H
  POP    DX
  POP    AX
  RET
PrintString ENDP

; 打印换行子程序
PrintNewLine PROC
  PUSH   AX
  PUSH   DX

  MOV    AH, 02H
  MOV    DL, 0DH
  INT    21H
  MOV    DL, 0AH
  INT    21H

  POP    DX
  POP    AX
  RET
PrintNewLine ENDP

; 读取单个字符子程序
ReadChar PROC
  MOV    AH, 01H
  INT    21H
  RET
ReadChar ENDP

Print_Number PROC
; 打印 AX 中的数字
    PUSH AX
    MOV CX, 0
    MOV BX, 10

divid_loop:
    XOR DX, DX
    DIV BX
    ; 余数入栈
    PUSH DX
    INC CX
    ; 检查商是否为 0
    CMP AX, 0
    JE  Print_Digit
    JMP divid_loop
Print_Digit:
    ; 从栈中取出数字并打印
    POP DX
    ADD DL, '0'
    MOV AH, 2
    INT 21H
    LOOP Print_Digit
Print_End:    
  POP AX
  RET
Print_Number ENDP
 
CODE ENDS
END START