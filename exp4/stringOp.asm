DATA SEGMENT
  MENU           DB "1. Update String", 0AH
                 DB "2. Seach for substrings.", 0AH
                 DB "3. Insert a substring.", 0AH
                 DB "4. Delete substrings.", 0AH
                 DB "5. Print Now String.", 0AH
                 DB "6. Exit", 0AH, "$"
  ENTER_STRING   DB "Please input the string: $"
  ALREADY_RESD   DB "The string has been updated to: $"
  PROMPT         DB "Please input Number $"
  PROMPT_2       DB " is not a valid base number, please input again: $"
  ERROR          DB "Can not convert to number, please input again: $"
  ERROR_2        DB "ERROR: Index out of range$"
  ANS            DW 0
  NOW_BASE       DW 0
  INPUT          DB 100 DUP ('?')
  MY_STR         DB "Hello, World$", 100 DUP (?)
  TMP_STR        DB 100 DUP (?)
  String         DB "Hello, World$", 100 DUP (?)
  CNT            DW 0
  BASE           DW 10
  TMP_NUM        DW 0
  ERROR_FLAG     DB 0
  NEGATIVE_FLAG  DB 0
  NUM            DW 0
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

  ; 设置栈段
  MOV    AX, MY_STACK
  MOV    SS, AX

repeat:
  ; 打印菜单
  MOV    DX, OFFSET MENU
  CALL   PrintString
  ; 读取字符
  MOV AH, 01H
  INT 21H
  CALL  PrintNewLine

  CMP AL, '1'
  JE   Just_Update
  CMP AL, '2'
  JE   Just_Search
  CMP AL, '3'
  JE   Just_Insert
  CMP AL, '4'
  JE   Just_Delete
  CMP AL, '5'
  JE   Just_Print
exit:
  JE  EXIT

Just_Update:
  MOV  DX, OFFSET ENTER_STRING
  CALL PrintString
  CALL UPDATE_STRING
  JMP  repeat

Just_Search:
  CALL Search_substring
  JMP  repeat

Just_Insert:
  CALL Insert_substring
  JMP Just_Print
  
Just_Delete:
  ; CALL Delete_substring
  JMP  Just_Print

Just_Print:
  MOV  DX, OFFSET String
  CALL PrintString
  CALL PrintNewLine
  JMP  repeat


Insert_substring PROC
  MOV  DX, OFFSET ENTER_STRING
  CALL PrintString
  CALL READ_STR
  MOV  DX, OFFSET  PROMPT
  CALL PrintString
  CALL READ_NUM

  MOV  DI, OFFSET String; DI 指向 原始String
  MOV  SI, OFFSET TMP_STR; SI 指向 TMP_STR

  MOV  CX, TMP_NUM


copy_loop:; 拷贝 CX 个字符到 TMP_STR
  MOV  AL, BYTE PTR [DI]
  CMP  AL, '$'
  JE   End_copy; 如果拷贝到结尾，说明输入的位置不合法
  MOV  BYTE PTR [SI], AL
  INC  DI
  INC  SI
  LOOP copy_loop

  PUSH DI; 记录当前处理到的位置
  MOV DI, OFFSET MY_STR; DI 指向 MY_STR

copy_loop_2:
  MOV  AL, BYTE PTR [DI]
  CMP  AL, '$'
  JE   out_loop_2
  MOV  BYTE PTR [SI], AL
  INC  DI
  INC  SI
  JMP copy_loop_2

out_loop_2:
  POP DI; DI 指向原本的 String

copy_loop_3:
  
  MOV  AL, BYTE PTR [DI]
  CMP  AL, '$'
  JE   End_copy_Again
  MOV  BYTE PTR [SI], AL
  INC  DI
  INC  SI
  JMP copy_loop_3

End_copy_Again:
  MOV  BYTE PTR [SI], '$'
  CALL PrintNewLine
  MOV  DI, OFFSET TMP_STR
  MOV  SI, OFFSET String
re_copy:
  MOV  AL, BYTE PTR [DI]
  CMP  AL, '$'
  JE   End_re_copy
  MOV  BYTE PTR [SI], AL
  INC  DI
  INC  SI
  JMP re_copy
End_re_copy:
  MOV  BYTE PTR [SI], '$'
  RET
End_copy:
  MOV  DX, OFFSET ERROR_2
  CALL PrintString
  CALL PrintNewLine
  RET
Insert_substring ENDP

Search_substring PROC
  MOV  DX, OFFSET ENTER_STRING
  CALL PrintString
  CALL READ_STR

  MOV  ANS, 0
Search_loop_1:
  MOV  DI, OFFSET String
  MOV  SI, OFFSET MY_STR
  CMP  BYTE PTR [DI + ANS], '$'
  JE  End_loop_1
  ; SI 指向 MY_STR
  MOV  CX, 0
  ; CX 记录当前匹配的长度

  Seach_loop_2:
    MOV  BX, ANS
    ADD  BX, CX
    ; BX = ANS + CX, 即当前匹配位置（相对于 String）
    MOV  AL, BYTE PTR [DI + BX]
    MOV  BX, CX
    ; BX = CX, 即当前匹配位置（相对于 MY_STR）
    MOV  AH, BYTE PTR [SI + BX]
    CMP  AL, AH
    JNE Not_match
    CMP  AH, '$'
    JE  Matched
    INC  CX
    JMP Seach_loop_2

  Not_match:
    CMP AH, '$'
    JE  Matched
    CMP AL, '$'
    JE  End_loop_1
    INC  ANS
    JMP Search_loop_1
  Matched:
    PUSH AX
    MOV AX, ANS
    CALL Print_Number
    CALL  PrintSpace
    POP AX
    CMP AL, '$'
    JE  End_loop_1
    INC  ANS
    JMP Search_loop_1
End_loop_1:
  CALL PrintNewLine
  RET
Search_substring ENDP

UPDATE_STRING PROC
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
  MOV    DI, OFFSET String

  ; 拷贝内容到 String
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
  MOV    DX, OFFSET String
  CALL   PrintString
  CALL   PrintNewLine
  RET
UPDATE_STRING ENDP



READ_STR PROC
  ; 读取到 INPUT 缓冲区
  MOV    DX, OFFSET INPUT
  MOV    AH, 0AH
  INT    21H
    
  ; 重复输入的字符串作为确认
  ; CALL   PrintNewLine
  ; MOV    DX, OFFSET ALREADY_RESD
  ; CALL   PrintString

  MOV    SI, OFFSET INPUT + 1
  MOV    CX, [SI]
  INC    SI
  MOV    DI, OFFSET MY_STR

  ; 拷贝内容到 MY_STR
Copy_char_read:          
  MOV    AL, [SI]
  CMP    AL, 0DH
  JE     Meet_LF_read

  MOV    [DI], AL
  INC    DI

  INC    SI
  LOOP   Copy_char_read
    
Meet_LF_read:            
  MOV    BYTE PTR [DI], '$'
  ; CALL   PrintNewLine
  ; MOV    DX, OFFSET MY_STR
  ; CALL   PrintString
  CALL   PrintNewLine
  RET
READ_STR ENDP


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

PrintSpace PROC
	PUSH AX
	PUSH DX
	MOV AH, 2
	MOV DL, 20H
	INT 21H
	POP DX
	POP AX
	RET
PrintSpace ENDP

READ_NUM PROC 
  PUSH AX
  PUSH DX

BEGIN_READ:
  ; 读取到 INPUT 缓冲区
  MOV AH, 0AH
  MOV DX, OFFSET INPUT
  INT 21H

  ; 读取到的字符串转换为数字
  MOV SI, OFFSET INPUT + 2
  MOV AX, 0
  MOV BX, 10

  ; 检查是否为负数
  MOV AL, [SI]
  CMP AL, '-'
  JE NEGATIVE

POSITIVE:
  CALL ASCII_TO_INT
  JMP DONE

NEGATIVE:
  INC SI
  MOV NEGATIVE_FLAG, 1
  CALL ASCII_TO_INT
  JMP DONE

DONE:
  CMP ERROR_FLAG, 1
  JE ERROR_ECCURED
  JMP NO_ERROR

ERROR_ECCURED:
  ; 打印错误信息
  MOV DX, OFFSET ERROR
  CALL PrintString
  JMP BEGIN_READ

NO_ERROR:
  MOV AX, TMP_NUM
  CMP NEGATIVE_FLAG, 1
  JNE CONTINUE
  NEG AX
CONTINUE:
  MOV TMP_NUM, AX
  POP DX
  POP AX
  RET
READ_NUM ENDP




; 转换为数字
ASCII_TO_INT PROC
    PUSH AX
    PUSH BX
    XOR AX, AX                 
    XOR BX, BX     
    MOV ERROR_FLAG, 1            

NEXT_DIGIT:
    MOV BL, [SI]               ; 加载当前字符
    CMP BL, 0DH                
    JE S_DONE                    ; 跳转到结束处理
    MOV ERROR_FLAG, 0          ; 非空串，清除错误标志
    CMP BL, '0'                ; 检查是否为有效数字字符
    JB ERROR_DONE                 
    CMP BL, '9'
    JA ERROR_DONE                  

    SUB BL, '0'                
    MOV DX, 10                 
    MUL DX                     
    ADC AX, BX                 ; AX = AX * 10 + BX
    INC SI                     
    JMP NEXT_DIGIT            

ERROR_DONE:
    MOV ERROR_FLAG, 1
S_DONE:
    MOV TMP_NUM, AX
    POP BX
    POP AX
    RET
ASCII_TO_INT ENDP

CODE ENDS
END START