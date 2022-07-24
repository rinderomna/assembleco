	function pixblock(sym, color){
		this.sym = sym;
		this.color = color;	
	}
	
	function Model(cpuram_ini, charmap_ini){
		var Ins ;
		var Reg ;
		var controller;

		// --- Registradores ------
		var rx, ry, rz;

		var reg = [0,0,0,0,0,0,0,0]; //8
		var pc, ir, sp;
		var FR = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; //16

		// ---- Memoria --------
		var mem = new Array();

		// ---- Nome dos arquivos ------
		var cpuram = cpuram_ini;
		var charmap = charmap_ini;

		// -- buffer dos caracteres do charmap --
		var chars = new Array();

		// -- propriedades do charmap ----
		var charmapwidth;
		var charmapdepth;

		// -- Processamento ---

		var key;
		var auxpc;
		var pc2;
		var varDelay;
		var automatico = false;
		var interval;
		var reg_interval;

		// -- Video ---
		var block;

		
		//----Clock----
		var atual;
		var clock_count=0;
		var clock_t=400;
		var clock=100000;
		var clock_interval;
		
		this.getBlock = function(pos){
			return block[pos];
		}
		
		this.setController = function(value){
			controller=value
		}

		// ------ Registradores ----------------
		this.registraRegistrador = function(r){
			Reg = r;
		}

		this.removeRegistrador = function(){
			Reg = undefined;
		}


		// --- registradores gerais ---
		this.getRegistrador = function(regN){
			return reg[regN];
		}

		this.setRegistrador = function(vetor){
			reg = vetor;
			Reg.updateRegistradores();
		}


		// -------- PC -----------
		this.getPC = function(){return pc;}

		this.setPC = function(valor){
			if(valor >= 0)
				pc = valor;
			Reg.updatePC();
		}


		// -------- IR -----------
		this.getIR = function(){ return ir;}

		this.setIR = function(valor){
			if(valor >= 0)
				ir = valor;	
			Reg.updateIR();
		}


		// -------- SP -----------
		this.getSP = function(){ return sp;}

		this.setSP = function(valor){
			if(valor >= 0)
				sp = valor;
			Reg.updateSP();
		}


		// -------- FR -----------
		this.getFR = function(N){ return FR;}

		this.setFR = function(N, valor){
			if(valor >= 0)
				FR[N] = valor;
			Reg.updateFR();
		}

		
		this.setClock = function(value){
			clock=parseInt(value);
		}
	
		// ------ Instrucoes -------------------
		this.registraInstrucoes = function(i){Ins = i;}

		this.removeInstrucoes = function(){Ins = undefined;}

		this.processaAutomatico = function(){
			var me = this;
			start = new Date();
			clock_count=1000;
			interval=setInterval(function() {me.multiplicadorClock()}, 1);
			clock_interval=setInterval(function() {me.corrigeClock()}, 1000);
		}
		this.corrigeClock = function(){
			atual=clock_count;
			clock_t=clock_t*clock/atual;
			if(clock_t>10000) clock_t=10000;
			if(clock_t<1) clock_t=1;
			if(atual>1000000)
				document.getElementById("clock").innerHTML="Clock: "+parseInt(atual/1000000) + " mhz";
			else if(atual>1000)
				document.getElementById("clock").innerHTML="Clock: "+parseInt(atual/1000) + " khz";
			else
				document.getElementById("clock").innerHTML="Clock: "+parseInt(atual)+" hz";
			

			clock_count=0;
		}
		
		this.multiplicadorClock =  function(){
			for(var i=0;i<clock_t;i++){
				this.processador();
			}
			clock_count+=clock_t;
		}

		this.stop = function (){
			window.clearInterval(interval);
			window.clearInterval(clock_interval);
			this.updateAll();
		}
		
		this.processa = function(){
			if(automatico)			{	
				this.processaAutomatico();
			}else{			
				this.processador(); // executa soh uma vez
				this.updateAll();
			}
		}

		this.pega_pedaco = function(ir, a, b){ return ((ir &  ( ((1 << (a+1)) - 1) )  ) >> b);}


		// ------ Video -------------------
		this.registraVideo = function(v){Vid = v;}

		this.removeVideo = function(){Vid = undefined;}

		this.getChars = function(){ return chars;}

		this.getPixblock = function(){ return block;}

		this. gerarBlock = function(){
			block = new Array();
			for(var i=0; i<1200; i++)
			{	
				block[i] = new pixblock(0,0);
			}
		}

		// -------- arquivos.mif -----------

		function GravaArquivo(){
			var line = cpuram.split("\n");
			for(var i=6;i<32775;i++){
				mem[i-6] = parseInt(line[i].split(":")[1],2);
			}
		}

		function load_charmap(){
			var map = charmap.split("\n");
			for(var i=0;i<1024;i++) {
				chars[i] = new Array();
			}
			
			for(var i=0;i<map.length;i++){
				if(map[i].search("^(\t[0-9]+(?:\[0-9]*)?.*:.*[0-9]+(?:\[0-9]*)?;)")!=-1){
					var mapTok = map[i].match(/[0-9]+(?:\[0-9]*)?/g);
					var pos = parseInt(mapTok[0]);
					var value = mapTok[1];
					for(var j=0;j<8;j++){
						chars[pos][j] = parseInt(value.charAt(j));
					}
				}else if(map[i].search("^(\t\[[0-9]+(?:\[0-9]*)?..[0-9]+(?:\[0-9]*)?].*:.*[0-9]+(?:\[0-9]*)?;)")!=-1){
					var mapTok = map[i].match(/[0-9]+(?:\[0-9]*)?/g);
					var pos1 = parseInt(mapTok[0]);
					var pos2 = parseInt(mapTok[1]);
					var value = mapTok[2];
					for(var k=pos1;k<=pos2;k++){
						for(var j=0;j<8;j++){
							chars[k][j] = parseInt(value.charAt(j));
						}
					}
				}
			}
		}


		// ---- cpuram.mif e charmap.mif -------
		this.getCharmap = function(){ return charmap;}

		this.getCpuram = function(){ return cpuram;}

		// ------ Memoria --------
		this.getMem = function(pos){return mem[pos];}


		// ------ Processador ---------
		this.getProcessamento = function(){return automatico;}
		this.setProcessamento = function(value){automatico = value;}

		this._rotl = function(value, shift){
			if(shift >= 16)									 				 // evita rotacoes completas
				shift = shift - (shift/16)*16; 				 // shift = shift mod 16

			var aux = value << shift;			 // shifta para a esquerda
			aux += this.pega_pedaco(value, 15, 16-shift); // pega os bits finais que serao deslocados para o inicio

			return aux &= 65535;										 // retorna somente os 16 primeiros bits do numero
		}

		this._rotr = function(value, shift){ 
			if(shift >= 16)									 					// evita rotacoes completas
				shift = shift - (shift/16)*16; 					// shift = shift mod 16

			var aux = value >> shift;				// shifta para a direita
			aux += ( this.pega_pedaco(value, shift, 0) << (16 - shift) );  // pega os bits iniciais que serao deslocados para o final

			return aux &= 65535;											// retorna somente os 16 primeiros bits do numero
		}

		this.processador = function(){
			
			var la;
			var i;
			var temp;
			var opcode;

			var letra;

		  // ----- Ciclo de Busca: --------
			ir = mem[pc];

			if(pc > 32767)
			{ document.getElementById("status").innerHTML = "ERRO: Ultrapassou limite da memoria, coloque um jmp no fim do código\n";
		
			}
			pc++;
			// ----------- -- ---------------

		  // ------ Ciclo de Executa: ------
		  rx = this.pega_pedaco(ir,9,7);
		  ry = this.pega_pedaco(ir,6,4);
		  rz = this.pega_pedaco(ir,3,1);
			// ------------- -- --------------

		  // case .das instrucoes
		  opcode = this.pega_pedaco(ir,15,10);

		  switch(opcode)
			{ case Mnemonicos.INCHAR:
				key = controller.getKey();
				reg[rx] = this.pega_pedaco(key,7,0);
					//return;
					break;

			case Mnemonicos.OUTCHAR:
					if(reg[ry] > 1199 || reg[ry] < 0)
					{	document.getElementById("status").innerHTML = "ERRO - tentou escrever na posição da tela: "+ reg[ry];
						break;
					}

					letra = reg[rx] & 0x7f;

					if(letra > 0)
				temp = letra;
					else
						temp = 0;

				  block[reg[ry]].color = this.pega_pedaco(reg[rx], 11, 8);
				  block[reg[ry]].sym = temp * 8;
					Reg.draw_pixmap(reg[ry]);
					//return;
					break;

				case Mnemonicos.MOV:
					switch(this.pega_pedaco(ir,1,0))
					{ case 0:
							reg[rx] = reg[ry];
							break;
						case 1:
							reg[rx] = sp;
							break;
						default:
							sp = reg[rx];
						break;
					}
					//return;
			  break;

			case Mnemonicos.STORE:
			  mem[mem[pc]] = reg[rx];
			  pc++;
			  break;

			case Mnemonicos.STOREINDEX:
			  mem[reg[rx]] = reg[ry];
			  break;

			case Mnemonicos.LOAD:
			  reg[rx] = mem[mem[pc]];
			  pc++;
			  break;

			case Mnemonicos.LOADIMED:
			  reg[rx] = mem[pc];
			  //console.log(mem[pc]);
			  pc++;
			  break;

			case Mnemonicos.LOADINDEX:
			  reg[rx] = mem[reg[ry]];
			  break;

			case Mnemonicos.LAND:
			  reg[rx] = reg[ry] & reg[rz];
					FR[3] = 0; 
			  if(reg[rx] == 0)
						FR[3] = 1;
						//return;
			  break;

			case Mnemonicos.LOR:
			  reg[rx] = reg[ry] | reg[rz];
					FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
			  if(reg[rx] == 0)
						FR[3] = 1;
						//return;
			  break;

			case Mnemonicos.LXOR:
			  reg[rx] = reg[ry] ^ reg[rz];
					FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
			  if(reg[rx] == 0)
						FR[3] = 1;
					//	return;
			  break;

			case Mnemonicos.LNOT:
			  reg[rx] =  ~(reg[ry]);
					FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
			  if(reg[rx] == 0)
						FR[3] = 1;
					//	return;
			  break;

			case Mnemonicos.CMP:

			  if (reg[rx] > reg[ry])
					{	FR[2] = 0; // FR = <...|zero|equal|lesser|greater>
						FR[1] = 0;
						FR[0] = 1;
					}
			  else if (reg[rx] < reg[ry])
					{	FR[2] = 0; // FR = <...|zero|equal|lesser|greater>
						FR[1] = 1;
						FR[0] = 0;
					}
			  else // reg[rx] == reg[ry]
					{	FR[2] = 1; // FR = <...|zero|equal|lesser|greater>
						FR[1] = 0;
						FR[0] = 0;
					}
					//return;
			  break;

			case Mnemonicos.JMP:
					la = this.pega_pedaco(ir,9,6);

					if((la == 0) // NO COND
						|| (FR[0]==1 && (la==7)) 							// GREATER
						|| ((FR[2]==1 || FR[0]==1) && (la==9))  // GREATER EQUAL
						|| (FR[1]==1 && (la==8)) 							// LESSER
						|| ((FR[2]==1 || FR[1]==1) && (la==10)) // LESSER EQUAL
						|| (FR[2]==1 && (la==1)) 							// EQUAL
						|| (FR[2]==0 && (la==2)) 							// NOT EQUAL
						|| (FR[3]==1 && (la==3)) 							// ZERO
						|| (FR[3]==0 && (la==4)) 							// NOT ZERO
						|| (FR[4]==1 && (la==5)) 							// CARRY
						|| (FR[4]==0 && (la==6)) 							// NOT CARRY
						|| (FR[5]==1 && (la==11)) 						// OVERFLOW
						|| (FR[5]==0 && (la==12)) 						// NOT OVERFLOW
						|| (FR[6]==1 && (la==14)) 						// NEGATIVO
						|| (FR[9]==1 && (la==13))) 						// DIVBYZERO
						 { pc = mem[pc];
										}
						else
							pc++;
				break;

			case Mnemonicos.PUSH:
			  if(!this.pega_pedaco(ir,6,6)) // Registrador
						mem[sp] = reg[rx];
			  else  // FR
					{	temp = 0;
				for(i=16; i--; ) 		// Converte o vetor FR para int
							temp = temp + parseInt((FR[i] * (Math.pow(2.0,i))));
				mem[sp] = temp;
			  }
			  sp--;
			 // return;
			  break;

			case Mnemonicos.POP:
			  sp++;
			  if(!this.pega_pedaco(ir,6,6))  // Registrador
						reg[rx] = mem[sp];
			  else // FR
					{ for(i=16; i--; )				// Converte o int mem[sp] para o vetor FR
							FR[i] = this.pega_pedaco(mem[sp],i,i);
			  }
			  //return ;
			  break;

			case Mnemonicos.CALL:
					la = this.pega_pedaco(ir,9,6);

					if( (la == 0) // NO COND
					   || (FR[0]==1 && (la==7)) 							// GREATER
						|| ((FR[2]==1 || FR[0]==1) && (la==9))  // GREATER EQUAL
						|| (FR[1]==1 && (la==8)) 							// LESSER
						|| ((FR[2]==1 || FR[1]==1) && (la==10)) // LESSER EQUAL
						|| (FR[2]==1 && (la==1)) 							// EQUAL
						|| (FR[2]==0 && (la==2)) // NOT EQUAL
						|| (FR[3]==1 && (la==3)) // ZERO
						|| (FR[3]==0 && (la==4)) // NOT ZERO
						|| (FR[4]==1 && (la==5)) // CARRY
						|| (FR[4]==0 && (la==6)) // NOT CARRY
						|| (FR[5]==1 && (la==11)) // OVERFLOW
						|| (FR[5]==0 && (la==12)) // NOT OVERFLOW
						|| (FR[6]==1 && (la==14)) // NEGATIVO
						|| (FR[9]==1 && (la==13))) { // DIVBYZERO
							mem[sp] = pc;
							sp--;
							pc = mem[pc];
							}
						else
							pc++;
					break;

			  case Mnemonicos.RTS:
				sp++;
				pc = mem[sp];
				pc++;
				break;

			  case Mnemonicos.ADD:
				reg[rx] = reg[ry] + reg[rz]; // Soma sem Carry

				if(this.pega_pedaco(ir,0,0))   // Soma com Carry
					reg[rx] += FR[4];

						FR[3] = 0; 									// -- FR = <...|zero|equal|lesser|greater>
						FR[4] = 0;

				if(!reg[rx]) // Se resultado = 0, seta o Flag de Zero
							FR[3] = 1;
						else
					if(reg[rx] > 0xffff)
							{ FR[4] = 1;  // Deu Carry
					reg[rx] = reg[rx] - 0xffff;
					}
					//return;
				break;

			  case Mnemonicos.SUB:
				reg[rx] = reg[ry] - reg[rz]; // Subtracao sem Carry

				if(this.pega_pedaco(ir,0,0)==1)  // Subtracao com Carry
				  reg[rx] += FR[4];

						FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
						FR[9] = 0;

				if(!reg[rx]) // Se resultado = 0, seta o Flag de Zero
							FR[3] = 1;
				else
					if(reg[rx] < 0x0000)
							{ FR[9] = 1;  // Resultado e' Negativo
					  reg[rx] = 0;
					}
					//return;
				break;

			  case Mnemonicos.MULT:
				reg[rx] = reg[ry] * reg[rz]; // MULT sem Carry

				if(this.pega_pedaco(ir,0,0)==1)  // MULT com Carry
				  reg[rx] += FR[4];

						FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
						FR[5] = 0;

				if(!reg[rx])
							FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero
				else
					if(reg[rx] > 0xffff)
								FR[5] = 1;  // Arithmetic Overflow
								//return;
				break;

			  case Mnemonicos.DIV:
				if(!reg[rz])
						{ FR[6] = 1;  // Arithmetic Overflow
				  reg[rx] = 0;
							FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero
				}
				else
						{ FR[6] = 0;

				  reg[rx] = parseInt(reg[ry] / reg[rz]); // DIV sem Carry
				  if(this.pega_pedaco(ir,0,0)==1)  // DIV com Carry
					reg[rx] += FR[4];

							FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>
					if(!reg[rx])
								FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero
						}
						//return;
				break;

			  case Mnemonicos.LMOD:
				reg[rx] = reg[ry] % reg[rz];
				
						FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>

				if(!reg[rx])
							FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero
						//	return;
						break;

			  case Mnemonicos.INC:
						reg[rx]++;									// Inc Rx
				if(this.pega_pedaco(ir,6,6)!=0) // Dec Rx
				  reg[rx] = reg[rx] - 2;

						FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>

				if(!reg[rx])
							FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero
						//	return;
						break;

			  case Mnemonicos.SHIFT:
						FR[3] = 0; // -- FR = <...|zero|equal|lesser|greater>

				if(!reg[rx])
							FR[3] = 1;  // Se resultado = 0, seta o Flag de Zero

						switch(this.pega_pedaco(ir,6,4))
				{ case 0: reg[rx] = reg[rx] << this.pega_pedaco(ir,3,0);					break;
					case 1: reg[rx] = ~((~(reg[rx]) << this.pega_pedaco(ir,3,0)));	break;
					case 2: reg[rx] = reg[rx] >> this.pega_pedaco(ir,3,0);					break;
					case 3: reg[rx] = ~((~(reg[rx]) >> this.pega_pedaco(ir,3,0)));	break;
							default:
						if(this.pega_pedaco(ir,6,5)==2) // ROTATE LEFT
						{  reg[rx] = _rotl(reg[rx],this.pega_pedaco(ir,3,0)); break; }
					  reg[rx] = _rotr(reg[rx],this.pega_pedaco(ir,3,0)); break;
						}
						//return;
				break;

			  case Mnemonicos.SETC:
				FR[4] = this.pega_pedaco(ir,9,9);
				break;

			  case Mnemonicos.HALT:		controller.switchExecucao(); break;
			  case Mnemonicos.NOP:			break;
			  case Mnemonicos.BREAKP:	
				controller.switchExecucao();
				break;

					default:						break;
					
			}
			reg[rx]=reg[rx]&0xffff;
			auxpc = pc;

			var ir2;

			// ----- Ciclo de Busca: --------
		  ir2 = mem[pc];
			pc2 = pc + 1;
			// ----------- -- ---------------

			// case .das instrucoes
			opcode = this.pega_pedaco(ir2,15,10);

			switch(opcode)
			{	case Mnemonicos.JMP:
					la = this.pega_pedaco(ir2,9,6);

					if((la == 0) // NO COND
						|| (FR[0]==1 && (la==7)) 							// GREATER
						|| ((FR[2]==1 || FR[0]==1) && (la==9))  // GREATER EQUAL
						|| (FR[1]==1 && (la==8)) 							// LESSER
						|| ((FR[2]==1 || FR[1]==1) && (la==10)) // LESSER EQUAL
						|| (FR[2]==1 && (la==1)) 							// EQUAL
						|| (FR[2]==0 && (la==2)) 							// NOT EQUAL
						|| (FR[3]==1 && (la==3)) 							// ZERO
						|| (FR[3]==0 && (la==4)) 							// NOT ZERO
						|| (FR[4]==1 && (la==5)) 							// CARRY
						|| (FR[4]==0 && (la==6)) 							// NOT CARRY
						|| (FR[5]==1 && (la==11)) 						// OVERFLOW
						|| (FR[5]==0 && (la==12)) 						// NOT OVERFLOW
						|| (FR[6]==1 && (la==14)) 						// NEGATIVO
						|| (FR[9]==1 && (la==13))) 						// DIVBYZERO
							pc2 = mem[pc2];
						else
							pc2++;
				break;

			case Mnemonicos.CALL:
					la = this.pega_pedaco(ir2,9,6);

					if( (la == 0) // NO COND
						|| (FR[0]==1 && (la==7)) // GREATER
						|| ((FR[2]==1 || FR[0]==1) && (la==9)) // GREATER EQUAL
						|| (FR[1]==1 && (la==8)) // LESSER
						|| ((FR[2]==1 || FR[1]==1) && (la==10)) // LESSER EQUAL
						|| (FR[2]==1 && (la==1)) // EQUAL
						|| (FR[2]==0 && (la==2)) // NOT EQUAL
						|| (FR[3]==1 && (la==3)) // ZERO
						|| (FR[3]==0 && (la==4)) // NOT ZERO
						|| (FR[4]==1 && (la==5)) // CARRY
						|| (FR[4]==0 && (la==6)) // NOT CARRY
						|| (FR[5]==1 && (la==11)) // OVERFLOW
						|| (FR[5]==0 && (la==12)) // NOT OVERFLOW
						|| (FR[6]==1 && (la==14)) // NEGATIVO
						|| (FR[9]==1 && (la==13))) { // DIVBYZERO
							pc2 = mem[pc2];
							}
						else
							pc2++;
					break;

			case Mnemonicos.RTS:
					pc2 = mem[sp+1];
					pc2++;
					break;

				case Mnemonicos.STORE:
				case Mnemonicos.LOAD:
				case Mnemonicos.LOADIMED:
					pc2++;
					break;

				case Mnemonicos.BREAKP:
					controller.notifyProcessamento();
					break;

				case Mnemonicos.HALT:
					controller.notifyProcessamento();
					break;

				default: break;
		
		  }
  }

		this.reset = function(){
			pc = 0;
			ir = 0;
			sp = 0x7FFC;
			auxpc = 0;
			pc2 = 0;	

			var i, tmp;
			var vetor = [0, 0, 0, 0, 0 , 0, 0, 0];
			this.setRegistrador(vetor);

			for(i = 16; i-- ; )
				FR[i] = 0;

			this.processador();

			tmp = auxpc;

			this.setPC(0);
			this.setIR(0);
			this.setSP(0x7FFC);

			this.setRegistrador(vetor);

			for(i = 16; i-- ; )
				this.setFR(i, 0);

			Ins.updateInstrucoes(0, tmp, 35);		// termina imprimindo o resultado
		}

		this.updateAll = function(){
			Ins.updateInstrucoes(auxpc, pc2, 35);		// termina imprimindo o resultado
			Reg.updateRegistradores();	// e atualizando os registradores
			Reg.updateFR();
			Reg.updatePC();
			Reg.updateIR();
			Reg.updateSP();
		}
		
		
		if(cpuram.slice(0,30)!="-- Codigo gerado pelo montador")
		{	
			console.log("Codigo gerado Invalido! " + cpuram.slice(0, 30));
			return;
		}

		GravaArquivo();
		load_charmap();
		
		automatico = false;

		this.gerarBlock();
	}