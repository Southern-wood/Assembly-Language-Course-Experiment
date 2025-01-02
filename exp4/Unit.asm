DATA SEGMENT
    STRA DB 100, 0, 100 DUP(0)
    STRB DB 100, 0, 100 DUP(0)
    TIPS1 DB 'Please enter String A:$'
    TIPS2 DB 'Please enter String B:$'
    TIPS3 DB 0DH, 0AH, '$'
    TIPS4 DB 'The intersection: $'
    TIPS5 DB 'The Union: $'
    TIPS6 DB 'The difference set: $'
    ANS DB 100 DUP(0)
DATA ENDS

MY_STACK SEGMENT
    DW 100 DUP(0)
MY_STACK ENDS

CODE SEGMENT

print_space PROC
    push ax
    push dx
    mov ah, 2
    mov dl, ' '
    int 21h
    pop dx
    pop ax
    ret
print_space ENDP

start:
    ASSUME CS:CODE, DS:DATA, SS:MY_STACK
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
    MOV AX, STACK
    MOV SS, AX  
    
    
    LEA DX, TIPS1 ;提示用户输入数组A
    MOV AH, 09H
    INT 21H    
    
    LEA DX, STRA ;提示用户输入字符串1
    MOV AH, 0AH
    INT 21H
    
    LEA DX, TIPS3 ;输出回车换行符
    MOV AH, 09H
    INT 21H 
    
    
    LEA DX, TIPS2 ;提示用户输入数组A
    MOV AH, 09H
    INT 21H    
    
    LEA DX, STRB ;提示用户输入字符串1
    MOV AH, 0AH
    INT 21H
    
    LEA DX, TIPS3 ;输出回车换行符
    MOV AH, 09H                                                                  
    INT 21H
    
op1: ;计算交集
    MOV SI, 0
    MOV DI, 0 ;
    LEA BX, ANS ;得到结果字符串的首地址
   
op1_2:
    MOV AL, [STRA+SI+2] ;取出字符串StrA中的一个字符
    MOV AH, [STRB+DI+2] ;取出字符串StrB中的一个字符
    INC DI
    CMP AL, AH ;判断两个字符是否相等
    JE op1_4
    MOV CL, STRB+1 ;判断字符串StrB是否已经遍历完
    MOV CH, 0
    CMP CX, DI
    JE op1_3               
    JMP op1_2
    
op1_3: ;遍历字符串StrA中的下一个字符
    INC SI
    MOV DI, 0
    MOV CL, STRA+1 ;判断字符串StrA是否已经遍历完
    MOV CH, 0
    CMP CX, SI
    JNE op1_2
    JMP op1_last 

op1_4:
    LEA DI, ANS
    
    
op1_5:
    CMP DI, BX
    JE op1_6
    MOV AL, [DI]
    MOV AH, [STRA+SI+2]
    CMP AL, AH
    JE op1_3
    INC DI
    JMP op1_5  
             
op1_6:
    MOV AL, [STRA+SI+2]
    MOV [BX], AL
    INC BX
    JMP op1_3
    
op1_last:
    MOV CX, BX
    LEA BX, ANS
    SUB CX, BX
    
    LEA DX, TIPS4 ;提示用户将要输出A和B的交集
    MOV AH, 09H
    INT 21H     
    
op1_last1:
    CMP CX, 0
    JE op2
    MOV DL, [BX]
    INC BX
    MOV AH, 02H
    INT 21H
    call print_space
    DEC CX
    JMP op1_last1
    
    
op2:
    LEA DX, TIPS3 ;输出回车换行符
    MOV AH, 09H                                                                  
    INT 21H
    
    MOV SI, 0 ;保存结果字符串的位置
    MOV DI, 0 ;保存A的位置
 
    MOV CL, STRA+1
    MOV CH, 0
    
op2_1:
    CMP CX, 0 ;判断A是否已经遍历完
    JE op2_5 
    LEA BX, ANS
    MOV DX, BX
    ADD DX, SI 
    
op2_2:  
    CMP BX, DX ;循环遍历判断该字符是否已经出现在结果中
    JE op2_3 
    MOV AL, [BX]
    INC BX
    MOV AH, [STRA+2+DI]
    CMP AH, AL
    JE op2_4
    JNE op2_2
    
op2_3: ;没有在结果中遍历到相同的字符，把该字符加入到结果中
    MOV AL, [STRA+2+DI]
    MOV [ANS+SI], AL
    INC SI
    INC DI
    DEC CX
    JMP op2_1

op2_4: ;在结果中遍历到相同的字符，把该字符加入到结果中
    INC DI
    DEC CX
    JMP op2_1
    
op2_5:
    MOV CL, STRB+1 ;把B中的内容加入结果中
    MOV CH, 0
    MOV DI, 0
    
op2_6:
    CMP CX, 0 ;判断B中的内容是否已经遍历完
    JE op2_last
    LEA BX, ANS
    MOV DX, BX
    ADD DX, SI
    
op2_7:
    CMP BX, DX ;循环比较该字符是否已经出现在结果中
    JE op2_8 
    MOV AL, [BX]
    INC BX
    MOV AH, [STRB+2+DI]
    CMP AH, AL
    JE op2_9
    JNE op2_7
    
op2_8:
    MOV AL, [STRB+2+DI] ;将该字符加入到结果中
    MOV [ANS+SI], AL
    INC SI
    INC DI
    DEC CX
    JMP op2_6


op2_9:
    INC DI
    DEC CX
    JMP op2_6
    
op2_last:
    LEA DX, TIPS5 ;提示用户将要输出A和B的交集
    MOV AH, 09H
    INT 21H
    
    MOV CX, SI
    MOV SI, 0     
    
op2_last1: ;输出最终的并集
    CMP SI, CX
    JE op3
    MOV DL, [ANS+SI]
    MOV AH, 02H
    INT 21H
    call print_space
    INC SI
    JMP op2_last1


op3: ;输出A-B
    MOV SI, 0 ;记录数组A的字符位置
    LEA BX, ANS ;得到结果字符串的首地址
    
op3_1:
    MOV DI, 0
    MOV AL, STRA+1
    MOV AH, 0
    CMP AX, SI
    JE op3_last
     
op3_2: ;在数组B中查找是否出现数组A对应的字符
    MOV AL, STRB+1
    MOV AH, 0
    CMP AX, DI
    JE op3_3
    MOV AL, [STRB+DI+2]
    INC DI
    MOV AH, [STRA+SI+2]
    CMP AH, AL
    JE op3_6
    JMP op3_2


op3_3: ;在数组B中没有找到数组A对应的字符，此时应该检查结果中是否已经出现过
    MOV AX, BX
    LEA DX, ANS
    SUB AX, DX
    MOV DI, 0

op3_4:
    CMP AX, 0 ;在结果中遍历是否已经出现过该字符
    JE op3_5
    DEC AX
    MOV CL, [ANS+DI]
    INC DI
    MOV CH, [STRA+2+SI]
    CMP CH, CL
    JE  op3_6 
    JMP op3_4
    
op3_5:
    MOV AL, [STRA+2+SI] ;在结果中加入A中的字符
    MOV [BX], AL 
    INC BX

op3_6:
    INC SI
    JMP op3_1
    
op3_last:
    LEA DX, TIPS3 ;提示用户输入数组A
    MOV AH, 09H
    INT 21H
    
    LEA DX, TIPS6 ;提示用户输入数组A
    MOV AH, 09H
    INT 21H
    
    MOV CX, BX
    LEA BX, ANS

op3_last1: ;循环输出结果中的所有内容
    CMP BX, CX
    JE LAST
    MOV DL, [BX]
    MOV AH, 02H
    INT 21H
    call print_space
    INC BX
    JMP op3_last1
       
    
LAST:
    LEA DX, TIPS3 ;输出回车换行符
    MOV AH, 09H
    INT 21H      

exit:   
    MOV AH, 4CH
    INT 21H
             
CODE ENDS

end start