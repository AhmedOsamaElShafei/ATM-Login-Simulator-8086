#make_bin#  
include emu8086.inc


; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=0500h#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0500h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=1000h#	; same as loading segment
#ES=2000h#	; same as loading segment

; set stack
#SS=3000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#    


            ;set cx counter to 20 and setting starting id  
            
            MOV     CX,20 
            MOV     DX,10000
            
            ;loop 20 times to store ids from 10000 to 10020
            ;in memory locations from 1000:0000
            ;store passwords as the counter divided by 4 (int)
            ;in memory locations from 3000:0000
            
DATA:       MOV     AX,DX
            MOV     [DI],AX     
            MOV     [BP],CX  
            SHR     [BP],1      
            SHR     [BP],1 
            INC     DX
            ADD     BP,2
            ADD     DI,2
            LOOP    DATA    
        
            ;ask user to enter number less than 65536 to
            ;validate it is in range of 16 bits

START:      PRINTN  'PLEASE ENTER ID LESS THAN 65536'
            XOR     AX,AX
            XOR     BX,BX
            XOR     DX,DX
            MOV     AH,1
            MOV     CX,5
            MOV     DI,1000H
            
            ;changin the user input from ascii to hex number
            ;in memory location 1000:1200
            
INPUT:      XOR     AL,AL
            INT     21H
            SUB     AL,30H
            MOV     [DI],AL
            INC     DI
            LOOP    INPUT      
                            
            MOV     SI,1200H                
            MOV     [SI],0  
            MOV     [SI+1],0
            MOV     DI,1000H    
            MOV     AL,[DI]
            XOR     AH,AH
            MOV     BX,2710H   
            MUL     BX   
            JC      INVALID
            ADD     [SI],AX   
            JC      INVALID
            INC     DI     
            MOV     AL,[DI]
            XOR     AH,AH
            MOV     BX,3E8H   
            MUL     BX  
            JC      INVALID
            ADD     [SI],AX
            JC      INVALID
            INC     DI     
            MOV     AL,[DI]
            XOR     AH,AH
            MOV     BX,64H   
            MUL     BX     
            JC      INVALID
            ADD     [SI],AX
            JC      INVALID
            INC     DI     
            MOV     AL,[DI]
            XOR     AH,AH
            MOV     BX,0AH   
            MUL     BX     
            JC      INVALID
            ADD     [SI],AX
            JC      INVALID
            INC     DI     
            MOV     AL,[DI]
            XOR     AH,AH
            MOV     BX,1H   
            MUL     BX    
            JC      INVALID
            ADD     [SI],AX
            JC      INVALID     
            
            ;storing the id in bx 
            MOV     BX,[SI]    
            MOV     DI,0000H    
            
            ;searching for the id from memory locations 1000:0000
            ;if found we check the password
            ;else we print not found and ask for another id  
            
            MOV     CX,20
SEARCH_ID:  CMP     BX,[DI]
            JE      CORRECT_ID     
            ADD     DI,2     
            LOOP    SEARCH_ID
            JMP     NOT_FOUND        
            
            ;ask user for password less than 4 bits
            ;by the offset of the id in memory we lookup the relative password
            ;in the stack segment with same offset of id to ensure they belong
            ;to the same person
            ;if password matches we print logged in
            ;else we print incorrect and halt
             
PASSWORD:   PRINTN  ''
            PRINTN  'PLEASE ENTER PASSWORD'
            MOV     AH,1     
            XOR     AL,AL
            INT     21H
            SUB     AL,30H
            MOV     BL,AL 
            MOV     BP,DI  
            CMP     BL,[BP]
            JE      CORRECT_PASS       
            JMP     INCORRECT_PASS
            
            
            
            
            
INVALID:        PRINTN  ''
                PRINTN  'PLEASE ENTER NUMBER LESS THAN 65536'
                JMP     START            
             
CORRECT_ID:     PRINTN  ''
                PRINTN  'CORRECT ID!'    
                JMP     PASSWORD          
                
INCORRECT_PASS: PRINTN  ''
                PRINTN  'INCORRECT PASSWORD'
                JMP     FINIS               

CORRECT_PASS:   PRINTN  ''
                PRINTN  'USER LOGGED IN SUCCESSFULLY'  
                JMP     FINIS
                                                         

NOT_FOUND:      PRINTN  ''
                PRINTN  'ID NOT FOUND'     
                JMP     START                                                    

FINIS:          HLT
        
        



