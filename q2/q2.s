.data
fmt_space: .string "%lld "
fmt_newline: .string "%lld\n"

.text
.globl main

# main(int argc, char** argv)
# a0 = argc
# a1 = argv

main:

    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)
    sd s1, 56(sp)
    sd s2, 48(sp)
    sd s3, 40(sp)
    sd s4, 32(sp)
    sd s5, 24(sp)
    sd s6, 16(sp)
    sd s7, 8(sp)

    # s0 = n (number of elements = argc-1)
    addi s0, a0, -1
    addi s1, a1 ,0               # s1 = argv (char**)

    # allocate memory for arr result and stack (n*8 bytes each for 64 bit)
    slli t0, s0, 3          # t0 = n*8
    
    addi a0, t0 ,0
    call malloc
    addi s2, a0 ,0               # s2 = int*arr

    slli t0, s0, 3
    addi a0, t0 ,0
    call malloc
    addi s3, a0 ,0               # s3 = int*result

    slli t0, s0, 3
    addi a0, t0 ,0
    call malloc
    addi s4, a0 ,0               # s4 = int*stack

    # parse command line arguments into arr
    li s6, 1                # argv_index = 1
    li s7, 0                # arr_index = 0
parse_loop:
    bgt s6, s0, parse_done
    
    slli t0, s6, 3          # argv + (argv_index*8)
    add t1, s1, t0
    ld a0, 0(t1)            # load char* argv[argv_index]
    call atoi               # Convert string to integer
    
    slli t0, s7, 3          # arr + (arr_index*8)
    add t1, s2, t0
    sd a0, 0(t1)            # arr[arr_index] = atoi(...)
    
    addi s6, s6, 1
    addi s7, s7, 1
    j parse_loop
parse_done:

    # initialize result array to -1
    li s7, 0                # i = 0
    li t2, -1
init_loop:
    bge s7, s0, init_done
    slli t0, s7, 3
    add t1, s3, t0
    sd t2, 0(t1)            # result[i] = -1
    addi s7, s7, 1
    j init_loop
init_done:

    # s5 represents stack_size (empty when 0)
    li s5, 0                # stack_size = 0
    addi s7, s0, -1         # i = n - 1

nge_loop:
    blt s7,x0, nge_done       # if i < 0, break

while_loop:
    # while (!stack.empty() && arr[stack.top()] <= arr[i])
    beq s5,x0, while_done     # if stack empty, break while loop
    
    # get stack.top()
    addi t0, s5, -1         # top_index = stack_size - 1
    slli t0, t0, 3
    add t1, s4, t0
    ld t2, 0(t1)            # t2 = stack[top_index] (this is an index in arr)

    # load arr[stack.top()]
    slli t3, t2, 3
    add t4, s2, t3
    ld t5, 0(t4)            # t5 = arr[stack.top()]

    # load arr[i]
    slli t6, s7, 3
    add t6, s2, t6
    ld t6, 0(t6)            # t6 = arr[i]

    # if arr[stack.top()] > arr[i], the condition fails -> break while
    bgt t5, t6, while_done

    # condition met (<=), so stack.pop()
    addi s5, s5, -1         # stack_size--
    j while_loop

while_done:
    beqz s5, skip_result    # if stack.empty(), skip assigning to result
    
    # result[i] = stack.top()
    addi t0, s5, -1
    slli t0, t0, 3
    add t1, s4, t0
    ld t2, 0(t1)            # t2 = stack.top()

    slli t3, s7, 3
    add t4, s3, t3
    sd t2, 0(t4)            # result[i] = stack.top()

skip_result:
    # stack.push(i)
    slli t0, s5, 3
    add t1, s4, t0
    sd s7, 0(t1)            # stack[stack_size] = i
    addi s5, s5, 1          # stack_size++

    addi s7, s7, -1         # i--
    j nge_loop

nge_done:

    ble s0, x0, main_end    # Edge case: if array is empty (n <= 0), skip to end

    li s7, 0                # i = 0
    addi t6, s0, -1         # t6 = n - 1 (limit for the space loop)

print_loop:
    bge s7, t6, print_last  # if i >= n - 1, break to print the last element
    
    slli t0, s7, 3
    add t1, s3, t0
    ld a1, 0(t1)            # a1 = result[i]
    
    la a0, fmt_space        # a0 = "%lld "
    call printf
    
    addi s7, s7, 1
    j print_loop

print_last:
    # print the very last element with a newline instead of a space
    slli t0, s7, 3
    add t1, s3, t0
    ld a1, 0(t1)            # a1 = result[n-1]
    
    la a0, fmt_newline      # a0 = "%lld\n"
    call printf

main_end:

    li a0, 0                # return code 0
    
    ld s7, 8(sp)
    ld s6, 16(sp)
    ld s5, 24(sp)
    ld s4, 32(sp)
    ld s3, 40(sp)
    ld s2, 48(sp)
    ld s1, 56(sp)
    ld s0, 64(sp)
    ld ra, 72(sp)
    addi sp, sp, 80
    ret