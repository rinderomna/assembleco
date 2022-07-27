# Membros do Grupo POC-2
| **Aluno**                         | **N°USP** |
|-----------------------------------|-----------|
| Hélio Nogueira Cardoso            | 10310227  |
| Paulo Henrique dos Santos Almeida | 12543926  |
| Theo da Mota dos Santos           | 10691331  |

# Item 1 - Assembleco
Inspirados no famoso jogo Wordle, especialmente em sua versão ["Letreco" (desenvolvida por Gabriel Toschi)](https://github.com/gabtoschi/letreco), decidimos criar uma versão em Assembly para o Processador do ICMC. O jogo consiste na advinhação de uma palavra de 5 letras dentre 6 tentativas. Para auxiliar, são dadas dicas sobre a existência e a posição das letras em cada tentativa. Para tanto, elas são coloridas com:
* Vermelho: indicando que a letra não está presente na palavra-resposta
* Amarelo: indicando que a letra está presente na palavra-resposta, mas em outra posição
* Verde: indicando que a letra está presente na palavra-resposta na mesma posição

Obs.: mesmo em caso de repetição de letras, cada uma delas conta apenas uma vez. Ou seja, se a palavra-resposta for "forma" e a tentativa for "bolos", a primeira letra 'o' de "bolos" ficará verde, mas a segunda ficará vermelha.

![Tela inicial do jogo](images/tela_inicial.png)

O programa começa com uma tela inicial e aguarda o usuário digitar alguma tecla. Este tempo de aguardo é utilizado para gerar um número pseudoaleatório que irá selecionar a palavra-resposta da primeira partida.

![Início de uma partida](images/1.png)

A partida inicia com 6 linhas de 5 quadrados, uma para cada tentativa. A primeira delas é feita sem nenhuma dica na primeira linha de quadrados. Basta digitar a palavra e apertar ENTER para confirmar. Caso queira apagar, utiliza-se a tecla '1'. 

![Primeira tentativa da rodada teste](images/2.png)

Após confirmar a tentativa, ela é impressa com dicas de cores. No exemplo acima, as cores indicam que a resposta não tem as letras 'p', 'o', nem 't', que termina com a letra 'a' e que possui a letra 'r', mas não na posição central.

![Vitória](images/3.png)

No exemplo, a partida for vencida na quinta tentativa, revelando a palavra-resposta "clara". Ao final da partida, é perguntado ao jogador se ele gostaria de jogar uma nova rodada. Caso queira, ele deve escrever 's' dentro do quadrado na resposta e confirmar com ENTER. Caso não, basta escrever qualquer outra letra, como 'n', e também confirmar com ENTER. Antes da confirmação, é possível também apagar com a tecla '1'.

![Derrota](images/4.png)

A derrota ocorre quanto o jogador não consegue adivinhar a palavra-resposta dentro das 6 tentativas. Neste caso, a resposta é revelada.

# Item 2 - Construir o Hardware do Processador em VHDL na FPGA
O código das instruções faltantes no VHDL do processador (cpu.vhd) foi sendo completado ao longo das aulas da disciplina e se encontra na Pasta 'PROCESSADOR FPGA MODIFICADO', dentro da pasta da DE0-CV. 

# Item 3 - Nova Instrução cmpz (comparar com zero)

![Arquitetura Modificada](images/arquitetura.png)

## 3.1. Modificar o projeto na FPGA
## 3.2. Modificar o Montador para que reconheça a nova Instrução
## 3.3. Modificar o Manual do Processador, descrevendo sua nova Instrução (e alteraçao na Arquitetura)

# Vídeo Demonstrando Jogo e Explicando Nova Instrução
[Link para o vídeo](https://youtu.be/sQ_09y4LZx0)

