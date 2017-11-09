#!/bin/bash

source cron.conf

DIRETORIO_RAIZ="/opt"
DIRETORIO_REPOSITORIO="poc-stack-ansible"
DIRETORIO_LOG="$DIRETORIO_RAIZ/$DIRETORIO_REPOSITORIO/log"
SERVIDOR=`hostname -f`
LOG="$DIRETORIO_LOG/stack-`hostname -f`-`/bin/date +"%m-%d-%y_%T"`.log"
LOG_DEBUG="$DIRETORIO_LOG/stack-`hostname -f`-`/bin/date +"%m-%d-%y_%T"`-DEBUG.log"


echo $DIRETORIO_RAIZ
echo $DIRETORIO_REPOSITORIO
echo $DIRETORIO_LOG

echo $SERVIDOR

echo $LOG
echo $LOG_DEBUG




