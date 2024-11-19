.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
   # Prologue
   addi sp, sp, -44
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   
   # Save arguments
   mv s1, a1        # matrix pointer
   mv s2, a2        # rows
   mv s3, a3        # columns

   # Open file
   li a1, 1         # Write mode
   jal fopen
   li t0, -1
   beq a0, t0, fopen_error
   mv s0, a0        # Save file descriptor

   # Write dimensions
   sw s2, 24(sp)    # rows
   sw s3, 28(sp)    # cols
   mv a0, s0
   addi a1, sp, 24  # Buffer
   li a2, 2         # Write 2 ints 
   li a3, 4         # Size of int
   jal fwrite
   li t0, 2
   bne a0, t0, fwrite_error

   # Calculate total elements (rows * cols)
   mv s4, zero      # Initialize result
   mv t0, zero      # Counter
mul_loop:
   beq t0, s3, mul_done
   add s4, s4, s2   # Add rows
   addi t0, t0, 1
   j mul_loop
mul_done:

   # Write matrix data
   mv a0, s0
   mv a1, s1        # Matrix data
   mv a2, s4        # Total elements
   li a3, 4         # Size of int
   jal fwrite
   bne a0, s4, fwrite_error

   # Close file
   mv a0, s0
   jal fclose
   li t0, -1
   beq a0, t0, fclose_error

   # Epilogue
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 44
   ret

fopen_error:
   li a0, 27
   j error_exit
fwrite_error:
   li a0, 30
   j error_exit
fclose_error:
   li a0, 28
   j error_exit
error_exit:
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 44
   j exit