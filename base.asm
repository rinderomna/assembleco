
Letra: var #1		; Contem a letra que foi digitada
quadradinhoPosition : var #1

jmp definicoes
fim_definicoes:

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
    call printCaixinhas

    loadn r0, #131
    loadn r1, #4
    loadn r2, #140

    loadn r4, #6
    main_caixinhas_loop_vertical:
        loadn r3, #5
        main_caixinha_loop_linha:
            call digLetra
            load r5, Letra

            outchar r5, r0

            add r0, r0, r1 ; somar 4 a posicao para proximo

        dec r3
        jnz main_caixinha_loop_linha
        add r0, r0, r2 ; somar 140 a posicao (seguir na proxima linha)
    dec r4
    jnz main_caixinhas_loop_vertical

	halt
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Subrotinas -----

printCaixinhas:
    push R0
    push R1
    push R2
    push R3
    push R4
    push fr

    loadn r0, #90
    loadn r1, #4
    loadn r2, #140

    loadn r4, #6
    printCaixinhas_loop_vertical:
        loadn r3, #5
        printCaixinhas_loop_linha:
            store quadradinhoPosition, r0
            call printquadradinho

            add r0, r0, r1 ; somar 4 a posicao para proximo

        dec r3
        jnz printCaixinhas_loop_linha
        add r0, r0, r2 ; somar 140 a posicao (seguir na proxima linha)
    dec r4
    jnz printCaixinhas_loop_vertical

    pop fr
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0

    rts


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

definicoes:

quadradinhoPosition : var #1

quadradinho : var #8
  static quadradinho + #0, #2 ; se
  static quadradinho + #1, #1 ; horizontal
  static quadradinho + #2, #3 ; sd
  ;38  espacos para o proximo caractere
  static quadradinho + #3, #0 ; vertical
  ;2  espacos para o proximo caractere
  static quadradinho + #4, #0 ; vertical
  ;38  espacos para o proximo caractere
  static quadradinho + #5, #4 ; ie
  static quadradinho + #6, #1 ; horizontal
  static quadradinho + #7, #5 ; id

quadradinhoGaps : var #8
  static quadradinhoGaps + #0, #0
  static quadradinhoGaps + #1, #0
  static quadradinhoGaps + #2, #0
  static quadradinhoGaps + #3, #37
  static quadradinhoGaps + #4, #1
  static quadradinhoGaps + #5, #37
  static quadradinhoGaps + #6, #0
  static quadradinhoGaps + #7, #0

jmp fim_definicoes

printquadradinho:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5
  push R6

  loadn R0, #quadradinho
  loadn R1, #quadradinhoGaps
  load R2, quadradinhoPosition
  loadn R3, #8 ;tamanho quadradinho
  loadn R4, #0 ;incremetador

  printquadradinhoLoop:
    add R5,R0,R4
    loadi R5, R5

    add R6,R1,R4
    loadi R6, R6

    add R2, R2, R6

    outchar R5, R2

    inc R2
     inc R4
     cmp R3, R4
    jne printquadradinhoLoop

  pop R6
  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts

apagarquadradinho:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5

  loadn R0, #3967
  loadn R1, #quadradinhoGaps
  load R2, quadradinhoPosition
  loadn R3, #8 ;tamanho quadradinho
  loadn R4, #0 ;incremetador

  apagarquadradinhoLoop:
    add R5,R1,R4
    loadi R5, R5

    add R2,R2,R5
    outchar R0, R2

    inc R2
     inc R4
     cmp R3, R4
    jne apagarquadradinhoLoop

  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts
