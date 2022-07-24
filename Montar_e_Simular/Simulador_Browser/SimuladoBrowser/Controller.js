function Controller(model_ini){
	var view = new View(model_ini, this);
	setInterval(function() {view.updateCanvas()}, 30);
	var model=model_ini;
	var hex;
	var automatico=false;
	var resetVideo;
	var key;

	this.reset = function(){
		model.reset();
		if(resetVideo)
		{	
			model.gerarBlock();
		}	
	}
	this.getKey = function(){
		var aux = key;
		key = 255;
		if(aux>=65 && aux <=90) aux+=32;
		return aux;
	}
	
	this.setKey = function(code){ 
		key = code;
	//	if(key>=65 && key<=90) key +=32;
		//console.log(key.toString());
	}

	
	this.AlteraRegistradores = function(){
		var i, j;
		var aux = new Array();

		for(i=0; i<8; i++)
		{	j = parseInt(document.getElementById('r['+i+']').value);
			
			if( j == -1 || j > 32768) // se for 0 = erro ou maior do que um numero de 16 bits
			{	aux[i] = -1;
				continue;
			}

			aux[i] = j;
		}
		model.setRegistrador(aux);
	}
	// ---- comandos de set -------
	this.setDelay = function(valor){}
	this.setResetVideo = function(valor){}
	this.setRegistradorHex = function(valor){}

	this.switchExecucao = function(){

		if(!automatico)
		{	
			model.setProcessamento(true);
			model.processa();
			automatico=true;
			document.getElementById("status").innerHTML="Automatico";
			document.getElementById("buttonAutomatico").innerHTML="Manual";
			return;
		}
		automatico=false;
		document.getElementById("status").innerHTML="Manual";
		document.getElementById("clock").innerHTML="";
		model.setProcessamento(false);
		model.stop();
		document.getElementById("buttonAutomatico").innerHTML="Automatico";
	}

	// ---- comandos de get --------
	this.getHex = function(){return hex;}
	
	model.setController(this);
	
	hex = false;				// comeca decimal
	automatico = false;	// comeca manual
	resetVideo = true;	// comeca resetando o video, quando dah reset

	this.reset();
}