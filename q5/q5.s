.data
    filename:   .string "input.txt"
    mode:       .string "r"             # read mode string required for fopen
    fmt_out:    .string "%s\n"          # format string for printf
    buffer:     .space 1048576  

.text
.globl main

main:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)                # we will use s0 to hold the file pointer

    la a0, filename             # arg 1: filename
    la a1, mode                 # arg 2: "r" (read mode)
    call fopen
    addi s0, a0,0                   # save file pointer in s0

    la a0, buffer               # arg 1 pointer to destination buffer
    li a1, 1                    # arg 2 size of each element (1 byte)
    li a2, 1048576              # arg 3 maximum number of elements to read
    addi a3, s0,0                   # arg 4 file pointer
    call fread

    addi a0, s0,0                   # arg 1: file pointer
    call fclose

    la t0, buffer               # t0 = left pointer
    la t1, buffer               # t1 = right pointer

find_end_loop:
    lbu t2, 0(t1)               # load character at right pointer
    
    beq t2,x0, end_found          # break if null terminator
    li t6, 10
    beq t2, t6, end_found       # break if newline (\n)
    
    addi t1, t1, 1              # increment right pointer
    j find_end_loop

end_found:
    addi t1, t1, -1             # step back 1 to point to the actual last letter
    li t3, 1                    # t3 (check bit) = 1 (true)

check_loop:
    bge t0, t1, end_check       # if left >= right, break checking loop

    lbu t4, 0(t0)               # load left character
    lbu t5, 0(t1)               # load right character

    beq t4, t5, chars_match     # if they match, continue
    li t3, 0                    # difference found -> check bit = 0 (false)
    j end_check                 # break the loop

chars_match:
    addi t0, t0, 1              # move left pointer right
    addi t1, t1, -1             # move right pointer left
    j check_loop

end_check:
    beq t3,x0, print_no           # if check bit is 0, jump to print "no"

print_yes:
    addi sp, sp, -16            
    li t6, 89                   # ascii 'Y'
    sb t6, 0(sp)
    li t6, 101                  # ascii 'e'
    sb t6, 1(sp)
    li t6, 115                  # ascii 's'
    sb t6, 2(sp)
    li t6, 0                    # ascii '\0'
    sb t6, 3(sp)
    
    j do_print                  # jump to print

print_no:
    addi sp, sp, -16            
    li t6, 78                   # ascii 'N'
    sb t6, 0(sp)
    li t6, 111                  # ascii 'o'
    sb t6, 1(sp)
    li t6, 0                    # ascii '\0'
    sb t6, 2(sp)

do_print:
    la a0, fmt_out              # arg 1 "%s\n"
    addi a1, sp,0                   # arg 2 stack pointer
    call printf                 # call printf
    
    addi sp, sp, 16             # clean up

exit:
    li a0, 0                    # return 0 from main
    ld s0, 0(sp)                # restore s0
    ld ra, 8(sp)                # restore return address
    addi sp, sp, 16             # restore original stack frame
    ret
