SYS_EXIT    equ 1
SYS_READ    equ 3
SYS_WRITE   equ 4
STDIN       equ 0
STDOUT      equ 1

%include    'functions.asm'
%include    'atoi.asm'

section .data
    instruction_prompt     db  `Welcome to Binary to Decimal & Decimal to Binary Converter! \nPlease select an operation to perform:\nEnter 1 - Convert Binary to Decimal\nEnter 2 - Convert Decimal to binary`, 0h
    operation_prompt       db  `Select Operation: `, 0h
    dec_prompt             db  "Enter a decimal number ranging from (-2,147,483,648 to 2,147,483,647) to be converted to binary: ", 0h
    bin_prompt             db  "Enter a binary number (maximum of 32-bits) to be converted to a decimal number: ", 0h    
    dec_result             dw   0

section .bss
    op_input  resb 2
    dec_input resb 32       ; reserve 32 bits for decimal input
    bin_input resb 8      ; reserve 32 bits for binary input

section .text
    global _start
    
_start:
    ; display program instruction
    mov     eax, instruction_prompt
    call    sprintLF

    ; display input operation prompt
    mov     eax, operation_prompt
    call    sprint

    ; get user input for operation
    mov     eax, 3
    mov     ebx, 0
    mov     ecx, op_input
    mov     edx, 2
    int     80h

    ; check what operation to perform
    cmp     byte [op_input], '1'
    je      get_binary_input
    jne     get_decimal_input



; -----------------------------------------------------------------
; FUNCTIONS FOR CONVERTING BINARY TO DECIMAL

; function to get binary input
get_binary_input:
    ; display input binary prompt 
    mov     eax, bin_prompt
    call    sprint

    ; get user input for binary
    mov     eax, SYS_READ
    mov     ebx, STDIN
    mov     ecx, bin_input
    mov     edx, 32
    int     80h
    
    mov     eax, bin_input
    call    slen
    mov     ecx, eax
    mov     eax, bin_input
    call    atoi

extract_digits:
    xor edx, edx
    mov ebx, 10
    div ebx

    cmp edx, 1
    je  compute_bit_value
    jne skip_zero_bit

    compute_bit_value:
        push eax
        mov eax, 2
        call iprint
        pop eax

    skip_zero_bit:

    cmp eax, 0
    jg extract_digits
    jle exit_program




; END OF CONVERTING BINARY TO DECIMAL
; -----------------------------------------------------------------



; -----------------------------------------------------------------
; FUNCTIONS FOR CONVERTING DECIMAL TO BINARY

; function to get decimal input and calls convert to binary function
get_decimal_input:
    ; display input decimal prompt
    mov     eax, dec_prompt
    call    sprint

    ; get user input for decimal
    mov     eax, SYS_READ
    mov     ebx, STDIN
    mov     ecx, dec_input
    mov     edx, 32
    int     80h

    ; convert ascii input to integer
    mov     eax, dec_input
    call    atoi

    ; set counter to 0
    mov     ecx, 0
    call    convert_to_bin


; function to convert decimal to binary using continuous division method
convert_to_bin:
    xor     edx, edx        ; clear edx for storing remainder
    mov     ebx, 2          ; set divisor to 2
    div     ebx             ; divide decimal input by 2
    push    edx             ; push remainder onto the stack
    inc     ecx             ; increment counter
    cmp     eax, 0          ; check if decimal input is equal to 0
    je      pop_remainders  ; display all the remainders when decimal reaches 0
    jne     convert_to_bin  ; continue to loop until decimal input is equal to 0


; function that pop all the remainders to display the binary result in reverse order
pop_remainders:
    pop     eax             ; restore remainder from the edx that we pushed onto the stack
    call    iprint          ; print remainder as integer
    dec     ecx             ; decrement counter
    cmp     ecx, 0          ; check if counter is not equal to 0
    je      exit_program    ; exit program when all the remainders are popped
    jne     pop_remainders  ; continue to pop all the remainders until counter is 0
    
; END OF CONVERTING DECIMAL TO BINARY
; -----------------------------------------------------------------


; program exit
exit_program:
    call quit