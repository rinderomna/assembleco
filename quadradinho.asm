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
