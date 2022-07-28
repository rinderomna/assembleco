; -------------- | ASSEMBLECO |  -----------------

;|--------------- GRUPO POC-2 -------------------|
;|   Aluno                           |   N°USP   |
;|-----------------------------------|-----------|
;| Hélio Nogueira Cardoso            | 10310227  |
;| Paulo Henrique dos Santos Almeida | 12543926  |
;| Theo da Mota dos Santos           | 10691331  |
;|-----------------------------------------------|

; --- Mensagens ---
msg_vitoria: string "Venceu!"
msg_derrota: string "Perdeu :("
msg_resposta: string "A resposta era:"
msg_denovo: string "De novo? (s/*)"

; --- Alguma 'Variaveis' ----

Letra: var #1		    ; Contem a letra que foi digitada
Rand: var #1            ; Numero que sera coletado pseudoaleatoriamente
palavraResposta: var #1 ; Palavra Resposta do Jogo (endereco)
palavraChute: var #6    ; Palavra que o usuário vai tentar (conteudo)

;; --- Guardando Cores na Memoria ---
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

;; --- Chute Vazio Inicialmente Incorreto ---
    loadn r0, #0    
    store certo, r0                         ; certo = False

;; --- Inicializando Rand com 0 --- ^
    store Rand, r0                          ; Rand = 0

;; --- Definindo numero de palavras ---
    loadn r0, #1579
    store n_palavras, r0                    ; n_palavras = 1579

jmp main

;---- Inicio do Programa Principal -----

main:
    ;; Imprimir Tela Inicial e aguardar usuario teclar algo
    call printTelaInicial    
    call digLetra ; --> Gera número pseudoaleatorio para sortear palavra depois
    
    ;; Loop de Partidas
    de_novo:
        ;; Limpar a tela e sortear palavra
        call printHintsScreen              ; Tela que indica como apagar e enviar palavra
        call sortearPalavra                
        
        ;; Imprimir as 6 linhas de 5 caixinhas da partida
        call printCaixinhas

        ;; Loop de uma Partida
        loadn r4, #160      ; r4 := 160 (constante para pular para proxima linha)
        loadn r3, #6        ; r3 := 6   (quantidade de repeticoes do loop)
        loadn r7, #131      ; r7 := 131 (posicao da primeira caixinha da primeira linha [pos])
        loadn r5, #1        ; r5 := TRUE
        
        main_loop:
            ;; Ler palavra chute
            call lerPalavraChute

            ;; Checar com resposta e imprimir dicas coloridas
            loadn r1, #palavraChute
            call definir_coloracao ;zera variaveis de checagem
            call checa_resposta
            call imprime_com_dicas

            ;; Testar se o chute estava certo
            load r2, certo
            cmp r2, r5
            jeq vitoria

            add r7, r7, r4 ; pos += 160 (proxima linha de caixinhas)
        dec r3
        jnz main_loop

        jmp fim_jogo
        vitoria: ;; Se venceu, imprimir mensagem de vitoria
            loadn r0, #1121
            loadn r1, #msg_vitoria
            load r2, Verde
            call Imprimestr

        fim_jogo:

        ;; Compara a variavel de controle do loop com 0
        ;; Se nao for zero, e por que o loop terminou antes, ou seja,
        ;; o chute estava incorreto -> derrota
        loadn r0, #0
        cmp r3, r0
        jne nao_derrota
            ;; Derrota -> imprimir mensagem de derrota e a resposta
            loadn r0, #1041
            loadn r1, #msg_derrota
            load r2, Vermelho
            call Imprimestr

            loadn r0, #1081
            loadn r1, #msg_resposta
            load r2, Branco
            call Imprimestr

            loadn r0, #1121
            load r1, palavraResposta
            load r2, Verde
            call Imprimestr
        nao_derrota:

        ;; Ler se o usuario quer continuar jogando
        call denovo_pergunta

        ;; Se for 's', comecar nova partida
        loadn r0, #sim_ou_nao
        loadi r0, r0
        loadn r1, #'s'
        cmp r0, r1
        jeq de_novo
    ;;;; -----------

	halt

    jmp fim_do_codigo
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Subrotinas -----

;;----------------------------------
;;------ DEFINIR COLORACAO ---------
;;----------------------------------
;; Rotina que compara a palavra-chute com a palavra-resposta para
;; determinar o vetor de coloracao, o qual ira servir para imprimir
;; a palavra-chute da tentativa com as dicas coloridas, que sao:
;; * Vermelho: letra nao presente na palavra resposta
;; * Amarelo:  letra presente na palavra resposta mas em outra posicap
;; * Verde:    letra presente na palavra resposta na posicao correta
definir_coloracao:
    push fr ; proteger flag register
    push r0 ; <livre>
    push r1 ; <livre>
    push r2 ; <livre>
    push r3 ; endereco da letra chute
    push r4 ; endereco da letra resposta
    push r5 ; i
    push r6 ; j
    push r7 ; <livre>

    ;; Zerar vetor de coloracao (tudo VERMELHO(0)), checado_no_chute e checado_na_resposta
    call zerar_variaveis_de_checagem
    
    loadn r3, #palavraChute  ;; r3 := &palavraChute[0]
    load r4, palavraResposta ;; r4 := &palavraresposta[0]

    ;; Loop1 : Checar letras em mesma posicao ("Testa-Verde")
    ;; r5 := i
    loadn r5, #0 ;; i = 0 (inicializacao da variavel de controle do loop1)
    definir_coloracao_loop1:
        add r1, r3, r5  ;r1 = &palavraChute[i]
        add r2, r4, r5  ;r2 = &palavraResposta[i]

        loadi r1, r1  ;r1 = palavraChute[i]
        loadi r2, r2  ;r2 = palavraResposta[i]

        ;; Comparar letras em mesma posicao para ver se sao iguais e, se forem:
        ;; * Setar vetor de coloracao para VERDE(2) na posicao
        ;; * Setar vetores de checa_na_resposta e checado_no_chute para TRUE na posicao
        cmp r1, r2 ; palavraChute[i] == palavraResposta[i] ? seguir : loop continue
        jne nao_sao_iguais_em_mesma_posicao
            loadn r1, #coloracao 
            loadn r2, #checado_na_resposta 
            loadn r7, #checado_no_chute

            add r1, r1, r5 ;r1 = &coloracao[i]
            add r2, r2, r5 ;r2 = &checado_na_resposta[i]
            add r7, r7, r5 ;r7 = &checado_no_chute[i]

            loadn r0, #2  
            storei r1, r0 ; coloracao[i] = 2 {VERDE}

            loadn r0, #1
            storei r2, r0 ; checado_na_resposta[i] = TRUE
            storei r7, r0 ; checado_no_chute[i] = TRUE

        nao_sao_iguais_em_mesma_posicao:        

        inc r5 ;; incrementar variavel i de controle do loop1
        ;; continuar no loop enquanto i nao for 5
        loadn r0, #5
        cmp r5, r0
        jne definir_coloracao_loop1 
    definir_coloracao_fim_loop1:
    
    ;; Loop2 (externo e interno): Checar letras em outras posicoes ("Testa-Amarelo-ou-Vermelho")
    ;; r5 := i & r6 := j
    loadn r5, #0 ;; i = 0 (inicializacao da variavel de controle do loop2 externo)
    definir_coloracao_loop2_externo:
        ;;;; Primeiro ver se posicao já foi checada no chute. Se sim, passar para proxima
        loadn r1, #checado_no_chute
        add r1, r1, r5  ; r1 = &checado_no_chute[i]
        loadi r1, r1    ; r1 = checado_no_chute[i]
        loadn r0, #1    ; r0 = TRUE
        cmp r1, r0      ; checado_no_chute[i] == TRUE ? loop continue : seguir
        jeq definir_coloracao_loop2_externo_continue
        ;;;; ----

        loadn r6, #0 ;; i = 0 (inicializacao da variavel de controle do loop2 interno)
        definir_coloracao_loop2_interno:
            ;;;; Primeiro ver se posicao já foi checada na resposta. Se sim, passar para proxima
            loadn r1, #checado_na_resposta
            add r1, r1, r6 ; r1 = &checado_na_resposta[j]
            loadi r1, r1   ; r1 = checado_na_resposta[j]
            loadn r0, #1   ; r0 = TRUE
            cmp r1, r0     ; checado_na_resposta[i] == TRUE ? loop continue : seguir
            jeq definir_coloracao_loop2_interno_continue
            ;;;; ----

            ;; Comparar a letra do chute na posicao com a da resposta na posicao j.
            ;; Se forem iguais, setar vetor de coloracao na posicao i para AMARELO(1)

            add r1, r3, r5 ; r1 = &palavraChute[i]
            add r2, r4, r6 ; r2 = &palavraResposta[j]

            loadi r1, r1 ; r1 = palavraChute[i]
            loadi r2, r2 ; r2 = palavraResposta[j]

            cmp r1, r2 ; palavraChute[i] == palavraResposta[j] ? seguir : loop continue
            jne definir_coloracao_loop2_interno_continue

                loadn r1, #coloracao
                loadn r2, #checado_no_chute
                loadn r7, #checado_na_resposta

                add r1, r1, r5 ; r1 = &coloracao[i]
                add r2, r2, r5 ; r2 = &checado_no_chute[i]
                add r7, r7, r6 ; r3 = &checa_na_resposta[j]

                loadn r0, #1   ; const TRUE ou AMARELO

                storei r1, r0 ; coloracao[i] = 1 {AMARELO}
                storei r2, r0 ; checado_no_chute[i] = TRUE
                storei r7, r0 ; checa_na_resposta[j] = TRUE
        
        definir_coloracao_loop2_interno_continue:
            inc r6 ;; incrementar variavel j de controle do loop2 interno
            ;; continuar no loop enquanto j nao for 5
            loadn r0, #5
            cmp r6, r0
            jne definir_coloracao_loop2_interno
        definir_coloracao_fim_loop2_interno:
        ;;;
    definir_coloracao_loop2_externo_continue:
        inc r5 ;; incrementar variavel i de controle do loop2 externo
        ;; continuar no loop enquanto i nao for 5
        loadn r0, #5
        cmp r5, r0
        jne definir_coloracao_loop2_externo
    definir_coloracao_fim_loop2_externo:

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1 
    pop r0
    pop fr
    
    rts

;;-------------------------------
;;------ CHECA RESPOSTA ---------
;;-------------------------------
;; Rotina que compara a palavra-chute com a palavra-resposta para
;; ver se sao iguais. Se forem, seta variavel certo para TRUE (1).
;; Caso contrario, seta certo para FALSE (0)

checa_resposta:
    push fr
    push r0 
    push r1 ; letra chute
    push r2 ; letra resposta
    push r3 ; endereco da letra chute
    push r4 ; endereco da letra resposta 

    loadn r0, #5 ; controlador do loop (5 repeticoes)

    loadn r3, #palavraChute  ;; r3 := &palavraChute[0]
    load r4, palavraResposta ;; r4 := &palavraresposta[0]

    ;; Loop que compara chute e resposta letra a letra
    checa_resposta_loop:
        loadi r1, r3 ;; r1 = palavraChute[i]
        loadi r2, r4 ;; r2 = palavraresposta[i]

        ;; Se letras forem diferentes, sair do loop
        cmp r1, r2
        jne checa_resposta_fim_loop

        inc r3 ;; Passar para proxima letra da palavra-chute
        inc r4 ;; Passar para proxima letra da palavra-resposta
    dec r0
    jnz checa_resposta_loop

    checa_resposta_fim_loop:

    ;; As palavras sao iguais se o loop completou as 5 voltas, ou seja
    ;; a variavel de controle r0 chegou em 0:
    loadn r1, #0 ;; 0 para comparar
    cmp r0, r1 ;; r0 == 0?
    jeq sao_iguais

    loadn r1, #0
    store certo, r1 ;; Retorna que está errado

    jmp fim_checa_resposta
    sao_iguais:
        loadn r1, #1
        store certo, r1 ;; Retorna que está certo

    fim_checa_resposta:

    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    pop fr

    rts

;;----------------------------------
;;------ IMPRIME COM DICAS ---------
;;----------------------------------
;; Imprime a palavra-chute com as cores-dicas, baseado no vetor
;; de coloracao. Os codigos das cores sao:
;; * 0 : VERMELHO
;; * 1 : AMARELO
;; * 2 : VERDE
;; PARAMS: 
;; --> r1 eh o endereco da palavra
;; --> r7 eh a posicao da primeira caixinha em que imprimir

imprime_com_dicas:
    push fr
    push r0 
    push r1 ; endereco da palavra #
    push r2 ; comparador
    push r3 ; contador de loop
    push r4 ; valor de coloracao a comparar
    push r5 ; cor
    push r6 ; letra atual da palavra
    push r7 ; posicao da primeira caixinha #

    load r5, Branco ; Cor padrao

    loadn r3, #5

    loadn r0, #coloracao 

    imprime_com_dicas_loop:
        loadi r6, r1 ;; Recebe letra atual da palavra
        loadi r4, r0 ;; Recebe valor da coloracao
        
        loadn r2, #0
        cmp r4, r2
        jeq eh_vermelho

        loadn r2, #1
        cmp r4, r2
        jeq eh_amarelo

        loadn r2, #2
        cmp r4, r2
        jeq eh_verde

        eh_vermelho:
            load r5, Vermelho
            jmp fim_testagem

        eh_amarelo:
            load r5, Amarelo
            jmp fim_testagem
        
        eh_verde:
            load r5, Verde
            jmp fim_testagem

        fim_testagem:

        add r6, r6, r5
        outchar r6, r7

        inc r0
        inc r1
        inc r7
        inc r7
        inc r7
        inc r7
    dec r3
    jnz imprime_com_dicas_loop

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    pop fr

    rts

;;----------------------------------
;;------ LER PALAVRA CHUTE ---------
;;----------------------------------
;; Rotina que le a palavra-chute do jogador enquanto mostra as letras
;; digitadas dentro das caixinhas de uma determinada linha.
;; A tecla '1' serve para apagar e e preciso confirmar com ENTER. 

lerPalavraChute:  ; Rotina que recebe uma palavraChute (r7 <- posicao primeira letra)
    ;salva as variaveis anteriores e inicializa as novas
    push fr    ; Protege o registrador de flags
    push r0    ; Recebe letra digitada
    push r1    ; codigo do '1' (nosso backspace)
    push r2    ; Contador de letras para o vetor que armazena a palavra
    push r3    ; ponteiro para palavra
    push r4    ; palavra[r3+r2]
    push r5    ; Tamanho maximo da palavra
    push r6    ; Cor a imprimir
    push r7    ; Posicao inicial de escrita

    loadn r1, #'1'               ; codigo '1' (nosso backspace)
    loadn r2, #0                ; inicia r2 = 0
    loadn r3, #palavraChute     ; ponteiro para palavra
    loadn r5, #5                ; Tamanho maximo da palavra
    ;----------------
    lerPalavraChute_Loop:
        call digLetra    ; Espera que uma tecla seja digitada e salva na variavel global "Letra"

        load r0, Letra        ; Letra --> r0

        ;; Primeiro ver se é enter para nao contar
        loadn r6, #13 ;; enter(13)
        cmp r0, r6
        jeq lerPalavraChute_Loop
        ;; --------------------------------------

        cmp r0, r1          ;comparacao se r0 eh '1' (nosso backspace)
        jne lerPalavraChute_segue        ; se for '1' (nosso backspace)

        eh_backspace:
            loadn r6, #0  ; para comparar com 0
            cmp r2, r6    ; r2 == 0?
            jeq lerPalavraChute_Loop ; se for, volta para o loop

            dec r2 ; se nao for 0, decrementa tamanho da palavra
            dec r7 ;    e decrementa 4 na posicao de escrita
                dec r7
                dec r7
                dec r7
            loadn r0, #' ' ; e vai escrever espaço em cima da ultima posicao 
            outchar r0, r7 ; imprime na posicao

            jmp lerPalavraChute_Loop
        lerPalavraChute_segue:
        
        add r4, r3, r2
        storei r4, r0        ; palavra[r2] = Letra
        inc r2
            ; add r0, r0, r6 ; coloca cor
        outchar r0, r7 ; imprime na posicao
        inc r7       ; aumenta 4 na posicao de escrita
            inc r7
            inc r7
            inc r7

            cmp r2, r5            ; verifica se r2 = 5 (tam maximo)
        jne lerPalavraChute_Loop      ; Se for, sai, senao goto loop!!
        ;; eh o tamanho maximo -> aguardar enter ou '1' (nosso backspace)

        loadn r6, #13 ;; enter(13)
        lerPalavraChute_loop_enter:
            call digLetra    ; Espera que uma tecla seja digitada e salva na variavel global "Letra"

            load r0, Letra        ; Letra --> r0
            cmp r0, r6          ;comparacao se r0 eh Enter (13)
            jeq lerPalavraChute_End

            cmp r0, r1  ; Eh '1' (nosso backspace)?
            jeq eh_backspace
        jmp lerPalavraChute_loop_enter
          
    lerPalavraChute_End:
    ; Poe um \0 no final da palavra pra poder imprimir e testar!!
    loadn r0, #0
    add r4, r3, r2
    storei r4, r0        ; palavra[r2] = /0
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    pop fr
    rts    

;;--------------------------------
;;------ SORTEAR PALAVRA ---------
;;--------------------------------
;; Sorteia palavra-respota baseado no numero Rand e salva
;; endereco da palavra sorteada em palavraResposta.

sortearPalavra:
    push R0
    push R1
    push R2

    load R0, Rand

    load R1, n_palavras
    mod R0, R0, R1 ; rand = rand % n_palavras

    loadn R2, #palavras

    add R2, R2, R0 ; &palavras[0] = &palavras[0] + rand

    loadi R0, R2   ; R0 = &palavras[rand]

    store palavraResposta, R0

    pop R2
    pop R1
    pop R0

    RTS

;;--------------------------
;;------ DE NOVO ? ---------
;;--------------------------
;; Rotina que pergunta para o jogador se ele que jogar mais uma partida.
;; Lendo da variavel sim_ou_nao: se for 's', indica que o usuário quer
;; jogar mais uma rodada. Se for qualquer outra coisa, indica que o jogador
;; nao quer mais continuas jogando.

denovo_pergunta:
    push r0
    push r1
    push r2
    push r7

    loadn r0, #1063
    loadn r1, #msg_denovo
    load r2, Branco
    call Imprimestr

    loadn r0, #1108
    store quadradinhoPosition, r0
    call printquadradinho

    loadn r7, #1149
    call lerSimouNao

    pop r7
    pop r2
    pop r1
    pop r0
    rts

;;--------------------------------
;;------ PRINT CAIXINHAS ---------
;;--------------------------------
;; Rotina para imprimir as 6 linhas de 5 caixinhas do jogo

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

;;---------------------------------
;;------ DIGITE UMA LETRA ---------
;;---------------------------------
;; Rotina que le uma letra e salva na variavel Letra.
;; Alem disso, aproveita o loop de entrada para gerar um numero
;; pseudoaleatorio entre 0 e (n_palavras - 1), que ira ajudar
;; a sortear uma palavra para as partidas do jogo

digLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push fr		; Protege o registrador de flags
	push r0
	push r1
	push r2
    push r3
    push r4

	loadn r1, #255	; Se nao digitar nada vem 255
	loadn r2, #0	; Logo que programa a FPGA o inchar vem 0
    load r3, Rand    ; numero aleatorio (comeca com valor enterior)

    load r4, n_palavras

    digLetra_Loop:
        inc r3
        mod r3, r3, r4 ; não deixa rand ultrapassar n_palavras
		
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
	
    loadn r2, #0 ; para comparar com 0

    store Rand, r3 ; Retorna um número pseudoaleatorio entre 0 e (n_palavras - 1)

    pop r4
    pop r3
	pop r2
	pop r1
	pop r0
	pop fr

	rts

;;------------------------------- 
;;------ IMPRIME STRING ---------
;;-------------------------------
;;  Rotina de Impresao de Mensagens:

Imprimestr:		    
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

;;----------------------------------- 
;;------ PRINT TELA INICIAL ---------
;;-----------------------------------
;; Rotina para imprimir a tela inicial do jogo

printTelaInicial:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #Screen
  loadn R1, #0
  loadn R2, #1200

  printTelaInicialLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printTelaInicialLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts

;;---------------------------------- 
;;------ PRINT QUADRADINHO ---------
;;----------------------------------
;; Rotina para imprimir desenho de um quadrado em quadradinhoPosition

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

;;----------------------------------- 
;;------ PRINT HINTS SCREEN ---------
;;-----------------------------------
;; Rotina para imprimir tela com instruções para apagar letra ('1') e
;; para enviar palavra ('ENTER')

printHintsScreen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #Hints
  loadn R1, #0
  loadn R2, #1200

  printHintsScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printHintsScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts

;;--------------------------------------------
;;------ ZERAR VARIAVEIR DE CHECAGEM ---------
;;--------------------------------------------
;; As variavei de checagem sao:
;; * certo : booleana que indica se o chute bate com a resposta
;; * coloracao : (VERMELHO(0), AMARELO(1), VERDE(2))
;; * checado_na_resposta : bool[5]
;; * checado_no_chute : bool[5]
;; Esta rotina seta todos os valores booleanos para FALSE (0) e
;; todas as posicoes do vetor de coloracao para VERMELHO (0)

zerar_variaveis_de_checagem:
    push fr
    push r0
    push r1
    push r2
    push r3
    push r7

    loadn r0, #0 ; const 0

    store certo, r0 ; certo := FALSE

    loadn r1, #checado_na_resposta  
    loadn r2, #checado_no_chute
    loadn r3, #coloracao
    loadn r7, #5 ; controle de loop (5 repeticoes)

    zerar_loop:
        storei r1, r0 ;; checa_na_resposta[i] = FALSE
        storei r2, r0 ;; checado_no_chute[i] = FALSE
        storei r3, r0 ;; coloracao[i] = VERMELHO
        inc r1
        inc r2
        inc r3
    dec r7
    jnz zerar_loop

    pop r7
    pop r3 
    pop r2 
    pop r1
    pop r0
    pop fr

    rts

;;------------------------------- 
;;------ LER SIM OU NAO ---------
;;------------------------------- 
;; Rotina similar a de ler palavra-chute, mas destinada a ler
;; a string sim_ou_nao de 1 caractere, que se for lida como "s",
;; indicara que o jogador que jogar mais uma partida.
;; É possível apagar com a tecla '1' e e necessario confirmar com ENTER.

lerSimouNao:  ; Rotina que recebe uma palavraChute (r7 <- posicao primeira letra)
    ;salva as variaveis anteriores e inicializa as novas
    push fr    ; Protege o registrador de flags
    push r0    ; Recebe letra digitada
    push r1    ; codigo do '1' (nosso backspace)
    push r2    ; Contador de letras para o vetor que armazena a palavra
    push r3    ; ponteiro para palavra
    push r4    ; palavra[r3+r2]
    push r5    ; Tamanho maximo da palavra
    push r6    ; Cor a imprimir
    push r7    ; Posicao inicial de escrita #

    loadn r1, #'1'              ; codigo '1' (nosso backspace)
    loadn r2, #0                ; inicia r2 = 0
    loadn r3, #sim_ou_nao       ; ponteiro para palavra
    loadn r5, #1                ; Tamanho maximo da palavra
    ;----------------
    lerSimouNao_Loop:
        call digLetra    ; Espera que uma tecla seja digitada e salva na variavel global "Letra"

        load r0, Letra        ; Letra --> r0

        ;; Primeiro ver se é enter para nao contar
        loadn r6, #13 ;; enter(13)
        cmp r0, r6
        jeq lerSimouNao_Loop
        ;; --------------------------------------

        cmp r0, r1          ;comparacao se r0 eh '1' (nosso backspace)
        jne lerSimouNao_segue        ; se for '1' (nosso backspace)

        eh_backspace:
            loadn r6, #0  ; para comparar com 0
            cmp r2, r6    ; r2 == 0?
            jeq lerSimouNao_Loop ; se for, volta para o loop

            dec r2 ; se nao for 0, decrementa tamanho da palavra
            dec r7 ;    e decrementa 4 na posicao de escrita
                dec r7
                dec r7
                dec r7
            loadn r0, #' ' ; e vai escrever espaço em cima da ultima posicao 
            outchar r0, r7 ; imprime na posicao

            jmp lerSimouNao_Loop
        lerSimouNao_segue:
        
        add r4, r3, r2
        storei r4, r0        ; palavra[r2] = Letra
        inc r2
            ; add r0, r0, r6 ; coloca cor
        outchar r0, r7 ; imprime na posicao
        inc r7       ; aumenta 4 na posicao de escrita
            inc r7
            inc r7
            inc r7

            cmp r2, r5            ; verifica se r2 = 5 (tam maximo)
        jne lerSimouNao_Loop      ; Se for, sai, senao goto loop!!
        ;; eh o tamanho maximo -> aguardar enter ou '1' (nosso backspace)

        loadn r6, #13 ;; enter(13)
        lerSimouNaor_loop_enter:
            call digLetra    ; Espera que uma tecla seja digitada e salva na variavel global "Letra"

            load r0, Letra        ; Letra --> r0
            cmp r0, r6          ;comparacao se r0 eh Enter (13)
            jeq lerSimouNao_End

            cmp r0, r1  ; Eh '1' (nosso backspace)?
            jeq eh_backspace
        jmp lerSimouNaor_loop_enter
          
    lerSimouNao_End:
    ; Poe um \0 no final da palavra pra poder imprimir e testar!!
    loadn r0, #0
    add r4, r3, r2
    storei r4, r0        ; palavra[r2] = /0
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    pop fr
    rts    

;;;;

;;-------------------------
;;--- OUTRAS DEFINICOES ---
;;-------------------------

;; --- Vetor de Coloracao ---
    ;; 0 -> VERMELHO (letra nao esta na resposta)
    ;; 1 -> AMARELO  (letra na resposta em outra posicao)
    ;; 2 -> VERDE    (letra na resposta em posicao correta)
    coloracao: var #5

;; --- Variaveis de Checagem --- 
    certo: var #1 ; booleano para dizer se a palavra bateu ou não
    checado_na_resposta: var #5
    checado_no_chute: var #5

;; --- sim ou nao para de novo ---
    sim_ou_nao: var #2

;; --- Guardando desenho do quadradinho ---
    quadradinhoPosition : var #1

    quadradinho : var #8
    static quadradinho + #0, #2 ;   se
    static quadradinho + #1, #1 ;   horizontal
    static quadradinho + #2, #3 ;   sd
    ;38  espacos para o proximo caractere
    static quadradinho + #3, #0 ;   vertical
    ;2  espacos para o proximo caractere
    static quadradinho + #4, #0 ;   vertical
    ;38  espacos para o proximo caractere
    static quadradinho + #5, #4 ;   ie
    static quadradinho + #6, #1 ;   horizontal
    static quadradinho + #7, #5 ;   id

    quadradinhoGaps : var #8
    static quadradinhoGaps + #0, #0
    static quadradinhoGaps + #1, #0
    static quadradinhoGaps + #2, #0
    static quadradinhoGaps + #3, #37
    static quadradinhoGaps + #4, #1
    static quadradinhoGaps + #5, #37
    static quadradinhoGaps + #6, #0
    static quadradinhoGaps + #7, #0

;; --- Guardando Tela Inicial ---
Screen : var #1200
  ;Linha 0
  static Screen + #0, #127
  static Screen + #1, #127
  static Screen + #2, #127
  static Screen + #3, #127
  static Screen + #4, #127
  static Screen + #5, #127
  static Screen + #6, #127
  static Screen + #7, #127
  static Screen + #8, #127
  static Screen + #9, #127
  static Screen + #10, #127
  static Screen + #11, #127
  static Screen + #12, #127
  static Screen + #13, #127
  static Screen + #14, #127
  static Screen + #15, #127
  static Screen + #16, #127
  static Screen + #17, #127
  static Screen + #18, #127
  static Screen + #19, #127
  static Screen + #20, #127
  static Screen + #21, #127
  static Screen + #22, #127
  static Screen + #23, #127
  static Screen + #24, #127
  static Screen + #25, #127
  static Screen + #26, #127
  static Screen + #27, #127
  static Screen + #28, #127
  static Screen + #29, #127
  static Screen + #30, #127
  static Screen + #31, #127
  static Screen + #32, #127
  static Screen + #33, #127
  static Screen + #34, #127
  static Screen + #35, #127
  static Screen + #36, #127
  static Screen + #37, #127
  static Screen + #38, #127
  static Screen + #39, #127

  ;Linha 1
  static Screen + #40, #127
  static Screen + #41, #127
  static Screen + #42, #127
  static Screen + #43, #127
  static Screen + #44, #127
  static Screen + #45, #127
  static Screen + #46, #2310
  static Screen + #47, #2310
  static Screen + #48, #2310
  static Screen + #49, #2310
  static Screen + #50, #127
  static Screen + #51, #127
  static Screen + #52, #2822
  static Screen + #53, #2822
  static Screen + #54, #2822
  static Screen + #55, #2822
  static Screen + #56, #127
  static Screen + #57, #127
  static Screen + #58, #518
  static Screen + #59, #518
  static Screen + #60, #518
  static Screen + #61, #518
  static Screen + #62, #127
  static Screen + #63, #127
  static Screen + #64, #6
  static Screen + #65, #6
  static Screen + #66, #6
  static Screen + #67, #6
  static Screen + #68, #127
  static Screen + #69, #127
  static Screen + #70, #6
  static Screen + #71, #127
  static Screen + #72, #127
  static Screen + #73, #6
  static Screen + #74, #127
  static Screen + #75, #127
  static Screen + #76, #127
  static Screen + #77, #127
  static Screen + #78, #127
  static Screen + #79, #127

  ;Linha 2
  static Screen + #80, #127
  static Screen + #81, #127
  static Screen + #82, #127
  static Screen + #83, #127
  static Screen + #84, #127
  static Screen + #85, #127
  static Screen + #86, #2310
  static Screen + #87, #127
  static Screen + #88, #127
  static Screen + #89, #2310
  static Screen + #90, #127
  static Screen + #91, #127
  static Screen + #92, #2822
  static Screen + #93, #127
  static Screen + #94, #127
  static Screen + #95, #127
  static Screen + #96, #127
  static Screen + #97, #127
  static Screen + #98, #518
  static Screen + #99, #127
  static Screen + #100, #127
  static Screen + #101, #127
  static Screen + #102, #127
  static Screen + #103, #127
  static Screen + #104, #6
  static Screen + #105, #127
  static Screen + #106, #127
  static Screen + #107, #127
  static Screen + #108, #127
  static Screen + #109, #127
  static Screen + #110, #6
  static Screen + #111, #6
  static Screen + #112, #6
  static Screen + #113, #6
  static Screen + #114, #127
  static Screen + #115, #127
  static Screen + #116, #127
  static Screen + #117, #127
  static Screen + #118, #127
  static Screen + #119, #127

  ;Linha 3
  static Screen + #120, #127
  static Screen + #121, #127
  static Screen + #122, #127
  static Screen + #123, #127
  static Screen + #124, #127
  static Screen + #125, #127
  static Screen + #126, #2310
  static Screen + #127, #2310
  static Screen + #128, #2310
  static Screen + #129, #2310
  static Screen + #130, #127
  static Screen + #131, #127
  static Screen + #132, #2822
  static Screen + #133, #2822
  static Screen + #134, #2822
  static Screen + #135, #2822
  static Screen + #136, #127
  static Screen + #137, #127
  static Screen + #138, #518
  static Screen + #139, #518
  static Screen + #140, #518
  static Screen + #141, #518
  static Screen + #142, #127
  static Screen + #143, #127
  static Screen + #144, #6
  static Screen + #145, #6
  static Screen + #146, #6
  static Screen + #147, #6
  static Screen + #148, #127
  static Screen + #149, #127
  static Screen + #150, #6
  static Screen + #151, #7
  static Screen + #152, #8
  static Screen + #153, #6
  static Screen + #154, #127
  static Screen + #155, #127
  static Screen + #156, #127
  static Screen + #157, #127
  static Screen + #158, #127
  static Screen + #159, #127

  ;Linha 4
  static Screen + #160, #127
  static Screen + #161, #127
  static Screen + #162, #127
  static Screen + #163, #127
  static Screen + #164, #127
  static Screen + #165, #127
  static Screen + #166, #2310
  static Screen + #167, #127
  static Screen + #168, #127
  static Screen + #169, #2310
  static Screen + #170, #127
  static Screen + #171, #127
  static Screen + #172, #127
  static Screen + #173, #127
  static Screen + #174, #127
  static Screen + #175, #2822
  static Screen + #176, #127
  static Screen + #177, #127
  static Screen + #178, #127
  static Screen + #179, #127
  static Screen + #180, #127
  static Screen + #181, #518
  static Screen + #182, #127
  static Screen + #183, #127
  static Screen + #184, #6
  static Screen + #185, #127
  static Screen + #186, #127
  static Screen + #187, #127
  static Screen + #188, #127
  static Screen + #189, #127
  static Screen + #190, #6
  static Screen + #191, #127
  static Screen + #192, #127
  static Screen + #193, #6
  static Screen + #194, #127
  static Screen + #195, #127
  static Screen + #196, #127
  static Screen + #197, #127
  static Screen + #198, #127
  static Screen + #199, #127

  ;Linha 5
  static Screen + #200, #127
  static Screen + #201, #127
  static Screen + #202, #127
  static Screen + #203, #127
  static Screen + #204, #127
  static Screen + #205, #127
  static Screen + #206, #2310
  static Screen + #207, #127
  static Screen + #208, #127
  static Screen + #209, #2310
  static Screen + #210, #127
  static Screen + #211, #127
  static Screen + #212, #2822
  static Screen + #213, #2822
  static Screen + #214, #2822
  static Screen + #215, #2822
  static Screen + #216, #127
  static Screen + #217, #127
  static Screen + #218, #518
  static Screen + #219, #518
  static Screen + #220, #518
  static Screen + #221, #518
  static Screen + #222, #127
  static Screen + #223, #127
  static Screen + #224, #6
  static Screen + #225, #6
  static Screen + #226, #6
  static Screen + #227, #6
  static Screen + #228, #127
  static Screen + #229, #127
  static Screen + #230, #6
  static Screen + #231, #127
  static Screen + #232, #127
  static Screen + #233, #6
  static Screen + #234, #127
  static Screen + #235, #127
  static Screen + #236, #127
  static Screen + #237, #127
  static Screen + #238, #127
  static Screen + #239, #127

  ;Linha 6
  static Screen + #240, #127
  static Screen + #241, #127
  static Screen + #242, #127
  static Screen + #243, #127
  static Screen + #244, #127
  static Screen + #245, #127
  static Screen + #246, #127
  static Screen + #247, #127
  static Screen + #248, #127
  static Screen + #249, #127
  static Screen + #250, #127
  static Screen + #251, #127
  static Screen + #252, #127
  static Screen + #253, #127
  static Screen + #254, #127
  static Screen + #255, #127
  static Screen + #256, #127
  static Screen + #257, #127
  static Screen + #258, #127
  static Screen + #259, #127
  static Screen + #260, #127
  static Screen + #261, #127
  static Screen + #262, #127
  static Screen + #263, #127
  static Screen + #264, #127
  static Screen + #265, #127
  static Screen + #266, #127
  static Screen + #267, #127
  static Screen + #268, #127
  static Screen + #269, #127
  static Screen + #270, #127
  static Screen + #271, #127
  static Screen + #272, #127
  static Screen + #273, #127
  static Screen + #274, #127
  static Screen + #275, #127
  static Screen + #276, #127
  static Screen + #277, #127
  static Screen + #278, #127
  static Screen + #279, #127

  ;Linha 7
  static Screen + #280, #127
  static Screen + #281, #127
  static Screen + #282, #127
  static Screen + #283, #127
  static Screen + #284, #127
  static Screen + #285, #127
  static Screen + #286, #127
  static Screen + #287, #127
  static Screen + #288, #6
  static Screen + #289, #6
  static Screen + #290, #6
  static Screen + #291, #9
  static Screen + #292, #127
  static Screen + #293, #6
  static Screen + #294, #127
  static Screen + #295, #127
  static Screen + #296, #127
  static Screen + #297, #127
  static Screen + #298, #6
  static Screen + #299, #6
  static Screen + #300, #6
  static Screen + #301, #6
  static Screen + #302, #127
  static Screen + #303, #6
  static Screen + #304, #6
  static Screen + #305, #6
  static Screen + #306, #6
  static Screen + #307, #127
  static Screen + #308, #12
  static Screen + #309, #6
  static Screen + #310, #6
  static Screen + #311, #9
  static Screen + #312, #127
  static Screen + #313, #127
  static Screen + #314, #127
  static Screen + #315, #127
  static Screen + #316, #127
  static Screen + #317, #127
  static Screen + #318, #127
  static Screen + #319, #127

  ;Linha 8
  static Screen + #320, #127
  static Screen + #321, #127
  static Screen + #322, #127
  static Screen + #323, #127
  static Screen + #324, #127
  static Screen + #325, #127
  static Screen + #326, #127
  static Screen + #327, #127
  static Screen + #328, #6
  static Screen + #329, #127
  static Screen + #330, #127
  static Screen + #331, #6
  static Screen + #332, #127
  static Screen + #333, #6
  static Screen + #334, #127
  static Screen + #335, #127
  static Screen + #336, #127
  static Screen + #337, #127
  static Screen + #338, #6
  static Screen + #339, #127
  static Screen + #340, #127
  static Screen + #341, #127
  static Screen + #342, #127
  static Screen + #343, #6
  static Screen + #344, #127
  static Screen + #345, #127
  static Screen + #346, #127
  static Screen + #347, #127
  static Screen + #348, #6
  static Screen + #349, #127
  static Screen + #350, #127
  static Screen + #351, #6
  static Screen + #352, #127
  static Screen + #353, #127
  static Screen + #354, #127
  static Screen + #355, #127
  static Screen + #356, #127
  static Screen + #357, #127
  static Screen + #358, #127
  static Screen + #359, #127

  ;Linha 9
  static Screen + #360, #127
  static Screen + #361, #127
  static Screen + #362, #127
  static Screen + #363, #127
  static Screen + #364, #127
  static Screen + #365, #127
  static Screen + #366, #127
  static Screen + #367, #127
  static Screen + #368, #6
  static Screen + #369, #6
  static Screen + #370, #6
  static Screen + #371, #6
  static Screen + #372, #127
  static Screen + #373, #6
  static Screen + #374, #127
  static Screen + #375, #127
  static Screen + #376, #127
  static Screen + #377, #127
  static Screen + #378, #6
  static Screen + #379, #6
  static Screen + #380, #6
  static Screen + #381, #6
  static Screen + #382, #127
  static Screen + #383, #6
  static Screen + #384, #127
  static Screen + #385, #127
  static Screen + #386, #127
  static Screen + #387, #127
  static Screen + #388, #6
  static Screen + #389, #127
  static Screen + #390, #127
  static Screen + #391, #6
  static Screen + #392, #127
  static Screen + #393, #127
  static Screen + #394, #127
  static Screen + #395, #127
  static Screen + #396, #127
  static Screen + #397, #127
  static Screen + #398, #127
  static Screen + #399, #127

  ;Linha 10
  static Screen + #400, #127
  static Screen + #401, #127
  static Screen + #402, #127
  static Screen + #403, #127
  static Screen + #404, #127
  static Screen + #405, #127
  static Screen + #406, #127
  static Screen + #407, #127
  static Screen + #408, #6
  static Screen + #409, #127
  static Screen + #410, #127
  static Screen + #411, #6
  static Screen + #412, #127
  static Screen + #413, #6
  static Screen + #414, #127
  static Screen + #415, #127
  static Screen + #416, #127
  static Screen + #417, #127
  static Screen + #418, #6
  static Screen + #419, #127
  static Screen + #420, #127
  static Screen + #421, #127
  static Screen + #422, #127
  static Screen + #423, #6
  static Screen + #424, #127
  static Screen + #425, #127
  static Screen + #426, #127
  static Screen + #427, #127
  static Screen + #428, #6
  static Screen + #429, #127
  static Screen + #430, #127
  static Screen + #431, #6
  static Screen + #432, #127
  static Screen + #433, #127
  static Screen + #434, #127
  static Screen + #435, #127
  static Screen + #436, #127
  static Screen + #437, #127
  static Screen + #438, #127
  static Screen + #439, #127

  ;Linha 11
  static Screen + #440, #127
  static Screen + #441, #127
  static Screen + #442, #127
  static Screen + #443, #127
  static Screen + #444, #127
  static Screen + #445, #127
  static Screen + #446, #127
  static Screen + #447, #127
  static Screen + #448, #6
  static Screen + #449, #6
  static Screen + #450, #6
  static Screen + #451, #10
  static Screen + #452, #127
  static Screen + #453, #6
  static Screen + #454, #6
  static Screen + #455, #6
  static Screen + #456, #6
  static Screen + #457, #127
  static Screen + #458, #6
  static Screen + #459, #6
  static Screen + #460, #6
  static Screen + #461, #6
  static Screen + #462, #127
  static Screen + #463, #6
  static Screen + #464, #6
  static Screen + #465, #6
  static Screen + #466, #6
  static Screen + #467, #127
  static Screen + #468, #11
  static Screen + #469, #6
  static Screen + #470, #6
  static Screen + #471, #10
  static Screen + #472, #127
  static Screen + #473, #127
  static Screen + #474, #127
  static Screen + #475, #127
  static Screen + #476, #127
  static Screen + #477, #127
  static Screen + #478, #127
  static Screen + #479, #127

  ;Linha 12
  static Screen + #480, #127
  static Screen + #481, #127
  static Screen + #482, #127
  static Screen + #483, #127
  static Screen + #484, #127
  static Screen + #485, #127
  static Screen + #486, #127
  static Screen + #487, #127
  static Screen + #488, #127
  static Screen + #489, #127
  static Screen + #490, #127
  static Screen + #491, #127
  static Screen + #492, #127
  static Screen + #493, #127
  static Screen + #494, #127
  static Screen + #495, #127
  static Screen + #496, #127
  static Screen + #497, #127
  static Screen + #498, #127
  static Screen + #499, #127
  static Screen + #500, #127
  static Screen + #501, #127
  static Screen + #502, #127
  static Screen + #503, #127
  static Screen + #504, #127
  static Screen + #505, #127
  static Screen + #506, #127
  static Screen + #507, #127
  static Screen + #508, #127
  static Screen + #509, #127
  static Screen + #510, #127
  static Screen + #511, #127
  static Screen + #512, #127
  static Screen + #513, #127
  static Screen + #514, #127
  static Screen + #515, #127
  static Screen + #516, #127
  static Screen + #517, #127
  static Screen + #518, #127
  static Screen + #519, #127

  ;Linha 13
  static Screen + #520, #127
  static Screen + #521, #127
  static Screen + #522, #127
  static Screen + #523, #127
  static Screen + #524, #127
  static Screen + #525, #127
  static Screen + #526, #127
  static Screen + #527, #127
  static Screen + #528, #127
  static Screen + #529, #127
  static Screen + #530, #127
  static Screen + #531, #127
  static Screen + #532, #127
  static Screen + #533, #127
  static Screen + #534, #127
  static Screen + #535, #127
  static Screen + #536, #127
  static Screen + #537, #127
  static Screen + #538, #127
  static Screen + #539, #127
  static Screen + #540, #127
  static Screen + #541, #127
  static Screen + #542, #127
  static Screen + #543, #127
  static Screen + #544, #127
  static Screen + #545, #127
  static Screen + #546, #127
  static Screen + #547, #127
  static Screen + #548, #127
  static Screen + #549, #127
  static Screen + #550, #127
  static Screen + #551, #127
  static Screen + #552, #127
  static Screen + #553, #127
  static Screen + #554, #127
  static Screen + #555, #127
  static Screen + #556, #127
  static Screen + #557, #127
  static Screen + #558, #127
  static Screen + #559, #127

  ;Linha 14
  static Screen + #560, #127
  static Screen + #561, #127
  static Screen + #562, #127
  static Screen + #563, #127
  static Screen + #564, #127
  static Screen + #565, #127
  static Screen + #566, #127
  static Screen + #567, #127
  static Screen + #568, #127
  static Screen + #569, #127
  static Screen + #570, #127
  static Screen + #571, #127
  static Screen + #572, #127
  static Screen + #573, #127
  static Screen + #574, #127
  static Screen + #575, #127
  static Screen + #576, #127
  static Screen + #577, #127
  static Screen + #578, #127
  static Screen + #579, #127
  static Screen + #580, #127
  static Screen + #581, #127
  static Screen + #582, #127
  static Screen + #583, #127
  static Screen + #584, #127
  static Screen + #585, #127
  static Screen + #586, #127
  static Screen + #587, #127
  static Screen + #588, #127
  static Screen + #589, #127
  static Screen + #590, #127
  static Screen + #591, #127
  static Screen + #592, #127
  static Screen + #593, #127
  static Screen + #594, #127
  static Screen + #595, #127
  static Screen + #596, #127
  static Screen + #597, #127
  static Screen + #598, #127
  static Screen + #599, #127

  ;Linha 15
  static Screen + #600, #127
  static Screen + #601, #127
  static Screen + #602, #127
  static Screen + #603, #127
  static Screen + #604, #127
  static Screen + #605, #127
  static Screen + #606, #127
  static Screen + #607, #127
  static Screen + #608, #127
  static Screen + #609, #127
  static Screen + #610, #127
  static Screen + #611, #127
  static Screen + #612, #127
  static Screen + #613, #127
  static Screen + #614, #127
  static Screen + #615, #127
  static Screen + #616, #127
  static Screen + #617, #127
  static Screen + #618, #127
  static Screen + #619, #127
  static Screen + #620, #127
  static Screen + #621, #127
  static Screen + #622, #127
  static Screen + #623, #127
  static Screen + #624, #127
  static Screen + #625, #127
  static Screen + #626, #127
  static Screen + #627, #127
  static Screen + #628, #127
  static Screen + #629, #127
  static Screen + #630, #127
  static Screen + #631, #127
  static Screen + #632, #127
  static Screen + #633, #127
  static Screen + #634, #127
  static Screen + #635, #127
  static Screen + #636, #127
  static Screen + #637, #127
  static Screen + #638, #127
  static Screen + #639, #127

  ;Linha 16
  static Screen + #640, #127
  static Screen + #641, #127
  static Screen + #642, #2384
  static Screen + #643, #127
  static Screen + #644, #2888
  static Screen + #645, #127
  static Screen + #646, #596
  static Screen + #647, #127
  static Screen + #648, #127
  static Screen + #649, #2327
  static Screen + #650, #80
  static Screen + #651, #114
  static Screen + #652, #101
  static Screen + #653, #115
  static Screen + #654, #115
  static Screen + #655, #105
  static Screen + #656, #111
  static Screen + #657, #110
  static Screen + #658, #101
  static Screen + #659, #2327
  static Screen + #660, #117
  static Screen + #661, #109
  static Screen + #662, #97
  static Screen + #663, #2327
  static Screen + #664, #116
  static Screen + #665, #101
  static Screen + #666, #99
  static Screen + #667, #108
  static Screen + #668, #97
  static Screen + #669, #33
  static Screen + #670, #2839
  static Screen + #671, #2327
  static Screen + #672, #2327
  static Screen + #673, #579
  static Screen + #674, #127
  static Screen + #675, #2890
  static Screen + #676, #127
  static Screen + #677, #2375
  static Screen + #678, #2327
  static Screen + #679, #127

  ;Linha 17
  static Screen + #680, #127
  static Screen + #681, #127
  static Screen + #682, #127
  static Screen + #683, #127
  static Screen + #684, #127
  static Screen + #685, #127
  static Screen + #686, #127
  static Screen + #687, #127
  static Screen + #688, #127
  static Screen + #689, #127
  static Screen + #690, #2323
  static Screen + #691, #2323
  static Screen + #692, #2323
  static Screen + #693, #2323
  static Screen + #694, #2323
  static Screen + #695, #2323
  static Screen + #696, #2323
  static Screen + #697, #527
  static Screen + #698, #2323
  static Screen + #699, #127
  static Screen + #700, #2323
  static Screen + #701, #2323
  static Screen + #702, #2323
  static Screen + #703, #127
  static Screen + #704, #2323
  static Screen + #705, #2323
  static Screen + #706, #2323
  static Screen + #707, #2323
  static Screen + #708, #2323
  static Screen + #709, #2323
  static Screen + #710, #127
  static Screen + #711, #2327
  static Screen + #712, #127
  static Screen + #713, #127
  static Screen + #714, #127
  static Screen + #715, #2327
  static Screen + #716, #127
  static Screen + #717, #127
  static Screen + #718, #127
  static Screen + #719, #127

  ;Linha 18
  static Screen + #720, #127
  static Screen + #721, #127
  static Screen + #722, #2369
  static Screen + #723, #127
  static Screen + #724, #2885
  static Screen + #725, #127
  static Screen + #726, #584
  static Screen + #727, #127
  static Screen + #728, #127
  static Screen + #729, #127
  static Screen + #730, #527
  static Screen + #731, #527
  static Screen + #732, #527
  static Screen + #733, #527
  static Screen + #734, #527
  static Screen + #735, #527
  static Screen + #736, #527
  static Screen + #737, #2335
  static Screen + #738, #2335
  static Screen + #739, #2335
  static Screen + #740, #2335
  static Screen + #741, #2335
  static Screen + #742, #2335
  static Screen + #743, #127
  static Screen + #744, #527
  static Screen + #745, #527
  static Screen + #746, #527
  static Screen + #747, #527
  static Screen + #748, #527
  static Screen + #749, #527
  static Screen + #750, #2839
  static Screen + #751, #2327
  static Screen + #752, #2327
  static Screen + #753, #597
  static Screen + #754, #2327
  static Screen + #755, #2895
  static Screen + #756, #127
  static Screen + #757, #2369
  static Screen + #758, #127
  static Screen + #759, #127

  ;Linha 19
  static Screen + #760, #127
  static Screen + #761, #127
  static Screen + #762, #127
  static Screen + #763, #127
  static Screen + #764, #127
  static Screen + #765, #127
  static Screen + #766, #127
  static Screen + #767, #127
  static Screen + #768, #127
  static Screen + #769, #127
  static Screen + #770, #2335
  static Screen + #771, #2335
  static Screen + #772, #2335
  static Screen + #773, #2335
  static Screen + #774, #31
  static Screen + #775, #31
  static Screen + #776, #31
  static Screen + #777, #31
  static Screen + #778, #31
  static Screen + #779, #127
  static Screen + #780, #31
  static Screen + #781, #527
  static Screen + #782, #31
  static Screen + #783, #31
  static Screen + #784, #31
  static Screen + #785, #31
  static Screen + #786, #31
  static Screen + #787, #127
  static Screen + #788, #31
  static Screen + #789, #20
  static Screen + #790, #127
  static Screen + #791, #2327
  static Screen + #792, #127
  static Screen + #793, #127
  static Screen + #794, #127
  static Screen + #795, #127
  static Screen + #796, #127
  static Screen + #797, #127
  static Screen + #798, #127
  static Screen + #799, #127

  ;Linha 20
  static Screen + #800, #127
  static Screen + #801, #127
  static Screen + #802, #2389
  static Screen + #803, #127
  static Screen + #804, #2892
  static Screen + #805, #127
  static Screen + #806, #581
  static Screen + #807, #127
  static Screen + #808, #127
  static Screen + #809, #127
  static Screen + #810, #2369
  static Screen + #811, #2370
  static Screen + #812, #2371
  static Screen + #813, #2362
  static Screen + #814, #76
  static Screen + #815, #101
  static Screen + #816, #116
  static Screen + #817, #114
  static Screen + #818, #97
  static Screen + #819, #127
  static Screen + #820, #2424
  static Screen + #821, #527
  static Screen + #822, #76
  static Screen + #823, #117
  static Screen + #824, #103
  static Screen + #825, #97
  static Screen + #826, #114
  static Screen + #827, #127
  static Screen + #828, #2424
  static Screen + #829, #127
  static Screen + #830, #2839
  static Screen + #831, #2327
  static Screen + #832, #2327
  static Screen + #833, #594
  static Screen + #834, #2327
  static Screen + #835, #2887
  static Screen + #836, #127
  static Screen + #837, #2382
  static Screen + #838, #127
  static Screen + #839, #127

  ;Linha 21
  static Screen + #840, #127
  static Screen + #841, #127
  static Screen + #842, #127
  static Screen + #843, #127
  static Screen + #844, #127
  static Screen + #845, #127
  static Screen + #846, #127
  static Screen + #847, #127
  static Screen + #848, #127
  static Screen + #849, #127
  static Screen + #850, #543
  static Screen + #851, #543
  static Screen + #852, #543
  static Screen + #853, #2335
  static Screen + #854, #31
  static Screen + #855, #31
  static Screen + #856, #31
  static Screen + #857, #31
  static Screen + #858, #31
  static Screen + #859, #527
  static Screen + #860, #31
  static Screen + #861, #527
  static Screen + #862, #31
  static Screen + #863, #31
  static Screen + #864, #31
  static Screen + #865, #31
  static Screen + #866, #31
  static Screen + #867, #127
  static Screen + #868, #31
  static Screen + #869, #127
  static Screen + #870, #127
  static Screen + #871, #127
  static Screen + #872, #127
  static Screen + #873, #127
  static Screen + #874, #127
  static Screen + #875, #127
  static Screen + #876, #127
  static Screen + #877, #127
  static Screen + #878, #127
  static Screen + #879, #127

  ;Linha 22
  static Screen + #880, #127
  static Screen + #881, #127
  static Screen + #882, #2380
  static Screen + #883, #127
  static Screen + #884, #2889
  static Screen + #885, #127
  static Screen + #886, #591
  static Screen + #887, #127
  static Screen + #888, #127
  static Screen + #889, #127
  static Screen + #890, #2881
  static Screen + #891, #2882
  static Screen + #892, #2883
  static Screen + #893, #2874
  static Screen + #894, #76
  static Screen + #895, #101
  static Screen + #896, #116
  static Screen + #897, #114
  static Screen + #898, #97
  static Screen + #899, #527
  static Screen + #900, #525
  static Screen + #901, #527
  static Screen + #902, #76
  static Screen + #903, #117
  static Screen + #904, #103
  static Screen + #905, #97
  static Screen + #906, #114
  static Screen + #907, #127
  static Screen + #908, #2424
  static Screen + #909, #127
  static Screen + #910, #2839
  static Screen + #911, #2327
  static Screen + #912, #127
  static Screen + #913, #596
  static Screen + #914, #127
  static Screen + #915, #2901
  static Screen + #916, #127
  static Screen + #917, #2376
  static Screen + #918, #127
  static Screen + #919, #127

  ;Linha 23
  static Screen + #920, #127
  static Screen + #921, #127
  static Screen + #922, #127
  static Screen + #923, #127
  static Screen + #924, #127
  static Screen + #925, #127
  static Screen + #926, #127
  static Screen + #927, #127
  static Screen + #928, #127
  static Screen + #929, #127
  static Screen + #930, #2335
  static Screen + #931, #2335
  static Screen + #932, #2335
  static Screen + #933, #2335
  static Screen + #934, #31
  static Screen + #935, #31
  static Screen + #936, #31
  static Screen + #937, #31
  static Screen + #938, #31
  static Screen + #939, #127
  static Screen + #940, #31
  static Screen + #941, #127
  static Screen + #942, #31
  static Screen + #943, #31
  static Screen + #944, #31
  static Screen + #945, #31
  static Screen + #946, #31
  static Screen + #947, #127
  static Screen + #948, #31
  static Screen + #949, #127
  static Screen + #950, #127
  static Screen + #951, #127
  static Screen + #952, #127
  static Screen + #953, #127
  static Screen + #954, #127
  static Screen + #955, #127
  static Screen + #956, #127
  static Screen + #957, #127
  static Screen + #958, #127
  static Screen + #959, #127

  ;Linha 24
  static Screen + #960, #127
  static Screen + #961, #127
  static Screen + #962, #2383
  static Screen + #963, #127
  static Screen + #964, #2895
  static Screen + #965, #127
  static Screen + #966, #526
  static Screen + #967, #127
  static Screen + #968, #127
  static Screen + #969, #127
  static Screen + #970, #577
  static Screen + #971, #578
  static Screen + #972, #579
  static Screen + #973, #570
  static Screen + #974, #76
  static Screen + #975, #101
  static Screen + #976, #116
  static Screen + #977, #114
  static Screen + #978, #97
  static Screen + #979, #127
  static Screen + #980, #525
  static Screen + #981, #127
  static Screen + #982, #76
  static Screen + #983, #117
  static Screen + #984, #103
  static Screen + #985, #97
  static Screen + #986, #114
  static Screen + #987, #127
  static Screen + #988, #525
  static Screen + #989, #127
  static Screen + #990, #2839
  static Screen + #991, #2327
  static Screen + #992, #127
  static Screen + #993, #577
  static Screen + #994, #2327
  static Screen + #995, #2885
  static Screen + #996, #127
  static Screen + #997, #2373
  static Screen + #998, #127
  static Screen + #999, #127

  ;Linha 25
  static Screen + #1000, #127
  static Screen + #1001, #127
  static Screen + #1002, #127
  static Screen + #1003, #127
  static Screen + #1004, #127
  static Screen + #1005, #127
  static Screen + #1006, #127
  static Screen + #1007, #127
  static Screen + #1008, #127
  static Screen + #1009, #127
  static Screen + #1010, #127
  static Screen + #1011, #127
  static Screen + #1012, #127
  static Screen + #1013, #127
  static Screen + #1014, #127
  static Screen + #1015, #127
  static Screen + #1016, #127
  static Screen + #1017, #127
  static Screen + #1018, #127
  static Screen + #1019, #127
  static Screen + #1020, #127
  static Screen + #1021, #127
  static Screen + #1022, #127
  static Screen + #1023, #127
  static Screen + #1024, #127
  static Screen + #1025, #127
  static Screen + #1026, #127
  static Screen + #1027, #127
  static Screen + #1028, #2335
  static Screen + #1029, #127
  static Screen + #1030, #127
  static Screen + #1031, #127
  static Screen + #1032, #127
  static Screen + #1033, #127
  static Screen + #1034, #127
  static Screen + #1035, #127
  static Screen + #1036, #127
  static Screen + #1037, #127
  static Screen + #1038, #127
  static Screen + #1039, #127

  ;Linha 26
  static Screen + #1040, #127
  static Screen + #1041, #127
  static Screen + #1042, #127
  static Screen + #1043, #127
  static Screen + #1044, #127
  static Screen + #1045, #127
  static Screen + #1046, #127
  static Screen + #1047, #127
  static Screen + #1048, #127
  static Screen + #1049, #127
  static Screen + #1050, #127
  static Screen + #1051, #127
  static Screen + #1052, #127
  static Screen + #1053, #127
  static Screen + #1054, #127
  static Screen + #1055, #127
  static Screen + #1056, #127
  static Screen + #1057, #127
  static Screen + #1058, #127
  static Screen + #1059, #127
  static Screen + #1060, #127
  static Screen + #1061, #127
  static Screen + #1062, #127
  static Screen + #1063, #127
  static Screen + #1064, #127
  static Screen + #1065, #127
  static Screen + #1066, #127
  static Screen + #1067, #127
  static Screen + #1068, #2335
  static Screen + #1069, #127
  static Screen + #1070, #127
  static Screen + #1071, #127
  static Screen + #1072, #127
  static Screen + #1073, #127
  static Screen + #1074, #127
  static Screen + #1075, #127
  static Screen + #1076, #127
  static Screen + #1077, #127
  static Screen + #1078, #127
  static Screen + #1079, #127

  ;Linha 27
  static Screen + #1080, #127
  static Screen + #1081, #127
  static Screen + #1082, #127
  static Screen + #1083, #127
  static Screen + #1084, #127
  static Screen + #1085, #127
  static Screen + #1086, #127
  static Screen + #1087, #127
  static Screen + #1088, #127
  static Screen + #1089, #127
  static Screen + #1090, #127
  static Screen + #1091, #127
  static Screen + #1092, #127
  static Screen + #1093, #127
  static Screen + #1094, #127
  static Screen + #1095, #127
  static Screen + #1096, #127
  static Screen + #1097, #127
  static Screen + #1098, #127
  static Screen + #1099, #127
  static Screen + #1100, #127
  static Screen + #1101, #127
  static Screen + #1102, #127
  static Screen + #1103, #127
  static Screen + #1104, #127
  static Screen + #1105, #127
  static Screen + #1106, #127
  static Screen + #1107, #127
  static Screen + #1108, #127
  static Screen + #1109, #127
  static Screen + #1110, #127
  static Screen + #1111, #127
  static Screen + #1112, #127
  static Screen + #1113, #127
  static Screen + #1114, #127
  static Screen + #1115, #127
  static Screen + #1116, #127
  static Screen + #1117, #127
  static Screen + #1118, #127
  static Screen + #1119, #127

  ;Linha 28
  static Screen + #1120, #127
  static Screen + #1121, #127
  static Screen + #1122, #127
  static Screen + #1123, #127
  static Screen + #1124, #127
  static Screen + #1125, #127
  static Screen + #1126, #127
  static Screen + #1127, #127
  static Screen + #1128, #127
  static Screen + #1129, #127
  static Screen + #1130, #127
  static Screen + #1131, #127
  static Screen + #1132, #127
  static Screen + #1133, #127
  static Screen + #1134, #127
  static Screen + #1135, #127
  static Screen + #1136, #127
  static Screen + #1137, #127
  static Screen + #1138, #127
  static Screen + #1139, #127
  static Screen + #1140, #127
  static Screen + #1141, #127
  static Screen + #1142, #127
  static Screen + #1143, #127
  static Screen + #1144, #127
  static Screen + #1145, #127
  static Screen + #1146, #127
  static Screen + #1147, #127
  static Screen + #1148, #127
  static Screen + #1149, #127
  static Screen + #1150, #127
  static Screen + #1151, #127
  static Screen + #1152, #127
  static Screen + #1153, #127
  static Screen + #1154, #127
  static Screen + #1155, #127
  static Screen + #1156, #127
  static Screen + #1157, #127
  static Screen + #1158, #127
  static Screen + #1159, #127

  ;Linha 29
  static Screen + #1160, #127
  static Screen + #1161, #127
  static Screen + #1162, #127
  static Screen + #1163, #127
  static Screen + #1164, #127
  static Screen + #1165, #127
  static Screen + #1166, #127
  static Screen + #1167, #127
  static Screen + #1168, #127
  static Screen + #1169, #127
  static Screen + #1170, #127
  static Screen + #1171, #127
  static Screen + #1172, #127
  static Screen + #1173, #127
  static Screen + #1174, #127
  static Screen + #1175, #127
  static Screen + #1176, #127
  static Screen + #1177, #127
  static Screen + #1178, #127
  static Screen + #1179, #127
  static Screen + #1180, #127
  static Screen + #1181, #127
  static Screen + #1182, #127
  static Screen + #1183, #127
  static Screen + #1184, #127
  static Screen + #1185, #127
  static Screen + #1186, #127
  static Screen + #1187, #127
  static Screen + #1188, #127
  static Screen + #1189, #127
  static Screen + #1190, #127
  static Screen + #1191, #127
  static Screen + #1192, #127
  static Screen + #1193, #127
  static Screen + #1194, #127
  static Screen + #1195, #127
  static Screen + #1196, #127
  static Screen + #1197, #127
  static Screen + #1198, #127
  static Screen + #1199, #127

;; --- Guardando Tela Hints ---
Hints : var #1200
  ;Linha 0
  static Hints + #0, #3967
  static Hints + #1, #3967
  static Hints + #2, #3967
  static Hints + #3, #3967
  static Hints + #4, #3967
  static Hints + #5, #3967
  static Hints + #6, #3967
  static Hints + #7, #3967
  static Hints + #8, #3967
  static Hints + #9, #3967
  static Hints + #10, #3967
  static Hints + #11, #3967
  static Hints + #12, #3967
  static Hints + #13, #3967
  static Hints + #14, #3967
  static Hints + #15, #3967
  static Hints + #16, #3967
  static Hints + #17, #3967
  static Hints + #18, #3967
  static Hints + #19, #3967
  static Hints + #20, #3967
  static Hints + #21, #3967
  static Hints + #22, #3967
  static Hints + #23, #3967
  static Hints + #24, #3967
  static Hints + #25, #3967
  static Hints + #26, #3967
  static Hints + #27, #3967
  static Hints + #28, #3967
  static Hints + #29, #3967
  static Hints + #30, #3967
  static Hints + #31, #3967
  static Hints + #32, #3967
  static Hints + #33, #3967
  static Hints + #34, #3967
  static Hints + #35, #3967
  static Hints + #36, #3967
  static Hints + #37, #3967
  static Hints + #38, #3967
  static Hints + #39, #3967

  ;Linha 1
  static Hints + #40, #3967
  static Hints + #41, #3967
  static Hints + #42, #3967
  static Hints + #43, #3967
  static Hints + #44, #3967
  static Hints + #45, #3967
  static Hints + #46, #3967
  static Hints + #47, #3967
  static Hints + #48, #3967
  static Hints + #49, #3967
  static Hints + #50, #3967
  static Hints + #51, #3967
  static Hints + #52, #3967
  static Hints + #53, #3967
  static Hints + #54, #3967
  static Hints + #55, #3967
  static Hints + #56, #3967
  static Hints + #57, #3967
  static Hints + #58, #3967
  static Hints + #59, #3967
  static Hints + #60, #3967
  static Hints + #61, #3967
  static Hints + #62, #3967
  static Hints + #63, #3967
  static Hints + #64, #3967
  static Hints + #65, #3967
  static Hints + #66, #3967
  static Hints + #67, #3967
  static Hints + #68, #3967
  static Hints + #69, #3967
  static Hints + #70, #3967
  static Hints + #71, #3967
  static Hints + #72, #3967
  static Hints + #73, #3967
  static Hints + #74, #3967
  static Hints + #75, #3967
  static Hints + #76, #3967
  static Hints + #77, #3967
  static Hints + #78, #3967
  static Hints + #79, #3967

  ;Linha 2
  static Hints + #80, #3967
  static Hints + #81, #3967
  static Hints + #82, #3967
  static Hints + #83, #3967
  static Hints + #84, #3967
  static Hints + #85, #3967
  static Hints + #86, #3967
  static Hints + #87, #3967
  static Hints + #88, #3967
  static Hints + #89, #3967
  static Hints + #90, #3967
  static Hints + #91, #3967
  static Hints + #92, #3967
  static Hints + #93, #3967
  static Hints + #94, #3967
  static Hints + #95, #3967
  static Hints + #96, #3967
  static Hints + #97, #3967
  static Hints + #98, #3967
  static Hints + #99, #3967
  static Hints + #100, #3967
  static Hints + #101, #3967
  static Hints + #102, #3967
  static Hints + #103, #3967
  static Hints + #104, #3967
  static Hints + #105, #3967
  static Hints + #106, #3967
  static Hints + #107, #3967
  static Hints + #108, #3967
  static Hints + #109, #3967
  static Hints + #110, #3967
  static Hints + #111, #3967
  static Hints + #112, #3967
  static Hints + #113, #3967
  static Hints + #114, #3967
  static Hints + #115, #3967
  static Hints + #116, #3967
  static Hints + #117, #3967
  static Hints + #118, #3967
  static Hints + #119, #3967

  ;Linha 3
  static Hints + #120, #3967
  static Hints + #121, #3967
  static Hints + #122, #3967
  static Hints + #123, #3967
  static Hints + #124, #3967
  static Hints + #125, #3967
  static Hints + #126, #3967
  static Hints + #127, #3967
  static Hints + #128, #3967
  static Hints + #129, #3967
  static Hints + #130, #3967
  static Hints + #131, #3967
  static Hints + #132, #3967
  static Hints + #133, #3967
  static Hints + #134, #3967
  static Hints + #135, #3967
  static Hints + #136, #3967
  static Hints + #137, #3967
  static Hints + #138, #3967
  static Hints + #139, #3967
  static Hints + #140, #3967
  static Hints + #141, #3967
  static Hints + #142, #3967
  static Hints + #143, #3967
  static Hints + #144, #3967
  static Hints + #145, #3967
  static Hints + #146, #3967
  static Hints + #147, #3967
  static Hints + #148, #3967
  static Hints + #149, #3967
  static Hints + #150, #3967
  static Hints + #151, #3967
  static Hints + #152, #3967
  static Hints + #153, #3967
  static Hints + #154, #3967
  static Hints + #155, #3967
  static Hints + #156, #3967
  static Hints + #157, #3967
  static Hints + #158, #3967
  static Hints + #159, #3967

  ;Linha 4
  static Hints + #160, #3967
  static Hints + #161, #2
  static Hints + #162, #1
  static Hints + #163, #3
  static Hints + #164, #3967
  static Hints + #165, #3967
  static Hints + #166, #3967
  static Hints + #167, #3967
  static Hints + #168, #3967
  static Hints + #169, #3967
  static Hints + #170, #3967
  static Hints + #171, #3967
  static Hints + #172, #3967
  static Hints + #173, #3967
  static Hints + #174, #3967
  static Hints + #175, #3967
  static Hints + #176, #3967
  static Hints + #177, #3967
  static Hints + #178, #3967
  static Hints + #179, #3967
  static Hints + #180, #3967
  static Hints + #181, #3967
  static Hints + #182, #3967
  static Hints + #183, #3967
  static Hints + #184, #3967
  static Hints + #185, #3967
  static Hints + #186, #3967
  static Hints + #187, #3967
  static Hints + #188, #3967
  static Hints + #189, #3967
  static Hints + #190, #3967
  static Hints + #191, #3967
  static Hints + #192, #3967
  static Hints + #193, #3967
  static Hints + #194, #3967
  static Hints + #195, #3967
  static Hints + #196, #3967
  static Hints + #197, #3967
  static Hints + #198, #3967
  static Hints + #199, #3967

  ;Linha 5
  static Hints + #200, #3967
  static Hints + #201, #0
  static Hints + #202, #49
  static Hints + #203, #0
  static Hints + #204, #3967
  static Hints + #205, #3967
  static Hints + #206, #3967
  static Hints + #207, #3967
  static Hints + #208, #3967
  static Hints + #209, #3967
  static Hints + #210, #3967
  static Hints + #211, #3967
  static Hints + #212, #3967
  static Hints + #213, #3967
  static Hints + #214, #3967
  static Hints + #215, #3967
  static Hints + #216, #3967
  static Hints + #217, #3967
  static Hints + #218, #3967
  static Hints + #219, #3967
  static Hints + #220, #3967
  static Hints + #221, #3967
  static Hints + #222, #3967
  static Hints + #223, #3967
  static Hints + #224, #3967
  static Hints + #225, #3967
  static Hints + #226, #3967
  static Hints + #227, #3967
  static Hints + #228, #3967
  static Hints + #229, #3967
  static Hints + #230, #3967
  static Hints + #231, #3967
  static Hints + #232, #3967
  static Hints + #233, #3967
  static Hints + #234, #3967
  static Hints + #235, #3967
  static Hints + #236, #3967
  static Hints + #237, #3967
  static Hints + #238, #3967
  static Hints + #239, #3967

  ;Linha 6
  static Hints + #240, #3967
  static Hints + #241, #4
  static Hints + #242, #1
  static Hints + #243, #5
  static Hints + #244, #3967
  static Hints + #245, #3967
  static Hints + #246, #3967
  static Hints + #247, #3967
  static Hints + #248, #3967
  static Hints + #249, #3967
  static Hints + #250, #3967
  static Hints + #251, #3967
  static Hints + #252, #3967
  static Hints + #253, #3967
  static Hints + #254, #3967
  static Hints + #255, #3967
  static Hints + #256, #3967
  static Hints + #257, #3967
  static Hints + #258, #3967
  static Hints + #259, #3967
  static Hints + #260, #3967
  static Hints + #261, #3967
  static Hints + #262, #3967
  static Hints + #263, #3967
  static Hints + #264, #3967
  static Hints + #265, #3967
  static Hints + #266, #3967
  static Hints + #267, #3967
  static Hints + #268, #3967
  static Hints + #269, #3967
  static Hints + #270, #3967
  static Hints + #271, #3967
  static Hints + #272, #3967
  static Hints + #273, #3967
  static Hints + #274, #3967
  static Hints + #275, #3967
  static Hints + #276, #3967
  static Hints + #277, #3967
  static Hints + #278, #3967
  static Hints + #279, #3967

  ;Linha 7
  static Hints + #280, #65
  static Hints + #281, #80
  static Hints + #282, #65
  static Hints + #283, #71
  static Hints + #284, #65
  static Hints + #285, #82
  static Hints + #286, #3967
  static Hints + #287, #3967
  static Hints + #288, #3967
  static Hints + #289, #3967
  static Hints + #290, #3967
  static Hints + #291, #3967
  static Hints + #292, #3967
  static Hints + #293, #3967
  static Hints + #294, #3967
  static Hints + #295, #3967
  static Hints + #296, #3967
  static Hints + #297, #3967
  static Hints + #298, #3967
  static Hints + #299, #3967
  static Hints + #300, #3967
  static Hints + #301, #3967
  static Hints + #302, #3967
  static Hints + #303, #3967
  static Hints + #304, #3967
  static Hints + #305, #3967
  static Hints + #306, #3967
  static Hints + #307, #3967
  static Hints + #308, #3967
  static Hints + #309, #3967
  static Hints + #310, #3967
  static Hints + #311, #3967
  static Hints + #312, #3967
  static Hints + #313, #3967
  static Hints + #314, #3967
  static Hints + #315, #3967
  static Hints + #316, #3967
  static Hints + #317, #3967
  static Hints + #318, #3967
  static Hints + #319, #3967

  ;Linha 8
  static Hints + #320, #3967
  static Hints + #321, #3967
  static Hints + #322, #3967
  static Hints + #323, #3967
  static Hints + #324, #3967
  static Hints + #325, #3967
  static Hints + #326, #3967
  static Hints + #327, #3967
  static Hints + #328, #3967
  static Hints + #329, #3967
  static Hints + #330, #3967
  static Hints + #331, #3967
  static Hints + #332, #3967
  static Hints + #333, #3967
  static Hints + #334, #3967
  static Hints + #335, #3967
  static Hints + #336, #3967
  static Hints + #337, #3967
  static Hints + #338, #3967
  static Hints + #339, #3967
  static Hints + #340, #3967
  static Hints + #341, #3967
  static Hints + #342, #3967
  static Hints + #343, #3967
  static Hints + #344, #3967
  static Hints + #345, #3967
  static Hints + #346, #3967
  static Hints + #347, #3967
  static Hints + #348, #3967
  static Hints + #349, #3967
  static Hints + #350, #3967
  static Hints + #351, #3967
  static Hints + #352, #3967
  static Hints + #353, #3967
  static Hints + #354, #3967
  static Hints + #355, #3967
  static Hints + #356, #3967
  static Hints + #357, #3967
  static Hints + #358, #3967
  static Hints + #359, #3967

  ;Linha 9
  static Hints + #360, #3967
  static Hints + #361, #3967
  static Hints + #362, #3967
  static Hints + #363, #3967
  static Hints + #364, #3967
  static Hints + #365, #3967
  static Hints + #366, #3967
  static Hints + #367, #3967
  static Hints + #368, #3967
  static Hints + #369, #3967
  static Hints + #370, #3967
  static Hints + #371, #3967
  static Hints + #372, #3967
  static Hints + #373, #3967
  static Hints + #374, #3967
  static Hints + #375, #3967
  static Hints + #376, #3967
  static Hints + #377, #3967
  static Hints + #378, #3967
  static Hints + #379, #3967
  static Hints + #380, #3967
  static Hints + #381, #3967
  static Hints + #382, #3967
  static Hints + #383, #3967
  static Hints + #384, #3967
  static Hints + #385, #3967
  static Hints + #386, #3967
  static Hints + #387, #3967
  static Hints + #388, #3967
  static Hints + #389, #3967
  static Hints + #390, #3967
  static Hints + #391, #3967
  static Hints + #392, #3967
  static Hints + #393, #3967
  static Hints + #394, #3967
  static Hints + #395, #3967
  static Hints + #396, #3967
  static Hints + #397, #3967
  static Hints + #398, #3967
  static Hints + #399, #3967

  ;Linha 10
  static Hints + #400, #3967
  static Hints + #401, #2
  static Hints + #402, #1
  static Hints + #403, #3
  static Hints + #404, #3967
  static Hints + #405, #3967
  static Hints + #406, #3967
  static Hints + #407, #3967
  static Hints + #408, #3967
  static Hints + #409, #3967
  static Hints + #410, #3967
  static Hints + #411, #3967
  static Hints + #412, #3967
  static Hints + #413, #3967
  static Hints + #414, #3967
  static Hints + #415, #3967
  static Hints + #416, #3967
  static Hints + #417, #3967
  static Hints + #418, #3967
  static Hints + #419, #3967
  static Hints + #420, #3967
  static Hints + #421, #3967
  static Hints + #422, #3967
  static Hints + #423, #3967
  static Hints + #424, #3967
  static Hints + #425, #3967
  static Hints + #426, #3967
  static Hints + #427, #3967
  static Hints + #428, #3967
  static Hints + #429, #3967
  static Hints + #430, #3967
  static Hints + #431, #3967
  static Hints + #432, #3967
  static Hints + #433, #3967
  static Hints + #434, #3967
  static Hints + #435, #3967
  static Hints + #436, #3967
  static Hints + #437, #3967
  static Hints + #438, #3967
  static Hints + #439, #3967

  ;Linha 11
  static Hints + #440, #3967
  static Hints + #441, #0
  static Hints + #442, #18
  static Hints + #443, #0
  static Hints + #444, #3967
  static Hints + #445, #3967
  static Hints + #446, #3967
  static Hints + #447, #3967
  static Hints + #448, #3967
  static Hints + #449, #3967
  static Hints + #450, #3967
  static Hints + #451, #3967
  static Hints + #452, #3967
  static Hints + #453, #3967
  static Hints + #454, #3967
  static Hints + #455, #3967
  static Hints + #456, #3967
  static Hints + #457, #3967
  static Hints + #458, #3967
  static Hints + #459, #3967
  static Hints + #460, #3967
  static Hints + #461, #3967
  static Hints + #462, #3967
  static Hints + #463, #3967
  static Hints + #464, #3967
  static Hints + #465, #3967
  static Hints + #466, #3967
  static Hints + #467, #3967
  static Hints + #468, #3967
  static Hints + #469, #3967
  static Hints + #470, #3967
  static Hints + #471, #3967
  static Hints + #472, #3967
  static Hints + #473, #3967
  static Hints + #474, #3967
  static Hints + #475, #3967
  static Hints + #476, #3967
  static Hints + #477, #3967
  static Hints + #478, #3967
  static Hints + #479, #3967

  ;Linha 12
  static Hints + #480, #3967
  static Hints + #481, #4
  static Hints + #482, #1
  static Hints + #483, #5
  static Hints + #484, #3967
  static Hints + #485, #3967
  static Hints + #486, #3967
  static Hints + #487, #3967
  static Hints + #488, #3967
  static Hints + #489, #3967
  static Hints + #490, #3967
  static Hints + #491, #3967
  static Hints + #492, #3967
  static Hints + #493, #3967
  static Hints + #494, #3967
  static Hints + #495, #3967
  static Hints + #496, #3967
  static Hints + #497, #3967
  static Hints + #498, #3967
  static Hints + #499, #3967
  static Hints + #500, #3967
  static Hints + #501, #3967
  static Hints + #502, #3967
  static Hints + #503, #3967
  static Hints + #504, #3967
  static Hints + #505, #3967
  static Hints + #506, #3967
  static Hints + #507, #3967
  static Hints + #508, #3967
  static Hints + #509, #3967
  static Hints + #510, #3967
  static Hints + #511, #3967
  static Hints + #512, #3967
  static Hints + #513, #3967
  static Hints + #514, #3967
  static Hints + #515, #3967
  static Hints + #516, #3967
  static Hints + #517, #3967
  static Hints + #518, #3967
  static Hints + #519, #3967

  ;Linha 13
  static Hints + #520, #69
  static Hints + #521, #78
  static Hints + #522, #86
  static Hints + #523, #73
  static Hints + #524, #65
  static Hints + #525, #82
  static Hints + #526, #3967
  static Hints + #527, #3967
  static Hints + #528, #3967
  static Hints + #529, #3967
  static Hints + #530, #3967
  static Hints + #531, #3967
  static Hints + #532, #3967
  static Hints + #533, #3967
  static Hints + #534, #3967
  static Hints + #535, #3967
  static Hints + #536, #3967
  static Hints + #537, #3967
  static Hints + #538, #3967
  static Hints + #539, #3967
  static Hints + #540, #3967
  static Hints + #541, #3967
  static Hints + #542, #3967
  static Hints + #543, #3967
  static Hints + #544, #3967
  static Hints + #545, #3967
  static Hints + #546, #3967
  static Hints + #547, #3967
  static Hints + #548, #3967
  static Hints + #549, #3967
  static Hints + #550, #3967
  static Hints + #551, #3967
  static Hints + #552, #3967
  static Hints + #553, #3967
  static Hints + #554, #3967
  static Hints + #555, #3967
  static Hints + #556, #3967
  static Hints + #557, #3967
  static Hints + #558, #3967
  static Hints + #559, #3967

  ;Linha 14
  static Hints + #560, #3967
  static Hints + #561, #3967
  static Hints + #562, #3967
  static Hints + #563, #3967
  static Hints + #564, #3967
  static Hints + #565, #3967
  static Hints + #566, #3967
  static Hints + #567, #3967
  static Hints + #568, #3967
  static Hints + #569, #3967
  static Hints + #570, #3967
  static Hints + #571, #3967
  static Hints + #572, #3967
  static Hints + #573, #3967
  static Hints + #574, #3967
  static Hints + #575, #3967
  static Hints + #576, #3967
  static Hints + #577, #3967
  static Hints + #578, #3967
  static Hints + #579, #3967
  static Hints + #580, #3967
  static Hints + #581, #3967
  static Hints + #582, #3967
  static Hints + #583, #3967
  static Hints + #584, #3967
  static Hints + #585, #3967
  static Hints + #586, #3967
  static Hints + #587, #3967
  static Hints + #588, #3967
  static Hints + #589, #3967
  static Hints + #590, #3967
  static Hints + #591, #3967
  static Hints + #592, #3967
  static Hints + #593, #3967
  static Hints + #594, #3967
  static Hints + #595, #3967
  static Hints + #596, #3967
  static Hints + #597, #3967
  static Hints + #598, #3967
  static Hints + #599, #3967

  ;Linha 15
  static Hints + #600, #3967
  static Hints + #601, #3967
  static Hints + #602, #3967
  static Hints + #603, #3967
  static Hints + #604, #3967
  static Hints + #605, #3967
  static Hints + #606, #3967
  static Hints + #607, #3967
  static Hints + #608, #3967
  static Hints + #609, #3967
  static Hints + #610, #3967
  static Hints + #611, #3967
  static Hints + #612, #3967
  static Hints + #613, #3967
  static Hints + #614, #3967
  static Hints + #615, #3967
  static Hints + #616, #3967
  static Hints + #617, #3967
  static Hints + #618, #3967
  static Hints + #619, #3967
  static Hints + #620, #3967
  static Hints + #621, #3967
  static Hints + #622, #3967
  static Hints + #623, #3967
  static Hints + #624, #3967
  static Hints + #625, #3967
  static Hints + #626, #3967
  static Hints + #627, #3967
  static Hints + #628, #3967
  static Hints + #629, #3967
  static Hints + #630, #3967
  static Hints + #631, #3967
  static Hints + #632, #3967
  static Hints + #633, #3967
  static Hints + #634, #3967
  static Hints + #635, #3967
  static Hints + #636, #3967
  static Hints + #637, #3967
  static Hints + #638, #3967
  static Hints + #639, #3967

  ;Linha 16
  static Hints + #640, #3967
  static Hints + #641, #3967
  static Hints + #642, #3967
  static Hints + #643, #3967
  static Hints + #644, #3967
  static Hints + #645, #3967
  static Hints + #646, #3967
  static Hints + #647, #3967
  static Hints + #648, #3967
  static Hints + #649, #3967
  static Hints + #650, #3967
  static Hints + #651, #3967
  static Hints + #652, #3967
  static Hints + #653, #3967
  static Hints + #654, #3967
  static Hints + #655, #3967
  static Hints + #656, #3967
  static Hints + #657, #3967
  static Hints + #658, #3967
  static Hints + #659, #3967
  static Hints + #660, #3967
  static Hints + #661, #3967
  static Hints + #662, #3967
  static Hints + #663, #3967
  static Hints + #664, #3967
  static Hints + #665, #3967
  static Hints + #666, #3967
  static Hints + #667, #3967
  static Hints + #668, #3967
  static Hints + #669, #3967
  static Hints + #670, #3967
  static Hints + #671, #3967
  static Hints + #672, #3967
  static Hints + #673, #3967
  static Hints + #674, #3967
  static Hints + #675, #3967
  static Hints + #676, #3967
  static Hints + #677, #3967
  static Hints + #678, #3967
  static Hints + #679, #3967

  ;Linha 17
  static Hints + #680, #3967
  static Hints + #681, #3967
  static Hints + #682, #3967
  static Hints + #683, #3967
  static Hints + #684, #3967
  static Hints + #685, #3967
  static Hints + #686, #3967
  static Hints + #687, #3967
  static Hints + #688, #3967
  static Hints + #689, #3967
  static Hints + #690, #3967
  static Hints + #691, #3967
  static Hints + #692, #3967
  static Hints + #693, #3967
  static Hints + #694, #3967
  static Hints + #695, #3967
  static Hints + #696, #3967
  static Hints + #697, #3967
  static Hints + #698, #3967
  static Hints + #699, #3967
  static Hints + #700, #3967
  static Hints + #701, #3967
  static Hints + #702, #3967
  static Hints + #703, #3967
  static Hints + #704, #3967
  static Hints + #705, #3967
  static Hints + #706, #3967
  static Hints + #707, #3967
  static Hints + #708, #3967
  static Hints + #709, #3967
  static Hints + #710, #3967
  static Hints + #711, #3967
  static Hints + #712, #3967
  static Hints + #713, #3967
  static Hints + #714, #3967
  static Hints + #715, #3967
  static Hints + #716, #3967
  static Hints + #717, #3967
  static Hints + #718, #3967
  static Hints + #719, #3967

  ;Linha 18
  static Hints + #720, #3967
  static Hints + #721, #3967
  static Hints + #722, #3967
  static Hints + #723, #3967
  static Hints + #724, #3967
  static Hints + #725, #3967
  static Hints + #726, #3967
  static Hints + #727, #3967
  static Hints + #728, #3967
  static Hints + #729, #3967
  static Hints + #730, #3967
  static Hints + #731, #3967
  static Hints + #732, #3967
  static Hints + #733, #3967
  static Hints + #734, #3967
  static Hints + #735, #3967
  static Hints + #736, #3967
  static Hints + #737, #3967
  static Hints + #738, #3967
  static Hints + #739, #3967
  static Hints + #740, #3967
  static Hints + #741, #3967
  static Hints + #742, #3967
  static Hints + #743, #3967
  static Hints + #744, #3967
  static Hints + #745, #3967
  static Hints + #746, #3967
  static Hints + #747, #3967
  static Hints + #748, #3967
  static Hints + #749, #3967
  static Hints + #750, #3967
  static Hints + #751, #3967
  static Hints + #752, #3967
  static Hints + #753, #3967
  static Hints + #754, #3967
  static Hints + #755, #3967
  static Hints + #756, #3967
  static Hints + #757, #3967
  static Hints + #758, #3967
  static Hints + #759, #3967

  ;Linha 19
  static Hints + #760, #3967
  static Hints + #761, #3967
  static Hints + #762, #3967
  static Hints + #763, #3967
  static Hints + #764, #3967
  static Hints + #765, #3967
  static Hints + #766, #3967
  static Hints + #767, #3967
  static Hints + #768, #3967
  static Hints + #769, #3967
  static Hints + #770, #3967
  static Hints + #771, #3967
  static Hints + #772, #3967
  static Hints + #773, #3967
  static Hints + #774, #3967
  static Hints + #775, #3967
  static Hints + #776, #3967
  static Hints + #777, #3967
  static Hints + #778, #3967
  static Hints + #779, #3967
  static Hints + #780, #3967
  static Hints + #781, #3967
  static Hints + #782, #3967
  static Hints + #783, #3967
  static Hints + #784, #3967
  static Hints + #785, #3967
  static Hints + #786, #3967
  static Hints + #787, #3967
  static Hints + #788, #3967
  static Hints + #789, #3967
  static Hints + #790, #3967
  static Hints + #791, #3967
  static Hints + #792, #3967
  static Hints + #793, #3967
  static Hints + #794, #3967
  static Hints + #795, #3967
  static Hints + #796, #3967
  static Hints + #797, #3967
  static Hints + #798, #3967
  static Hints + #799, #3967

  ;Linha 20
  static Hints + #800, #3967
  static Hints + #801, #3967
  static Hints + #802, #3967
  static Hints + #803, #3967
  static Hints + #804, #3967
  static Hints + #805, #3967
  static Hints + #806, #3967
  static Hints + #807, #3967
  static Hints + #808, #3967
  static Hints + #809, #3967
  static Hints + #810, #3967
  static Hints + #811, #3967
  static Hints + #812, #3967
  static Hints + #813, #3967
  static Hints + #814, #3967
  static Hints + #815, #3967
  static Hints + #816, #3967
  static Hints + #817, #3967
  static Hints + #818, #3967
  static Hints + #819, #3967
  static Hints + #820, #3967
  static Hints + #821, #3967
  static Hints + #822, #3967
  static Hints + #823, #3967
  static Hints + #824, #3967
  static Hints + #825, #3967
  static Hints + #826, #3967
  static Hints + #827, #3967
  static Hints + #828, #3967
  static Hints + #829, #3967
  static Hints + #830, #3967
  static Hints + #831, #3967
  static Hints + #832, #3967
  static Hints + #833, #3967
  static Hints + #834, #3967
  static Hints + #835, #3967
  static Hints + #836, #3967
  static Hints + #837, #3967
  static Hints + #838, #3967
  static Hints + #839, #3967

  ;Linha 21
  static Hints + #840, #3967
  static Hints + #841, #3967
  static Hints + #842, #3967
  static Hints + #843, #3967
  static Hints + #844, #3967
  static Hints + #845, #3967
  static Hints + #846, #3967
  static Hints + #847, #3967
  static Hints + #848, #3967
  static Hints + #849, #3967
  static Hints + #850, #3967
  static Hints + #851, #3967
  static Hints + #852, #3967
  static Hints + #853, #3967
  static Hints + #854, #3967
  static Hints + #855, #3967
  static Hints + #856, #3967
  static Hints + #857, #3967
  static Hints + #858, #3967
  static Hints + #859, #3967
  static Hints + #860, #3967
  static Hints + #861, #3967
  static Hints + #862, #3967
  static Hints + #863, #3967
  static Hints + #864, #3967
  static Hints + #865, #3967
  static Hints + #866, #3967
  static Hints + #867, #3967
  static Hints + #868, #3967
  static Hints + #869, #3967
  static Hints + #870, #3967
  static Hints + #871, #3967
  static Hints + #872, #3967
  static Hints + #873, #3967
  static Hints + #874, #3967
  static Hints + #875, #3967
  static Hints + #876, #3967
  static Hints + #877, #3967
  static Hints + #878, #3967
  static Hints + #879, #3967

  ;Linha 22
  static Hints + #880, #3967
  static Hints + #881, #3967
  static Hints + #882, #3967
  static Hints + #883, #3967
  static Hints + #884, #3967
  static Hints + #885, #3967
  static Hints + #886, #3967
  static Hints + #887, #3967
  static Hints + #888, #3967
  static Hints + #889, #3967
  static Hints + #890, #3967
  static Hints + #891, #3967
  static Hints + #892, #3967
  static Hints + #893, #3967
  static Hints + #894, #3967
  static Hints + #895, #3967
  static Hints + #896, #3967
  static Hints + #897, #3967
  static Hints + #898, #3967
  static Hints + #899, #3967
  static Hints + #900, #3967
  static Hints + #901, #3967
  static Hints + #902, #3967
  static Hints + #903, #3967
  static Hints + #904, #3967
  static Hints + #905, #3967
  static Hints + #906, #3967
  static Hints + #907, #3967
  static Hints + #908, #3967
  static Hints + #909, #3967
  static Hints + #910, #3967
  static Hints + #911, #3967
  static Hints + #912, #3967
  static Hints + #913, #3967
  static Hints + #914, #3967
  static Hints + #915, #3967
  static Hints + #916, #3967
  static Hints + #917, #3967
  static Hints + #918, #3967
  static Hints + #919, #3967

  ;Linha 23
  static Hints + #920, #3967
  static Hints + #921, #3967
  static Hints + #922, #3967
  static Hints + #923, #3967
  static Hints + #924, #3967
  static Hints + #925, #3967
  static Hints + #926, #3967
  static Hints + #927, #3967
  static Hints + #928, #3967
  static Hints + #929, #3967
  static Hints + #930, #3967
  static Hints + #931, #3967
  static Hints + #932, #3967
  static Hints + #933, #3967
  static Hints + #934, #3967
  static Hints + #935, #3967
  static Hints + #936, #3967
  static Hints + #937, #3967
  static Hints + #938, #3967
  static Hints + #939, #3967
  static Hints + #940, #3967
  static Hints + #941, #3967
  static Hints + #942, #3967
  static Hints + #943, #3967
  static Hints + #944, #3967
  static Hints + #945, #3967
  static Hints + #946, #3967
  static Hints + #947, #3967
  static Hints + #948, #3967
  static Hints + #949, #3967
  static Hints + #950, #3967
  static Hints + #951, #3967
  static Hints + #952, #3967
  static Hints + #953, #3967
  static Hints + #954, #3967
  static Hints + #955, #3967
  static Hints + #956, #3967
  static Hints + #957, #3967
  static Hints + #958, #3967
  static Hints + #959, #3967

  ;Linha 24
  static Hints + #960, #3967
  static Hints + #961, #3967
  static Hints + #962, #3967
  static Hints + #963, #3967
  static Hints + #964, #3967
  static Hints + #965, #3967
  static Hints + #966, #3967
  static Hints + #967, #3967
  static Hints + #968, #3967
  static Hints + #969, #3967
  static Hints + #970, #3967
  static Hints + #971, #3967
  static Hints + #972, #3967
  static Hints + #973, #3967
  static Hints + #974, #3967
  static Hints + #975, #3967
  static Hints + #976, #3967
  static Hints + #977, #3967
  static Hints + #978, #3967
  static Hints + #979, #3967
  static Hints + #980, #3967
  static Hints + #981, #3967
  static Hints + #982, #3967
  static Hints + #983, #3967
  static Hints + #984, #3967
  static Hints + #985, #3967
  static Hints + #986, #3967
  static Hints + #987, #3967
  static Hints + #988, #3967
  static Hints + #989, #3967
  static Hints + #990, #3967
  static Hints + #991, #3967
  static Hints + #992, #3967
  static Hints + #993, #3967
  static Hints + #994, #3967
  static Hints + #995, #3967
  static Hints + #996, #3967
  static Hints + #997, #3967
  static Hints + #998, #3967
  static Hints + #999, #3967

  ;Linha 25
  static Hints + #1000, #3967
  static Hints + #1001, #3967
  static Hints + #1002, #3967
  static Hints + #1003, #3967
  static Hints + #1004, #3967
  static Hints + #1005, #3967
  static Hints + #1006, #3967
  static Hints + #1007, #3967
  static Hints + #1008, #3967
  static Hints + #1009, #3967
  static Hints + #1010, #3967
  static Hints + #1011, #3967
  static Hints + #1012, #3967
  static Hints + #1013, #3967
  static Hints + #1014, #3967
  static Hints + #1015, #3967
  static Hints + #1016, #3967
  static Hints + #1017, #3967
  static Hints + #1018, #3967
  static Hints + #1019, #3967
  static Hints + #1020, #3967
  static Hints + #1021, #3967
  static Hints + #1022, #3967
  static Hints + #1023, #3967
  static Hints + #1024, #3967
  static Hints + #1025, #3967
  static Hints + #1026, #3967
  static Hints + #1027, #3967
  static Hints + #1028, #3967
  static Hints + #1029, #3967
  static Hints + #1030, #3967
  static Hints + #1031, #3967
  static Hints + #1032, #3967
  static Hints + #1033, #3967
  static Hints + #1034, #3967
  static Hints + #1035, #3967
  static Hints + #1036, #3967
  static Hints + #1037, #3967
  static Hints + #1038, #3967
  static Hints + #1039, #3967

  ;Linha 26
  static Hints + #1040, #3967
  static Hints + #1041, #3967
  static Hints + #1042, #3967
  static Hints + #1043, #3967
  static Hints + #1044, #3967
  static Hints + #1045, #3967
  static Hints + #1046, #3967
  static Hints + #1047, #3967
  static Hints + #1048, #3967
  static Hints + #1049, #3967
  static Hints + #1050, #3967
  static Hints + #1051, #3967
  static Hints + #1052, #3967
  static Hints + #1053, #3967
  static Hints + #1054, #3967
  static Hints + #1055, #3967
  static Hints + #1056, #3967
  static Hints + #1057, #3967
  static Hints + #1058, #3967
  static Hints + #1059, #3967
  static Hints + #1060, #3967
  static Hints + #1061, #3967
  static Hints + #1062, #3967
  static Hints + #1063, #3967
  static Hints + #1064, #3967
  static Hints + #1065, #3967
  static Hints + #1066, #3967
  static Hints + #1067, #3967
  static Hints + #1068, #3967
  static Hints + #1069, #3967
  static Hints + #1070, #3967
  static Hints + #1071, #3967
  static Hints + #1072, #3967
  static Hints + #1073, #3967
  static Hints + #1074, #3967
  static Hints + #1075, #3967
  static Hints + #1076, #3967
  static Hints + #1077, #3967
  static Hints + #1078, #3967
  static Hints + #1079, #3967

  ;Linha 27
  static Hints + #1080, #3967
  static Hints + #1081, #3967
  static Hints + #1082, #3967
  static Hints + #1083, #3967
  static Hints + #1084, #3967
  static Hints + #1085, #3967
  static Hints + #1086, #3967
  static Hints + #1087, #3967
  static Hints + #1088, #3967
  static Hints + #1089, #3967
  static Hints + #1090, #3967
  static Hints + #1091, #3967
  static Hints + #1092, #3967
  static Hints + #1093, #3967
  static Hints + #1094, #3967
  static Hints + #1095, #3967
  static Hints + #1096, #3967
  static Hints + #1097, #3967
  static Hints + #1098, #3967
  static Hints + #1099, #3967
  static Hints + #1100, #3967
  static Hints + #1101, #3967
  static Hints + #1102, #3967
  static Hints + #1103, #3967
  static Hints + #1104, #3967
  static Hints + #1105, #3967
  static Hints + #1106, #3967
  static Hints + #1107, #3967
  static Hints + #1108, #3967
  static Hints + #1109, #3967
  static Hints + #1110, #3967
  static Hints + #1111, #3967
  static Hints + #1112, #3967
  static Hints + #1113, #3967
  static Hints + #1114, #3967
  static Hints + #1115, #3967
  static Hints + #1116, #3967
  static Hints + #1117, #3967
  static Hints + #1118, #3967
  static Hints + #1119, #3967

  ;Linha 28
  static Hints + #1120, #3967
  static Hints + #1121, #3967
  static Hints + #1122, #3967
  static Hints + #1123, #3967
  static Hints + #1124, #3967
  static Hints + #1125, #3967
  static Hints + #1126, #3967
  static Hints + #1127, #3967
  static Hints + #1128, #3967
  static Hints + #1129, #3967
  static Hints + #1130, #3967
  static Hints + #1131, #3967
  static Hints + #1132, #3967
  static Hints + #1133, #3967
  static Hints + #1134, #3967
  static Hints + #1135, #3967
  static Hints + #1136, #3967
  static Hints + #1137, #3967
  static Hints + #1138, #3967
  static Hints + #1139, #3967
  static Hints + #1140, #3967
  static Hints + #1141, #3967
  static Hints + #1142, #3967
  static Hints + #1143, #3967
  static Hints + #1144, #3967
  static Hints + #1145, #3967
  static Hints + #1146, #3967
  static Hints + #1147, #3967
  static Hints + #1148, #3967
  static Hints + #1149, #3967
  static Hints + #1150, #3967
  static Hints + #1151, #3967
  static Hints + #1152, #3967
  static Hints + #1153, #3967
  static Hints + #1154, #3967
  static Hints + #1155, #3967
  static Hints + #1156, #3967
  static Hints + #1157, #3967
  static Hints + #1158, #3967
  static Hints + #1159, #3967

  ;Linha 29
  static Hints + #1160, #3967
  static Hints + #1161, #3967
  static Hints + #1162, #3967
  static Hints + #1163, #3967
  static Hints + #1164, #3967
  static Hints + #1165, #3967
  static Hints + #1166, #3967
  static Hints + #1167, #3967
  static Hints + #1168, #3967
  static Hints + #1169, #3967
  static Hints + #1170, #3967
  static Hints + #1171, #3967
  static Hints + #1172, #3967
  static Hints + #1173, #3967
  static Hints + #1174, #3967
  static Hints + #1175, #3967
  static Hints + #1176, #3967
  static Hints + #1177, #3967
  static Hints + #1178, #3967
  static Hints + #1179, #3967
  static Hints + #1180, #3967
  static Hints + #1181, #3967
  static Hints + #1182, #3967
  static Hints + #1183, #3967
  static Hints + #1184, #3967
  static Hints + #1185, #3967
  static Hints + #1186, #3967
  static Hints + #1187, #3967
  static Hints + #1188, #3967
  static Hints + #1189, #3967
  static Hints + #1190, #3967
  static Hints + #1191, #3967
  static Hints + #1192, #3967
  static Hints + #1193, #3967
  static Hints + #1194, #3967
  static Hints + #1195, #3967
  static Hints + #1196, #3967
  static Hints + #1197, #3967
  static Hints + #1198, #3967
  static Hints + #1199, #3967

;; --- Guardando as palavras ---
    n_palavras: var #1      

    palavras: var #1579

    word0: string "abaco"
    word1: string "abada"
    word2: string "abana"
    word3: string "abril"
    word4: string "abrir"
    word5: string "acais"
    word6: string "acaro"
    word7: string "acaso"
    word8: string "aceso"
    word9: string "achar"
    word10: string "acido"
    word11: string "acima"
    word12: string "acola"
    word13: string "acres"
    word14: string "acusa"
    word15: string "adaga"
    word16: string "adeus"
    word17: string "adiar"
    word18: string "advir"
    word19: string "afeto"
    word20: string "afiar"
    word21: string "afora"
    word22: string "agape"
    word23: string "agora"
    word24: string "aguar"
    word25: string "aguas"
    word26: string "aguda"
    word27: string "agudo"
    word28: string "ainda"
    word29: string "aipim"
    word30: string "aipos"
    word31: string "alcar"
    word32: string "alema"
    word33: string "algas"
    word34: string "algum"
    word35: string "alhos"
    word36: string "aliar"
    word37: string "alias"
    word38: string "alibi"
    word39: string "almas"
    word40: string "altar"
    word41: string "altas"
    word42: string "altos"
    word43: string "aluno"
    word44: string "alvor"
    word45: string "amada"
    word46: string "amado"
    word47: string "amago"
    word48: string "ambar"
    word49: string "amido"
    word50: string "amigo"
    word51: string "amora"
    word52: string "amplo"
    word53: string "andar"
    word54: string "animo"
    word55: string "anjos"
    word56: string "anodo"
    word57: string "anoes"
    word58: string "ansia"
    word59: string "antas"
    word60: string "antro"
    word61: string "anuir"
    word62: string "anzol"
    word63: string "aonde"
    word64: string "apaga"
    word65: string "apelo"
    word66: string "apice"
    word67: string "apito"
    word68: string "apoia"
    word69: string "aqueo"
    word70: string "arabe"
    word71: string "arcar"
    word72: string "arcas"
    word73: string "arcos"
    word74: string "arder"
    word75: string "ardor"
    word76: string "arear"
    word77: string "areia"
    word78: string "arena"
    word79: string "arfar"
    word80: string "aries"
    word81: string "armar"
    word82: string "arpao"
    word83: string "arroz"
    word84: string "artes"
    word85: string "aspas"
    word86: string "assar"
    word87: string "assaz"
    word88: string "assim"
    word89: string "atico"
    word90: string "atomo"
    word91: string "atono"
    word92: string "atras"
    word93: string "atriz"
    word94: string "atroz"
    word95: string "atual"
    word96: string "atuar"
    word97: string "audio"
    word98: string "aurea"
    word99: string "aveia"
    word100: string "avela"
    word101: string "aviao"
    word102: string "avido"
    word103: string "aviso"
    word104: string "azedo"
    word105: string "azuis"
    word106: string "babar"
    word107: string "babas"
    word108: string "bacia"
    word109: string "bagas"
    word110: string "bagre"
    word111: string "bahia"
    word112: string "baiao"
    word113: string "baile"
    word114: string "baixo"
    word115: string "balao"
    word116: string "balas"
    word117: string "balde"
    word118: string "balir"
    word119: string "balsa"
    word120: string "bamba"
    word121: string "bambi"
    word122: string "bambo"
    word123: string "bambu"
    word124: string "banal"
    word125: string "banco"
    word126: string "banda"
    word127: string "bando"
    word128: string "banho"
    word129: string "banir"
    word130: string "banjo"
    word131: string "baoba"
    word132: string "baque"
    word133: string "barao"
    word134: string "barba"
    word135: string "barca"
    word136: string "barco"
    word137: string "bario"
    word138: string "baroa"
    word139: string "barra"
    word140: string "barro"
    word141: string "basal"
    word142: string "basar"
    word143: string "basco"
    word144: string "bater"
    word145: string "bauru"
    word146: string "bazar"
    word147: string "beber"
    word148: string "bebes"
    word149: string "bebum"
    word150: string "beico"
    word151: string "beijo"
    word152: string "beira"
    word153: string "belas"
    word154: string "belem"
    word155: string "belga"
    word156: string "belos"
    word157: string "bemol"
    word158: string "bento"
    word159: string "berbe"
    word160: string "berco"
    word161: string "berro"
    word162: string "besta"
    word163: string "betim"
    word164: string "bicar"
    word165: string "bicha"
    word166: string "bicho"
    word167: string "biela"
    word168: string "bimba"
    word169: string "bioma"
    word170: string "biose"
    word171: string "biota"
    word172: string "bispo"
    word173: string "bloco"
    word174: string "blusa"
    word175: string "bobao"
    word176: string "bobos"
    word177: string "bocal"
    word178: string "bocas"
    word179: string "bocel"
    word180: string "bodar"
    word181: string "bodes"
    word182: string "boiar"
    word183: string "boias"
    word184: string "boina"
    word185: string "bolao"
    word186: string "bolar"
    word187: string "bolas"
    word188: string "boldo"
    word189: string "bolha"
    word190: string "bolor"
    word191: string "bolos"
    word192: string "bolsa"
    word193: string "bolsa"
    word194: string "bomba"
    word195: string "bonar"
    word196: string "bonde"
    word197: string "bones"
    word198: string "bonus"
    word199: string "borda"
    word200: string "bordo"
    word201: string "borel"
    word202: string "borra"
    word203: string "bosco"
    word204: string "boson"
    word205: string "bossa"
    word206: string "bosta"
    word207: string "botar"
    word208: string "botas"
    word209: string "botim"
    word210: string "botos"
    word211: string "botox"
    word212: string "bouba"
    word213: string "bouda"
    word214: string "braco"
    word215: string "brasa"
    word216: string "bravo"
    word217: string "brear"
    word218: string "breca"
    word219: string "brega"
    word220: string "brejo"
    word221: string "breus"
    word222: string "breve"
    word223: string "briga"
    word224: string "brisa"
    word225: string "brita"
    word226: string "broca"
    word227: string "bromo"
    word228: string "brumo"
    word229: string "bruto"
    word230: string "bruxa"
    word231: string "bucal"
    word232: string "bucha"
    word233: string "bucho"
    word234: string "bufar"
    word235: string "bugio"
    word236: string "bugre"
    word237: string "bujao"
    word238: string "bulbo"
    word239: string "bules"
    word240: string "bulir"
    word241: string "bunda"
    word242: string "burro"
    word243: string "busca"
    word244: string "busso"
    word245: string "busto"
    word246: string "buzio"
    word247: string "cabal"
    word248: string "caber"
    word249: string "cabos"
    word250: string "cabra"
    word251: string "cacao"
    word252: string "cacar"
    word253: string "cacas"
    word254: string "cacau"
    word255: string "cache"
    word256: string "cacho"
    word257: string "caciz"
    word258: string "cacos"
    word259: string "cacto"
    word260: string "cafes"
    word261: string "cafta"
    word262: string "cagar"
    word263: string "cairo"
    word264: string "cairu"
    word265: string "caixa"
    word266: string "cajas"
    word267: string "cajus"
    word268: string "calao"
    word269: string "calar"
    word270: string "calca"
    word271: string "calco"
    word272: string "caldo"
    word273: string "calos"
    word274: string "calvo"
    word275: string "camas"
    word276: string "campo"
    word277: string "canal"
    word278: string "canas"
    word279: string "canil"
    word280: string "canoa"
    word281: string "canto"
    word282: string "capas"
    word283: string "capaz"
    word284: string "capim"
    word285: string "capuz"
    word286: string "caqui"
    word287: string "caras"
    word288: string "carga"
    word289: string "carie"
    word290: string "carmo"
    word291: string "carne"
    word292: string "carne"
    word293: string "caros"
    word294: string "carro"
    word295: string "carta"
    word296: string "casal"
    word297: string "casao"
    word298: string "casar"
    word299: string "casas"
    word300: string "casca"
    word301: string "casco"
    word302: string "casos"
    word303: string "caspa"
    word304: string "casta"
    word305: string "casto"
    word306: string "catar"
    word307: string "cauda"
    word308: string "caule"
    word309: string "causa"
    word310: string "cavar"
    word311: string "ceara"
    word312: string "ceder"
    word313: string "cedro"
    word314: string "cegar"
    word315: string "cegos"
    word316: string "ceita"
    word317: string "censo"
    word318: string "cento"
    word319: string "cerar"
    word320: string "ceras"
    word321: string "cerca"
    word322: string "cerdo"
    word323: string "cerne"
    word324: string "cerol"
    word325: string "cervo"
    word326: string "cesta"
    word327: string "cesto"
    word328: string "cetim"
    word329: string "cetro"
    word330: string "chaga"
    word331: string "chale"
    word332: string "chama"
    word333: string "chaos"
    word334: string "chapa"
    word335: string "chato"
    word336: string "chave"
    word337: string "chefe"
    word338: string "cheio"
    word339: string "chile"
    word340: string "china"
    word341: string "choco"
    word342: string "chule"
    word343: string "chuva"
    word344: string "ciano"
    word345: string "ciclo"
    word346: string "cidra"
    word347: string "cilio"
    word348: string "cinza"
    word349: string "cipos"
    word350: string "circo"
    word351: string "cisao"
    word352: string "cisco"
    word353: string "cisma"
    word354: string "cisne"
    word355: string "citar"
    word356: string "ciume"
    word357: string "civis"
    word358: string "clara"
    word359: string "claro"
    word360: string "clava"
    word361: string "clero"
    word362: string "clima"
    word363: string "clipe"
    word364: string "clone"
    word365: string "cloro"
    word366: string "clube"
    word367: string "cobre"
    word368: string "cocar"
    word369: string "cocos"
    word370: string "codon"
    word371: string "coeso"
    word372: string "cofre"
    word373: string "cohab"
    word374: string "coice"
    word375: string "coifa"
    word376: string "coisa"
    word377: string "coito"
    word378: string "colar"
    word379: string "colas"
    word380: string "colon"
    word381: string "colos"
    word382: string "combe"
    word383: string "combo"
    word384: string "comer"
    word385: string "comum"
    word386: string "conde"
    word387: string "congo"
    word388: string "conta"
    word389: string "conto"
    word390: string "copas"
    word391: string "copos"
    word392: string "coral"
    word393: string "corar"
    word394: string "corda"
    word395: string "cores"
    word396: string "corgo"
    word397: string "corno"
    word398: string "coroa"
    word399: string "coroa"
    word400: string "corpo"
    word401: string "corte"
    word402: string "corvo"
    word403: string "coser"
    word404: string "cosmo"
    word405: string "cospe"
    word406: string "costa"
    word407: string "cotas"
    word408: string "couve"
    word409: string "covas"
    word410: string "covil"
    word411: string "coxas"
    word412: string "coxos"
    word413: string "cravo"
    word414: string "credo"
    word415: string "creme"
    word416: string "crepe"
    word417: string "creta"
    word418: string "criar"
    word419: string "crime"
    word420: string "crina"
    word421: string "crise"
    word422: string "crivo"
    word423: string "cruel"
    word424: string "cubos"
    word425: string "cucas"
    word426: string "cueca"
    word427: string "culpa"
    word428: string "culto"
    word429: string "cunha"
    word430: string "cunho"
    word431: string "cupim"
    word432: string "cupio"
    word433: string "cupom"
    word434: string "curar"
    word435: string "curas"
    word436: string "curau"
    word437: string "curso"
    word438: string "curto"
    word439: string "curva"
    word440: string "curvo"
    word441: string "cuspe"
    word442: string "custo"
    word443: string "cutia"
    word444: string "dados"
    word445: string "damas"
    word446: string "danar"
    word447: string "danca"
    word448: string "daqui"
    word449: string "datar"
    word450: string "datas"
    word451: string "debil"
    word452: string "dedos"
    word453: string "delta"
    word454: string "dengo"
    word455: string "denso"
    word456: string "dente"
    word457: string "depor"
    word458: string "derme"
    word459: string "desce"
    word460: string "deter"
    word461: string "deusa"
    word462: string "dever"
    word463: string "devir"
    word464: string "diabo"
    word465: string "dicas"
    word466: string "digno"
    word467: string "disco"
    word468: string "ditos"
    word469: string "dizer"
    word470: string "dobro"
    word471: string "doces"
    word472: string "docil"
    word473: string "dogma"
    word474: string "doido"
    word475: string "dolar"
    word476: string "domar"
    word477: string "donas"
    word478: string "donos"
    word479: string "dopar"
    word480: string "dores"
    word481: string "dorso"
    word482: string "dosar"
    word483: string "doses"
    word484: string "dotar"
    word485: string "draga"
    word486: string "drama"
    word487: string "duble"
    word488: string "ducto"
    word489: string "duelo"
    word490: string "dueto"
    word491: string "dunas"
    word492: string "duplo"
    word493: string "duque"
    word494: string "durar"
    word495: string "duras"
    word496: string "duzia"
    word497: string "ebrio"
    word498: string "ecoar"
    word499: string "edema"
    word500: string "egito"
    word501: string "eixos"
    word502: string "enfim"
    word503: string "entao"
    word504: string "entre"
    word505: string "epico"
    word506: string "epoca"
    word507: string "errar"
    word508: string "erros"
    word509: string "ervas"
    word510: string "estar"
    word511: string "etapa"
    word512: string "etico"
    word513: string "etnia"
    word514: string "exame"
    word515: string "exato"
    word516: string "exito"
    word517: string "expor"
    word518: string "extra"
    word519: string "facao"
    word520: string "facas"
    word521: string "faces"
    word522: string "facil"
    word523: string "fadar"
    word524: string "fadas"
    word525: string "faixa"
    word526: string "falar"
    word527: string "falha"
    word528: string "falir"
    word529: string "falso"
    word530: string "fanho"
    word531: string "farao"
    word532: string "farda"
    word533: string "farol"
    word534: string "farsa"
    word535: string "farta"
    word536: string "fasor"
    word537: string "fatal"
    word538: string "fatia"
    word539: string "fator"
    word540: string "fatos"
    word541: string "faula"
    word542: string "fauno"
    word543: string "favas"
    word544: string "favor"
    word545: string "fazer"
    word546: string "febre"
    word547: string "fecal"
    word548: string "fecho"
    word549: string "feder"
    word550: string "fedor"
    word551: string "feias"
    word552: string "feios"
    word553: string "feira"
    word554: string "feito"
    word555: string "feixe"
    word556: string "femea"
    word557: string "femur"
    word558: string "feras"
    word559: string "ferir"
    word560: string "feroz"
    word561: string "ferpa"
    word562: string "ferro"
    word563: string "festa"
    word564: string "fetal"
    word565: string "fetos"
    word566: string "feudo"
    word567: string "fibra"
    word568: string "ficar"
    word569: string "filho"
    word570: string "final"
    word571: string "finar"
    word572: string "finas"
    word573: string "finca"
    word574: string "finda"
    word575: string "findo"
    word576: string "firma"
    word577: string "fitar"
    word578: string "fitas"
    word579: string "fixar"
    word580: string "fixos"
    word581: string "flama"
    word582: string "flavo"
    word583: string "floco"
    word584: string "flora"
    word585: string "fluir"
    word586: string "fluor"
    word587: string "fluxo"
    word588: string "fobia"
    word589: string "focal"
    word590: string "focar"
    word591: string "focas"
    word592: string "focos"
    word593: string "fofos"
    word594: string "fogao"
    word595: string "fogos"
    word596: string "foice"
    word597: string "folha"
    word598: string "folia"
    word599: string "fomes"
    word600: string "fonte"
    word601: string "forca"
    word602: string "forca"
    word603: string "forma"
    word604: string "forno"
    word605: string "forra"
    word606: string "forro"
    word607: string "forte"
    word608: string "forum"
    word609: string "fosco"
    word610: string "fossa"
    word611: string "fosso"
    word612: string "fotos"
    word613: string "fraco"
    word614: string "frase"
    word615: string "frear"
    word616: string "freio"
    word617: string "fresa"
    word618: string "frete"
    word619: string "frevo"
    word620: string "frias"
    word621: string "friez"
    word622: string "frios"
    word623: string "frita"
    word624: string "frito"
    word625: string "frota"
    word626: string "fruta"
    word627: string "fruto"
    word628: string "fugaz"
    word629: string "fugir"
    word630: string "fumar"
    word631: string "fumos"
    word632: string "fundo"
    word633: string "fungo"
    word634: string "funil"
    word635: string "furar"
    word636: string "furia"
    word637: string "furor"
    word638: string "furos"
    word639: string "fusao"
    word640: string "fusil"
    word641: string "fusos"
    word642: string "futil"
    word643: string "fuzil"
    word644: string "fuzis"
    word645: string "gabar"
    word646: string "galho"
    word647: string "galos"
    word648: string "gamao"
    word649: string "gamar"
    word650: string "gamba"
    word651: string "ganho"
    word652: string "ganir"
    word653: string "ganso"
    word654: string "garbo"
    word655: string "garca"
    word656: string "garra"
    word657: string "gases"
    word658: string "gasto"
    word659: string "gatos"
    word660: string "geada"
    word661: string "gelos"
    word662: string "gemas"
    word663: string "gemeo"
    word664: string "gemer"
    word665: string "genio"
    word666: string "genro"
    word667: string "gente"
    word668: string "geral"
    word669: string "gerar"
    word670: string "germe"
    word671: string "gesso"
    word672: string "gesto"
    word673: string "girar"
    word674: string "giros"
    word675: string "glace"
    word676: string "globo"
    word677: string "glote"
    word678: string "gnomo"
    word679: string "goela"
    word680: string "goias"
    word681: string "golas"
    word682: string "golfo"
    word683: string "golpe"
    word684: string "gomas"
    word685: string "gordo"
    word686: string "gosma"
    word687: string "gosto"
    word688: string "graal"
    word689: string "graca"
    word690: string "grade"
    word691: string "grafo"
    word692: string "grama"
    word693: string "graos"
    word694: string "grato"
    word695: string "grave"
    word696: string "graxa"
    word697: string "grego"
    word698: string "greve"
    word699: string "grilo"
    word700: string "grude"
    word701: string "grupo"
    word702: string "gruta"
    word703: string "guiar"
    word704: string "guias"
    word705: string "habil"
    word706: string "hagar"
    word707: string "harem"
    word708: string "haste"
    word709: string "helio"
    word710: string "heras"
    word711: string "heroi"
    word712: string "hiato"
    word713: string "hidra"
    word714: string "hiena"
    word715: string "hifen"
    word716: string "himen"
    word717: string "homem"
    word718: string "honra"
    word719: string "horas"
    word720: string "horda"
    word721: string "horta"
    word722: string "hotel"
    word723: string "hulha"
    word724: string "humor"
    word725: string "humus"
    word726: string "icone"
    word727: string "idear"
    word728: string "ideia"
    word729: string "idolo"
    word730: string "igneo"
    word731: string "igual"
    word732: string "ileso"
    word733: string "ilhas"
    word734: string "impar"
    word735: string "impio"
    word736: string "impor"
    word737: string "imune"
    word738: string "index"
    word739: string "india"
    word740: string "indio"
    word741: string "inves"
    word742: string "irmao"
    word743: string "irmas"
    word744: string "iscas"
    word745: string "jacas"
    word746: string "jambo"
    word747: string "jambu"
    word748: string "janio"
    word749: string "japao"
    word750: string "jarro"
    word751: string "jatos"
    word752: string "jaula"
    word753: string "jazer"
    word754: string "jeito"
    word755: string "jejum"
    word756: string "jesus"
    word757: string "jogar"
    word758: string "jogos"
    word759: string "joias"
    word760: string "jotas"
    word761: string "jovem"
    word762: string "judeu"
    word763: string "judia"
    word764: string "juiza"
    word765: string "juizo"
    word766: string "julho"
    word767: string "jumbo"
    word768: string "junho"
    word769: string "junia"
    word770: string "jurar"
    word771: string "justa"
    word772: string "labio"
    word773: string "labor"
    word774: string "lacar"
    word775: string "lacre"
    word776: string "lagoa"
    word777: string "lagos"
    word778: string "laico"
    word779: string "lamas"
    word780: string "lambe"
    word781: string "lanca"
    word782: string "lapas"
    word783: string "lapis"
    word784: string "lapso"
    word785: string "laque"
    word786: string "largo"
    word787: string "larva"
    word788: string "lasca"
    word789: string "latao"
    word790: string "latas"
    word791: string "latex"
    word792: string "latim"
    word793: string "latir"
    word794: string "lauda"
    word795: string "laudo"
    word796: string "lavar"
    word797: string "lavra"
    word798: string "lazer"
    word799: string "leais"
    word800: string "lebre"
    word801: string "legal"
    word802: string "legua"
    word803: string "leite"
    word804: string "leito"
    word805: string "lenco"
    word806: string "lenha"
    word807: string "lento"
    word808: string "leoas"
    word809: string "leoes"
    word810: string "lepra"
    word811: string "leque"
    word812: string "lerdo"
    word813: string "lesao"
    word814: string "lesar"
    word815: string "lesma"
    word816: string "leste"
    word817: string "letal"
    word818: string "letra"
    word819: string "levar"
    word820: string "leves"
    word821: string "lhama"
    word822: string "liame"
    word823: string "libra"
    word824: string "licao"
    word825: string "licor"
    word826: string "lidar"
    word827: string "lider"
    word828: string "ligar"
    word829: string "ligas"
    word830: string "lilas"
    word831: string "limao"
    word832: string "limar"
    word833: string "limas"
    word834: string "limbo"
    word835: string "limpo"
    word836: string "lince"
    word837: string "lindo"
    word838: string "linha"
    word839: string "linho"
    word840: string "lirio"
    word841: string "lisos"
    word842: string "lista"
    word843: string "litio"
    word844: string "litro"
    word845: string "livre"
    word846: string "livro"
    word847: string "lixao"
    word848: string "lixar"
    word849: string "lixas"
    word850: string "lixos"
    word851: string "lobos"
    word852: string "local"
    word853: string "locao"
    word854: string "locar"
    word855: string "lombo"
    word856: string "lonas"
    word857: string "longe"
    word858: string "longo"
    word859: string "lotar"
    word860: string "lotus"
    word861: string "louca"
    word862: string "louco"
    word863: string "louro"
    word864: string "lousa"
    word865: string "lucro"
    word866: string "lugar"
    word867: string "lulas"
    word868: string "lunar"
    word869: string "lutar"
    word870: string "luvas"
    word871: string "luxar"
    word872: string "luxos"
    word873: string "macas"
    word874: string "macho"
    word875: string "macio"
    word876: string "macom"
    word877: string "macos"
    word878: string "madre"
    word879: string "magma"
    word880: string "magna"
    word881: string "magoa"
    word882: string "magro"
    word883: string "maior"
    word884: string "major"
    word885: string "malas"
    word886: string "malha"
    word887: string "malta"
    word888: string "mamae"
    word889: string "mamao"
    word890: string "mamar"
    word891: string "mamas"
    word892: string "manca"
    word893: string "manga"
    word894: string "manha"
    word895: string "mania"
    word896: string "manso"
    word897: string "manta"
    word898: string "manto"
    word899: string "mapas"
    word900: string "marca"
    word901: string "marco"
    word902: string "marco"
    word903: string "mares"
    word904: string "marte"
    word905: string "massa"
    word906: string "matar"
    word907: string "matiz"
    word908: string "matos"
    word909: string "mecha"
    word910: string "media"
    word911: string "medio"
    word912: string "medir"
    word913: string "meias"
    word914: string "meigo"
    word915: string "meios"
    word916: string "melao"
    word917: string "melar"
    word918: string "menor"
    word919: string "menos"
    word920: string "menta"
    word921: string "merce"
    word922: string "merda"
    word923: string "meros"
    word924: string "mesas"
    word925: string "meses"
    word926: string "mesmo"
    word927: string "meter"
    word928: string "metro"
    word929: string "metro"
    word930: string "mexer"
    word931: string "midia"
    word932: string "mijar"
    word933: string "mijos"
    word934: string "milho"
    word935: string "mimar"
    word936: string "minar"
    word937: string "minas"
    word938: string "minha"
    word939: string "miolo"
    word940: string "miope"
    word941: string "mirar"
    word942: string "miras"
    word943: string "mirim"
    word944: string "misto"
    word945: string "miudo"
    word946: string "mocas"
    word947: string "modas"
    word948: string "modos"
    word949: string "moeda"
    word950: string "moela"
    word951: string "mofar"
    word952: string "mofos"
    word953: string "mogno"
    word954: string "moita"
    word955: string "molar"
    word956: string "molas"
    word957: string "molde"
    word958: string "moles"
    word959: string "molho"
    word960: string "monja"
    word961: string "morar"
    word962: string "morro"
    word963: string "morta"
    word964: string "morte"
    word965: string "morto"
    word966: string "mosca"
    word967: string "motel"
    word968: string "motim"
    word969: string "motor"
    word970: string "motos"
    word971: string "movel"
    word972: string "mover"
    word973: string "mudar"
    word974: string "mudas"
    word975: string "mudez"
    word976: string "mudos"
    word977: string "multa"
    word978: string "mumia"
    word979: string "mundo"
    word980: string "munir"
    word981: string "mural"
    word982: string "muros"
    word983: string "murro"
    word984: string "musas"
    word985: string "museu"
    word986: string "nabos"
    word987: string "nacao"
    word988: string "nadar"
    word989: string "nariz"
    word990: string "nasal"
    word991: string "natal"
    word992: string "natas"
    word993: string "naval"
    word994: string "negar"
    word995: string "negro"
    word996: string "nepal"
    word997: string "nervo"
    word998: string "nevar"
    word999: string "neves"
    word1000: string "ninfa"
    word1001: string "ninho"
    word1002: string "ninja"
    word1003: string "nobre"
    word1004: string "nocao"
    word1005: string "nodal"
    word1006: string "nodos"
    word1007: string "noivo"
    word1008: string "nonos"
    word1009: string "norte"
    word1010: string "nosso"
    word1011: string "notar"
    word1012: string "notas"
    word1013: string "novos"
    word1014: string "nozes"
    word1015: string "nudez"
    word1016: string "nunca"
    word1017: string "nuvem"
    word1018: string "oasis"
    word1019: string "obito"
    word1020: string "obras"
    word1021: string "obter"
    word1022: string "obvio"
    word1023: string "octal"
    word1024: string "oculo"
    word1025: string "odiar"
    word1026: string "ofuro"
    word1027: string "olhar"
    word1028: string "olhos"
    word1029: string "oliva"
    word1030: string "ombro"
    word1031: string "omega"
    word1032: string "oncas"
    word1033: string "ondas"
    word1034: string "opaco"
    word1035: string "opcao"
    word1036: string "opera"
    word1037: string "optar"
    word1038: string "orfao"
    word1039: string "ornar"
    word1040: string "osseo"
    word1041: string "ossos"
    word1042: string "ostra"
    word1043: string "otimo"
    word1044: string "ouros"
    word1045: string "ousar"
    word1046: string "outro"
    word1047: string "ouvir"
    word1048: string "ovino"
    word1049: string "ovulo"
    word1050: string "oxido"
    word1051: string "padre"
    word1052: string "pagao"
    word1053: string "pagar"
    word1054: string "pagos"
    word1055: string "paiol"
    word1056: string "pajem"
    word1057: string "pajes"
    word1058: string "palco"
    word1059: string "palha"
    word1060: string "palma"
    word1061: string "panda"
    word1062: string "papar"
    word1063: string "papel"
    word1064: string "papos"
    word1065: string "parar"
    word1066: string "pardo"
    word1067: string "pareo"
    word1068: string "pares"
    word1069: string "parir"
    word1070: string "parte"
    word1071: string "parto"
    word1072: string "parvo"
    word1073: string "passo"
    word1074: string "pasto"
    word1075: string "patas"
    word1076: string "patio"
    word1077: string "patos"
    word1078: string "pavao"
    word1079: string "pavio"
    word1080: string "pavoa"
    word1081: string "pavor"
    word1082: string "pecar"
    word1083: string "pecas"
    word1084: string "pedal"
    word1085: string "pedir"
    word1086: string "pedra"
    word1087: string "pegar"
    word1088: string "peido"
    word1089: string "peito"
    word1090: string "peixe"
    word1091: string "peles"
    word1092: string "pelos"
    word1093: string "pelve"
    word1094: string "penal"
    word1095: string "penar"
    word1096: string "penas"
    word1097: string "penca"
    word1098: string "pente"
    word1099: string "peoes"
    word1100: string "pepel"
    word1101: string "pequi"
    word1102: string "peras"
    word1103: string "perca"
    word1104: string "perna"
    word1105: string "persa"
    word1106: string "perto"
    word1107: string "perua"
    word1108: string "pesar"
    word1109: string "pesca"
    word1110: string "pesos"
    word1111: string "peste"
    word1112: string "pifar"
    word1113: string "pifio"
    word1114: string "pilha"
    word1115: string "pinar"
    word1116: string "pingo"
    word1117: string "pinha"
    word1118: string "pinho"
    word1119: string "pinos"
    word1120: string "pinta"
    word1121: string "pinto"
    word1122: string "pioes"
    word1123: string "pipas"
    word1124: string "pirar"
    word1125: string "piris"
    word1126: string "pisar"
    word1127: string "pisca"
    word1128: string "pisos"
    word1129: string "placa"
    word1130: string "plano"
    word1131: string "plato"
    word1132: string "plebe"
    word1133: string "pleno"
    word1134: string "pluma"
    word1135: string "pneus"
    word1136: string "pobre"
    word1137: string "pocos"
    word1138: string "podar"
    word1139: string "poder"
    word1140: string "podio"
    word1141: string "podre"
    word1142: string "poema"
    word1143: string "poeta"
    word1144: string "polen"
    word1145: string "polir"
    word1146: string "polos"
    word1147: string "polvo"
    word1148: string "pomar"
    word1149: string "pomba"
    word1150: string "pombo"
    word1151: string "ponei"
    word1152: string "ponta"
    word1153: string "ponte"
    word1154: string "ponto"
    word1155: string "porco"
    word1156: string "porta"
    word1157: string "porto"
    word1158: string "posar"
    word1159: string "posto"
    word1160: string "potro"
    word1161: string "pouco"
    word1162: string "poupa"
    word1163: string "povos"
    word1164: string "praca"
    word1165: string "praga"
    word1166: string "praia"
    word1167: string "prata"
    word1168: string "prato"
    word1169: string "prazo"
    word1170: string "prece"
    word1171: string "preco"
    word1172: string "prego"
    word1173: string "preso"
    word1174: string "preto"
    word1175: string "primo"
    word1176: string "prior"
    word1177: string "prole"
    word1178: string "prosa"
    word1179: string "pudim"
    word1180: string "pudor"
    word1181: string "pular"
    word1182: string "pulga"
    word1183: string "pulos"
    word1184: string "punho"
    word1185: string "punir"
    word1186: string "puros"
    word1187: string "puxar"
    word1188: string "quase"
    word1189: string "queda"
    word1190: string "quibe"
    word1191: string "quimo"
    word1192: string "quina"
    word1193: string "rabos"
    word1194: string "racao"
    word1195: string "radar"
    word1196: string "radio"
    word1197: string "raias"
    word1198: string "raios"
    word1199: string "raiva"
    word1200: string "rajar"
    word1201: string "ralar"
    word1202: string "ralos"
    word1203: string "ramal"
    word1204: string "ramas"
    word1205: string "ramos"
    word1206: string "rampa"
    word1207: string "ranho"
    word1208: string "rapaz"
    word1209: string "rapel"
    word1210: string "raque"
    word1211: string "raros"
    word1212: string "rasos"
    word1213: string "raspa"
    word1214: string "ratos"
    word1215: string "razao"
    word1216: string "reais"
    word1217: string "recem"
    word1218: string "redes"
    word1219: string "refem"
    word1220: string "regar"
    word1221: string "regio"
    word1222: string "regra"
    word1223: string "regua"
    word1224: string "relar"
    word1225: string "relva"
    word1226: string "remar"
    word1227: string "renal"
    word1228: string "renda"
    word1229: string "resto"
    word1230: string "retos"
    word1231: string "retro"
    word1232: string "reuma"
    word1233: string "reves"
    word1234: string "revoa"
    word1235: string "rezar"
    word1236: string "ricos"
    word1237: string "rifar"
    word1238: string "rijos"
    word1239: string "rimar"
    word1240: string "rimas"
    word1241: string "rixas"
    word1242: string "robos"
    word1243: string "rocar"
    word1244: string "rocas"
    word1245: string "rocha"
    word1246: string "rodar"
    word1247: string "rodas"
    word1248: string "rodos"
    word1249: string "rogar"
    word1250: string "rojao"
    word1251: string "rolar"
    word1252: string "rolha"
    word1253: string "romas"
    word1254: string "rombo"
    word1255: string "romeu"
    word1256: string "ronda"
    word1257: string "rosal"
    word1258: string "rosas"
    word1259: string "rosca"
    word1260: string "rosto"
    word1261: string "rotas"
    word1262: string "rotor"
    word1263: string "rouco"
    word1264: string "roupa"
    word1265: string "roxos"
    word1266: string "rubor"
    word1267: string "rubro"
    word1268: string "rubro"
    word1269: string "rudez"
    word1270: string "ruela"
    word1271: string "rufar"
    word1272: string "rufos"
    word1273: string "rugir"
    word1274: string "ruina"
    word1275: string "ruins"
    word1276: string "ruivo"
    word1277: string "rumar"
    word1278: string "rumor"
    word1279: string "rural"
    word1280: string "russo"
    word1281: string "saara"
    word1282: string "sabao"
    word1283: string "saber"
    word1284: string "sabio"
    word1285: string "sabor"
    word1286: string "sabre"
    word1287: string "sacar"
    word1288: string "sacas"
    word1289: string "sache"
    word1290: string "sacos"
    word1291: string "sacro"
    word1292: string "sadio"
    word1293: string "safar"
    word1294: string "sagaz"
    word1295: string "sagui"
    word1296: string "saias"
    word1297: string "saida"
    word1298: string "salao"
    word1299: string "salas"
    word1300: string "salmo"
    word1301: string "salsa"
    word1302: string "salto"
    word1303: string "salvo"
    word1304: string "samba"
    word1305: string "santo"
    word1306: string "sapos"
    word1307: string "sarar"
    word1308: string "sarau"
    word1309: string "sarda"
    word1310: string "sarna"
    word1311: string "saude"
    word1312: string "sauna"
    word1313: string "sebos"
    word1314: string "secar"
    word1315: string "secos"
    word1316: string "secto"
    word1317: string "sedar"
    word1318: string "sedas"
    word1319: string "seios"
    word1320: string "seita"
    word1321: string "seiva"
    word1322: string "seixo"
    word1323: string "selar"
    word1324: string "selim"
    word1325: string "selos"
    word1326: string "selva"
    word1327: string "semen"
    word1328: string "senda"
    word1329: string "senil"
    word1330: string "senso"
    word1331: string "serio"
    word1332: string "serra"
    word1333: string "setor"
    word1334: string "sexos"
    word1335: string "sexta"
    word1336: string "sidra"
    word1337: string "sifao"
    word1338: string "sigma"
    word1339: string "signo"
    word1340: string "silvo"
    word1341: string "sinal"
    word1342: string "sinos"
    word1343: string "siria"
    word1344: string "sirio"
    word1345: string "siris"
    word1346: string "sisos"
    word1347: string "sisto"
    word1348: string "sitio"
    word1349: string "sobre"
    word1350: string "socar"
    word1351: string "socio"
    word1352: string "socos"
    word1353: string "sodio"
    word1354: string "sofas"
    word1355: string "sogro"
    word1356: string "sojas"
    word1357: string "solas"
    word1358: string "solda"
    word1359: string "solos"
    word1360: string "solta"
    word1361: string "somar"
    word1362: string "sonar"
    word1363: string "sonda"
    word1364: string "sonos"
    word1365: string "sonso"
    word1366: string "sopra"
    word1367: string "soros"
    word1368: string "sorte"
    word1369: string "sosia"
    word1370: string "sosso"
    word1371: string "sotao"
    word1372: string "sovar"
    word1373: string "suave"
    word1374: string "subir"
    word1375: string "sucos"
    word1376: string "sueco"
    word1377: string "suica"
    word1378: string "suico"
    word1379: string "suino"
    word1380: string "suite"
    word1381: string "sujar"
    word1382: string "sujos"
    word1383: string "sulao"
    word1384: string "sumos"
    word1385: string "super"
    word1386: string "surdo"
    word1387: string "sutia"
    word1388: string "sutil"
    word1389: string "tabua"
    word1390: string "tacar"
    word1391: string "tacas"
    word1392: string "tacos"
    word1393: string "taiga"
    word1394: string "talco"
    word1395: string "tanto"
    word1396: string "tapar"
    word1397: string "tarar"
    word1398: string "tarde"
    word1399: string "tatus"
    word1400: string "taxar"
    word1401: string "tecer"
    word1402: string "tedio"
    word1403: string "telha"
    word1404: string "telas"
    word1405: string "temas"
    word1406: string "temor"
    word1407: string "tempo"
    word1408: string "tenaz"
    word1409: string "tenda"
    word1410: string "tenor"
    word1411: string "tenro"
    word1412: string "tenso"
    word1413: string "tenue"
    word1414: string "terca"
    word1415: string "terco"
    word1416: string "terra"
    word1417: string "testa"
    word1418: string "tetas"
    word1419: string "tetos"
    word1420: string "texto"
    word1421: string "tigre"
    word1422: string "timao"
    word1423: string "times"
    word1424: string "tinir"
    word1425: string "tinta"
    word1426: string "tinto"
    word1427: string "tipos"
    word1428: string "tirar"
    word1429: string "tiras"
    word1430: string "tiros"
    word1431: string "titio"
    word1432: string "tocar"
    word1433: string "tocos"
    word1434: string "todos"
    word1435: string "tolos"
    word1436: string "tonal"
    word1437: string "tonel"
    word1438: string "tonus"
    word1439: string "topar"
    word1440: string "topos"
    word1441: string "toque"
    word1442: string "torce"
    word1443: string "torno"
    word1444: string "torpe"
    word1445: string "torre"
    word1446: string "torso"
    word1447: string "torta"
    word1448: string "torto"
    word1449: string "tosar"
    word1450: string "total"
    word1451: string "touro"
    word1452: string "traca"
    word1453: string "traco"
    word1454: string "traga"
    word1455: string "trago"
    word1456: string "trair"
    word1457: string "trapo"
    word1458: string "trava"
    word1459: string "treco"
    word1460: string "treze"
    word1461: string "triar"
    word1462: string "tribo"
    word1463: string "trico"
    word1464: string "trigo"
    word1465: string "trios"
    word1466: string "tripa"
    word1467: string "tripe"
    word1468: string "troca"
    word1469: string "tropa"
    word1470: string "truco"
    word1471: string "truta"
    word1472: string "tubos"
    word1473: string "tufao"
    word1474: string "tufos"
    word1475: string "tulha"
    word1476: string "tumor"
    word1477: string "tunel"
    word1478: string "turco"
    word1479: string "turma"
    word1480: string "turne"
    word1481: string "turno"
    word1482: string "tutor"
    word1483: string "uivar"
    word1484: string "uivos"
    word1485: string "umido"
    word1486: string "uncao"
    word1487: string "ungir"
    word1488: string "unhar"
    word1489: string "unhas"
    word1490: string "uniao"
    word1491: string "unico"
    word1492: string "unido"
    word1493: string "untar"
    word1494: string "urgir"
    word1495: string "urina"
    word1496: string "urnas"
    word1497: string "urrar"
    word1498: string "urros"
    word1499: string "ursos"
    word1500: string "urubu"
    word1501: string "usina"
    word1502: string "usual"
    word1503: string "utero"
    word1504: string "vacas"
    word1505: string "vacuo"
    word1506: string "vagao"
    word1507: string "vagar"
    word1508: string "vagem"
    word1509: string "vagos"
    word1510: string "vaiar"
    word1511: string "valas"
    word1512: string "vales"
    word1513: string "valor"
    word1514: string "vapor"
    word1515: string "varao"
    word1516: string "varas"
    word1517: string "varoa"
    word1518: string "vazao"
    word1519: string "vazar"
    word1520: string "vedar"
    word1521: string "velas"
    word1522: string "velho"
    word1523: string "veloz"
    word1524: string "venda"
    word1525: string "vento"
    word1526: string "venus"
    word1527: string "verao"
    word1528: string "verbo"
    word1529: string "verde"
    word1530: string "verme"
    word1531: string "verso"
    word1532: string "vesgo"
    word1533: string "vespa"
    word1534: string "veste"
    word1535: string "vetar"
    word1536: string "vetor"
    word1537: string "vetos"
    word1538: string "vicio"
    word1539: string "vidas"
    word1540: string "video"
    word1541: string "vidro"
    word1542: string "vigor"
    word1543: string "vilao"
    word1544: string "vilas"
    word1545: string "vinda"
    word1546: string "vinho"
    word1547: string "vinil"
    word1548: string "viola"
    word1549: string "viral"
    word1550: string "virar"
    word1551: string "viril"
    word1552: string "virus"
    word1553: string "visao"
    word1554: string "visar"
    word1555: string "visor"
    word1556: string "visos"
    word1557: string "vista"
    word1558: string "vital"
    word1559: string "viuva"
    word1560: string "vivaz"
    word1561: string "viver"
    word1562: string "vivos"
    word1563: string "vocal"
    word1564: string "vogal"
    word1565: string "volei"
    word1566: string "volta"
    word1567: string "votar"
    word1568: string "votos"
    word1569: string "vozes"
    word1570: string "vulgo"
    word1571: string "xampu"
    word1572: string "zebra"
    word1573: string "zelar"
    word1574: string "zerar"
    word1575: string "zeros"
    word1576: string "ziper"
    word1577: string "zonas"
    word1578: string "zorra"
    static palavras + #0, #word0
    static palavras + #1, #word1
    static palavras + #2, #word2
    static palavras + #3, #word3
    static palavras + #4, #word4
    static palavras + #5, #word5
    static palavras + #6, #word6
    static palavras + #7, #word7
    static palavras + #8, #word8
    static palavras + #9, #word9
    static palavras + #10, #word10
    static palavras + #11, #word11
    static palavras + #12, #word12
    static palavras + #13, #word13
    static palavras + #14, #word14
    static palavras + #15, #word15
    static palavras + #16, #word16
    static palavras + #17, #word17
    static palavras + #18, #word18
    static palavras + #19, #word19
    static palavras + #20, #word20
    static palavras + #21, #word21
    static palavras + #22, #word22
    static palavras + #23, #word23
    static palavras + #24, #word24
    static palavras + #25, #word25
    static palavras + #26, #word26
    static palavras + #27, #word27
    static palavras + #28, #word28
    static palavras + #29, #word29
    static palavras + #30, #word30
    static palavras + #31, #word31
    static palavras + #32, #word32
    static palavras + #33, #word33
    static palavras + #34, #word34
    static palavras + #35, #word35
    static palavras + #36, #word36
    static palavras + #37, #word37
    static palavras + #38, #word38
    static palavras + #39, #word39
    static palavras + #40, #word40
    static palavras + #41, #word41
    static palavras + #42, #word42
    static palavras + #43, #word43
    static palavras + #44, #word44
    static palavras + #45, #word45
    static palavras + #46, #word46
    static palavras + #47, #word47
    static palavras + #48, #word48
    static palavras + #49, #word49
    static palavras + #50, #word50
    static palavras + #51, #word51
    static palavras + #52, #word52
    static palavras + #53, #word53
    static palavras + #54, #word54
    static palavras + #55, #word55
    static palavras + #56, #word56
    static palavras + #57, #word57
    static palavras + #58, #word58
    static palavras + #59, #word59
    static palavras + #60, #word60
    static palavras + #61, #word61
    static palavras + #62, #word62
    static palavras + #63, #word63
    static palavras + #64, #word64
    static palavras + #65, #word65
    static palavras + #66, #word66
    static palavras + #67, #word67
    static palavras + #68, #word68
    static palavras + #69, #word69
    static palavras + #70, #word70
    static palavras + #71, #word71
    static palavras + #72, #word72
    static palavras + #73, #word73
    static palavras + #74, #word74
    static palavras + #75, #word75
    static palavras + #76, #word76
    static palavras + #77, #word77
    static palavras + #78, #word78
    static palavras + #79, #word79
    static palavras + #80, #word80
    static palavras + #81, #word81
    static palavras + #82, #word82
    static palavras + #83, #word83
    static palavras + #84, #word84
    static palavras + #85, #word85
    static palavras + #86, #word86
    static palavras + #87, #word87
    static palavras + #88, #word88
    static palavras + #89, #word89
    static palavras + #90, #word90
    static palavras + #91, #word91
    static palavras + #92, #word92
    static palavras + #93, #word93
    static palavras + #94, #word94
    static palavras + #95, #word95
    static palavras + #96, #word96
    static palavras + #97, #word97
    static palavras + #98, #word98
    static palavras + #99, #word99
    static palavras + #100, #word100
    static palavras + #101, #word101
    static palavras + #102, #word102
    static palavras + #103, #word103
    static palavras + #104, #word104
    static palavras + #105, #word105
    static palavras + #106, #word106
    static palavras + #107, #word107
    static palavras + #108, #word108
    static palavras + #109, #word109
    static palavras + #110, #word110
    static palavras + #111, #word111
    static palavras + #112, #word112
    static palavras + #113, #word113
    static palavras + #114, #word114
    static palavras + #115, #word115
    static palavras + #116, #word116
    static palavras + #117, #word117
    static palavras + #118, #word118
    static palavras + #119, #word119
    static palavras + #120, #word120
    static palavras + #121, #word121
    static palavras + #122, #word122
    static palavras + #123, #word123
    static palavras + #124, #word124
    static palavras + #125, #word125
    static palavras + #126, #word126
    static palavras + #127, #word127
    static palavras + #128, #word128
    static palavras + #129, #word129
    static palavras + #130, #word130
    static palavras + #131, #word131
    static palavras + #132, #word132
    static palavras + #133, #word133
    static palavras + #134, #word134
    static palavras + #135, #word135
    static palavras + #136, #word136
    static palavras + #137, #word137
    static palavras + #138, #word138
    static palavras + #139, #word139
    static palavras + #140, #word140
    static palavras + #141, #word141
    static palavras + #142, #word142
    static palavras + #143, #word143
    static palavras + #144, #word144
    static palavras + #145, #word145
    static palavras + #146, #word146
    static palavras + #147, #word147
    static palavras + #148, #word148
    static palavras + #149, #word149
    static palavras + #150, #word150
    static palavras + #151, #word151
    static palavras + #152, #word152
    static palavras + #153, #word153
    static palavras + #154, #word154
    static palavras + #155, #word155
    static palavras + #156, #word156
    static palavras + #157, #word157
    static palavras + #158, #word158
    static palavras + #159, #word159
    static palavras + #160, #word160
    static palavras + #161, #word161
    static palavras + #162, #word162
    static palavras + #163, #word163
    static palavras + #164, #word164
    static palavras + #165, #word165
    static palavras + #166, #word166
    static palavras + #167, #word167
    static palavras + #168, #word168
    static palavras + #169, #word169
    static palavras + #170, #word170
    static palavras + #171, #word171
    static palavras + #172, #word172
    static palavras + #173, #word173
    static palavras + #174, #word174
    static palavras + #175, #word175
    static palavras + #176, #word176
    static palavras + #177, #word177
    static palavras + #178, #word178
    static palavras + #179, #word179
    static palavras + #180, #word180
    static palavras + #181, #word181
    static palavras + #182, #word182
    static palavras + #183, #word183
    static palavras + #184, #word184
    static palavras + #185, #word185
    static palavras + #186, #word186
    static palavras + #187, #word187
    static palavras + #188, #word188
    static palavras + #189, #word189
    static palavras + #190, #word190
    static palavras + #191, #word191
    static palavras + #192, #word192
    static palavras + #193, #word193
    static palavras + #194, #word194
    static palavras + #195, #word195
    static palavras + #196, #word196
    static palavras + #197, #word197
    static palavras + #198, #word198
    static palavras + #199, #word199
    static palavras + #200, #word200
    static palavras + #201, #word201
    static palavras + #202, #word202
    static palavras + #203, #word203
    static palavras + #204, #word204
    static palavras + #205, #word205
    static palavras + #206, #word206
    static palavras + #207, #word207
    static palavras + #208, #word208
    static palavras + #209, #word209
    static palavras + #210, #word210
    static palavras + #211, #word211
    static palavras + #212, #word212
    static palavras + #213, #word213
    static palavras + #214, #word214
    static palavras + #215, #word215
    static palavras + #216, #word216
    static palavras + #217, #word217
    static palavras + #218, #word218
    static palavras + #219, #word219
    static palavras + #220, #word220
    static palavras + #221, #word221
    static palavras + #222, #word222
    static palavras + #223, #word223
    static palavras + #224, #word224
    static palavras + #225, #word225
    static palavras + #226, #word226
    static palavras + #227, #word227
    static palavras + #228, #word228
    static palavras + #229, #word229
    static palavras + #230, #word230
    static palavras + #231, #word231
    static palavras + #232, #word232
    static palavras + #233, #word233
    static palavras + #234, #word234
    static palavras + #235, #word235
    static palavras + #236, #word236
    static palavras + #237, #word237
    static palavras + #238, #word238
    static palavras + #239, #word239
    static palavras + #240, #word240
    static palavras + #241, #word241
    static palavras + #242, #word242
    static palavras + #243, #word243
    static palavras + #244, #word244
    static palavras + #245, #word245
    static palavras + #246, #word246
    static palavras + #247, #word247
    static palavras + #248, #word248
    static palavras + #249, #word249
    static palavras + #250, #word250
    static palavras + #251, #word251
    static palavras + #252, #word252
    static palavras + #253, #word253
    static palavras + #254, #word254
    static palavras + #255, #word255
    static palavras + #256, #word256
    static palavras + #257, #word257
    static palavras + #258, #word258
    static palavras + #259, #word259
    static palavras + #260, #word260
    static palavras + #261, #word261
    static palavras + #262, #word262
    static palavras + #263, #word263
    static palavras + #264, #word264
    static palavras + #265, #word265
    static palavras + #266, #word266
    static palavras + #267, #word267
    static palavras + #268, #word268
    static palavras + #269, #word269
    static palavras + #270, #word270
    static palavras + #271, #word271
    static palavras + #272, #word272
    static palavras + #273, #word273
    static palavras + #274, #word274
    static palavras + #275, #word275
    static palavras + #276, #word276
    static palavras + #277, #word277
    static palavras + #278, #word278
    static palavras + #279, #word279
    static palavras + #280, #word280
    static palavras + #281, #word281
    static palavras + #282, #word282
    static palavras + #283, #word283
    static palavras + #284, #word284
    static palavras + #285, #word285
    static palavras + #286, #word286
    static palavras + #287, #word287
    static palavras + #288, #word288
    static palavras + #289, #word289
    static palavras + #290, #word290
    static palavras + #291, #word291
    static palavras + #292, #word292
    static palavras + #293, #word293
    static palavras + #294, #word294
    static palavras + #295, #word295
    static palavras + #296, #word296
    static palavras + #297, #word297
    static palavras + #298, #word298
    static palavras + #299, #word299
    static palavras + #300, #word300
    static palavras + #301, #word301
    static palavras + #302, #word302
    static palavras + #303, #word303
    static palavras + #304, #word304
    static palavras + #305, #word305
    static palavras + #306, #word306
    static palavras + #307, #word307
    static palavras + #308, #word308
    static palavras + #309, #word309
    static palavras + #310, #word310
    static palavras + #311, #word311
    static palavras + #312, #word312
    static palavras + #313, #word313
    static palavras + #314, #word314
    static palavras + #315, #word315
    static palavras + #316, #word316
    static palavras + #317, #word317
    static palavras + #318, #word318
    static palavras + #319, #word319
    static palavras + #320, #word320
    static palavras + #321, #word321
    static palavras + #322, #word322
    static palavras + #323, #word323
    static palavras + #324, #word324
    static palavras + #325, #word325
    static palavras + #326, #word326
    static palavras + #327, #word327
    static palavras + #328, #word328
    static palavras + #329, #word329
    static palavras + #330, #word330
    static palavras + #331, #word331
    static palavras + #332, #word332
    static palavras + #333, #word333
    static palavras + #334, #word334
    static palavras + #335, #word335
    static palavras + #336, #word336
    static palavras + #337, #word337
    static palavras + #338, #word338
    static palavras + #339, #word339
    static palavras + #340, #word340
    static palavras + #341, #word341
    static palavras + #342, #word342
    static palavras + #343, #word343
    static palavras + #344, #word344
    static palavras + #345, #word345
    static palavras + #346, #word346
    static palavras + #347, #word347
    static palavras + #348, #word348
    static palavras + #349, #word349
    static palavras + #350, #word350
    static palavras + #351, #word351
    static palavras + #352, #word352
    static palavras + #353, #word353
    static palavras + #354, #word354
    static palavras + #355, #word355
    static palavras + #356, #word356
    static palavras + #357, #word357
    static palavras + #358, #word358
    static palavras + #359, #word359
    static palavras + #360, #word360
    static palavras + #361, #word361
    static palavras + #362, #word362
    static palavras + #363, #word363
    static palavras + #364, #word364
    static palavras + #365, #word365
    static palavras + #366, #word366
    static palavras + #367, #word367
    static palavras + #368, #word368
    static palavras + #369, #word369
    static palavras + #370, #word370
    static palavras + #371, #word371
    static palavras + #372, #word372
    static palavras + #373, #word373
    static palavras + #374, #word374
    static palavras + #375, #word375
    static palavras + #376, #word376
    static palavras + #377, #word377
    static palavras + #378, #word378
    static palavras + #379, #word379
    static palavras + #380, #word380
    static palavras + #381, #word381
    static palavras + #382, #word382
    static palavras + #383, #word383
    static palavras + #384, #word384
    static palavras + #385, #word385
    static palavras + #386, #word386
    static palavras + #387, #word387
    static palavras + #388, #word388
    static palavras + #389, #word389
    static palavras + #390, #word390
    static palavras + #391, #word391
    static palavras + #392, #word392
    static palavras + #393, #word393
    static palavras + #394, #word394
    static palavras + #395, #word395
    static palavras + #396, #word396
    static palavras + #397, #word397
    static palavras + #398, #word398
    static palavras + #399, #word399
    static palavras + #400, #word400
    static palavras + #401, #word401
    static palavras + #402, #word402
    static palavras + #403, #word403
    static palavras + #404, #word404
    static palavras + #405, #word405
    static palavras + #406, #word406
    static palavras + #407, #word407
    static palavras + #408, #word408
    static palavras + #409, #word409
    static palavras + #410, #word410
    static palavras + #411, #word411
    static palavras + #412, #word412
    static palavras + #413, #word413
    static palavras + #414, #word414
    static palavras + #415, #word415
    static palavras + #416, #word416
    static palavras + #417, #word417
    static palavras + #418, #word418
    static palavras + #419, #word419
    static palavras + #420, #word420
    static palavras + #421, #word421
    static palavras + #422, #word422
    static palavras + #423, #word423
    static palavras + #424, #word424
    static palavras + #425, #word425
    static palavras + #426, #word426
    static palavras + #427, #word427
    static palavras + #428, #word428
    static palavras + #429, #word429
    static palavras + #430, #word430
    static palavras + #431, #word431
    static palavras + #432, #word432
    static palavras + #433, #word433
    static palavras + #434, #word434
    static palavras + #435, #word435
    static palavras + #436, #word436
    static palavras + #437, #word437
    static palavras + #438, #word438
    static palavras + #439, #word439
    static palavras + #440, #word440
    static palavras + #441, #word441
    static palavras + #442, #word442
    static palavras + #443, #word443
    static palavras + #444, #word444
    static palavras + #445, #word445
    static palavras + #446, #word446
    static palavras + #447, #word447
    static palavras + #448, #word448
    static palavras + #449, #word449
    static palavras + #450, #word450
    static palavras + #451, #word451
    static palavras + #452, #word452
    static palavras + #453, #word453
    static palavras + #454, #word454
    static palavras + #455, #word455
    static palavras + #456, #word456
    static palavras + #457, #word457
    static palavras + #458, #word458
    static palavras + #459, #word459
    static palavras + #460, #word460
    static palavras + #461, #word461
    static palavras + #462, #word462
    static palavras + #463, #word463
    static palavras + #464, #word464
    static palavras + #465, #word465
    static palavras + #466, #word466
    static palavras + #467, #word467
    static palavras + #468, #word468
    static palavras + #469, #word469
    static palavras + #470, #word470
    static palavras + #471, #word471
    static palavras + #472, #word472
    static palavras + #473, #word473
    static palavras + #474, #word474
    static palavras + #475, #word475
    static palavras + #476, #word476
    static palavras + #477, #word477
    static palavras + #478, #word478
    static palavras + #479, #word479
    static palavras + #480, #word480
    static palavras + #481, #word481
    static palavras + #482, #word482
    static palavras + #483, #word483
    static palavras + #484, #word484
    static palavras + #485, #word485
    static palavras + #486, #word486
    static palavras + #487, #word487
    static palavras + #488, #word488
    static palavras + #489, #word489
    static palavras + #490, #word490
    static palavras + #491, #word491
    static palavras + #492, #word492
    static palavras + #493, #word493
    static palavras + #494, #word494
    static palavras + #495, #word495
    static palavras + #496, #word496
    static palavras + #497, #word497
    static palavras + #498, #word498
    static palavras + #499, #word499
    static palavras + #500, #word500
    static palavras + #501, #word501
    static palavras + #502, #word502
    static palavras + #503, #word503
    static palavras + #504, #word504
    static palavras + #505, #word505
    static palavras + #506, #word506
    static palavras + #507, #word507
    static palavras + #508, #word508
    static palavras + #509, #word509
    static palavras + #510, #word510
    static palavras + #511, #word511
    static palavras + #512, #word512
    static palavras + #513, #word513
    static palavras + #514, #word514
    static palavras + #515, #word515
    static palavras + #516, #word516
    static palavras + #517, #word517
    static palavras + #518, #word518
    static palavras + #519, #word519
    static palavras + #520, #word520
    static palavras + #521, #word521
    static palavras + #522, #word522
    static palavras + #523, #word523
    static palavras + #524, #word524
    static palavras + #525, #word525
    static palavras + #526, #word526
    static palavras + #527, #word527
    static palavras + #528, #word528
    static palavras + #529, #word529
    static palavras + #530, #word530
    static palavras + #531, #word531
    static palavras + #532, #word532
    static palavras + #533, #word533
    static palavras + #534, #word534
    static palavras + #535, #word535
    static palavras + #536, #word536
    static palavras + #537, #word537
    static palavras + #538, #word538
    static palavras + #539, #word539
    static palavras + #540, #word540
    static palavras + #541, #word541
    static palavras + #542, #word542
    static palavras + #543, #word543
    static palavras + #544, #word544
    static palavras + #545, #word545
    static palavras + #546, #word546
    static palavras + #547, #word547
    static palavras + #548, #word548
    static palavras + #549, #word549
    static palavras + #550, #word550
    static palavras + #551, #word551
    static palavras + #552, #word552
    static palavras + #553, #word553
    static palavras + #554, #word554
    static palavras + #555, #word555
    static palavras + #556, #word556
    static palavras + #557, #word557
    static palavras + #558, #word558
    static palavras + #559, #word559
    static palavras + #560, #word560
    static palavras + #561, #word561
    static palavras + #562, #word562
    static palavras + #563, #word563
    static palavras + #564, #word564
    static palavras + #565, #word565
    static palavras + #566, #word566
    static palavras + #567, #word567
    static palavras + #568, #word568
    static palavras + #569, #word569
    static palavras + #570, #word570
    static palavras + #571, #word571
    static palavras + #572, #word572
    static palavras + #573, #word573
    static palavras + #574, #word574
    static palavras + #575, #word575
    static palavras + #576, #word576
    static palavras + #577, #word577
    static palavras + #578, #word578
    static palavras + #579, #word579
    static palavras + #580, #word580
    static palavras + #581, #word581
    static palavras + #582, #word582
    static palavras + #583, #word583
    static palavras + #584, #word584
    static palavras + #585, #word585
    static palavras + #586, #word586
    static palavras + #587, #word587
    static palavras + #588, #word588
    static palavras + #589, #word589
    static palavras + #590, #word590
    static palavras + #591, #word591
    static palavras + #592, #word592
    static palavras + #593, #word593
    static palavras + #594, #word594
    static palavras + #595, #word595
    static palavras + #596, #word596
    static palavras + #597, #word597
    static palavras + #598, #word598
    static palavras + #599, #word599
    static palavras + #600, #word600
    static palavras + #601, #word601
    static palavras + #602, #word602
    static palavras + #603, #word603
    static palavras + #604, #word604
    static palavras + #605, #word605
    static palavras + #606, #word606
    static palavras + #607, #word607
    static palavras + #608, #word608
    static palavras + #609, #word609
    static palavras + #610, #word610
    static palavras + #611, #word611
    static palavras + #612, #word612
    static palavras + #613, #word613
    static palavras + #614, #word614
    static palavras + #615, #word615
    static palavras + #616, #word616
    static palavras + #617, #word617
    static palavras + #618, #word618
    static palavras + #619, #word619
    static palavras + #620, #word620
    static palavras + #621, #word621
    static palavras + #622, #word622
    static palavras + #623, #word623
    static palavras + #624, #word624
    static palavras + #625, #word625
    static palavras + #626, #word626
    static palavras + #627, #word627
    static palavras + #628, #word628
    static palavras + #629, #word629
    static palavras + #630, #word630
    static palavras + #631, #word631
    static palavras + #632, #word632
    static palavras + #633, #word633
    static palavras + #634, #word634
    static palavras + #635, #word635
    static palavras + #636, #word636
    static palavras + #637, #word637
    static palavras + #638, #word638
    static palavras + #639, #word639
    static palavras + #640, #word640
    static palavras + #641, #word641
    static palavras + #642, #word642
    static palavras + #643, #word643
    static palavras + #644, #word644
    static palavras + #645, #word645
    static palavras + #646, #word646
    static palavras + #647, #word647
    static palavras + #648, #word648
    static palavras + #649, #word649
    static palavras + #650, #word650
    static palavras + #651, #word651
    static palavras + #652, #word652
    static palavras + #653, #word653
    static palavras + #654, #word654
    static palavras + #655, #word655
    static palavras + #656, #word656
    static palavras + #657, #word657
    static palavras + #658, #word658
    static palavras + #659, #word659
    static palavras + #660, #word660
    static palavras + #661, #word661
    static palavras + #662, #word662
    static palavras + #663, #word663
    static palavras + #664, #word664
    static palavras + #665, #word665
    static palavras + #666, #word666
    static palavras + #667, #word667
    static palavras + #668, #word668
    static palavras + #669, #word669
    static palavras + #670, #word670
    static palavras + #671, #word671
    static palavras + #672, #word672
    static palavras + #673, #word673
    static palavras + #674, #word674
    static palavras + #675, #word675
    static palavras + #676, #word676
    static palavras + #677, #word677
    static palavras + #678, #word678
    static palavras + #679, #word679
    static palavras + #680, #word680
    static palavras + #681, #word681
    static palavras + #682, #word682
    static palavras + #683, #word683
    static palavras + #684, #word684
    static palavras + #685, #word685
    static palavras + #686, #word686
    static palavras + #687, #word687
    static palavras + #688, #word688
    static palavras + #689, #word689
    static palavras + #690, #word690
    static palavras + #691, #word691
    static palavras + #692, #word692
    static palavras + #693, #word693
    static palavras + #694, #word694
    static palavras + #695, #word695
    static palavras + #696, #word696
    static palavras + #697, #word697
    static palavras + #698, #word698
    static palavras + #699, #word699
    static palavras + #700, #word700
    static palavras + #701, #word701
    static palavras + #702, #word702
    static palavras + #703, #word703
    static palavras + #704, #word704
    static palavras + #705, #word705
    static palavras + #706, #word706
    static palavras + #707, #word707
    static palavras + #708, #word708
    static palavras + #709, #word709
    static palavras + #710, #word710
    static palavras + #711, #word711
    static palavras + #712, #word712
    static palavras + #713, #word713
    static palavras + #714, #word714
    static palavras + #715, #word715
    static palavras + #716, #word716
    static palavras + #717, #word717
    static palavras + #718, #word718
    static palavras + #719, #word719
    static palavras + #720, #word720
    static palavras + #721, #word721
    static palavras + #722, #word722
    static palavras + #723, #word723
    static palavras + #724, #word724
    static palavras + #725, #word725
    static palavras + #726, #word726
    static palavras + #727, #word727
    static palavras + #728, #word728
    static palavras + #729, #word729
    static palavras + #730, #word730
    static palavras + #731, #word731
    static palavras + #732, #word732
    static palavras + #733, #word733
    static palavras + #734, #word734
    static palavras + #735, #word735
    static palavras + #736, #word736
    static palavras + #737, #word737
    static palavras + #738, #word738
    static palavras + #739, #word739
    static palavras + #740, #word740
    static palavras + #741, #word741
    static palavras + #742, #word742
    static palavras + #743, #word743
    static palavras + #744, #word744
    static palavras + #745, #word745
    static palavras + #746, #word746
    static palavras + #747, #word747
    static palavras + #748, #word748
    static palavras + #749, #word749
    static palavras + #750, #word750
    static palavras + #751, #word751
    static palavras + #752, #word752
    static palavras + #753, #word753
    static palavras + #754, #word754
    static palavras + #755, #word755
    static palavras + #756, #word756
    static palavras + #757, #word757
    static palavras + #758, #word758
    static palavras + #759, #word759
    static palavras + #760, #word760
    static palavras + #761, #word761
    static palavras + #762, #word762
    static palavras + #763, #word763
    static palavras + #764, #word764
    static palavras + #765, #word765
    static palavras + #766, #word766
    static palavras + #767, #word767
    static palavras + #768, #word768
    static palavras + #769, #word769
    static palavras + #770, #word770
    static palavras + #771, #word771
    static palavras + #772, #word772
    static palavras + #773, #word773
    static palavras + #774, #word774
    static palavras + #775, #word775
    static palavras + #776, #word776
    static palavras + #777, #word777
    static palavras + #778, #word778
    static palavras + #779, #word779
    static palavras + #780, #word780
    static palavras + #781, #word781
    static palavras + #782, #word782
    static palavras + #783, #word783
    static palavras + #784, #word784
    static palavras + #785, #word785
    static palavras + #786, #word786
    static palavras + #787, #word787
    static palavras + #788, #word788
    static palavras + #789, #word789
    static palavras + #790, #word790
    static palavras + #791, #word791
    static palavras + #792, #word792
    static palavras + #793, #word793
    static palavras + #794, #word794
    static palavras + #795, #word795
    static palavras + #796, #word796
    static palavras + #797, #word797
    static palavras + #798, #word798
    static palavras + #799, #word799
    static palavras + #800, #word800
    static palavras + #801, #word801
    static palavras + #802, #word802
    static palavras + #803, #word803
    static palavras + #804, #word804
    static palavras + #805, #word805
    static palavras + #806, #word806
    static palavras + #807, #word807
    static palavras + #808, #word808
    static palavras + #809, #word809
    static palavras + #810, #word810
    static palavras + #811, #word811
    static palavras + #812, #word812
    static palavras + #813, #word813
    static palavras + #814, #word814
    static palavras + #815, #word815
    static palavras + #816, #word816
    static palavras + #817, #word817
    static palavras + #818, #word818
    static palavras + #819, #word819
    static palavras + #820, #word820
    static palavras + #821, #word821
    static palavras + #822, #word822
    static palavras + #823, #word823
    static palavras + #824, #word824
    static palavras + #825, #word825
    static palavras + #826, #word826
    static palavras + #827, #word827
    static palavras + #828, #word828
    static palavras + #829, #word829
    static palavras + #830, #word830
    static palavras + #831, #word831
    static palavras + #832, #word832
    static palavras + #833, #word833
    static palavras + #834, #word834
    static palavras + #835, #word835
    static palavras + #836, #word836
    static palavras + #837, #word837
    static palavras + #838, #word838
    static palavras + #839, #word839
    static palavras + #840, #word840
    static palavras + #841, #word841
    static palavras + #842, #word842
    static palavras + #843, #word843
    static palavras + #844, #word844
    static palavras + #845, #word845
    static palavras + #846, #word846
    static palavras + #847, #word847
    static palavras + #848, #word848
    static palavras + #849, #word849
    static palavras + #850, #word850
    static palavras + #851, #word851
    static palavras + #852, #word852
    static palavras + #853, #word853
    static palavras + #854, #word854
    static palavras + #855, #word855
    static palavras + #856, #word856
    static palavras + #857, #word857
    static palavras + #858, #word858
    static palavras + #859, #word859
    static palavras + #860, #word860
    static palavras + #861, #word861
    static palavras + #862, #word862
    static palavras + #863, #word863
    static palavras + #864, #word864
    static palavras + #865, #word865
    static palavras + #866, #word866
    static palavras + #867, #word867
    static palavras + #868, #word868
    static palavras + #869, #word869
    static palavras + #870, #word870
    static palavras + #871, #word871
    static palavras + #872, #word872
    static palavras + #873, #word873
    static palavras + #874, #word874
    static palavras + #875, #word875
    static palavras + #876, #word876
    static palavras + #877, #word877
    static palavras + #878, #word878
    static palavras + #879, #word879
    static palavras + #880, #word880
    static palavras + #881, #word881
    static palavras + #882, #word882
    static palavras + #883, #word883
    static palavras + #884, #word884
    static palavras + #885, #word885
    static palavras + #886, #word886
    static palavras + #887, #word887
    static palavras + #888, #word888
    static palavras + #889, #word889
    static palavras + #890, #word890
    static palavras + #891, #word891
    static palavras + #892, #word892
    static palavras + #893, #word893
    static palavras + #894, #word894
    static palavras + #895, #word895
    static palavras + #896, #word896
    static palavras + #897, #word897
    static palavras + #898, #word898
    static palavras + #899, #word899
    static palavras + #900, #word900
    static palavras + #901, #word901
    static palavras + #902, #word902
    static palavras + #903, #word903
    static palavras + #904, #word904
    static palavras + #905, #word905
    static palavras + #906, #word906
    static palavras + #907, #word907
    static palavras + #908, #word908
    static palavras + #909, #word909
    static palavras + #910, #word910
    static palavras + #911, #word911
    static palavras + #912, #word912
    static palavras + #913, #word913
    static palavras + #914, #word914
    static palavras + #915, #word915
    static palavras + #916, #word916
    static palavras + #917, #word917
    static palavras + #918, #word918
    static palavras + #919, #word919
    static palavras + #920, #word920
    static palavras + #921, #word921
    static palavras + #922, #word922
    static palavras + #923, #word923
    static palavras + #924, #word924
    static palavras + #925, #word925
    static palavras + #926, #word926
    static palavras + #927, #word927
    static palavras + #928, #word928
    static palavras + #929, #word929
    static palavras + #930, #word930
    static palavras + #931, #word931
    static palavras + #932, #word932
    static palavras + #933, #word933
    static palavras + #934, #word934
    static palavras + #935, #word935
    static palavras + #936, #word936
    static palavras + #937, #word937
    static palavras + #938, #word938
    static palavras + #939, #word939
    static palavras + #940, #word940
    static palavras + #941, #word941
    static palavras + #942, #word942
    static palavras + #943, #word943
    static palavras + #944, #word944
    static palavras + #945, #word945
    static palavras + #946, #word946
    static palavras + #947, #word947
    static palavras + #948, #word948
    static palavras + #949, #word949
    static palavras + #950, #word950
    static palavras + #951, #word951
    static palavras + #952, #word952
    static palavras + #953, #word953
    static palavras + #954, #word954
    static palavras + #955, #word955
    static palavras + #956, #word956
    static palavras + #957, #word957
    static palavras + #958, #word958
    static palavras + #959, #word959
    static palavras + #960, #word960
    static palavras + #961, #word961
    static palavras + #962, #word962
    static palavras + #963, #word963
    static palavras + #964, #word964
    static palavras + #965, #word965
    static palavras + #966, #word966
    static palavras + #967, #word967
    static palavras + #968, #word968
    static palavras + #969, #word969
    static palavras + #970, #word970
    static palavras + #971, #word971
    static palavras + #972, #word972
    static palavras + #973, #word973
    static palavras + #974, #word974
    static palavras + #975, #word975
    static palavras + #976, #word976
    static palavras + #977, #word977
    static palavras + #978, #word978
    static palavras + #979, #word979
    static palavras + #980, #word980
    static palavras + #981, #word981
    static palavras + #982, #word982
    static palavras + #983, #word983
    static palavras + #984, #word984
    static palavras + #985, #word985
    static palavras + #986, #word986
    static palavras + #987, #word987
    static palavras + #988, #word988
    static palavras + #989, #word989
    static palavras + #990, #word990
    static palavras + #991, #word991
    static palavras + #992, #word992
    static palavras + #993, #word993
    static palavras + #994, #word994
    static palavras + #995, #word995
    static palavras + #996, #word996
    static palavras + #997, #word997
    static palavras + #998, #word998
    static palavras + #999, #word999
    static palavras + #1000, #word1000
    static palavras + #1001, #word1001
    static palavras + #1002, #word1002
    static palavras + #1003, #word1003
    static palavras + #1004, #word1004
    static palavras + #1005, #word1005
    static palavras + #1006, #word1006
    static palavras + #1007, #word1007
    static palavras + #1008, #word1008
    static palavras + #1009, #word1009
    static palavras + #1010, #word1010
    static palavras + #1011, #word1011
    static palavras + #1012, #word1012
    static palavras + #1013, #word1013
    static palavras + #1014, #word1014
    static palavras + #1015, #word1015
    static palavras + #1016, #word1016
    static palavras + #1017, #word1017
    static palavras + #1018, #word1018
    static palavras + #1019, #word1019
    static palavras + #1020, #word1020
    static palavras + #1021, #word1021
    static palavras + #1022, #word1022
    static palavras + #1023, #word1023
    static palavras + #1024, #word1024
    static palavras + #1025, #word1025
    static palavras + #1026, #word1026
    static palavras + #1027, #word1027
    static palavras + #1028, #word1028
    static palavras + #1029, #word1029
    static palavras + #1030, #word1030
    static palavras + #1031, #word1031
    static palavras + #1032, #word1032
    static palavras + #1033, #word1033
    static palavras + #1034, #word1034
    static palavras + #1035, #word1035
    static palavras + #1036, #word1036
    static palavras + #1037, #word1037
    static palavras + #1038, #word1038
    static palavras + #1039, #word1039
    static palavras + #1040, #word1040
    static palavras + #1041, #word1041
    static palavras + #1042, #word1042
    static palavras + #1043, #word1043
    static palavras + #1044, #word1044
    static palavras + #1045, #word1045
    static palavras + #1046, #word1046
    static palavras + #1047, #word1047
    static palavras + #1048, #word1048
    static palavras + #1049, #word1049
    static palavras + #1050, #word1050
    static palavras + #1051, #word1051
    static palavras + #1052, #word1052
    static palavras + #1053, #word1053
    static palavras + #1054, #word1054
    static palavras + #1055, #word1055
    static palavras + #1056, #word1056
    static palavras + #1057, #word1057
    static palavras + #1058, #word1058
    static palavras + #1059, #word1059
    static palavras + #1060, #word1060
    static palavras + #1061, #word1061
    static palavras + #1062, #word1062
    static palavras + #1063, #word1063
    static palavras + #1064, #word1064
    static palavras + #1065, #word1065
    static palavras + #1066, #word1066
    static palavras + #1067, #word1067
    static palavras + #1068, #word1068
    static palavras + #1069, #word1069
    static palavras + #1070, #word1070
    static palavras + #1071, #word1071
    static palavras + #1072, #word1072
    static palavras + #1073, #word1073
    static palavras + #1074, #word1074
    static palavras + #1075, #word1075
    static palavras + #1076, #word1076
    static palavras + #1077, #word1077
    static palavras + #1078, #word1078
    static palavras + #1079, #word1079
    static palavras + #1080, #word1080
    static palavras + #1081, #word1081
    static palavras + #1082, #word1082
    static palavras + #1083, #word1083
    static palavras + #1084, #word1084
    static palavras + #1085, #word1085
    static palavras + #1086, #word1086
    static palavras + #1087, #word1087
    static palavras + #1088, #word1088
    static palavras + #1089, #word1089
    static palavras + #1090, #word1090
    static palavras + #1091, #word1091
    static palavras + #1092, #word1092
    static palavras + #1093, #word1093
    static palavras + #1094, #word1094
    static palavras + #1095, #word1095
    static palavras + #1096, #word1096
    static palavras + #1097, #word1097
    static palavras + #1098, #word1098
    static palavras + #1099, #word1099
    static palavras + #1100, #word1100
    static palavras + #1101, #word1101
    static palavras + #1102, #word1102
    static palavras + #1103, #word1103
    static palavras + #1104, #word1104
    static palavras + #1105, #word1105
    static palavras + #1106, #word1106
    static palavras + #1107, #word1107
    static palavras + #1108, #word1108
    static palavras + #1109, #word1109
    static palavras + #1110, #word1110
    static palavras + #1111, #word1111
    static palavras + #1112, #word1112
    static palavras + #1113, #word1113
    static palavras + #1114, #word1114
    static palavras + #1115, #word1115
    static palavras + #1116, #word1116
    static palavras + #1117, #word1117
    static palavras + #1118, #word1118
    static palavras + #1119, #word1119
    static palavras + #1120, #word1120
    static palavras + #1121, #word1121
    static palavras + #1122, #word1122
    static palavras + #1123, #word1123
    static palavras + #1124, #word1124
    static palavras + #1125, #word1125
    static palavras + #1126, #word1126
    static palavras + #1127, #word1127
    static palavras + #1128, #word1128
    static palavras + #1129, #word1129
    static palavras + #1130, #word1130
    static palavras + #1131, #word1131
    static palavras + #1132, #word1132
    static palavras + #1133, #word1133
    static palavras + #1134, #word1134
    static palavras + #1135, #word1135
    static palavras + #1136, #word1136
    static palavras + #1137, #word1137
    static palavras + #1138, #word1138
    static palavras + #1139, #word1139
    static palavras + #1140, #word1140
    static palavras + #1141, #word1141
    static palavras + #1142, #word1142
    static palavras + #1143, #word1143
    static palavras + #1144, #word1144
    static palavras + #1145, #word1145
    static palavras + #1146, #word1146
    static palavras + #1147, #word1147
    static palavras + #1148, #word1148
    static palavras + #1149, #word1149
    static palavras + #1150, #word1150
    static palavras + #1151, #word1151
    static palavras + #1152, #word1152
    static palavras + #1153, #word1153
    static palavras + #1154, #word1154
    static palavras + #1155, #word1155
    static palavras + #1156, #word1156
    static palavras + #1157, #word1157
    static palavras + #1158, #word1158
    static palavras + #1159, #word1159
    static palavras + #1160, #word1160
    static palavras + #1161, #word1161
    static palavras + #1162, #word1162
    static palavras + #1163, #word1163
    static palavras + #1164, #word1164
    static palavras + #1165, #word1165
    static palavras + #1166, #word1166
    static palavras + #1167, #word1167
    static palavras + #1168, #word1168
    static palavras + #1169, #word1169
    static palavras + #1170, #word1170
    static palavras + #1171, #word1171
    static palavras + #1172, #word1172
    static palavras + #1173, #word1173
    static palavras + #1174, #word1174
    static palavras + #1175, #word1175
    static palavras + #1176, #word1176
    static palavras + #1177, #word1177
    static palavras + #1178, #word1178
    static palavras + #1179, #word1179
    static palavras + #1180, #word1180
    static palavras + #1181, #word1181
    static palavras + #1182, #word1182
    static palavras + #1183, #word1183
    static palavras + #1184, #word1184
    static palavras + #1185, #word1185
    static palavras + #1186, #word1186
    static palavras + #1187, #word1187
    static palavras + #1188, #word1188
    static palavras + #1189, #word1189
    static palavras + #1190, #word1190
    static palavras + #1191, #word1191
    static palavras + #1192, #word1192
    static palavras + #1193, #word1193
    static palavras + #1194, #word1194
    static palavras + #1195, #word1195
    static palavras + #1196, #word1196
    static palavras + #1197, #word1197
    static palavras + #1198, #word1198
    static palavras + #1199, #word1199
    static palavras + #1200, #word1200
    static palavras + #1201, #word1201
    static palavras + #1202, #word1202
    static palavras + #1203, #word1203
    static palavras + #1204, #word1204
    static palavras + #1205, #word1205
    static palavras + #1206, #word1206
    static palavras + #1207, #word1207
    static palavras + #1208, #word1208
    static palavras + #1209, #word1209
    static palavras + #1210, #word1210
    static palavras + #1211, #word1211
    static palavras + #1212, #word1212
    static palavras + #1213, #word1213
    static palavras + #1214, #word1214
    static palavras + #1215, #word1215
    static palavras + #1216, #word1216
    static palavras + #1217, #word1217
    static palavras + #1218, #word1218
    static palavras + #1219, #word1219
    static palavras + #1220, #word1220
    static palavras + #1221, #word1221
    static palavras + #1222, #word1222
    static palavras + #1223, #word1223
    static palavras + #1224, #word1224
    static palavras + #1225, #word1225
    static palavras + #1226, #word1226
    static palavras + #1227, #word1227
    static palavras + #1228, #word1228
    static palavras + #1229, #word1229
    static palavras + #1230, #word1230
    static palavras + #1231, #word1231
    static palavras + #1232, #word1232
    static palavras + #1233, #word1233
    static palavras + #1234, #word1234
    static palavras + #1235, #word1235
    static palavras + #1236, #word1236
    static palavras + #1237, #word1237
    static palavras + #1238, #word1238
    static palavras + #1239, #word1239
    static palavras + #1240, #word1240
    static palavras + #1241, #word1241
    static palavras + #1242, #word1242
    static palavras + #1243, #word1243
    static palavras + #1244, #word1244
    static palavras + #1245, #word1245
    static palavras + #1246, #word1246
    static palavras + #1247, #word1247
    static palavras + #1248, #word1248
    static palavras + #1249, #word1249
    static palavras + #1250, #word1250
    static palavras + #1251, #word1251
    static palavras + #1252, #word1252
    static palavras + #1253, #word1253
    static palavras + #1254, #word1254
    static palavras + #1255, #word1255
    static palavras + #1256, #word1256
    static palavras + #1257, #word1257
    static palavras + #1258, #word1258
    static palavras + #1259, #word1259
    static palavras + #1260, #word1260
    static palavras + #1261, #word1261
    static palavras + #1262, #word1262
    static palavras + #1263, #word1263
    static palavras + #1264, #word1264
    static palavras + #1265, #word1265
    static palavras + #1266, #word1266
    static palavras + #1267, #word1267
    static palavras + #1268, #word1268
    static palavras + #1269, #word1269
    static palavras + #1270, #word1270
    static palavras + #1271, #word1271
    static palavras + #1272, #word1272
    static palavras + #1273, #word1273
    static palavras + #1274, #word1274
    static palavras + #1275, #word1275
    static palavras + #1276, #word1276
    static palavras + #1277, #word1277
    static palavras + #1278, #word1278
    static palavras + #1279, #word1279
    static palavras + #1280, #word1280
    static palavras + #1281, #word1281
    static palavras + #1282, #word1282
    static palavras + #1283, #word1283
    static palavras + #1284, #word1284
    static palavras + #1285, #word1285
    static palavras + #1286, #word1286
    static palavras + #1287, #word1287
    static palavras + #1288, #word1288
    static palavras + #1289, #word1289
    static palavras + #1290, #word1290
    static palavras + #1291, #word1291
    static palavras + #1292, #word1292
    static palavras + #1293, #word1293
    static palavras + #1294, #word1294
    static palavras + #1295, #word1295
    static palavras + #1296, #word1296
    static palavras + #1297, #word1297
    static palavras + #1298, #word1298
    static palavras + #1299, #word1299
    static palavras + #1300, #word1300
    static palavras + #1301, #word1301
    static palavras + #1302, #word1302
    static palavras + #1303, #word1303
    static palavras + #1304, #word1304
    static palavras + #1305, #word1305
    static palavras + #1306, #word1306
    static palavras + #1307, #word1307
    static palavras + #1308, #word1308
    static palavras + #1309, #word1309
    static palavras + #1310, #word1310
    static palavras + #1311, #word1311
    static palavras + #1312, #word1312
    static palavras + #1313, #word1313
    static palavras + #1314, #word1314
    static palavras + #1315, #word1315
    static palavras + #1316, #word1316
    static palavras + #1317, #word1317
    static palavras + #1318, #word1318
    static palavras + #1319, #word1319
    static palavras + #1320, #word1320
    static palavras + #1321, #word1321
    static palavras + #1322, #word1322
    static palavras + #1323, #word1323
    static palavras + #1324, #word1324
    static palavras + #1325, #word1325
    static palavras + #1326, #word1326
    static palavras + #1327, #word1327
    static palavras + #1328, #word1328
    static palavras + #1329, #word1329
    static palavras + #1330, #word1330
    static palavras + #1331, #word1331
    static palavras + #1332, #word1332
    static palavras + #1333, #word1333
    static palavras + #1334, #word1334
    static palavras + #1335, #word1335
    static palavras + #1336, #word1336
    static palavras + #1337, #word1337
    static palavras + #1338, #word1338
    static palavras + #1339, #word1339
    static palavras + #1340, #word1340
    static palavras + #1341, #word1341
    static palavras + #1342, #word1342
    static palavras + #1343, #word1343
    static palavras + #1344, #word1344
    static palavras + #1345, #word1345
    static palavras + #1346, #word1346
    static palavras + #1347, #word1347
    static palavras + #1348, #word1348
    static palavras + #1349, #word1349
    static palavras + #1350, #word1350
    static palavras + #1351, #word1351
    static palavras + #1352, #word1352
    static palavras + #1353, #word1353
    static palavras + #1354, #word1354
    static palavras + #1355, #word1355
    static palavras + #1356, #word1356
    static palavras + #1357, #word1357
    static palavras + #1358, #word1358
    static palavras + #1359, #word1359
    static palavras + #1360, #word1360
    static palavras + #1361, #word1361
    static palavras + #1362, #word1362
    static palavras + #1363, #word1363
    static palavras + #1364, #word1364
    static palavras + #1365, #word1365
    static palavras + #1366, #word1366
    static palavras + #1367, #word1367
    static palavras + #1368, #word1368
    static palavras + #1369, #word1369
    static palavras + #1370, #word1370
    static palavras + #1371, #word1371
    static palavras + #1372, #word1372
    static palavras + #1373, #word1373
    static palavras + #1374, #word1374
    static palavras + #1375, #word1375
    static palavras + #1376, #word1376
    static palavras + #1377, #word1377
    static palavras + #1378, #word1378
    static palavras + #1379, #word1379
    static palavras + #1380, #word1380
    static palavras + #1381, #word1381
    static palavras + #1382, #word1382
    static palavras + #1383, #word1383
    static palavras + #1384, #word1384
    static palavras + #1385, #word1385
    static palavras + #1386, #word1386
    static palavras + #1387, #word1387
    static palavras + #1388, #word1388
    static palavras + #1389, #word1389
    static palavras + #1390, #word1390
    static palavras + #1391, #word1391
    static palavras + #1392, #word1392
    static palavras + #1393, #word1393
    static palavras + #1394, #word1394
    static palavras + #1395, #word1395
    static palavras + #1396, #word1396
    static palavras + #1397, #word1397
    static palavras + #1398, #word1398
    static palavras + #1399, #word1399
    static palavras + #1400, #word1400
    static palavras + #1401, #word1401
    static palavras + #1402, #word1402
    static palavras + #1403, #word1403
    static palavras + #1404, #word1404
    static palavras + #1405, #word1405
    static palavras + #1406, #word1406
    static palavras + #1407, #word1407
    static palavras + #1408, #word1408
    static palavras + #1409, #word1409
    static palavras + #1410, #word1410
    static palavras + #1411, #word1411
    static palavras + #1412, #word1412
    static palavras + #1413, #word1413
    static palavras + #1414, #word1414
    static palavras + #1415, #word1415
    static palavras + #1416, #word1416
    static palavras + #1417, #word1417
    static palavras + #1418, #word1418
    static palavras + #1419, #word1419
    static palavras + #1420, #word1420
    static palavras + #1421, #word1421
    static palavras + #1422, #word1422
    static palavras + #1423, #word1423
    static palavras + #1424, #word1424
    static palavras + #1425, #word1425
    static palavras + #1426, #word1426
    static palavras + #1427, #word1427
    static palavras + #1428, #word1428
    static palavras + #1429, #word1429
    static palavras + #1430, #word1430
    static palavras + #1431, #word1431
    static palavras + #1432, #word1432
    static palavras + #1433, #word1433
    static palavras + #1434, #word1434
    static palavras + #1435, #word1435
    static palavras + #1436, #word1436
    static palavras + #1437, #word1437
    static palavras + #1438, #word1438
    static palavras + #1439, #word1439
    static palavras + #1440, #word1440
    static palavras + #1441, #word1441
    static palavras + #1442, #word1442
    static palavras + #1443, #word1443
    static palavras + #1444, #word1444
    static palavras + #1445, #word1445
    static palavras + #1446, #word1446
    static palavras + #1447, #word1447
    static palavras + #1448, #word1448
    static palavras + #1449, #word1449
    static palavras + #1450, #word1450
    static palavras + #1451, #word1451
    static palavras + #1452, #word1452
    static palavras + #1453, #word1453
    static palavras + #1454, #word1454
    static palavras + #1455, #word1455
    static palavras + #1456, #word1456
    static palavras + #1457, #word1457
    static palavras + #1458, #word1458
    static palavras + #1459, #word1459
    static palavras + #1460, #word1460
    static palavras + #1461, #word1461
    static palavras + #1462, #word1462
    static palavras + #1463, #word1463
    static palavras + #1464, #word1464
    static palavras + #1465, #word1465
    static palavras + #1466, #word1466
    static palavras + #1467, #word1467
    static palavras + #1468, #word1468
    static palavras + #1469, #word1469
    static palavras + #1470, #word1470
    static palavras + #1471, #word1471
    static palavras + #1472, #word1472
    static palavras + #1473, #word1473
    static palavras + #1474, #word1474
    static palavras + #1475, #word1475
    static palavras + #1476, #word1476
    static palavras + #1477, #word1477
    static palavras + #1478, #word1478
    static palavras + #1479, #word1479
    static palavras + #1480, #word1480
    static palavras + #1481, #word1481
    static palavras + #1482, #word1482
    static palavras + #1483, #word1483
    static palavras + #1484, #word1484
    static palavras + #1485, #word1485
    static palavras + #1486, #word1486
    static palavras + #1487, #word1487
    static palavras + #1488, #word1488
    static palavras + #1489, #word1489
    static palavras + #1490, #word1490
    static palavras + #1491, #word1491
    static palavras + #1492, #word1492
    static palavras + #1493, #word1493
    static palavras + #1494, #word1494
    static palavras + #1495, #word1495
    static palavras + #1496, #word1496
    static palavras + #1497, #word1497
    static palavras + #1498, #word1498
    static palavras + #1499, #word1499
    static palavras + #1500, #word1500
    static palavras + #1501, #word1501
    static palavras + #1502, #word1502
    static palavras + #1503, #word1503
    static palavras + #1504, #word1504
    static palavras + #1505, #word1505
    static palavras + #1506, #word1506
    static palavras + #1507, #word1507
    static palavras + #1508, #word1508
    static palavras + #1509, #word1509
    static palavras + #1510, #word1510
    static palavras + #1511, #word1511
    static palavras + #1512, #word1512
    static palavras + #1513, #word1513
    static palavras + #1514, #word1514
    static palavras + #1515, #word1515
    static palavras + #1516, #word1516
    static palavras + #1517, #word1517
    static palavras + #1518, #word1518
    static palavras + #1519, #word1519
    static palavras + #1520, #word1520
    static palavras + #1521, #word1521
    static palavras + #1522, #word1522
    static palavras + #1523, #word1523
    static palavras + #1524, #word1524
    static palavras + #1525, #word1525
    static palavras + #1526, #word1526
    static palavras + #1527, #word1527
    static palavras + #1528, #word1528
    static palavras + #1529, #word1529
    static palavras + #1530, #word1530
    static palavras + #1531, #word1531
    static palavras + #1532, #word1532
    static palavras + #1533, #word1533
    static palavras + #1534, #word1534
    static palavras + #1535, #word1535
    static palavras + #1536, #word1536
    static palavras + #1537, #word1537
    static palavras + #1538, #word1538
    static palavras + #1539, #word1539
    static palavras + #1540, #word1540
    static palavras + #1541, #word1541
    static palavras + #1542, #word1542
    static palavras + #1543, #word1543
    static palavras + #1544, #word1544
    static palavras + #1545, #word1545
    static palavras + #1546, #word1546
    static palavras + #1547, #word1547
    static palavras + #1548, #word1548
    static palavras + #1549, #word1549
    static palavras + #1550, #word1550
    static palavras + #1551, #word1551
    static palavras + #1552, #word1552
    static palavras + #1553, #word1553
    static palavras + #1554, #word1554
    static palavras + #1555, #word1555
    static palavras + #1556, #word1556
    static palavras + #1557, #word1557
    static palavras + #1558, #word1558
    static palavras + #1559, #word1559
    static palavras + #1560, #word1560
    static palavras + #1561, #word1561
    static palavras + #1562, #word1562
    static palavras + #1563, #word1563
    static palavras + #1564, #word1564
    static palavras + #1565, #word1565
    static palavras + #1566, #word1566
    static palavras + #1567, #word1567
    static palavras + #1568, #word1568
    static palavras + #1569, #word1569
    static palavras + #1570, #word1570
    static palavras + #1571, #word1571
    static palavras + #1572, #word1572
    static palavras + #1573, #word1573
    static palavras + #1574, #word1574
    static palavras + #1575, #word1575
    static palavras + #1576, #word1576
    static palavras + #1577, #word1577
    static palavras + #1578, #word1578

;-------------------------------------------------------------------------------------------------
fim_do_codigo: