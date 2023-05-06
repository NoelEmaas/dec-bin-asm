%macro print_str 1
    mov     eax, %1     ; move data to be printed to eax
    call    sprint      ; print message prompt which is stored in eax
%endmacro

%macro print_int 1
    mov     eax, %1     ; move data to be printed to eax
    call    iprint      ; print message prompt as an integer which is stored in eax
%endmacro

%macro read_input 2
    mov     eax, 3      ; invoke SYS_READ (kernel opcode 3)
    mov     ebx, 0      ; read from the STDIN file
    mov     ecx, %1     ; reserved space to store operation input
    mov     edx, %2     ; number of bytes to read
    int     80h         ; call the SYS_READ function to read input
%endmacro

; include printing functions
%include    'functions.asm'

; include atoi function
%include    'atoi.asm'

section .data
    invalid_op_prompt      db  `Invalid Operation!\n`, 0h
    instruction_prompt     db  `Welcome to Binary to Decimal & Decimal to Binary Converter! \nPlease select an operation to perform:\nEnter 1 - Convert Binary to Decimal\nEnter 2 - Convert Decimal to binary\n`, 0h
    operation_prompt       db  `Select Operation: `, 0h
    dec_prompt             db  "Enter a decimal number (maximum of 2,147,483,647) to be converted to binary: ", 0h
    bin_prompt             db  "Enter a binary number (maximum of 10-bits) to be converted to a decimal number: ", 0h    
    bin_result_prompt      db  "The binary form of ", 0h
    dec_result_prompt      db  "The decimal form of ", 0h
    new_line               db  `\n`, 0h
    is                     db  " is ", 0h


section .bss  
    op_input    resb 2
    dec_input   resb 32     
    bin_input   resb 32    
    dec_result  resb 32

section .text
    global _start
    
_start:
    print_str   instruction_prompt      ; display instruction prompt
    print_str   operation_prompt        ; display operation input prompt
    read_input  op_input, 2             ; read operation input from user

    cmp     byte [op_input], '1'        ; compare op_input to 1
    je      get_binary_input            ; if op_input = 1 then perform binary to decimal conversion

    cmp     byte [op_input], '2'        ; compare op_input to 2
    je      get_decimal_input           ; if op_input = 1 then perform decimal to binary conversion

    jne     invalid_operation           ; if input is not equal to 1 or 2, then call invalid operation function


invalid_operation:
    print_str   invalid_op_prompt       ; print invalid operation prompt
    call        exit_program            ; exir program


; Implemented algorithm for converting binary to decimal:
; 1. Program extracts every digit starting from the LSB by dividing the binary integer by 10 and getting its remainder. reference: https://stackoverflow.com/a/3389287/21801565
; 2. After extracting the current digit, we then compare if it is 0 or 1
;   - if bit is 0 then we ignore it and continue to extract next digit
;   - if bit is 1 then we compute its positional value by 2^ecx (ecx is the counter register which keeps track the current bit position)
; 3. After computing the positional value, we then add it to the current value of dec_result
; 4. Then we display the value of dec_result which contains the sum of all the positional values with bit value of 1.

get_binary_input:
    print_str bin_prompt                ; display binary input prompt
    read_input  bin_input, 32           ; read binary input frm user

    mov     ecx, 0                      ; set counter to 0
    mov     eax, bin_input              ; mov the data that needs to be converted to integer to eax
    call    atoi                        ; convert whatever data inside the eax to integer


convert_to_dec:
    xor     edx, edx                    ; clear edx for storing remainder
    mov     ebx, 10                     ; set ebx (divisor) to 10
    div     ebx                         ; divide eax to ebx

    cmp     edx, 1                      ; compare remainder to 1
    je      get_pos_value               ; if current bit is 1, then get its positional value
    jne     skip_zero_bit               ; if current bit is zero, then do nothing

get_pos_value:
    push    eax                         ; preserve eax on the stack to be restored after function runs
    push    ecx                         ; preserve ecx on the stack to be restored after function runs

    cmp     ecx, 0                      ; compare ecx is to 0    
    je      set_pos_value_1             ; if ecx == 0, then go to set_pos_value_1 function

    cmp     ecx, 1                      ; compare ecx is to 1
    je      set_pos_value_2             ; if ecx == 1, then go to set_pos_value_2 function
    jg      compute_pos_value           ; if ecx > 1, then go to compute_pos_value function

set_pos_value_1:
    mov     eax, 1                      ; set positional value to 1
    jmp     add_pos_value               ; go to add_pos_value function

set_pos_value_2:
    mov     eax, 2                      ; set positional value to 2
    jmp     add_pos_value               ; go to add_pos_value function

compute_pos_value:
    mov     eax, 2                      ; set eax to 2 since we are going to compute 2^ecx
    call    pow                         ; compute for the positional value
    jmp     add_pos_value               ; go to add_pos_value function after computation

pow:
    mov     ebx, 2                      ; set multiplier to 2
    mul     ebx                         ; (eax * ebx) multiply 2 to whatever the current value of eax
    dec     ecx                         ; decrement counter
    cmp     ecx, 1                      ; compare counter to 1
    jg      pow                         ; continue to to loop until counter is greater than 1
    ret                                 ; return to caller function when finished
      
add_pos_value:
    mov     ebx, eax                    ; mov the current bit value to ebx
    mov     eax, [dec_result]           ; mov the value the current total decimal value to eax
    add     eax, ebx                    ; add eax to ebx
    mov     [dec_result], eax           ; mov the sum to dec_result
    pop     ecx                         ; restore ecx from the value we pushed onto the stack at the start
    pop     eax                         ; restore eax from the value we pushed onto the stack at the start

skip_zero_bit:                          ; skip to this part and do nothing when bit is 0
 
    inc     ecx                         ; increment counter
    cmp     eax, 0                      ; check if it already extracted all bits in the binary
    jg      convert_to_dec              ; continue to loop until it extracted all bits in the binary
    jle     display_dec_result              ; diplay result when finished

display_dec_result:
    print_str    dec_result_prompt      ; display result prompt
    mov          eax, bin_input         
    call         atoi                   ; convert bin_input to integer to remove the '\n' in the string version of bin_input
    call         iprint                 ; print bin_input
    print_str    is                     ; print "is"
    print_int    [dec_result]           ; print converted binary to decimal
    print_str    new_line               ; print new line
    call         exit_program           ; exit program




; Implemented algorithm for converting decimal to binary:
; This Program uses continuous division method to convert decimal to binary
; 1. The program divides the decimal to 2 and get its remainder
; 2. We push all the ramainder onto the stack until the decimal value reaches 0
; 3. After getting all the remainders, we then pop the remainders inside the stack one by one to
; 4. After popping all the remainders, it will display the binary version of the decimal number

get_decimal_input:
    print_str   dec_prompt              ; display input decimal prompt
    read_input  dec_input, 32           ; read decimal input from user

    mov     eax, dec_input              ; mov the data that needs to be converted to integer to eax
    call    atoi                        ; convert whatever data inside the eax to integer
    mov     ecx, 0                      ; set counter to 0


convert_to_bin:
    xor     edx, edx                    ; clear edx for storing remainder
    mov     ebx, 2                      ; set divisor to 2
    div     ebx                         ; divide decimal input by 2
    push    edx                         ; push remainder onto the stack
    inc     ecx                         ; increment counter
    cmp     eax, 0                      ; check if decimal input is equal to 0
    jne     convert_to_bin              ; continue to loop until decimal input is equal to 0

display_bin_result:
    print_str   bin_result_prompt       ; display result prompt
    mov         eax, dec_input          
    call        atoi                    ; convert dec_input to integer to remove the '\n' in the string version of bin_input
    call        iprint                  ; print dec_input
    print_str   is                      ; print "is"

pop_remainders:
    pop     eax                         ; restore remainder from the edx that we pushed onto the stack
    call    iprint                      ; print remainder as integer
    dec     ecx                         ; decrement counter
    cmp     ecx, 0                      ; check if counter is not equal to 0
    jne     pop_remainders              ; continue to pop all the remainders until counter is 0
    
    print_str new_line                  ; print new line after displaying result
    call      exit_program              ; exit program when all the remainders are popped    

; program exit
exit_program:
    call quit
