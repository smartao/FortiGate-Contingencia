#!/bin/bash

function MAIN(){
    # Criar funcao para mostrar o que seja fazer 1 para subir contingencia 2 para desativar
	DATA # Pegando a data atual
	CONFCOR # Configurando as variaveis com cor
	CARREGACONF # Carregando as configuracoes iniciais
	m1=0 # variavel para testar o primeiro while do primeiro meno
	while [ $m1 -ne 1 ]
	do
        MENU1 # funcao que chama o primeiro menu
		case $M1 in # validando a resposta dada ao menu1
		1) # Opcao para subir a contingencia
            m2=0 # variavel para testar o segundo while
			TIPO="ATIVAR" # variavel para mostrar msg ATIVA no menu2
	        CONFCOR # Configurando as variaveis com cor
            PRIO=42 # Reduzindo a prioridade da rota MPLS para ativar a contingencia via VPN
            while [ $m2 -ne 1 ]
			do
				CAPTURASITES #Capturando os sites disponiveis no diretorio
				MENU2 # Mostrando o menu 2
				VALIDAOPCAO2 # validando a opcao digida
			done
            GERASCRIPT # Funcao que gera script para iniciar contingencia
            EXECUTASCRIPT # Funcao que executa o script e ATIVA/DESATIVA contignencia
            m1=1 # variavel para saindo do primeiro while
        ;;
        2) # Opcao para desativar a contingencia
			m2=0 # funcao funcia exatamente como a de cima
			TIPO="DESATIVAR" # variavel para mostrar msg DESATIVA no menu2
	        CONFCOR # Configurando as variaveis com cor
            PRIO=0 # Aumentar a prioridade para sair da contingencia via VPN
            while [ $m2 -ne 1 ]
            do
                CAPTURASITES # Capturando os sites disponiveis no diretorio
                MENU2 # Mostrando o menu 2
                VALIDAOPCAO2 # validando a opcao digida
            done
            GERASCRIPT # Funcao que gera script para iniciar contingencia
            EXECUTASCRIPT # Funcao que executa o script e ATIVA/DESATIVA contingencia
            m1=1 # variavel para saindo do primeiro while
        ;;
        3) # Opcao para sair do programa
			m1=1
			exit;
			;;
		*) # Caso digitar uma opcao invalida
            MSGOPCAOINVALIDA # Apenas para mostrar que a opcao e invalida
            ;;
		esac
	done
    MSGFIM # Mensagem ao finalizar o script

}

function CARREGACONF(){
    PREF=script # Prefixo inicial dos scripts
    DIRCON=conexoes # Diretorio com o ID das rotas dos Fortigates
    DIRSCRIPT=scripts # Diretorio de scripts
    DIRLOG=logs # Diretorio de logs
	ARQLOG=$DIRLOG/script-contingencia.$DIA.log # Arquivo de logs
    mkdir -p $DIRSCRIPT > /dev/null 2>&1 # Criando de scripts
    mkdir -p $DIRLOG > /dev/null 2>&1 # Criando o diretorio de logs
}

function MENU1(){
	clear
	echo "#----------------- Script de VPN automatica ------------------#" | tee -a $ARQLOG
	echo -e "#--------------------$CAM $DATA $CF----------------------#" | tee -a $ARQLOG
	echo "#---------------------- MENU PRINCIPAL -----------------------#" | tee -a $ARQLOG
	echo "#-------------------------------------------------------------#" | tee -a $ARQLOG
	echo "# O que voce deseja fazer?                                     " | tee -a $ARQLOG
	echo "# 1 - Ativar a contigência em um site                          " | tee -a $ARQLOG
	echo "# 2 - Remover a contigência em um site                         " | tee -a $ARQLOG
	echo "# 3 - Sair                                                     " | tee -a $ARQLOG
	read -p "# R: " M1 # capturando o que digitar na tela
	echo "# R: $M1" >> $ARQLOG
}

function MENU2(){
	clear
	echo "" | tee -a $ARQLOG
	echo "#-------------------------------------------------------------#" | tee -a $ARQLOG
	echo -e "# Por favor informe o site que deseja ${COR}$TIPO${CF} a contingencia     " | tee -a $ARQLOG
        for((a=1;a<=${#SITE[@]};a++));
        do
		echo "# [$a] ${SITE[$a]}" | tee -a $ARQLOG # Mostrando as opcoes disponiveis
        done
	read -p "# R: " CAIDO
	echo "# R: $CAIDO" >> $ARQLOG # capturando o que digitar na tela
	echo "" | tee -a $ARQLOG		
}

function MSGFIM(){
	DATA
	echo ""	| tee -a $ARQLOG
	echo "#-------------------- Script Finalizado ----------------------#" | tee -a $ARQLOG
	echo -e "#--------------------$CAM $DATA $CF----------------------#" | tee -a $ARQLOG # Mostrando a data na tela
    echo -e "#Executando com sucesso script para ${COR}$TIPO${CF} contingencia" | tee -a $ARQLOG
	echo -e "\n\n"	| tee -a $ARQLOG
}

function CAPTURASITES(){ 
	a=1
	for i in `ls $DIRCON | cut -d- -f1 | sort | uniq` # Capturar todos os arquivos com final .redes transoformando em opcao
	do
		SITE[$a]=$i
		let a=$a+1
	done
}

function VALIDAOPCAO2(){ # Validando o que foi digitado no menu 2
	for((a=1;a<=${#SITE[@]};a++));
    do
		if [ $CAIDO == $a ];then # se o numero digitado estiver dentro do contado do vetor
		 	m2=1 # entao ele sai do segundo while
            sitefora=${SITE[$CAIDO]} # Capturando o site q caiu
		fi
    done
	if [ $m2 != 1 ];then # Caso tenha digita uma opcao invalida
		MSGOPCAOINVALIDA
	fi
} 
function GERASCRIPT(){

    ARQFINAL=$TIPO-ctg-$sitefora.sh
    echo "" | tee -a $ARQLOG
    echo "#-------------------------------------------------------------#" | tee -a $ARQLOG
    echo "#Gerando arquivo de script contingencia" | tee -a $ARQLOG

    echo "#!/bin/bash" > $ARQFINAL
    for arq in $(ls $DIRCON | grep -i $sitefora) # Coletando arquivo que precisa ser modificados
    do
        IP=$(cat $DIRCON/$arq |head -n 1 | tail -n 1)
        PORTA=$(cat $DIRCON/$arq |head -n 2 | tail -n 1)
        ARQROTAS=$PREF-$arq.sh
       
        # Gerando arquivo para subir a contingencia no site $arq
        echo "$DIRSCRIPT/$ARQROTAS" | tee -a $ARQLOG

        echo "#!/bin/bash" > $DIRSCRIPT/$ARQROTAS # Cabeçalho do script
        echo "ssh -p $PORTA admin@$IP << EOF" >> $DIRSCRIPT/$ARQROTAS # Conectando no FW via ssh
        echo "config router static" >> $DIRSCRIPT/$ARQROTAS # Comando fortigate de rotas
        for rota in $(cat $DIRCON/$arq | grep -i ^edit | cut -d" " -f 2)
        do 
            echo "edit $rota" >> $DIRSCRIPT/$ARQROTAS # Editando a rota
            echo "set priority $PRIO" >> $DIRSCRIPT/$ARQROTAS # Alterando a prioridade da rota
            echo "show" >> $DIRSCRIPT/$ARQROTAS # Mostrando as modificaoes realizadas
            echo "next" >> $DIRSCRIPT/$ARQROTAS # Passando para a proxima rota
        done
        echo "end" >> $DIRSCRIPT/$ARQROTAS # Saindo das conf de roteamento
        echo "exit" >> $DIRSCRIPT/$ARQROTAS # Saindo do fortigate
        echo "EOF" >> $DIRSCRIPT/$ARQROTAS # Fechando bloco de comandos enviado para o FW
        

        # Gerando o script central para executar os demais scripts
        echo "chmod 755 $DIRSCRIPT/$ARQROTAS" >> $ARQFINAL
        echo "$DIRSCRIPT/./$ARQROTAS" >> $ARQFINAL
        echo "sleep 2" >> $ARQFINAL
    done
    sleep 2
    clear
}
function EXECUTASCRIPT(){ # funcao para executar o script gerado
    echo "" | tee -a $ARQLOG 
    echo "#-------------------------------------------------------------#" | tee -a $ARQLOG
    echo -e "#Executando o script para ${COR}$TIPO${CF} contingencia" | tee -a $ARQLOG
    echo "#Arquivo: $ARQFINAL" | tee -a $ARQLOG
    echo "" | tee -a $ARQLOG 
    sleep 2
    chmod 755 $ARQFINAL # Ajustando permissoes do script
    ./$ARQFINAL | tee -a $ARQLOG # Executando o script e assim ativando/desativando contingencia
    echo "#Deletar arquivo: $ARQFINAL" | tee -a $ARQLOG
    rm $ARQFINAL # Removendo arquivo que foi criado
}

function DATA(){ # Configurando data para a tela e log
	DIA=`date "+%y%m%d"` > /dev/null # Data yymmdd
	HORA=`date "+%H:%M:%S"` > /dev/null # Hora hh:mm:ss
	DATA="$DIA - $HORA" # Juntando DIA e HORA
}

function CONFCOR(){ # Configurando variaveis com cor
	CVE='\e[1;31m' # Red Bold
	CVD='\e[1;32m' # Verde Bold
	CAM='\e[1;33m' # Yellow Bold
	CAZ='\e[1;34m' # Blue Bold
    CF='\e[0m'    # Tag end
    if [ $TIPO == "ATIVAR" ];then
	    COR='\e[1;31m' # Red Bold
    else 
	    COR='\e[1;34m' # Blue Bold
    fi
}

function MSGOPCAOINVALIDA(){
	echo -e "\n ${CVE}Entre com uma opcao valida!${CF}" | tee -a $ARQLOG 
	echo -e "Precione qualquer tecla para voltar..." | tee -a $ARQLOG
	read 
}

MAIN #Funcao principal que inicia o script
exit;
