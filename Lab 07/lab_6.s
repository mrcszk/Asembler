#----------------------------------------------------------------
# Program LAB_6.S - Asemblery Laboratorium IS II rok
#----------------------------------------------------------------
#
#  To compile: as -o lab_6.o lab_6.s
#  To link:    ld -o lab_6 lab_6.o
#  To run:     ./lab_6
#
#----------------------------------------------------------------


.equ	read_64,	0x00	# read data from file function
.equ	write_64,	0x01	# write data to file function
.equ	exit_64,	0x3C	# exit program function

.equ	tooval,	-1
.equ	errval,	-2
.equ    stdin, 0
.equ    stdout, 1
.equ    stderr, 2

	.data
	
buffer:			# buffer for file data
	.space		1024, 0
bufsize:		# size of buffer
	.quad		( . - buffer )
b_read:			# size of read data
	.quad		0
errmsg:			# file error message
	.ascii	"File error!\n"
errlen:
	.quad		( . - errmsg )
toomsg:			# file too big error message
	.ascii	"File too big!\n"
toolen:
	.quad		( . - toomsg ) 
promptmsg:
	.ascii	"String: "
promptlen:
	.quad		( . - promptmsg ) 
befmsg:
	.ascii	"Before:\n"
beflen:
	.quad		( . - befmsg ) 
aftmsg:
	.ascii	"After:\n"
aftlen:
	.quad		( . - aftmsg ) 

	.text
	.global _start
	
_start:
	NOP

	MOV	$write_64,%rax	# write function
	MOV	$stdout,%rdi	# file handle in RDI
	MOV	$promptmsg,%rsi	# RSI points to message
	MOV	promptlen,%rdx	# bytes to be written
	SYSCALL
	
	MOV	$read_64,%rax	# read function
	MOV	$stdin,%rdi	# file handle in RDI
	MOV	$buffer,%rsi	# RSI points to data buffer
	MOV	bufsize,%rdx	# bytes to be read
	SYSCALL

	CMP	$0,%rax
	JL	error		# if RAX<0 then something went wrong

	MOV	%rax,b_read	# store count of read bytes

	CMP	bufsize,%rax	# whole file was read ?
	JE	toobig		# probably not

	MOV	$write_64,%rax	# write function
	MOV	$stdout,%rdi	# file handle in RDI
	MOV	$befmsg,%rsi	# RSI points to message
	MOV	beflen,%rdx	# bytes to be written
	SYSCALL

	MOV	$write_64,%rax	# write function
	MOV	$stdout,%rdi	# file handle in RDI
	MOV	$buffer,%rsi	# offset to first character
	MOV	b_read,%rdx	# count of characters
	SYSCALL

	MOV	$buffer,%rsi
	MOV	%rsi,%rdi
	MOV	b_read,%rcx
	CLD

# małe na wielkie
#next:
#	LODSB			# al := MEM[ rsi ]; rsi++
#	CMPB	$'a', %al
#	JB skip
#	CMPB	$'z', %al
#	JA skip
#	#OR	$0x20, %al #nie działa dla tej sytuacji, w odwrotnej tak
#   #SUB $32, %al # dodawanie bo odleglosc w ascii 32
#   AND $0xDF, %al #  bo zawsze 01yxxxxx y=1 małe, 0 duze 

# wielkie na małe
#next:
#   LODSB			# al := MEM[ rsi ]; rsi++
#   CMPB	$'A', %al
#	JB skip
#	CMPB	$'Z', %al
#	JA skip
#	#ADD $32, %al # dodajemy 32
#   OR  $0x20, %al # bity wymienione

#zmiana wielkości + cyfry na #
next:
    LODSB
    CMPB $'0' ,%al
    JB skip
    CMPB $'9' , %al
    JA letter
    MOV $'#', %al
    JMP skip
letter:
    CMPB $'A' , %al
    JB skip
    CMPB $'z',%al
    JA skip
    CMPB $'Z',%al
    JBE change
    CMPB $'a',%al
    JB skip
change:
    XOR  $0x20, %al # bity wymienione


skip:	STOSB			# MEM[ rdi ] := al; rdi++
	LOOP next

	MOV	$write_64,%rax	# write function
	MOV	$stdout,%rdi	# file handle in RDI
	MOV	$aftmsg,%rsi	# RSI points to message
	MOV	aftlen,%rdx	# bytes to be written
	SYSCALL

	MOV	$write_64,%rax	# write function
	MOV	$stdout,%rdi	# file handle in RDI
	MOV	$buffer,%rsi	# offset to first character
	MOV	b_read,%rdx	# count of characters
	SYSCALL

	MOV	b_read,%rdi
	JMP	theend

toobig:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$toomsg,%rsi	# RSI points to toobig message
	MOV	toolen,%rdx	# bytes to be written
	SYSCALL
	MOV	$tooval,%rdi
	JMP	theend

error:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$errmsg,%rsi	# RSI points to file error message
	MOV	errlen,%rdx	# bytes to be written
	SYSCALL
	MOV	$errval,%rdi

theend:
	MOV	$exit_64,%rax	# exit program function
	SYSCALL