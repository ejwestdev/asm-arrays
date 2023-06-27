#program:
#   main:
#       n := facto_rec(5)
#       print n
#       
#       fun facto_rec(n) is
#           if (n <= 1) then
#               return 1
#           else
#               return n * facto_rec(n-1)
#           end if
#       end fun
#end program
#

.data


.text
subiu $sp,$sp,4 #space for n

	main:
		li $t0 , 0 
		sw $t0 , 0($sp) #$t0 = n
		
		li $t1, 5	
		#n, $ra, return value must be stored
		subiu $sp, $sp, 12 #making space for the values
		sw $t1,0($sp) # 0($sp) = $t1 = n
		sw $ra , 4($sp) #4($sp) = ra
		jal facto_rec
		lw $ra,4($sp)
		lw $t0,8($sp) #8($sp) = return value 
		sw $t0,0($sp) #= n
		addiu $sp,$sp,12
		move $a0, $t0
		
		li $v0,1
		syscall
		li $v0,10
		syscall
		
#      fun facto_rec(n) is
#           if (n <= 1) then
#               return 1
#           else
#               return n * facto_rec(n-1)
#           end if
#       end fun
	
	
	#$t0 = n
	facto_rec:
		lw $t0,0($sp) 
		bne $t0,1,else #if value isnot <=1 then branch to else 
		li $t1,1	
		sw $t1,8($sp) #return
		j end
		
	else:	subiu $t2,$t0,1
		subiu $sp,$sp,12
		sw $t2,0($sp)
		sw $ra,4($sp)
		jal facto_rec

		lw $ra,4($sp)
		lw $t3,8($sp) 
		
		addiu $sp,$sp,12
		
		lw $t0,0($sp)
		mul $t4,$t3,$t0
		sw $t4,8($sp)
		
	end:	jr $ra

		
