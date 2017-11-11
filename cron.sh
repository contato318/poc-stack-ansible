#!/bin/bash

CONF="bootstrap-cron.conf"
DIR="${BASH_SOURCE%/*}"
DIRETORIO_LOG_BOOTSTRAP=$DIRETORIO_BOOTSTRAP"logs/"


if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

for entry in "$DIR"/"$CONF" ; do
          if [ -f "$entry" ];then
             source "$entry"
         fi
done

if [ -z "${GRUPO_HOST}" ]; then
     echo "Não existe a variavel  GRUPO_HOST "
     exit
fi
if [ -z "${ARQUIVO_CHAVE_VAULT}" ]; then
     echo "Não existe a variavel  ARQUIVO_CHAVE_VAULT"
     exit
fi
if [ -z "${ENDERECO_GIT}" ]; then
     echo "Não existe a variavel ENDERECO_GIT"
     exit
fi




function msg_ambiente {
    /bin/echo "-" >> $CRON_LOG_DEBUG
    /bin/echo "-" >> $CRON_LOG

    /bin/echo "iniciando" >>$CRON_LOG
    /bin/echo "AMBIENTE:" >> $CRON_LOG
    /bin/echo $DIRETORIO_BOOTSTRAP >> $CRON_LOG
    /bin/echo $CRON_BOOTSTRAP >> $CRON_LOG
    /bin/echo $CRON_BOOTSTRAP_CONF >> $CRON_LOG
    /bin/echo $DIRETORIO_REPOS >> $CRON_LOG
    /bin/echo $CRON >> $CRON_LOG
    /bin/echo $CRON_CONF >> $CRON_LOG
    /bin/echo $GRUPO_HOST >> $CRON_LOG
    /bin/echo $ENDERECO_GIT >> $CRON_LOG
    /bin/echo $ARQUIVO_CHAVE_VAULT >> $CRON_LOG
    /bin/echo $CAMINHO_PLAYBOOK >> $CRON_LOG


}



function inicia {
   msg_ambiente
}

function limpa_log {

     #TODO: Colocar a limpeza de log para ocorrer apenas:
     #.     1) Se o espaço em disco estiver comprometido
     #.     2) Se existir mais de 7 dias de logs
     echo "-----"`/bin/date +"%m-%d-%y_%T"` - " INICIO limpeza log ------" >> $CRON_LOG
     
     /bin/find $DIRETORIO_LOG_BOOTSTRAP -mindepth 1 -mmin +30 -delete
     
     echo "-----"`/bin/date +"%m-%d-%y_%T"` - " FIM limpeza log ------" >> $CRON_LO 
}


function executa_playbook {
   echo "-----"`/bin/date +"%m-%d-%y_%T"` - " INICIO OUTPUT PLAYBOOK ------" >> $CRON_LOG
   local SAIDA=`/bin/ansible-pull --clean -i /etc/ansible/hosts -d $DIRETORIO_REPOS  -U $ENDERECO_GIT $CAMINHO_PLAYBOOK --vault-password-file $ARQUIVO_CHAVE_VAULT` 
   echo $SAIDA >> $CRON_LOG
   echo "-----"`/bin/date +"%m-%d-%y_%T"` - " FIM OUTPUT PLAYBOOK ------" >> $CRON_LOG
   
   
   limpa_log

}

function atualiza_cron {
   /bin/cp -f $CRON $CRON_BOOTSTRAP
}


function main {
    inicia
    executa_playbook
    atualiza_cron

}

main
