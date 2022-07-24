; ------- TABELA DE CORES -------
; adicione ao caracter para Selecionar a cor correspondente

; 0 branco							0000 0000
; 256 marrom						0001 0000
; 512 verde							0010 0000
; 768 oliva							0011 0000
; 1024 azul marinho					0100 0000
; 1280 roxo							0101 0000
; 1536 teal							0110 0000
; 1792 prata						0111 0000
; 2048 cinza						1000 0000
; 2304 vermelho						1001 0000
; 2560 lima							1010 0000
; 2816 amarelo						1011 0000
; 3072 azul							1100 0000
; 3328 rosa							1101 0000
; 3584 aqua							1110 0000
; 3840 branco						1111 0000

Letra: var #1		; Contem a letra que foi digitada

; --- Guardando Cores na Memoria ---
    Verde: var #1
    Vermelho: var #1
    Amarelo: var #1
    Branco: var #1

    loadn r0, #512
    loadn r1, #2304
    loadn r2, #2816
    loadn r3, #0

    store Verde, r0
    store Vermelho, r1 
    store Amarelo, r2
    store Branco, r3 
; --- Fim de Guardar as cores na memória ---

jmp main

;---- Inicio do Programa Principal -----

main:
	call digLetra  ; Lê letra do teclado
	load r1, Letra ; Recebe a letra lida

	loadn r0, #0		; Posicao na tela onde a mensagem sera escrita
    load r2, Vermelho 
    call imprimeLetraColorida

	loadn r0, #1		; Posicao na tela onde a mensagem sera escrita
    load r2, Amarelo 
    call imprimeLetraColorida

	loadn r0, #40		; Posicao na tela onde a mensagem sera escrita
    load r2, Verde 
    call imprimeLetraColorida

    loadn r0, #41		; Posicao na tela onde a mensagem sera escrita
    load r2, Branco 
    call imprimeLetraColorida

	halt
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Subrotinas -----
;********************************************************
;                   DIGITE UMA LETRA
;********************************************************

digLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push fr		; Protege o registrador de flags
	push r0
	push r1
	push r2
	loadn r1, #255	; Se nao digitar nada vem 255
	loadn r2, #0	; Logo que programa a FPGA o inchar vem 0

   digLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq digLetra_Loop	; Fica lendo ate' que digite uma tecla valida
		cmp r0, r2			;compara r0 com 0
		jeq digLetra_Loop	; Le novamente pois Logo que programa a FPGA o inchar vem 0

	store Letra, r0			; Salva a tecla na variavel global "Letra"
	
   digLetra_Loop2:	
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jne digLetra_Loop2	; Fica lendo ate' que digite uma tecla valida
	
	pop r2
	pop r1
	pop r0
	pop fr
	rts	

imprimeLetraColorida: ;; ROTINA PARA IMPRESSAO DE LETRA COLORIDA
    push r0 ; posicao na tela 
    push r1 ; letra 
    push r2 ; cor

    add r1, r1, r2
	outchar r1, r0 ; Imprime letra na posição em r0

    pop r2
    pop r1
    pop r0

    rts

Imprimestr:		;  Rotina de Impresao de Mensagens:    
				; r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso
				; r1 = endereco onde comeca a mensagem
				; r2 = cor da mensagem
				; Obs: a mensagem sera' impressa ate' encontrar "/0"
				
;---- Empilhamento: protege os registradores utilizados na subrotina na pilha para preservar seu valor				
	push r0	; Posicao da tela que o primeiro caractere da mensagem sera' impresso
	push r1	; endereco onde comeca a mensagem
	push r2	; cor da mensagem
	push r3	; Criterio de parada
	push r4	; Recebe o codigo do caractere da Mensagem
	
	loadn r3, #'\0'	; Criterio de parada

ImprimestrLoop:	
	loadi r4, r1		; aponta para a memoria no endereco r1 e busca seu conteudo em r4
	cmp r4, r3			; compara o codigo do caractere buscado com o criterio de parada
	jeq ImprimestrSai	; goto Final da rotina
	add r4, r2, r4		; soma a cor (r2) no codigo do caractere em r4
	outchar r4, r0		; imprime o caractere cujo codigo está em r4 na posicao r0 da tela
	inc r0				; incrementa a posicao que o proximo caractere sera' escrito na tela
	inc r1				; incrementa o ponteiro para a mensagem na memoria
	jmp ImprimestrLoop	; goto Loop
	
ImprimestrSai:	
;---- Desempilhamento: resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4	
	pop r3
	pop r2
	pop r1
	pop r0
	rts		; retorno da subrotina