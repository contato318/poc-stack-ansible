#!/bin/bash

DIRETORIO_RAIZ="/tmp"
LOG=$DIRETORIO_RAIZ"/stack-`hostname -f`-`/bin/date +"%m-%d-%y_%T"`.log"
LOG_DEBUG=$DIRETORIO_RAIZ"/stack-`hostname -f`-`/bin/date +"%m-%d-%y_%T"`-DEBUG.log"
SERVIDOR=`hostname -f`

##### CONF DO USUARIO DE ACESSO REMOTO #####
USUARIO="U2FsdGVkX1+wuJKwUztG+Gb0okH2neXZXdJR48/Aojw="

SENHA="U2FsdGVkX18IXzjjiDxxgUR7q+umxCqypj2T8pjM/EWTFjIfyIODlzRzRKg2gWVl"

SENHA_SALT="U2FsdGVkX18UjBO0VQQjujh9tw1ATCxDcnn9ICIHYss="

CHAVE_PRIVADA="U2FsdGVkX19j+MlmZ0SdnzBdTJwmBY+iT0UnIwftLcyLi4PQt7q53pjiWGYxa1g4
08BAwUR4UEHwIm05Vhh5N87hbNJ2rnlpi0di2DQgONA="

CHAVE_PUBLICA="U2FsdGVkX186QNzX8yxIE+pqc5orf+iym5wlfEDLgTuOjLSOIIuy4s8yr+kAs0XX
7pNgLdkAlmVrQsRdRwShP8VJ1ruPJBpO0tlY/korUMOMu60Ndx1fegBlJ9peoPVf"


##### CONF DO TELEGRAM ######
MENSAGEM="Segundo teste"

CHAT_ID="U2FsdGVkX1+HY3UuxKZAKr65eTx9DtZmhHsZ/jU9hK8="

URL_SEND_TELEGRAM="U2FsdGVkX1/Gxzw5syv4UijPn682ipL5pJHQvTQYs6Wzd5NJOz0C43Z+psLOD5Zu
FsLR0oK429pK6Fk/ay4Ze7nHoVegf5qWu4JvVqbjG3xl1RfjTkO0tRAoquuePWhK
BUWZDdfy4CZlahVIlYogPw=="


URL_DOCUMENT_TELEGRAM="U2FsdGVkX1/IpkctX13zhWRK9bOK4lbQXTp7izfOPXiPUPsKIHh2m/11KsngUjqK
reHYmnZE/R1tR2/tsOiEo3b/7ArZ6Fd/VZeYBBoyL0Hl9HVEx+mx4QOJFTZRkZLr
mR3UpfgJoF76G81JHEjCDw=="

TELEGRAM_DOCUMENTO=""


#### PEGANDO OS PARAMETROS #####
HOST_TIPO=$1
CHAVE_CRIPTOGRAFIA=$2
HOST_IP_PUBLICO=`curl 'https://api.ipify.org?format=txt'`
SERVIDOR_INFO="SERVIDOR: $HOST_TIPO -  $HOST_IP_PUBLICO (externo) - $SERVIDOR"

function descriptgrafa () {
    USUARIO=`echo $USUARIO | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    SENHA=`echo $SENHA | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    SENHA_SALT=`echo $SENHA_SALT | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    CHAVE_PRIVADA=`echo $CHAVE_PRIVADA | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    CHAVE_PUBLICA=`echo $CHAVE_PUBLICA | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    CHAT_ID=`echo $CHAT_ID | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    URL_SEND_TELEGRAM=`echo $URL_SEND_TELEGRAM | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
    URL_DOCUMENT_TELEGRAM=`echo $URL_DOCUMENT_TELEGRAM | openssl enc -d -a -aes256 -pass pass:$CHAVE_CRIPTOGRAFIA`
 
}


function valida_usuario () {
    if id "$USUARIO" >/dev/null 2>&1; then
        echo "usuario já existe" >> $LOG_DEBUG
    else
        criar_usuario
   fi
}

function criar_usuario () {
   MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - Iniciando criação do usuário '$usuario' no $SERVIDOR."
     send_msg $MENSAGEM
   useradd -m -p $SENHA_SALT $USUARIO && (MENSAGEM="SERVIDOR $SERVIDOR_INFO - criado o usuario $USUARIO" && send_msg $MENSAGEM ) || ( MENSAGEM="SERVIDOR $SERVIDOR_INFO - ERRO!!! ao criar usuario $USUARIO - saindo" && send_msg $MENSAGEM && exit 1 )

  wget $CHAVE_PUBLICA -O /tmp/chave_publica.pub && (MENSAGEM="SERVIDOR $SERVIDOR_INFO - download da chave" && send_msg $MENSAGEM ) || ( MENSAGEM="SERVIDOR $SERVIDOR_INFO - ERRO!!! download da chave - saindo" && send_msg $MENSAGEM && exit 1 )

   (mkdir /home/$USUARIO/.ssh 
   chmod 700 /home/$USUARIO/.ssh 
   touch /home/$USUARIO/.ssh/authorized_keys
   chmod 600 /home/$USUARIO/.ssh/authorized_key
   cat /tmp/chave_publica.pub >> /home/$USUARIO/.ssh/authorized_keys
   chown $USUARIO.$USUARIO /home/$USUARIO/.ssh/authorized_keys
   chown $USUARIO.$USUARIO -R /home/$USUARIO/
   echo -e "$SENHA\n$SENHA" | (passwd root) ) && (MENSAGEM="SERVIDOR $SERVIDOR_INFO - acesso remoto configurado " && send_msg $MENSAGEM ) || ( MENSAGEM="SERVIDOR $SERVIDOR_INFO - ERRO!!! Acesso remoto nao configurado - saindo" && send_msg $MENSAGEM && exit 1 )
   

   MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - FOI CRIADO O '$USUARIO' no $SERVIDOR. Para acessar:

     <code>
     SERVIDOR: $HOST_NOME
     TIPO DE HOST: $HOST_TIPO
     ENDERECO DO SERVIDOR: $HOST_IP_PUBLICO
     CHAVE PARA ACESSO: $CHAVE_PRIVADA
     USUARIO REMOTO: $USUARIO
     SENHA: $SENHA
     Obs.: A senha do root é a mesma.
     </code>
     
     "
     send_msg $MENSAGEM


}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function verifica_dados_entrada() {
    local saida=0
    if [ -z "${HOST_TIPO}" ]; then
     saida=1
     MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - TIPO DO HOST NAO INFORMADO PARA O  $SERVIDOR"
     send_msg $MENSAGEM
    
    else
     MENSAGEM="$SERVIDOR  - IP PUBLICO $HOST_IP_PUBLICO: Tipo de host <b> $HOST_TIPO </b>"
     send_msg $MENSAGEM
    fi

    if [ -z "${HOST_IP_PUBLICO}" ]; then
     saida=1
     MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - IP PUBLICO NAO INFORMADO  $SERVIDOR"
     send_msg $MENSAGEM
    fi

    if valid_ip $HOST_IP_PUBLICO
   then 
        MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - IP PUBLICO $HOST_IP_PUBLICO validado....    $SERVIDOR"
        send_msg $MENSAGEM
    else 
        saida=1
        MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - IP PUBLICO $HOST_IP_PUBLICO ERRADO!!!!!! -   $SERVIDOR"
        send_msg $MENSAGEM
    fi


   if [  $saida -eq 1   ]; then
     MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - Finalizando o script  $SERVIDOR, por falta de variáveis."
     send_msg $MENSAGEM
    exit 10
   fi
    
}

function send_msg() {
   
    echo $MENSAGEM >> $LOG
    MENSAGEM_SAIDA="
   <b> $SERVIDOR_INFO</b>
   =================== 
    $MENSAGEM
    "
    curl --data chat_id=$CHAT_ID --data parse_mode=html --data-urlencode "text=$MENSAGEM_SAIDA"  $URL_SEND_TELEGRAM
}

function send_document(){
   curl -s -X POST $URL_DOCUMENT_TELEGRAM -F chat_id=$CHAT_ID -F document=\@$1
}

function inicio {
   echo "-" >> $LOG_DEBUG
   echo "-" >> $LOG

   MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - INICIO DA EXECUCAO no SERVIDOR - $SERVIDOR"
   send_msg $MENSAGEM

  
  
}

function fim {
   MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - FIM DA EXECUCAO no SERVIDOR - $SERVIDOR"
   send_msg $MENSAGEM
   
   send_document $LOG
   send_document $LOG_DEBUG
}



function install_ansible {

      if [ ! $(which ansible-playbook) ]; then
        MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - NAO EXISTE ANSIBLE INSTALADO NO SERVIDOR $SERVIDOR"       
        send_msg $MENSAGEM
        if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ] || grep -q 'Amazon Linux' /etc/system-release; then
          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR é um centos ou derivado
          INSTALANDO certificanos e nss"
          send_msg $MENSAGEM
          rm -rf  /var/cache/yum
          yum -y install ca-certificates nss


          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO Epel "
          send_msg $MENSAGEM
          yum -y install epel-release


          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO python-pip PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko git "
          send_msg $MENSAGEM
          yum -y install python-pip PyYAML python-jinja2 python-httplib2 python-keyczar python-paramiko git
          
          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR VERIFICANDO pip e easy_install "
          send_msg $MENSAGEM
          if [ -z "$(which pip)" -a -z "$(which easy_install)" ]; then
            MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO pip  e easy_install"
           send_msg $MENSAGEM
            yum -y install python-setuptools
            easy_install pip
          elif [ -z "$(which pip)" -a -n "$(which easy_install)" ]; then
            MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO pip "
            send_msg $MENSAGEM
            easy_install pip
          fi

           MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO python-devel MySQL-python sshpass && pip install pyrax pysphere boto passlib dnspython e Development tools "
           send_msg $MENSAGEM
          yum -y groupinstall "Development tools"
          yum -y install python-devel MySQL-python sshpass && pip install pyrax pysphere boto passlib dnspython

         MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR 
         INSTALANDO Ansible e dependencias
         INSTALANDO bzip2 file findutils git gzip hg svn sudo tar which unzip xz zip libselinux-python"
           send_msg $MENSAGEM
          yum -y install bzip2 file findutils git gzip hg svn sudo tar which unzip xz zip libselinux-python
          [ -n "$(yum search procps-ng)" ] && yum -y install procps-ng || yum -y install procps
        elif [ -f /etc/debian_version ] || [ grep -qi ubuntu /etc/lsb-release ] || grep -qi ubuntu /etc/os-release; then
          
         MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - O HOST:$SERVIDOR é um Debian ou derivado
          - Realizando update dos pacotes"
          send_msg $MENSAGEM
          apt-get update
          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO python-pip python-yaml python-jinja2 python-httplib2 python-paramiko python-pkg-resources"
           send_msg $MENSAGEM
          apt-get install -y  python-pip python-yaml python-jinja2 python-httplib2 python-paramiko python-pkg-resources
          [ -n "$( apt-cache search python-keyczar )" ] && apt-get install -y  python-keyczar
          if ! apt-get install -y git ; then
            MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO git"
           send_msg $MENSAGEM
            apt-get install -y git-core
          fi
          if [ -z "$(which pip)" -a -z "$(which easy_install)" ]; then
            MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO easy_install e pip"
           send_msg $MENSAGEM
            apt-get -y install python-setuptools
            easy_install pip
          elif [ -z "$(which pip)" -a -n "$(which easy_install)" ]; then
            easy_install pip
          fi
          # If python-keyczar apt package does not exist, use pip
          [ -z "$( apt-cache search python-keyczar )" ] && sudo pip install python-keyczar

          # Install passlib for encrypt
          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO build-essential python-all-dev python-mysqldb sshpass && pip install pyrax pysphere boto passlib dnspython"
           send_msg $MENSAGEM
          apt-get install -y build-essential
          apt-get install -y python-all-dev python-mysqldb sshpass && pip install pyrax pysphere boto passlib dnspython

          # Install Ansible module dependencies
          MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - HOST: $SERVIDOR INSTALANDO bzip2 file findutils git gzip mercurial procps subversion sudo tar debianutils unzip xz-utils zip python-selinux"
           send_msg $MENSAGEM
          apt-get install -y bzip2 file findutils git gzip mercurial procps subversion sudo tar debianutils unzip xz-utils zip python-selinux

        else
          echo `/bin/date +"%m-%d-%y_%T"`" - WARN: Could not detect distro or distro unsupported" >> $LOG
          echo `/bin/date +"%m-%d-%y_%T"`" - WARN: Trying to install ansible via pip without some dependencies" >> $LOG
          echo `/bin/date +"%m-%d-%y_%T"`" - WARN: Not all functionality of ansible may be available" >> $LOG
        fi

        mkdir /etc/ansible/
        echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts
        MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - $SERVIDOR INSTALANDO o ANSIBLE"
           send_msg $MENSAGEM
        pip install ansible

        if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ] || grep -q 'Amazon Linux' /etc/system-release; then
          # Fix for pycrypto pip / yum issue
          # https://github.com/ansible/ansible/issues/276
          if  ansible --version 2>&1  | grep -q "AttributeError: 'module' object has no attribute 'HAVE_DECL_MPZ_POWM_SEC'" ; then
            echo `/bin/date +"%m-%d-%y_%T"` " - WARN: Re-installing python-crypto package to workaround ansible/ansible#276" >> $LOG
            echo `/bin/date +"%m-%d-%y_%T"` " - WARN: https://github.com/ansible/ansible/issues/276" >> $LOG
             MENSAGEM=`/bin/date +"%m-%d-%y_%T"`" - $SERVIDOR INSTALANDO pycrypt"
           send_msg $MENSAGEM
            pip uninstall -y pycrypto
            yum erase -y python-crypto
            yum install -y python-crypto python-paramiko
          fi
        fi

      fi
}

function main {
    descriptgrafa >> $LOG_DEBUG 2>&1
    inicio >> $LOG_DEBUG 2>&1
    verifica_dados_entrada >> $LOG_DEBUG 2>&1
    valida_usuario >> $LOG_DEBUG 2>&1
    #criar_usuario >> $LOG_DEBUG 2>&1
    install_ansible  >> $LOG_DEBUG 2>&1

    fim
}

main
