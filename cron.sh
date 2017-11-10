#!/bin/bash

CONF="bootstrap-cron.conf"
DIR="${BASH_SOURCE%/*}"

if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

for entry in "$DIR"/"$CONF" ; do
          if [ -f "$entry" ];then
             source "$entry"
         fi
done


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


function executa_playbook {
   local SAIDA=`/bin/ansible-pull --clean -i /etc/ansible/hosts -d $DIRETORIO_REPOS  -U $ENDERECO_GIT $CAMINHO_PLAYBOOK --vault-password-file $ARQUIVO_CHAVE_VAULT` 
   echo "----- INICIO OUTPUT PLAYBOOK ------" >> $CRON_LOG
   echo $SAIDA >> $CRON_LOG
   echo "----- FIM OUTPUT PLAYBOOK ------" >> $CRON_LOG

}

function atualiza_cron {
   /bin/mv -f $CRON $CRON_BOOTSTRAP
}

function main {
    inicia
    executa_playbook
    atualiza_cron

}

main
