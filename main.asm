SYS_EXIT    equ 1
SYS_READ    equ 3
SYS_WRITE   equ 4
STDIN       equ 0
STDOUT      equ 1

%include    'functions.asm'
%include    'atoi.asm'

section .data
    ip_prompt       db  "Enter a decimal number to be converted to binary: ", 0h
    binary_digits   db  32 dup('0')
    binary_len      dw  0

section .bss
    dec_input resb 32 

section .text
    global _start
    
_start:
    ;display input prompt
    mov eax, ip_prompt
    call sprint

    ;get user input for decimal
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, dec_input
    mov edx, 32
    int 80h

    ;convert ascii input to integer
    mov eax, dec_input
    call atoi

    ;set counter to 0
    mov ecx, 0


;convert decimal to binary
binary_conversion:
    ;divide input by 2
    xor edx, edx
    mov ebx, 2
    div ebx

    ;push remainder into the stack
    push edx

    ;increment counter
    inc ecx

    ;check if decimal is equal to 0
    cmp eax, 0

    ;continue to loop until dec is equal to 0
    jne binary_conversion


;pop all the remainders to display the binary result
pop_edx:
    pop eax
    call iprint
    dec ecx
    cmp ecx, 0
    jne pop_edx
    

    ;exit program
    call quit