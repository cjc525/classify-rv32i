.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:
   # Prologue
   addi sp, sp, -40
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   
   # Save row/col pointers
   mv s3, a1         
   mv s4, a2         

   # Open file
   li a1, 0          # Read mode
   jal fopen
   li t0, -1
   beq a0, t0, fopen_error
   mv s0, a0         # Save file descriptor

   # Read dimensions
   mv a0, s0
   addi a1, sp, 28   # Buffer for dimensions
   li a2, 8          # Read 8 bytes (2 ints)
   jal fread
   li t0, 8
   bne a0, t0, fread_error

   # Store dimensions
   lw t1, 28(sp)     # rows
   lw t2, 32(sp)     # cols
   sw t1, 0(s3)      
   sw t2, 0(s4)      

   # Calculate matrix size (rows * cols)
   mv s1, zero
   mv t3, zero       # Counter
mul_loop:
   beq t3, t2, mul_done
   add s1, s1, t1
   addi t3, t3, 1
   j mul_loop
mul_done:
   
   # Calculate bytes needed (elements * 4)
   slli t3, s1, 2
   sw t3, 24(sp)     # Save size

   # Allocate memory
   lw a0, 24(sp)     
   jal malloc
   beq a0, x0, malloc_error
   mv s2, a0         # Save matrix pointer

   # Read matrix data
   mv a0, s0
   mv a1, s2
   lw a2, 24(sp)
   jal fread
   lw t3, 24(sp)
   bne a0, t3, fread_error

   # Close file
   mv a0, s0
   jal fclose
   li t0, -1
   beq a0, t0, fclose_error

   # Return matrix pointer
   mv a0, s2

   # Epilogue
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 40
   ret

malloc_error:
   li a0, 26
   j error_exit
fopen_error:
   li a0, 27
   j error_exit
fread_error:
   li a0, 29
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
   addi sp, sp, 40
   j exit