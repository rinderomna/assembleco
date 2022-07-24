function Simulador(){
	var source;
	var charmap;
	var model;
	var controller;
	var me=this;
	
	var source = document.getElementById('source');
	var charmap = document.getElementById('charmap');		
	var next = document.getElementById('buttonNext');		
	var automatico = document.getElementById('buttonAutomatico');
	var regs = document.getElementsByClassName('regs');
	var brun = document.getElementById('buttonRun');
	var clock_sel = document.getElementById('clockSel');
	var restore = document.getElementById('restore');

	function handlerSource(evt) {
		var input = evt.target.files // FileList object

		f = input[0];
		var reader = new FileReader();
		
		reader.onload = function(e) {
			source = reader.result;
		}
  
		reader.readAsText(f);
	}
	
	function handlerCharmap(evt) {
		var input = evt.target.files // FileList object
		
		f = input[0];
		var reader = new FileReader();
		
		reader.onload = function(e) {
			charmap = reader.result;
		}
  
		reader.readAsText(f);
	}
	
	this.run = function run(){

		if(restore.checked==true){
			source = localStorage.source;
			charmap = localStorage.charmap;
		}else{			
			localStorage.source = source;
			localStorage.charmap = charmap;
		}

		document.getElementById("init").style.display = 'none';
		document.getElementById("simulador").style.display = 'block';
		model = new Model(source, charmap);
		controller = new Controller(model);
	}	
		
	for(var i=0;i<regs.length;i++){
		regs[i].addEventListener('change', function(event){
			controller.AlteraRegistradores();
		});
	}
	
	source.addEventListener('change', handlerSource);
	next.addEventListener('click', function(event) {model.processa()});
	brun.addEventListener('click', function(event) {me.run()});
	automatico.addEventListener('click', function(event) {controller.switchExecucao()});
	charmap.addEventListener('change', handlerCharmap);
	clock_sel.addEventListener('change', function(event){
		model.setClock(clock_sel.value);
	});
	
	document.addEventListener('keydown', function(event) {
		 controller.setKey(event.which);
	});
}