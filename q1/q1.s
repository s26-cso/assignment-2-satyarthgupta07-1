.text

.globl make_node
make_node:

    addi sp, sp, -16
    sd ra, 8(sp)       # save return address (64 bit)
    sd s0, 0(sp)       # save s0 (64 bit)

    addi s0, a0, 0     # save val into s0
    
    # malloc(24) as 24 bytes needed for 64 bit struct (4 int + 4 pad + 8 left + 8 right)
    li a0, 24
    call malloc

    # initialize fields
    sw s0, 0(a0)       # node->val = val (sw because int is 32 bit)
    sd x0, 8(a0)     # node->left = NULL (sd because pointer is 64 bit)
    sd x0, 16(a0)    # node->right = NULL (sd because pointer is 64 bit)

    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.globl insert
insert:

    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)      # s0 = root
    sd s1, 8(sp)       # s1 = val

    # base Case: if root == NULL, return make_node(val)
    bne a0, x0, insert_not_null
    addi a0, a1, 0
    jal make_node      # jal instead of tail
    j insert_end       # jump to epilogue

insert_not_null:
    addi s0, a0, 0
    addi s1, a1, 0

    lw t0, 0(s0)       # t0 = root->val (32 bit load)

    # if val >= root->val, go right
    bge s1, t0, insert_right 

insert_left:
    ld a0, 8(s0)       # a0 = root->left (64 bit load)
    addi a1, s1, 0
    jal insert         # insert(root->left, val)
    sd a0, 8(s0)       # root->left = return value (64 bit store)
    j insert_done

insert_right:
    ld a0, 16(s0)      # a0 = root->right (64 bit load)
    addi a1, s1, 0
    jal insert         # insert(root->right, val)
    sd a0, 16(s0)      # root->right = return value (64 bit store)

insert_done:
    addi a0, s0, 0     # return root

insert_end:
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

.globl get
get:
    addi sp, sp, -16
    sd ra, 8(sp)

    # base case: if root == NULL, return NULL
    beq a0, x0, get_end

    lw t0, 0(a0)       # t0 = root->val (32 bit)
    
    # if root->val == val, return root (a0)
    beq a1, t0, get_end      

    # if val < root->val, search left
    blt a1, t0, get_left     

get_right:
    ld a0, 16(a0)      # a0 = root->right (64 bit pointer load)
    jal get            # recursive call
    j get_end

get_left:
    ld a0, 8(a0)       # a0 = root->left (64 bit pointer load)
    jal get            # recursive call

get_end:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.globl getAtMost
getAtMost:
    # base case: if (root == NULL) return -1;
    bne  a1, x0, getAtMost_not_null
    li a0, -1
    ret

getAtMost_not_null:
    # we need to make recursive calls, save registers
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)      # s0 = root
    sd s1, 8(sp)       # s1 = val

    addi s1, a0, 0     # s1 = val
    addi s0, a1, 0     # s0 = root

    lw t0, 0(s0)       # t0 = root->val

    # case 1: if (root->val == val) return root->val;
    beq t0, s1, getAtMost_exact

    # case 2: if (root->val > val) return getAtMost(val, root->left);
    bgt t0, s1, getAtMost_go_left

    # case 3: root->val < val. this node is a candidate, but there might be a better (larger) candidate in the right subtree
    # int right_res = getAtMost(val, root->right)

    addi a0, s1, 0     # a0 = val
    ld a1, 16(s0)      # a1 = root->right
    jal getAtMost
    
    # if (right_res != -1) return right_res;
    li t1, -1
    bne a0, t1, getAtMost_done

    # else return root->val;
    lw a0, 0(s0)
    j getAtMost_done

getAtMost_exact:
    addi a0, s1, 0     # return val (which equals root->val)
    j getAtMost_done

getAtMost_go_left:
    addi a0, s1, 0     # a0 = val
    ld a1, 8(s0)       # a1 = root->left
    jal getAtMost      # return value will be stored in a0
    # fall through to done

getAtMost_done:
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret
