.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
matmul:
   # Error checks
   li t0, 1
   blt a1, t0, error    # m0_rows < 1
   blt a2, t0, error    # m0_cols < 1 
   blt a4, t0, error    # m1_rows < 1
   blt a5, t0, error    # m1_cols < 1
   bne a2, a4, error    # m0_cols != m1_rows
   
   # Prologue
   addi sp, sp, -28
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp) 
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   sw s5, 24(sp)

   li s0, 0           # i = 0 (row counter for m0)
   mv s2, a6          # result matrix pointer
   mv s3, a0          # m0 base pointer

outer_loop_start:
   bge s0, a1, outer_loop_end  # if i >= m0_rows, done
   li s1, 0                    # j = 0 (col counter for m1)
   mv s4, a3                   # reset m1 to base pointer

inner_loop_start:
   bge s1, a5, inner_loop_end  # if j >= m1_cols, next row

   # Save args before dot call
   addi sp, sp, -24
   sw a0, 0(sp)
   sw a1, 4(sp)
   sw a2, 8(sp)
   sw a3, 12(sp)
   sw a4, 16(sp)
   sw a5, 20(sp)

   # Set up dot product args
   mv a0, s3          # current row of m0
   mv a1, s4          # current col of m1  
   mv a2, a2          # length = m0_cols = m1_rows
   li a3, 1           # m0 stride = 1
   mv a4, a5          # m1 stride = m1_cols

   jal ra, dot
   
   # Store result
   sw a0, 0(s2)       # store dot product result
   
   # Restore saved args
   lw a5, 20(sp)
   lw a4, 16(sp)
   lw a3, 12(sp)
   lw a2, 8(sp)
   lw a1, 4(sp)
   lw a0, 0(sp)
   addi sp, sp, 24

   addi s2, s2, 4     # next result position
   addi s4, s4, 4     # next col in m1
   addi s1, s1, 1     # j++
   j inner_loop_start

inner_loop_end:
   slli t0, a2, 2     # t0 = m0_cols * 4
   add s3, s3, t0     # next row in m0
   addi s0, s0, 1     # i++
   j outer_loop_start

outer_loop_end:
   # Epilogue
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp) 
   lw s3, 16(sp)
   lw s4, 20(sp)
   lw s5, 24(sp)
   addi sp, sp, 28
   ret

error:
   li a0, 38
   j exit