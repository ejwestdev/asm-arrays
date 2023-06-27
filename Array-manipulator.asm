
.data
welcome_msg: .asciiz "Welcome to Array Manipulator v1.0!\nTo start array input please enter array size: "
elem: .asciiz "Enter elem "
colon: .asciiz ": "
main_menu: .asciiz "\n\nWhat do you want to do with the array?\n1. Sort.\n2. Compute sum of elements.\n3. Find greatest element.\n4. Quit.\nAction:\n"
result_msg: .asciiz "Result: "
result_msg_sort: .asciiz "Result: \n"               
bye_msg: .asciiz "Bye!"
.text
.globl main

main:
	li $v0,4
	la $a0,welcome_msg
	syscall
	# dyn_alloc code from class
	li $v0,5
	syscall
	# we use $s0 to save array size 
	move $s0,$v0
	# allocate space for array 
	li $v0,9
	sll $a0,$s0,2 # $a0 = size *4
	syscall
	move $s1,$v0 # save array address in $s1
	
	# we use $t2 as counter
	li $t2,0 # i= 0
	move $t1,$s1 # $t1 = address of first element in the array 
main_read_array_loop: #this code is from class
	bge $t2,$s0,main_print_menu
	li $v0,4
	la $a0,elem
	syscall
	# print i
	li $v0,1
	move $a0,$t2
	syscall 
	li $v0,4
	la $a0,colon
	syscall
	# read array value from user 
	li $v0,5
	syscall
	sw $v0,0($t1) # save to array[i]
	addiu $t1,$t1,4 # go to next element 
	addi $t2,$t2,1 # i++
	j main_read_array_loop
main_print_menu:
	
	# print menu 
	li $v0,4
	la $a0,main_menu
	syscall
	# read option
	li $v0,5
	syscall
	beq $v0,1,main_sort
	beq $v0,2,main_sum
	beq $v0,3,main_greatest
	beq $v0,4,main_exit
	j main_print_menu
main_sort:
	# sort using merge sort
	move $a0,$s1
	li $a1,0 # 0
	addi $a2,$s0,-1 # n-1
	jal mergeSort
	# here we print the array :) 
	li $v0,4
	la $a0,result_msg_sort
	syscall
	
	li $t2,0 # i=0
	move $t1,$s1 # address of the first elemnet 
main_print_loop:
	bge $t2,$s0,main_print_loop_done
	# here i<n
	# print array[i]
	li $v0,1
	lw $a0,0($t1)
	syscall
	# print new line
	li $v0,11
	li $a0,10
	syscall
	addi $t2,$t2,1 # i++
	addiu $t1,$t1,4
	j main_print_loop
main_print_loop_done:
	# print new line
	li $v0,11
	li $a0,10
	syscall
	
	j main_print_menu
main_sum:
	li $t3,0 # sum = 0
	li $t2,0 # i=0
	move $t1,$s1
main_sum_loop:
	bge $t2,$s0,main_sum_loop_done
	lw $t0,0($t1) # $t0 = array[i]
	add $t3,$t3,$t0 # sum = sum + array[i]
	addi $t2,$t2,1 # i++
	addiu $t1,$t1,4
	j main_sum_loop
main_sum_loop_done:
	li $v0,4
	la $a0,result_msg
	syscall
	# print sum
	li $v0,1
	move $a0,$t3
	syscall
	# print new line
	li $v0,11
	li $a0,10
	syscall
	j main_print_menu
main_greatest:
	move $t1,$s1
	lw $t3,0($t1) # default to array[0]
	li $t2,1 # i=1
	
	addiu $t1,$t1,4
main_greatest_loop:
	bge $t2,$s0,main_greatest_loop_done
	lw $t0,0($t1) # $t0 = array[i]
	ble $t0,$t3,main_greatest_loop_update
	# here array[i] > greatest
	move $t3,$t0
main_greatest_loop_update:
	addi $t2,$t2,1 # i++
	addiu $t1,$t1,4
	j main_greatest_loop
main_greatest_loop_done:
	li $v0,4
	la $a0,result_msg
	syscall
	# print greatest
	li $v0,1
	move $a0,$t3
	syscall
	# print new line
	li $v0,11
	li $a0,10
	syscall
	
	j main_print_menu 
main_exit:
	li $v0,4
	la $a0,bye_msg
	syscall
	li $v0,10
	syscall



	
#MergeSort code

merge:
	# $a0 : arr
	# $a1 : l
	# $a2 : m
	# $a3 : r
	addiu $sp,$sp,-20
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	move $s0,$a0 # save $a0 in $s0
	move $s1,$a1 # save $a1 in $s1
	move $s2,$a2 # save $a2 in $s2
	move $s3,$a3 # save $a3 in $s3
	# $t0 --> i
	# $t1 --> j
	# $t2 --> k
	# $t3 --> n1
	sub $t3,$s2,$s1
	addi $t3,$t3,1 # n1 = m - l + 1; 
	# $t4 --> n2
	sub $t4,$s3,$s2 # n2 =  r - m;
	#     temp arrays 
	sll $t7,$t3,2 # $t7 = n1 * 4
	subu $sp,$sp,$t7 # create L[n1]
	move $t5,$sp # $t5 --> L
	sll $t7,$t4,2 # $t7 = n2 * 4
	subu $sp,$sp,$t7 # create R[n2]
	move $t6,$sp # $t6 --> P

	li $t0,0 # i = 0
merge_for_loop_L:
	bge $t0,$t3,merge_for_loop_L_done
	add $a0,$s1,$t0 # $a0 = l + i
	sll $a0,$a0,2
	addu $a0,$a0,$s0 # $a0 = &arr[l + i]
	lw $t7,0($a0) # $t7 = arr[l + i]
	sll $a0,$t0,2 
	addu $a0,$a0,$t5 # $a0 = &L[i]
	sw $t7,0($a0) # L[i] = arr[l + i]; 
	addi $t0,$t0,1 # i++
	j merge_for_loop_L
merge_for_loop_L_done:
	li $t1,0 # j = 0
merge_for_loop_R:
	bge $t1,$t4,merge_for_loop_R_done
	add $a0,$s2,$t1
	addi $a0,$a0,1 # $a0 = m + 1+ j
	sll $a0,$a0,2
	addu $a0,$a0,$s0 
	lw $t7,0($a0)  # $t7 = arr[m + 1+ j]; 
	sll $a0,$t1,2 
	addu $a0,$a0,$t6 # $a0 = &R[i]
	sw $t7,0($a0) 
	addi $t1,$t1,1 # j++
	j merge_for_loop_R	
merge_for_loop_R_done: #reset
	li $t0,0 #i = 0;
	li $t1,0 #j = 0; 
	move $t2,$s1 # k = l;  	
#    while (i < n1 && j < n2) 
#     { 
#         if (L[i] <= R[j]) 
#         { 
#             arr[k] = L[i]; 
#             i++; 
#         } 
#         else
#         { 
#             arr[k] = R[j]; 
#             j++; 
#         } 
#         k++; 
#     } 
merge_while1:	
	bge $t0,$t3,merge_while1_done
	bge $t1,$t4,merge_while1_done
	# while (i < n1 && j < n2)
	sll $a0,$t0,2
	addu $a0,$a0,$t5 # $a0 = &L[i]
	lw $a0,0($a0) 
	sll $a1,$t1,2
	addu $a1,$a1,$t6 
	lw $a1,0($a1) 
	bgt $a0,$a1,merge_while1_else
	
	sll $a0,$t0,2
	addu $a0,$a0,$t5 
	lw $t7,0($a0)
	
	addi $t0,$t0,1 # i++
	j merge_while1_update
merge_while1_else:
	sll $a0,$t1,2
	addu $a0,$a0,$t6 
	lw $t7,0($a0)
	# arr[k] = R[j]; 
	addi $t1,$t1,1 # j++
merge_while1_update:
	sll $a0,$t2,2
	addu $a0,$a0,$s0 
	sw $t7,0($a0)
	addi $t2,$t2,1 # k++
	j merge_while1
merge_while1_done:
#pass
merge_whileL:
	bge $t0,$t3,merge_whileL_done
	sll $a0,$t0,2
	addu $a0,$a0,$t5 # $a0 : &L[i]
	lw $t7,0($a0)
	sll $a0,$t2,2
	addu $a0,$a0,$s0 # $a0 : &arr[k]
	sw $t7,0($a0) # arr[k] = L[i]; 
	
	addi $t0,$t0,1 # i++
	addi $t2,$t2,1 # k++
	j merge_whileL
merge_whileL_done:			
#pass
merge_whileR:
	bge $t1,$t4,merge_whileR_done
	sll $a0,$t1,2
	addu $a0,$a0,$t6 
	lw $t7,0($a0)
	sll $a0,$t2,2
	addu $a0,$a0,$s0 
	sw $t7,0($a0) 
	
	addi $t1,$t1,1
	addi $t2,$t2,1 
	j merge_whileR
merge_whileR_done:	
	# removes arr[n] in left and right array
	add $t7,$t3,$t4
	sll $t7,$t7,2 
	addu $sp,$sp,$t7 
	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	addiu $sp,$sp,20
	jr $ra 

  



mergeSort:
	# $a0 : arr
	# $a1 : l
	# $a2 : r
	addiu $sp,$sp,-20
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	move $s0,$a0 # $a0 is $s0
	move $s1,$a1 # $a1 is $s1
	move $s2,$a2 # $a2 is $s2
	# $s3 is m
	bge $s1,$s2,mergeSort_done
	# if (l < r) 
	addi $s3,$s2,-1 # $s3 = r-1
	add $s3,$s3,$s1 # $s3 = l+(r-l)
	srl $s3,$s3,1 # m = $s3/2; 
	move $a0,$s0 
	move $a1,$s1 
	move $a2,$s3 # m
	jal mergeSort
	move $a0,$s0 
	move $a1,$s3 
	addi $a1,$a1,1 # m+1
	move $a2,$s2 # r
	jal mergeSort 
	#move l,m,n,r arr
	move $a0,$s0 
	move $a1,$s1 
	move $a2,$s3 
	move $a3,$s2
	jal merge 
mergeSort_done:
	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	addiu $sp,$sp,20
	jr $ra
