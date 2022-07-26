# Item 1 - Assembleco
Inspirados no famoso jogo Wordle, especialmente em sua versão chamada ["Letreco" (desenvolvida por Gabriel Toschi)](https://github.com/gabtoschi/letreco), decidimos criar uma versão em Assembly para o Processador do ICMC. O jogo consiste na advinhação de uma palavra de 5 letras dentre 6 tentativas. Para auxiliar, são dadas dicas sobre a existência e posição das letras em cada tentativa. Para tanto, elas são coloridas com:
* Vermelho: indicando que a letra não está presente na palavra-resposta
* Amarelo: indicando que a letra está presente na palavra-resposta, mas em outra posição
* Verde: inicando que a letra está presente na palavra-resposta na mesma posição

Obs.: mesmo em caso de repetição de letras, cada uma delas conta apenas uma vez. Ou seja, se a palavra-reposta for "forma" e a tentativa for "bolos", a primeira letra 'o' de "bolos" ficará verde, mas a segunda ficará vermelha.

![Tela Inicial do Jogo](images/tela_inicial.png#center)

O programa começa com uma tela inicial e aguarda o usuário digitar alguma tecla. Este tempo de aguardo é utilizado para gerar um número pseudoaleatório que irá selecionar a palavra-resposta da primeira partida.

# Item 2 - Construir o Hardware do Processador em VHDL na FPGA

# Item 3 - Implementar Nova Instrução na Arquitetura do Processador

# 3.1. Modificar o projeto na FPGA
# 3.2. Modificar o Montador para que reconheça a nova Instrução
# 3.3. Modificar o Manual do Processador, descrevendo sua nova Instrução (e alteraçao na Arquitetura)
