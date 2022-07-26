    denovoPosition : var #1

    denovo : var #20
    static denovo + #0, #68 ;    D
    static denovo + #1, #101 ;    e
    ;2  espacos para o proximo caractere
    static denovo + #2, #110 ;    n
    static denovo + #3, #111 ;    o
    static denovo + #4, #118 ;    v
    static denovo + #5, #111 ;    o
    static denovo + #6, #63 ;    ?
    ;2  espacos para o proximo caractere
    static denovo + #7, #40 ;    (
    static denovo + #8, #115 ;    s
    static denovo + #9, #47 ;    /
    static denovo + #10, #42 ;    *
    static denovo + #11, #41 ;    )
    ;32  espacos para o proximo caractere
    static denovo + #12, #2 ;    se
    static denovo + #13, #1 ;    horizontal
    static denovo + #14, #3 ;    sd
    ;38  espacos para o proximo caractere
    static denovo + #15, #0 ;    vertical
    ;2  espacos para o proximo caractere
    static denovo + #16, #0 ;    vertical
    ;38  espacos para o proximo caractere
    static denovo + #17, #4 ;    ie
    static denovo + #18, #1 ;    horizontal
    static denovo + #19, #5 ;    id

    denovoGaps : var #20
    static denovoGaps + #0, #0
    static denovoGaps + #1, #0
    static denovoGaps + #2, #1
    static denovoGaps + #3, #0
    static denovoGaps + #4, #0
    static denovoGaps + #5, #0
    static denovoGaps + #6, #0
    static denovoGaps + #7, #1
    static denovoGaps + #8, #0
    static denovoGaps + #9, #0
    static denovoGaps + #10, #0
    static denovoGaps + #11, #0
    static denovoGaps + #12, #31
    static denovoGaps + #13, #0
    static denovoGaps + #14, #0
    static denovoGaps + #15, #37
    static denovoGaps + #16, #1
    static denovoGaps + #17, #37
    static denovoGaps + #18, #0
    static denovoGaps + #19, #0

printdenovo:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5
  push R6

  loadn R0, #denovo
  loadn R1, #denovoGaps
  load R2, denovoPosition
  loadn R3, #20 ;tamanho denovo
  loadn R4, #0 ;incremetador

  printdenovoLoop:
    add R5,R0,R4
    loadi R5, R5

    add R6,R1,R4
    loadi R6, R6

    add R2, R2, R6

    outchar R5, R2

    inc R2
     inc R4
     cmp R3, R4
    jne printdenovoLoop

  pop R6
  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts

apagardenovo:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5

  loadn R0, #3967
  loadn R1, #denovoGaps
  load R2, denovoPosition
  loadn R3, #20 ;tamanho denovo
  loadn R4, #0 ;incremetador

  apagardenovoLoop:
    add R5,R1,R4
    loadi R5, R5

    add R2,R2,R5
    outchar R0, R2

    inc R2
     inc R4
     cmp R3, R4
    jne apagardenovoLoop

  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts
