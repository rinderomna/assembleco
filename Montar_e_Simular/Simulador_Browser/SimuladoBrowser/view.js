function View (model, controller){
		// -------- MVC --------
		var model;
		var controller;
	
		var line2_instruction = [ Mnemonicos.STORE, Mnemonicos.LOAD, Mnemonicos.LOADIMED, Mnemonicos.JMP, Mnemonicos.CALL ];

		// ---- registradores -------
		var FR = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
		var reg = [0,0,0,0,0,0,0,0];
		var ir, sp;

		
		// ----------Canvas -----------
		var c=document.getElementById("canvas");
		var ctx=c.getContext("2d");
			
		var canvasData = ctx.getImageData(0, 0, 640, 480);
		for(var ci=3;ci<480*640*4;ci+=4){
			canvasData.data[ci] = 255;
		}
		// ----- Instrucoes ---------
		var buffer = new Array(40);

		// -- charmap e cpuram ---
		var charmap;
		var cpuram;

		// ----- Registradores -----
		this.updatePC  = function(){
			pc = model.getPC();
			if(!controller.getHex()){
				document.getElementById('PC').value = pc;
			}else{
				document.getElementById('PC').value = pc.toString(16);
			}
		}

		 this.updateIR  = function(){
			ir = model.getIR();
			if(!controller.getHex()){
				document.getElementById('IR').value = ir;
			}else{
				document.getElementById('IR').value = ir.toString(16);
			}
		}

		 this.updateSP  = function(){
			sp = model.getSP();
			if(!controller.getHex()){
				document.getElementById('SP').value = sp;
			}else{
				document.getElementById('SP').value = sp.toString(16);
			}
		}

		 this.updateFR  = function(){
			FR = model.getFR();
			document.getElementById('FR').value = "";
			for(var i=0;i<16;i++)
				document.getElementById('FR').value += FR[i].toString(16);
		}

		 this.updateRegistradores  = function(){
			for(var i=0; i<8; i++)
			{	reg[i] = model.getRegistrador(i);	// atualiza o valor dos registradores
				if(!controller.getHex()){
					document.getElementById('r['+i+']').value = reg[i];
				 }else{
					document.getElementById('r['+i+']').value = reg[i].toString(16);
				}
			}
		 }

		// -------- Video --------
		function drawPixel (x, y, color) {
		
			var R,G,B;
			switch(color)
			{ case Mnemonicos.BROWN: 	R = 165; G = 42; B = 42; break;
				case Mnemonicos.GREEN: 	R = 0; G = 255; B = 0; break;
				case Mnemonicos.OLIVE: 	R = 120; G = 130; B = 30; break;
				case Mnemonicos.NAVY: 		R = 30; G = 50; B = 130; break;
				case Mnemonicos.PURPLE: 	R = 132; G = 42; B = 120; break;
				case Mnemonicos.TEAL: 		R = 0; G = 127; B = 0.127; break;
				case Mnemonicos.SILVER: 	R = 178; G = 178; B = 178; break;
				case Mnemonicos.GRAY: 		R = 188; G = 188; B = 188; break;
				case Mnemonicos.RED: 		R = 255; G = 0; B = 0; break;
				case Mnemonicos.LIME: 		R = 198; G = 198; B = 50; break;
				case Mnemonicos.YELLOW: 	R = 255; G = 255; B = 0; break;
				case Mnemonicos.BLUE: 		R = 0; G = 0; B = 255; break;
				case Mnemonicos.FUCHSIA: R = 255; G = 27; B = 170; break;
				case Mnemonicos.AQUA: 		R = 120; G = 200; B = 135; break;
				case Mnemonicos.WHITE: 	R = 255; G = 255; B = 255; break;
				case Mnemonicos.BLACK:	 	R = 0; G = 0; B = 0; break;
				default:			R = 255; G = 255; B = 255; break;
		  }
		  for(var i = x*2; i < x*2+2 ;i++){
			for(var j = y*2; j < y*2+2 ;j++){
				var index = (i + j * 640) * 4;
			
				canvasData.data[index + 0] = R;
				canvasData.data[index + 1] = G;
				canvasData.data[index + 2] = B;
			}
		  }
		}
		
		this.updateCanvas = function() {
			ctx.putImageData(canvasData, 0, 0);
		}
		
		 this.draw_pixmap  = function(pos){
			var block = model.getBlock(pos);
			var symbol=block.sym, color=block.color;
			var x=8*(pos%40), y=8*parseInt(pos/40);
			  for(i=0; i<8; i++)	
			  {	for(j=0; j<8; j++)
					{
						 if(chars[i+symbol][j]){
							drawPixel(x+j, y+i, color);
						}else{
							drawPixel(x+j, y+i, Mnemonicos.BLACK);
						}
					}
				}
		 }

		// ----- Instrucoes -------
		 this.updateInstrucoes  = function(atual, proxima, linhas){
			var i, k;
			var temp;

			this.show_program(1, atual, sp);
			this.show_program(3, proxima, sp);
			for(i=0; i<linhas; i++)
			{ temp = 1;
				 for(k=0; k<5; k++)
				 { if(model.pega_pedaco(model.getMem(proxima),15,10) == line2_instruction[k])
					temp = 2;
				 }
				 proxima = proxima + temp;
				 this.show_program(i+4,proxima,sp);
			}
		 } 

		 this.show_program  = function(linha,  pc, sp){ 
				ir = model.getMem(pc),
				_rx = model.pega_pedaco(ir,9,7),
				_ry = model.pega_pedaco(ir,6,4), 
				_rz = model.pega_pedaco(ir,3,1);

			var texto;

		  switch(model.pega_pedaco(ir,15,10))
			{ case Mnemonicos.INCHAR: 	texto = "PC: "+pc+"&#09;|	INCHAR R"+_rx+"			|	R"+_rx+"        <- teclado";		 			 break;
				case Mnemonicos.OUTCHAR:	texto = "PC: "+pc+"&#09;|	OUTCHAR R"+_rx+", R"+_ry+"	|	video[R"+_rx+"] <- char[R"+_ry+"]"; break;
				case Mnemonicos.MOV:
					switch(model.pega_pedaco(ir,1,0))
					{	case 0:  texto = "PC: "+pc+"&#09;|	MOV R"+_rx+", R"+_ry+"			|	R"+_rx+" <- R"+_ry; break;
						case 1:  texto = "PC: "+pc+"&#09;|	MOV R"+_rx+", SP				|	R"+_rx+" <- SP"; 				   break;
						default: texto = "PC: "+pc+"&#09;|	MOV SP, R"+_rx+"				|	SP  <- R"+_rx;					 break;
					}
					break;

			case Mnemonicos.STORE:				texto = "PC: "+pc+"&#09;|	STORE "+model.getMem(pc+1)+", R"+_rx+"	|	MEM["+model.getMem(pc+1)+"] <- R"+_rx; break;
			case Mnemonicos.STOREINDEX: 	texto = "PC: "+pc+"&#09;|	STOREI R"+_rx+", R"+_ry+"		|	MEM[R"+_rx+"] <- R"+_ry;					 break;

			case Mnemonicos.LOAD: 			texto = "PC: "+pc+"&#09;|	LOAD R"+_rx+", "+_rx+"		|	R"+_rx+" <- MEM["+model.getMem(pc+1)+"]"; 	break;
			case Mnemonicos.LOADIMED: 	texto = "PC: "+pc+"&#09;|	LOADN R"+_rx+", #"+model.getMem(pc+1)+"	|	R"+_rx+" <- #"+model.getMem(pc+1); 	break;
			case Mnemonicos.LOADINDEX:	texto = "PC: "+pc+"&#09;|	LOADI R"+_rx+", R"+_ry+"		|	R"+_rx+" <- MEM[R"+_ry+"]"; 							break;

			case Mnemonicos.LAND: texto = "PC: "+pc+"&#09;|	AND R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" and R"+_rz;	break;
			case Mnemonicos.LOR:	 texto = "PC: "+pc+"&#09;|	OR R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" or R"+_rz;	break;
			case Mnemonicos.LXOR: texto = "PC: "+pc+"&#09;|	XOR R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" xor R"+_rz;  break;
			case Mnemonicos.LNOT: texto = "PC: "+pc+"&#09;|	NOT R"+_rx+", R"+_ry+"			|	R"+_rx+" <- R"+_ry;					break;

			case Mnemonicos.CMP:	texto = "PC: "+pc+"&#09;|	CMP R"+_rx+", R"+_ry+"			|	FR <- \<eq|le|gr\>"; break;

			case Mnemonicos.JMP:
					switch(model.pega_pedaco(ir,9,6))
					{ case 0:	 texto = "PC: "+pc+"&#09;|	JMP #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 1:	 texto = "PC: "+pc+"&#09;|	JEQ #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 2:	 texto = "PC: "+pc+"&#09;|	JNE #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 3:  texto = "PC: "+pc+"&#09;|	JZ  #"+model.getMem(pc+1)+"			|	PC <- #"+model.getMem(pc+1); break;
						case 4:  texto = "PC: "+pc+"&#09;|	JNZ #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 5:  texto = "PC: "+pc+"&#09;|	JC  #"+model.getMem(pc+1)+"			|	PC <- #"+model.getMem(pc+1); break;
						case 6:  texto = "PC: "+pc+"&#09;|	JNC #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 7:  texto = "PC: "+pc+"&#09;|	JGR #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 8:  texto = "PC: "+pc+"&#09;|	JLE #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 9:  texto = "PC: "+pc+"&#09;|	JEG #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 10: texto = "PC: "+pc+"&#09;|	JEL #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 11: texto = "PC: "+pc+"&#09;|	JOV #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 12: texto = "PC: "+pc+"&#09;|	JNO #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 13: texto = "PC: "+pc+"&#09;|	JDZ #"+model.getMem(pc+1)+" 		|	PC <- #"+model.getMem(pc+1); break;
						case 14: texto = "PC: "+pc+"&#09;|	JN  #"+model.getMem(pc+1)+"			|	PC <- #"+model.getMem(pc+1); break;
						default: console.log("Erro. Instrucao inesperada em show_program"); break;
					}
					break;

			case Mnemonicos.PUSH:
				if(!model.pega_pedaco(ir,6,6)) // Registrador
					{ texto = "PC: "+pc+"&#09;|	PUSH R"+_rx+"			|	MEM["+sp+"] <- R"+_rx+"] "; 
						break; 
					}
					texto = "PC: "+pc+"&#09;|	PUSH FR			|	MEM["+sp+"] <- FR]" // FR
			  break;

			case Mnemonicos.POP:
				if(!model.pega_pedaco(ir,6,6))  // Registrador
					{ texto = "PC: "+pc+"&#09;|	POP R"+_rx+"				|	R"+_rx+" <- MEM["+sp+"] ";
						break; 
					}
					texto = "PC: "+pc+"&#09;|	POP FR			|	FR <- MEM["+sp+"] "; // FR
			  break;

			case Mnemonicos.CALL:
					switch(model.pega_pedaco(ir,9,6))
					{ case 0:  texto = "PC: "+pc+"&#09;|	CALL #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 1:  texto = "PC: "+pc+"&#09;|	CEQ #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 2:  texto = "PC: "+pc+"&#09;|	CNE #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 3:  texto = "PC: "+pc+"&#09;|	CZ #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 4:  texto = "PC: "+pc+"&#09;|	CNZ #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 5:  texto = "PC: "+pc+"&#09;|	CC #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 6:  texto = "PC: "+pc+"&#09;|	CNC #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 7:  texto = "PC: "+pc+"&#09;|	CGR #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 8:  texto = "PC: "+pc+"&#09;|	CLE #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 9:  texto = "PC: "+pc+"&#09;|	CEG #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1); break;
						case 10: texto = "PC: "+pc+"&#09;|	CEL #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1);	break;
						case 11: texto = "PC: "+pc+"&#09;|	COV #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1);	break;
						case 12: texto = "PC: "+pc+"&#09;|	CNO #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1);	break;
						case 13: texto = "PC: "+pc+"&#09;|	CDZ #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1);	break;
						case 14: texto = "PC: "+pc+"&#09;|	CN #"+model.getMem(pc+1)+"&#09;&#09;|	M["+sp+"]<-PC; SP--; PC<-#"+model.getMem(pc+1);	break;
						default: printf("Erro. Linha inesperada show_program"); break;
					}
					break;

			case Mnemonicos.RTS:  texto = "PC: "+pc+"&#09;|	RTS				|	SP++; PC <- MEM["+sp+"]; PC++"; break;

			case Mnemonicos.ADD:	 texto = "PC: "+pc+"&#09;|	ADD R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" + R"+_rz;break;
			case Mnemonicos.SUB:  texto = "PC: "+pc+"&#09;|	SUB R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" - R"+_rz;break;
			case Mnemonicos.MULT: texto = "PC: "+pc+"&#09;|	MULT R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" * R"+_rz; break;
			case Mnemonicos.DIV:	 texto = "PC: "+pc+"&#09;|	DIV R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" / R"+_rz;break;
			case Mnemonicos.LMOD: texto = "PC: "+pc+"&#09;|	MOD R"+_rx+", R"+_ry+", R"+_rz+"		|	R"+_rx+" <- R"+_ry+" %% R"+_rz; break;
			case Mnemonicos.INC:
				if(!model.pega_pedaco(ir,6,6))  // Inc Rx
					{ texto = "PC: "+pc+"&#09;|	INC R"+_rx+"				|	R"+_rx+" <- R"+_rx + " + 1";
						break; 
					}
					texto = "PC: "+pc+"&#09;|	DEC R"+_rx+"				|	R"+_rx+" <- R"+_rx+" - 1";// Dec Rx
			  break;

			case Mnemonicos.SHIFT:     // Nao tive paciencia de fazer diferente para cada SHIFT/ROT
					switch(model.pega_pedaco(ir,6,4))
					{ case 0: texto = "PC: "+pc+"&#09;|	SHIFTL0 R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"		|	R"+_rx+" <-'0'  << "+model.pega_pedaco(ir,3,0); break;
						case 1: texto = "PC: "+pc+"&#09;|	SHIFTL1 R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"		|	R"+_rx+" <-'1'  << "+model.pega_pedaco(ir,3,0);	break;
						case 2: texto = "PC: "+pc+"&#09;|	SHIFTR0 R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"		|	'0'. R"+_rx+"   >> "+model.pega_pedaco(ir,3,0);break;
						case 3: texto = "PC: "+pc+"&#09;|	SHIFTR1 R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"		|	'1'. R"+_rx+"   >> "+model.pega_pedaco(ir,3,0);break;
						default:
					if(model.pega_pedaco(ir,6,5) == 2) // ROTATE LEFT
				  { texto = "PC: "+pc+"&#09;|	ROTL R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"	|	R"+_rx+" <- R"+_rx+"   << "+model.pega_pedaco(ir,3,0);
								break; 
							}
							texto = "PC: "+pc+"&#09;|	ROTR R"+_rx+", #"+model.pega_pedaco(ir,3,0)+"	|	R"+_rx+" . R"+_rx+"   >> "+model.pega_pedaco(ir,3,0); break;
					}
					break;

			case Mnemonicos.SETC: texto = "PC: "+pc+"&#09;|	SETC				|	C <- "+model.pega_pedaco(ir,9,9); break;

			case Mnemonicos.HALT: texto = "PC: "+pc+"&#09;|	HALT				|	Pausa a execucao"; break;

			case Mnemonicos.NOP:	texto = "PC: "+pc+"&#09;|	NOOP				|	Do nothing"; break;

			case Mnemonicos.BREAKP: texto = "PC: "+pc+"&#09;|	BREAKP #"+model.pega_pedaco(ir,9,0)+"		|	Break Point"; break;

				default: 
					console.log("ERRO - show program linha: " + linha + " pc " + pc +" " +Mnemonicos.JMP);
					break;
		  }
			this.escrever_na_tela(texto, linha, 1);
			}

		// ---- interface grafica ------

		 this.escrever_na_tela = function(string, linha, size){
			buffer[linha]=string;
			document.getElementById('listinst').innerHTML = '';
			buffer[0]="LINHA  | INSTRUCAO";
			buffer[2]="Proximas:";
			for(var i=0;i<35;i++){
				document.getElementById('listinst').innerHTML += buffer[i] + "<br>";
			}
		 }

		 this.model = model;

	// adiciona o view como observador 
	model.registraRegistrador(this);
	model.registraInstrucoes(this);
	model.registraVideo(this);

	// recupera o nome do charmap e do cpuram
	charmap = model.getCharmap();
	cpuram = model.getCpuram();

	// recupera o desenhos binario dos caracteres
	chars = model.getChars();
}