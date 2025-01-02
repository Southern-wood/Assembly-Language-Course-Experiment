DATA SEGMENT
  MENU           DB "1. Set extra base (2 ~ 16 supported only)", 0AH
                 DB "2. Into convert loop, input any negative number to exit", 0AH
                 DB "3. Exit", 0AH, "$"
  PROMPT_1       DB "Please input the extra base: $"
  PROMPT_2       DB " is not a valid base number, please input again: $"
  ERROR          DB "Can not convert to number, please input again: $"
  SET_BASE       DB "The extra base is set to: $"
  DECIMAL        DB "Decimal: $"
  BINARY         DB "Binary: $"
  BINARY_SUFFIX  DB "B$"
  HEX            DB "Hex: $"
  HEX_SUFFIX     DB "H$"
  EXTR_BASE      DB "Extra Base $"
  ADDD           DB " : $"
  NOW_BASE       DW 0
  INPUT          DB 100 DUP ('?')
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
  ; ; 设置数据段
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
  JE  SetExtraBase
  CMP AL, '2'
  JE  ConvertLoop
  CMP AL, '3'
exit:
  JE  EXIT

SetExtraBase:
  ; 打印提示
  MOV    DX, OFFSET PROMPT_1
  CALL   PrintString
  ; 读取用户输入
read:
  CALL   READ_NUM
  MOV    AX, TMP_NUM
  MOV    BASE, AX
  CALL   PrintNewLine
  CMP    BASE, 2
  JL     re_read
  CMP    BASE, 16
  JG     re_read
  MOV    DX, OFFSET SET_BASE
  CALL   PrintString
  MOV    AX, BASE
  CALL   Print_Number
  CALL   PrintNewLine
  JMP    repeat

re_read:
  MOV   AX, BASE
  CALL  Print_Number
  MOV   DX, OFFSET PROMPT_2
  CALL  PrintString
  JMP   read

ConvertLoop:
  ; 读取一个字符
  CALL READ_NUM_B
  CALL  PrintNewLine
  CMP NEGATIVE_FLAG, 1
  JE  repeat

  MOV BX, TMP_NUM
  MOV NUM, BX
  
  MOV DX, OFFSET DECIMAL
  CALL PrintString
  XOR AX, AX
  MOV AX, NUM
  CALL Print_Number
  CALL PrintNewLine

  MOV DX, OFFSET BINARY
  CALL PrintString
  XOR AX, AX
  MOV AX, NUM
  MOV BX, BASE
  MOV TMP_NUM, BX
  MOV BASE, 2
  CALL Print_Number_Base
  MOV DX, OFFSET BINARY_SUFFIX
  CALL PrintString
  CALL PrintNewLine

  MOV DX, OFFSET HEX
  CALL PrintString
  XOR AX, AX
  MOV AX, NUM
  MOV BASE, 16
  CALL Print_Number_Base
  MOV DX, OFFSET HEX_SUFFIX
  CALL PrintString
  CALL PrintNewLine

  MOV DX, OFFSET EXTR_BASE
  CALL PrintString
  MOV BX, TMP_NUM
  MOV BASE, BX
  MOV AX, BASE
  CALL Print_Number
  MOV DX, OFFSET ADDD
  CALL PrintString
  XOR AX, AX
  MOV AX, NUM
  CALL Print_Number_Base
  CALL PrintNewLine

  JMP ConvertLoop




Print_Number PROC
; 打印 AX 中的数字
    PUSH AX
    PUSH CX

    MOV CX, 0
    MOV BX, 10

    CMP AX, 0
    JGE divid_loop
    MOV BX, AX
    MOV DL, '-'
    MOV AH, 2
    INT 21H
    MOV AX, BX
    NEG AX
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
    POP CX
    POP AX
    RET
Print_Number ENDP


READ_NUM PROC 
  PUSH AX
  PUSH DX
  MOV ERROR_FLAG, 0
  MOV NEGATIVE_FLAG, 0

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
  CALL PrintNewLine
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


READ_NUM_B PROC 
  PUSH AX
  PUSH DX
  MOV ERROR_FLAG, 0
  MOV NEGATIVE_FLAG, 0

BEGIN_READ_B:
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
  JE NEGATIVE_B

POSITIVE_B:
  CALL ASCII_TO_INT_B
  JMP DONE_B

NEGATIVE_B:
  INC SI
  MOV NEGATIVE_FLAG, 1
  CALL ASCII_TO_INT
  JMP DONE_B

DONE_B:
  CMP ERROR_FLAG, 1
  JE ERROR_ECCURED_B
  JMP NO_ERROR_B

ERROR_ECCURED_B:
  ; 打印错误信息
  CALL PrintNewLine
  MOV DX, OFFSET ERROR
  CALL PrintString
  JMP BEGIN_READ_B

NO_ERROR_B:
  MOV AX, TMP_NUM
  CMP NEGATIVE_FLAG, 1
  JNE CONTINUE_B
  NEG AX
CONTINUE_B:
  MOV TMP_NUM, AX
  POP DX
  POP AX
  RET
READ_NUM_B ENDP


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

Print_Number_Base PROC
; 打印 AX 中的数字
    PUSH AX
    PUSH CX

    MOV CX, 0
    MOV BX, BASE

    CMP AX, 0
    JGE divid_loop_Base
    MOV BX, AX
    MOV DL, '-'
    MOV AH, 2
    INT 21H
    MOV AX, BX
    NEG AX
    MOV BX, 10


divid_loop_Base:
    XOR DX, DX
    DIV BX
    ; 余数入栈
    PUSH DX
    INC CX
    ; 检查商是否为 0
    CMP AX, 0
    JE  Print_Digit_Base
    JMP divid_loop_Base
Print_Digit_Base:
    ; 从栈中取出数字并打印
    POP DX
    CMP DL, 9
    JA HEX_NUM
    ADD DL, '0'
    JMP SKIP_HEX_NUM
HEX_NUM:
    ADD DL, 'A' - 10    
SKIP_HEX_NUM:
    MOV AH, 2
    INT 21H
    LOOP Print_Digit_Base
Print_End_Base:    
    POP CX
    POP AX
    RET
Print_Number_Base ENDP

; 转换为数字(十进制）
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



; 转换为数字(二进制）
ASCII_TO_INT_B PROC
    PUSH AX
    PUSH BX
    XOR AX, AX                 
    XOR BX, BX     
    MOV ERROR_FLAG, 1            

NEXT_DIGIT_B:
    MOV BL, [SI]               ; 加载当前字符
    CMP BL, 0DH                
    JE S_DONE_B                    ; 跳转到结束处理
    MOV ERROR_FLAG, 0          ; 非空串，清除错误标志
    CMP BL, '0'                ; 检查是否为有效数字字符
    JB ERROR_DONE_B                  
    CMP BL, '2'
    JA ERROR_DONE_B                  

    SUB BL, '0'                
    MOV DX, 2                 
    MUL DX                     
    ADC AX, BX                 ; AX = AX * 2 + BX
    INC SI                     
    JMP NEXT_DIGIT_B            

ERROR_DONE_B:
    MOV ERROR_FLAG, 1
S_DONE_B:
    MOV TMP_NUM, AX
    POP BX
    POP AX
    RET
ASCII_TO_INT_B ENDP

CODE ENDS
END START