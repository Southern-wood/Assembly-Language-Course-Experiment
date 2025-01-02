DATA SEGMENT
    STR1 DB 100, 0, 100 DUP(0)
    STR2 DB 100, 0, 100 DUP(0)
    CHOSE DB 0
    ANS DB 100 DUP(0)
    CTLF DB 0DH, 0AH, '$'
    STRINGA DB 'string a: $'
    STRINGB DB 'string b: $'
    TIPS4 DB ' ', 0DH, 0AH, '$'
    FIND_STRING DB '1: Find string b in string a.', 0DH, 0AH, '$'
    FIND_STRING_1 DB 'Find b in a, the position:$'
    INSERT_STRING DB '2: Insert string b to string a.', 0DH, 0AH, '$'
    INSERT_STRING_1 DB 'Please indicate where you want to insert:$'
    INSERT_STRING_2 DB 'Error: exceeded length$'
    INSERT_STRING_3 DB 'after insertion:$'
    DELETE DB '3: Delete string b from string a.', 0DH, 0AH, '$'
    DELETE_1 DB 'After delete:$'
    TIPS8 DB 'Please enter the option: $'
    TIPS9 DB '4: Update string', 0DH, 0AH, '$'
    TIPS9_1 DB 'Update string a:$'
    TIPS9_2 DB 'Update string b:$'
    CTLF0 DB '5: Exit', 0DH, 0AH, '$'
DATA ENDS

MY_STACK SEGMENT
    DW 128 DUP(0)
MY_STACK ENDS

CODE SEGMENT
start:
   ASSUME CS:CODE,DS:DATA,SS:MY_STACK
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
    MOV AX, MY_STACK
    MOV SS, AX
    
    LEA DX, STRINGA     
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR1    
    MOV AH, 0AH
    INT 21H
    
    LEA DX, CTLF    
    MOV AH, 09H
    INT 21H
    
    LEA DX, STRINGB     
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR2   
    MOV AH, 0AH
    INT 21H     
    
    LEA DX, CTLF   
    MOV AH, 09H
    INT 21H
    
    LEA DX, TIPS4    
    MOV AH, 09H
    INT 21H
    
    LEA DX, FIND_STRING    
    MOV AH, 09H
    INT 21H
    
    LEA DX, INSERT_STRING    
    MOV AH, 09H
    INT 21H
    
    LEA DX, DELETE   
    MOV AH, 09H
    INT 21H
    
    LEA DX, TIPS9    
    MOV AH, 09H
    INT 21H
    
    LEA DX, CTLF0   
    MOV AH, 09H
    INT 21H
    
    LEA DX, TIPS4    
    MOV AH, 09H
    INT 21H  
    
S_1:
    LEA DX, TIPS8   
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    MOV CHOSE, AL
    
    CMP AL, 31H
    JE op1      
    CMP AL, 32H
    JE op2          
    CMP AL, 33H
    JE op3          
    CMP AL, 34H
    JE op4
    CMP AL, 35H
    JE exit 
    
op1: 
    LEA DX, CTLF    
    MOV AH, 09H
    INT 21H

    LEA DX, FIND_STRING_1     
    MOV AH, 09H
    INT 21H
    
    MOV CL, STR2+1
    MOV CH, 0
    PUSH CX
    
    MOV SI, 2
    MOV DI, 0           
    LEA BX, STR1+2   
    
    MOV AL, STR1+1   
    
op1_1:
    MOV AH, [BX+DI]
    CMP AH, [STR2 + SI]
    JNE op1_2
    INC DI
    INC SI
    DEC CX
    CMP CX, 0
    JE op1_3
    JMP op1_1
    
op1_2:
    INC BX   
    DEC AL
    CMP AL, 0
    JE last  
    CMP AL, STR2+1 
    JB last
    MOV SI, 2
    MOV DI, 0
    POP CX
    PUSH CX
    JMP op1_1

    JMP skip_jump_section_1

op2:
    JMP op2_

op3:
    JMP op3_

op4:
    JMP op4_

exit:
    JMP exit_

last:
    JMP last_

skip_jump_section_1:


op1_3:
    MOV CX, BX        
    LEA AX, STR1+2
    SUB CX, AX
    INC CX
    
    CMP CX, 09H      
    JBE op1_6
  
    MOV DL, 0
    
op1_4:
    CMP CX, 09H  
    JBE op1_5
    INC DL        
    SUB CX, 0AH
      
    JMP op1_4
    
op1_5:
    ADD DL, 30H   
    MOV AH, 02H
    INT 21H  
    
op1_6:
    MOV DL, CL     
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    
    MOV DL, 20H  
    MOV AH, 02H
    INT 21H
    
    JMP op1_2
    
op2_:
    LEA DX, CTLF    
    MOV AH, 09H
    INT 21H
    
    LEA DX, INSERT_STRING_1    
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H      
    INT 21H
    MOV DL, AL
    SUB DL, 30H
    
    MOV BL, STR1+1   
    INC BL
    CMP DL, BL
    JA op2_error
    
    MOV SI, 2
    MOV DI, 0

    JMP skip_jump_section_2

op3_:
    JMP op3__

op4_:
    JMP op4__

exit_:
    JMP exit__

last_:
    JMP last__

skip_jump_section_2:

op2_1:
    DEC DL             
    CMP DL, 0
    JE op2_2
    MOV AL, [STR1+SI]
    MOV [ANS+DI], AL
    INC DI
    INC SI
    JMP op2_1
    
op2_2:
    PUSH SI
    MOV SI, 2
    MOV CL, STR2+1
    MOV CH, 0

op2_3:                      
    MOV AL, [STR2+SI ]
    MOV [ANS+DI], AL
    INC SI
    INC DI
    LOOP op2_3
    
    POP SI

op2_4:                    
    MOV BL, STR1+1
    ADD BL, 2
    MOV BH, 0
 
    CMP SI, BX
    JAE op2_5
    
    MOV AL, [STR1+SI]
    MOV [ANS+DI], AL
    INC SI
    INC DI
    JMP op2_4
    
    
op2_5:
    MOV SI, 0
    
    LEA DX, CTLF  
    MOV AH, 09H
    INT 21H  
    
    LEA DX, INSERT_STRING_3    
    MOV AH, 09H
    INT 21H  
    
    
op2_6:
    MOV DL, [ANS+SI]  
    MOV AH, 02H
    INT 21H
    INC SI
    
    CMP SI, DI
    JNE op2_6   
  
    JMP last 
    
op2_error: 
    LEA DX, INSERT_STRING_2  
    MOV AH, 09H
    INT 21H
             
             
op3__: 
    LEA DX, CTLF    
    MOV AH, 09H
    INT 21H

    LEA DX, DELETE_1    
    MOV AH, 09H
    INT 21H
    
    LEA BX, STR1+1    
    MOV CX, 0
    
op3_1:
    MOV SI, 2
    MOV DI, 0
    INC BX
    PUSH BX
    MOV AL, STR2+1      
    MOV AH, 0
    
    LEA DX, STR1+2
    MOV BL, STR1+1
    MOV BH, 0
    ADD DX, BX
    POP BX
    SUB DX, BX
    CMP DX, AX
    JB op3_4 

    JMP skip_jump_section_3

op4__:
    JMP op4___

exit__:
    JMP exit___

last__:
    JMP last___

skip_jump_section_3:
    
op3_2:
    MOV AL, [BX+DI]         
    MOV AH, [STR2+SI]
    INC DI
    INC SI
    CMP AH, AL 
    JNE op3_3
    MOV AL, STR2+1      
    MOV AH, 0
    CMP DI, AX
    JNE op3_2
    
    MOV AL, STR2+1
    DEC AL
    MOV AH, 0
    ADD BX, AX
    JMP op3_1
    
    
op3_3:
    MOV AL, [BX]
    MOV SI, CX
    MOV [ANS+SI], AL
    INC CX
    
    JMP op3_1
    
op3_4:
    LEA AX, STR1+2
    MOV DL, STR1+1
    MOV DH, 0
    ADD DX, AX
    
op3_5:
    CMP BX, DX
    JE op3_print
    MOV AL, [BX]
    MOV SI, CX
    MOV [ANS+SI], AL
    INC CX
    INC BX
    JMP op3_5
         
op3_print:
    MOV SI, 0
    
op3_6:
    MOV DL, [ANS+SI]
    MOV AH, 02H
    INT 21H
    INC SI
    CMP SI, CX
    JE last___
    JNE op3_6

    JMP skip_jump_section_4

exit___:
    JMP exit____

last___:
    JMP last____

skip_jump_section_4:

op4___:
    LEA DX, CTLF   
    MOV AH, 09H
    INT 21H

    LEA DX, STRINGA     
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR1    
    MOV AH, 0AH
    INT 21H
    
    LEA DX, CTLF    
    MOV AH, 09H
    INT 21H
    
    LEA DX, STRINGB     
    MOV AH, 09H
    INT 21H
    
    LEA DX, STR2   
    MOV AH, 0AH
    INT 21H     
    
    LEA DX, CTLF   
    MOV AH, 09H
    INT 21H

; op4_1:
;     MOV DL, [BX]
;     MOV AH, 02H
;     INT 21H
    
;     DEC BX
;     LOOP op4_1
    
;     LEA DX, CTLF    
;     MOV AH, 09H
;     INT 21H
    
;     LEA DX, TIPS9_2    
;     MOV AH, 09H
;     INT 21H
    
    
; op4_2:
;     LEA BX, STR2+2
;     MOV AL, STR2+1
;     MOV CL, AL
;     MOV AH, 0
;     ADD BX, AX
;     DEC BX
;     MOV CH, 0
    
; op4_3:
;     MOV DL, [BX]
;     MOV AH, 02H
;     INT 21H
    
;     DEC BX
;     LOOP op4_3
    ; JMP last

last____:
    LEA DX, CTLF 
    MOV AH, 09H
    INT 21H
    JMP S_1

exit____:   
    MOV AH, 4CH
    INT 21H
  
CODE ENDS

end start 
