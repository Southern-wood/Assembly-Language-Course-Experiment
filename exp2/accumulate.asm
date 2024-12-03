DATA SEGMENT
  MENU           DB "Type Number of Input, -1 to exit: $"
  PROMPT         DB "Please input Number $"
  ERROR          DB "Can not convert to number, please input again$"
  AGAIN          DB "Please input again:$"
  SUM_STR        DB "The sum of the numbers is:$"
  NOW_SUM        DB "Now the sum is:$"
  INPUT          DB 100 DUP ('?')
  NUM            DW 0
  TMP_NUM        DW 0
  SUM            DW 0
  ERROR_FLAG     DB 0
  NEGATIVE_FLAG  DB 0
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
    
  ; 读取用户输入

  CALL   READ_NUM
  CALL   PrintNewLine
  MOV    AX, TMP_NUM
  CMP    AX, -1
  JE     EXIT
  MOV    CX, TMP_NUM
  MOV    SUM, 0

; 计算和
CALC_SUM:
  MOV    DX, OFFSET PROMPT
  CALL   PrintString
  MOV    ERROR_FLAG, 0
  MOV    NEGATIVE_FLAG, 0
  CALL   READ_NUM
  CALL   PrintNewLine


  MOV    AX, TMP_NUM
  ADC    SUM, AX
  DEC    SUM                                                                                                                                                                                                                                                                                  
  
  MOV     DX, OFFSET NOW_SUM
  CALL   PrintString


  MOV    AX, SUM
  CALL   Print_Number
  CALL   PrintNewLine
  LOOP   CALC_SUM

; 打印和
  MOV    DX, OFFSET SUM_STR
  CALL   PrintString
  MOV    AX, SUM
  CALL   Print_Number
  CALL   PrintNewLine

EXIT:
  ; 退出程序
  MOV    AX, 4C00H
  INT    21H

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
 
CODE ENDS
END START