FOLDERNAME=$$(date +%Y%m%d%H%M%S)

# compile instructions
# make all 2>&1 | tee -a install_apertium_spa_qve.log

#COMPILANDO SPA-QVE
all: comp_dict_m_spa comp_dict_m_qve comp_dict_m_qve_rv comp_dict_m_qve_spa_bi comp_desamb_qve comp_postgen comp_chunk_spa_qve comp_chunk_qve_spa final

log:
	if [ -e install_apertium_spa_qve.log ] then cp install_apertium_spa_qve.log install_apertium_spa_qve$(FOLDERNAME).log fi
	rm -f install_apertium_spa_qve.log

comp_dict_m_spa:
	#COMPILANDO DICCIONARIO MORFOLOGICO ESPAÑOL
	#valida el diccionario morfologico
	@apertium-validate-dictionary apertium-spa-qve.spa.dix	
	#compila el diccionario morfologico
	@lt-comp lr apertium-spa-qve.spa.dix spa-qve.automorf.bin  
	#COMPILANDO DICCIONARIO DE AUTOGENERACION PARA qve-spa EN SENTIDO CONTRARIO
	@lt-comp rl apertium-spa-qve.spa.dix qve-spa.autogen.bin

comp_dict_m_qve:
	#---------------------------------------------------------------------------------
	#COMPILANDO DICCIONARIO MORFOLOGICO QUECHUA  adaptado de kaz-tat   tat.lexc
	@cat apertium-spa-qve.qve.lexc | grep -v 'Dir/RL' > .deps/qve.LR.lexc
	#formatea con foma lexc
	@hfst-lexc --format foma .deps/qve.LR.lexc -o .deps/qve.LR.lexc.hfst
	#formatea con foma twol
	@hfst-twolc --format foma apertium-spa-qve.qve.twol -o .deps/qve.twol.hfst  
	#compone lexc y twol
	@hfst-compose-intersect -1 .deps/qve.LR.lexc.hfst -2 .deps/qve.twol.hfst -o .deps/qve.LR.hfst
	#crea el diccionario mofologico 
	@hfst-invert .deps/qve.LR.hfst | hfst-fst2fst -O -o qve-spa.automorf.hfst

comp_dict_m_qve_rv:
	#COMPILANDO DICCIONARIO DE AUTOGENERACION PARA spa-qve EN SENTIDO CONTRARIO
	@cat apertium-spa-qve.qve.lexc | grep -v 'Dir/LR' > .deps/qve.RL.lexc
	#formatea con forma lex a hfst
	@hfst-lexc --format foma .deps/qve.RL.lexc -o .deps/qve.RL.lexc.hfst	
	#formatea con forma twol a hfst
	@hfst-twolc --format foma apertium-spa-qve.qve.twol -o .deps/qve.twol.hfst 
	#compone lexc y twol
	@hfst-compose-intersect -1 .deps/qve.RL.lexc.hfst -2 .deps/qve.twol.hfst -o .deps/qve.RL.hfst
	#general el autogenerados
	@hfst-fst2fst -O .deps/qve.RL.hfst -o spa-qve.autogen.hfst
	#---------------------------------------------------------------------------------

comp_dict_m_qve_spa_bi:
	#COMPILANDO DICCIONARIO BILINGUE EN AMBAS DIRECCIONES
	#valida diccionario biningue
	@apertium-validate-dictionary apertium-spa-qve.spa-qve.dix  
	#genera el diccionar bilingue spa-qve
	@lt-comp rl apertium-spa-qve.spa-qve.dix spa-qve.autobil.bin
	#valida diccionario biningue
	@apertium-validate-dictionary apertium-spa-qve.spa-qve.dix
	#genera el diccionar bilingue qve-spa
	@lt-comp lr apertium-spa-qve.spa-qve.dix qve-spa.autobil.bin

comp_desamb_qve:
	#COMPILANDO DESAMBIGUADOR  QUECHUA
	#Vislcg3
	@cg-comp apertium-spa-qve.qve-spa.rlx qve-spa.rlx.bin	

comp_postgen:
	#GENERANDO POSTGENERACION
	@apertium-validate-dictionary apertium-spa-qve.post-spa.dix
	@lt-comp lr apertium-spa-qve.post-spa.dix qve-spa.autopgen.bin

comp_chunk_spa_qve:
	#COMPILANDO REGLAS DE REGISTRCCION CHUNK, INTERCKUNK Y POSTCHUNK spa-qve
	@apertium-validate-transfer apertium-spa-qve.spa-qve.t1x
	@apertium-preprocess-transfer apertium-spa-qve.spa-qve.t1x spa-qve.t1x.bin
	@apertium-validate-interchunk apertium-spa-qve.spa-qve.t2x
	@apertium-preprocess-transfer apertium-spa-qve.spa-qve.t2x spa-qve.t2x.bin
	@apertium-validate-postchunk apertium-spa-qve.spa-qve.t3x
	@apertium-preprocess-transfer apertium-spa-qve.spa-qve.t3x spa-qve.t3x.bin 

comp_chunk_qve_spa:
	#COMPILANDO REGLAS DE REGISTRCCION CHUNK, INTERCKUNK Y POSTCHUNK qve-spa
	@apertium-validate-transfer apertium-spa-qve.qve-spa.t1x
	@apertium-preprocess-transfer apertium-spa-qve.qve-spa.t1x qve-spa.t1x.bin
	@apertium-validate-interchunk apertium-spa-qve.qve-spa.t2x
	@apertium-preprocess-transfer apertium-spa-qve.qve-spa.t2x qve-spa.t2x.bin
	@apertium-validate-postchunk apertium-spa-qve.qve-spa.t3x
	@apertium-preprocess-transfer apertium-spa-qve.qve-spa.t3x qve-spa.t3x.bin 

final:
	@lrx-comp apertium-spa-qve.qve-spa.lrx qve-spa.autolex.bin
	@apertium-gen-modes modes.xml
	@cp *.mode modes/

