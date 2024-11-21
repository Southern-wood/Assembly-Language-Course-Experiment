; Author:  Southern-wood
; Date:    2024-11-21
DATA SEGMENT
  MENU           DB "1. Convert string to lowercase.", 0AH
                 DB "2. Convert string to uppercase.", 0AH
                 DB "3. Smart converting.", 0AH
                 DB "4. Update String", 0AH
                 DB "5. Check if the string is a palindrome.", 0AH
                 DB "6. Show menu again.", 0AH
                 DB "7. Show current string again.", 0AH
                 DB "8. Exit program.", 0AH, "$"
  PALINDROME     DB "The string is a palindrome.$"
  NOT_PALINDROME DB "The string is not a palindrome.$"
  PROMPT         DB "Please enter the menu item number: $"
  NOW_STR        DB "Current string: $"
  ALREADY_RESD   DB "The string has been updated to: $"
  INPUT          DB 50 DUP ('?')
  LOWER          DB "Converted to lowercase: $"
  UPPER          DB "Converted to uppercase: $"
  _SMART          DB "Smart converting: $"
  MY_STR         DB "Hello, World$", 50 DUP (?)
  SPACE_FORWORD  DB 1
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
  JE     TO_LOWER
  CMP    AL, '2'
  JE     TO_UPPER
  CMP    AL, '3'
  JE     SMAET_CONVERT
  CMP    AL, '4'
  JE     UPDATE_STRING
  CMP    AL, '5'
  JE     IS_PARLINDROME
  CMP    AL, '6'
  JNE    skip_prompt
  MOV    DX, OFFSET MENU
  CALL   PrintString
  JMP    REPEAT
  skip_prompt:       
  CMP    AL, '7'
  JNE    skip_print_now_str
  MOV    DX, OFFSET NOW_STR
  CALL   PrintString
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT
skip_print_now_str: 
  CMP    AL, '8'
  JMP    EXIT

UPDATE_STRING:      
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


TO_UPPER:           
  JMP    _TO_UPPER

TO_LOWER:           
  JMP    _TO_LOWER

SMAET_CONVERT:
  JMP   _SMART_CONVERT

IS_PARLINDROME:     
  ; 检查字符串是否是回文
  MOV    SI, OFFSET MY_STR
  MOV    DI, OFFSET MY_STR
  MOV    CX, 0

  ; 获取字符串长度
Get_Length:                 
  MOV    AL, [DI]
  CMP    AL, '$'
  JE     End_String
  INC    DI
  INC    CX
  JMP    Get_Length
End_String:             

  ; 检查是否是回文
  MOV    BX, CX
  SHR    BX, 1
  MOV    SI, OFFSET MY_STR
  ADD    SI, CX
  DEC    SI
  MOV    DI, OFFSET MY_STR
  MOV    CX, BX

Checking_Palindrome:
  MOV    AL, [SI]
  CMP    AL, [DI]

  JNE    Check_Fail
  INC    DI
  DEC    SI
  LOOP   Checking_Palindrome
Check_Success:      
  MOV    DX, OFFSET PALINDROME
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT
Check_Fail:         
  MOV    DX, OFFSET NOT_PALINDROME
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT


_TO_LOWER:          
  ; 显示转换为小写
  MOV    DX, OFFSET LOWER
  CALL   PrintString
  ; 转换 MY_STR 为小写
  MOV    SI, OFFSET MY_STR
  MOV    CX, 0

  ; 循环直到字符串结束
Lower_Loop:         
  MOV    AL, [SI]
  CMP    AL, '$'
  JE     Lower_End
  CMP    AL, 'A'
  JB     Lower_Not_Ascii
  CMP    AL, 'Z'
  JA     Lower_Not_Ascii
  ADD    AL, 20H
  MOV    [SI], AL
Lower_Not_Ascii:    
  INC    SI
  INC    CX
  JMP    Lower_Loop
Lower_End:          
  CALL   PrintNewLine

  ; 打印转换后的字符串
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT

_TO_UPPER:          
  ; 显示转换为大写
  MOV    DX, OFFSET UPPER
  CALL   PrintString
  ; 转换 MY_STR 为大写
  MOV    SI, OFFSET MY_STR
  MOV    CX, 0

  ; 循环直到字符串结束
Upper_Loop:         
  MOV    AL, [SI]
  CMP    AL, '$'
  JE     Upper_End
  CMP    AL, 'a'
  JB     Upper_Not_Ascii
  CMP    AL, 'z'
  JA     Upper_Not_Ascii
  SUB    AL, 20H
  MOV    [SI], AL
Upper_Not_Ascii:    
  INC    SI
  INC    CX
  JMP    Upper_Loop
Upper_End:          
  CALL   PrintNewLine

  ; 打印转换后的字符串
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT

_SMART_CONVERT:
  ; 智能转换
  MOV    DX, OFFSET _SMART
  CALL   PrintString
  ; 智能转换 MY_STR
  MOV    SI, OFFSET MY_STR
  MOV    CX, 0
  MOV    SPACE_FORWORD, 1

  ; 循环直到字符串结束
Smate_Loop:         
  MOV    AL, [SI]
  CMP    AL, '$'
  JE     Smart_End
  CMP    SPACE_FORWORD, 1
  JNE    Not_Space_Forword
Is_Space_Forword:  
  CMP    AL, 'a'
  JB     No_Need_Convert
  CMP    AL, 'z'
  JA     No_Need_Convert
  SUB    AL, 20H
  MOV    [SI], AL
  JMP     No_Need_Convert
Not_Space_Forword:
  CMP    AL, 'A'
  JB     No_Need_Convert
  CMP    AL, 'Z'
  JA     No_Need_Convert
  ADD    AL, 20H
  MOV    [SI], AL
No_Need_Convert:
  CMP    AL, ' '
  JNE    unset_space_forword
set_space_forword:
  MOV    SPACE_FORWORD, 1
  JMP    skip_unset
unset_space_forword:
  MOV    SPACE_FORWORD, 0
skip_unset:
  INC    SI
  INC    CX
  JMP    Smate_Loop
Smart_End:
  CALL   PrintNewLine

  ; 打印转换后的字符串
  MOV    DX, OFFSET MY_STR
  CALL   PrintString
  CALL   PrintNewLine
  JMP    REPEAT

EXIT:               
  ; 退出程序
  MOV    AX, 4C00H
  INT    21H

  ; 打印字符串子程序
PrintString PROC
  PUSH   AX
  MOV    AH, 09H
  INT    21H
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

; 打印单个字符子程序
PrintChar PROC
  PUSH   AX

  MOV    AH, 02H
  INT    21H

  POP    AX
  RET
PrintChar ENDP

CODE ENDS
END START