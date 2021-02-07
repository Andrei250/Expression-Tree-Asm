section .data
    delim db " ", 0
    format db "%s", 0
    lastPos dd -1
    numberOfBytes dd 0
    negativeNumber db 0

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern malloc

global create_tree
global iocla_atoi

iocla_atoi: 
    ; TODO
    mov 	esi, [esp + 4]
   	xor 	ebx, ebx
   	xor 	eax, eax
   	mov 	byte[negativeNumber], 0

trim:
    cmp 	byte[esi], 43
    jl 		reduce
    cmp 	byte[esi], '9'
    jle  	startAtoi

reduce:
    inc 	esi
    jmp 	trim

startAtoi:
	cmp 	byte[esi], '-'
	jne 	checkPlus
	mov 	byte[negativeNumber], 1
	inc 	esi
	jmp 	convert

checkPlus:

convert:
	xor 	ebx, ebx
	mov 	bl, byte[esi]
	test 	bl, bl
	je 		checkSign

	inc 	esi
	sub 	bl, '0'
	imul 	eax, 10
	add 	eax, ebx
	jmp 	convert

checkSign:
    cmp 	byte[negativeNumber], 0
    je 		endAtoi
    not eax
    inc eax

endAtoi:
	leave
	ret

;functie care creeaza arborele
create_tree:
    ; TODO
    enter 	0, 0
    xor 	eax, eax
    mov 	esi, [ebp + 8]
    ;se retine ceva in ecx si ebx asa ca le patrez
    push 	ecx
    push 	ebx
    xor 	ecx, ecx
    xor 	ebx, ebx
    xor 	edx, edx

;calculez lungimea sirului
calculateLen:
	cmp 	byte [esi + ecx], 0
	je 		forLoop
	inc 	ecx
	jmp 	calculateLen

;parcurg de la final spre inceput si verific daca este operand sau operator
forLoop:
	cmp 	byte[esi + ecx - 1], ' '
	je 		checkWord
	cmp 	byte[esi + ecx - 1], 10
	je 		endFor

	cmp 	byte[esi + ecx - 1], '*'
	je 		operator

	cmp 	byte[esi + ecx - 1], '/'
	je 		operator

	cmp 	byte[esi + ecx - 1], '+'
	jne 	check2

	cmp 	byte[esi + ecx], ' '
	je 		operator
	jmp 	operand

;minusul si plusul sunt speciale ca se pot pune si in fata operanzilor
check2:
	cmp 	byte[esi + ecx - 1], '-'
	jne 	operand

	cmp 	byte[esi + ecx], ' '
	je 		operator

;daca e operand si nu am ultima pozitie selectata inseamna ca sunt la final
operand:
	cmp 	dword [lastPos], -1
	jne 	endFor 
	mov 	dword [lastPos], ecx
	jmp 	endFor

;creez un nod nou cu valoarea operatorului si scot din stiva cei 2 copii
;apoi bag in stiva noul nod
operator:
	push 	ecx
	push 	dword 1
	call 	malloc
	add 	esp, 4
	pop 	ecx
	xor 	ebx, ebx
	mov 	bl, byte[esi + ecx - 1]
	mov 	[eax], ebx
	xor 	ebx, ebx
	mov 	ebx, eax
	push 	ecx
	push 	dword 12
	call 	malloc
	add 	esp, 4
	pop 	ecx
	mov 	[eax], ebx
	xor 	ebx, ebx
	pop 	ebx
	mov 	[eax + 4], ebx
	xor 	ebx, ebx
	pop 	ebx
	mov 	[eax + 8], ebx
	push 	eax

	xor 	ebx, ebx
	mov 	ebx, ecx
	sub 	ebx, 2
	mov 	dword [lastPos], ebx
	jmp 	endFor

;verific daca este un cuvant sau nu cand ajunge la spatiu
checkWord:
	cmp 	dword [lastPos], dword -1
	je 		endFor
	cmp 	byte[esi + ecx], 48
	jge 	solveWord
	cmp 	byte[esi + ecx + 1], ' '
	je 		endFor

;aloc memorie pentru cuvant
solveWord:
	xor 	ebx, ebx
	mov 	ebx, dword [lastPos]
	mov 	dword [numberOfBytes], ebx
	sub 	dword [numberOfBytes], ecx
	cmp 	dword [numberOfBytes], 0
	jle 	endFor

	xor 	eax, eax
	mov 	edx, dword [numberOfBytes]
	push 	ecx
	push 	edx
	call 	malloc
	add 	esp, 4
	pop 	ecx

;pun valorile in noul nod pe car eil creez ( nod frunza)
fillString:
	xor 	ebx, ebx
	mov 	edi, dword [lastPos]
	mov 	bl, byte[esi + edi - 1]
	mov 	edx, dword [numberOfBytes]
	mov 	byte[eax + edx - 1], bl
	sub 	dword [numberOfBytes], 1
	sub 	dword [lastPos], 1
	cmp 	dword [numberOfBytes], 0
	jg 		fillString

	xor 	ebx, ebx
	mov 	ebx, eax
	push 	ecx
	push 	dword 12
	call 	malloc
	add 	esp, 4
	pop 	ecx
	mov 	[eax], ebx
	mov 	[eax + 4], dword 0
	mov 	[eax + 8], dword 0
	push 	eax
	xor 	ebx, ebx
	mov 	ebx, ecx
	dec 	ebx
	mov 	dword [lastPos], ebx
endFor:
	dec 	ecx
	cmp 	ecx, 0
	jg 		forLoop

	pop 	eax
	pop 	ebx
	pop 	ecx

	leave
	ret
