.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
   # Input validation
   li t6, 1
   blt a1, t6, handle_error    # if length < 1, error
   
   # Initialize
   lw t0, 0(a0)        # t0 = max_val = array[0]
   li t1, 0           # t1 = max_idx = 0
   li t2, 1           # t2 = i = 1

loop_start:
   bge t2, a1, loop_end    # if i >= length, exit loop
   
   # Get current element
   slli t3, t2, 2     # t3 = i * 4 (offset)
   add t4, a0, t3     # t4 = array + offset
   lw t5, 0(t4)       # t5 = array[i]
   
   # Compare with max
   ble t5, t0, loop_continue   # if array[i] <= max_val, skip
   mv t0, t5          # max_val = array[i]
   mv t1, t2          # max_idx = i

loop_continue:
   addi t2, t2, 1     # i++
   j loop_start

loop_end:
   mv a0, t1          # return max_idx
   ret

handle_error:
   li a0, 36
   j exit