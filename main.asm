;predefined directives
SYS_EXIT  equ 1
SYS_READ  equ 3
SYS_WRITE equ 4
STDIN     equ 0
STDOUT    equ 1

;macros for printing
%macro print 2 
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

;macros for getting input
%macro read 2
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

section .data
    data_size_prompt db 'Enter the number of data: ', 0xa
    data_size_prompt_len equ $-data_size_prompt
    data_input_prompt db 'Enter the numbers: ', 0xa
    data_input_prompt_len equ $-data_input_prompt

section .bss
    data_size resd 2
    data times 100 resd 2

section .text
    global _start

_start:
    print data_size_prompt, data_size_prompt_len

    read data_size, 3

    print data_size, 2

    ;exit program
    mov eax, SYS_EXIT
    int 80h