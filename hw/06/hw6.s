.data
input_label: .asciiz "Input Scores: "
output_label: .asciiz "Histogram: "

# Input Data Set (i.e. `in`)
# Feel free to add or remove values as desired to see the histogram change
# If you add values great than 9, you will have to change the length argument 
# that is passed into `print_hist` (set in line 44)
input:
    .word 1 2 3 4 5 6 7 0 9 1 2 3 4 5 0 7 8 9 1 2 3 1 2 9 5 4 2 2 1 7
output:
    .word 0 0 0 0 0 0 0 0 0 0

.text

main:
    la $a0 input_label
    li $v0 4
    syscall # print "Input Scores: "

    la $a0 input
    la $a1 output
    subu $a1 $a1 $a0
    srl $a1 $a1 2 # calculate number of elements in input
    jal print_arr # print the initial set of input values

    la $a0 input
    la $a1 output
    subu $a2 $a1 $a0
    srl $a2 $a2 2 # calculate number of elements in input
    jal update_hist # create the histogram

    li $a0 10
    li $v0 11
    syscall # print a newline
    la $a0 output_label
    li $v0 4
    syscall # print "Histogram: "
    li $a0 10
    li $v0 11
    syscall # print a newline

    la $a0 output
    li $a1 10 # number of histogram buckets to print
    jal print_hist # print a visualization of the created histogram

    li $v0 10
    syscall # exit

# $a0 = int* in, $a1 = int* hist, $a2 = num_scores
update_hist:
    addu $t0 $a0 $0
    addu $t1 $a1 $0
    addu $t2 $0 $0
    sll $a2 $a2 2

    hist_loop:
        beq $t2 $a2 hist_done
        addu $t3 $t0 $t2
        lw $t3 0($t3) # load in[i]

        sll $t3 $t3 2
        addu $t3 $t1 $t3
        lw $t4 0($t3) # load hist[in[i]]
        addiu $t4 $t4 1
        sw $t4 0($t3) # store hist[in[i]] + 1

        addu $t2 $t2 4
        j hist_loop

    hist_done:
    jr $ra


print_arr: # $a0 = arr, $a1 = len
    addu $t0 $0 $0
    addu $t1 $a0 $0
    sll $a1 $a1 2
    li $v0 1
    print_arr_loop:
        beq $t0 $a1 print_arr_done
        addu $a0 $t0 $t1
        lw $a0 0($a0)
        syscall # print a value
        li $a0 32
    li $v0 11
    syscall # print a space
    li $v0 1
        addiu $t0 $t0 4
        j print_arr_loop

    print_arr_done:
    li $a0 10
    li $v0 11
    syscall # print a newline
        jr $ra

print_hist: # $a0 = arr, $a1 = len
    addu $t0 $0 $0
    addu $t1 $a0 $0
    sll $a1 $a1 2
    li $v0 1

    print_hist_loop:
        beq $t0 $a1 print_hist_done

        srl $a0 $t0 2
        li $v0 1
        syscall # Print the index
        li $a0 58
    li $v0 11
    syscall # Print the colon
    li $a0 32
    syscall # Print the space

    addu $a0 $t0 $t1
        lw $t2 0($a0)

        print_hist_star_loop: # print stars for current histogram bucket
            beq $t2 $0 print_hist_star_loop_done
            li $a0 42
            syscall # print a star
            addiu $t2 $t2 -1
            j print_hist_star_loop
        print_hist_star_loop_done:

        li $a0 10
        syscall

        addiu $t0 $t0 4
        j print_hist_loop

    print_hist_done:
    li $a0 10
    li $v0 11
    syscall # Print newline

        jr $ra
