#!/bin/bash

function usuario(){
    echo "Antes de comenzar.... Introduce nombre del usuario que usas en el sistema";
    echo "el fichero vars hay que copiarlo en /home/USUARIO"
    read -p "USUARIO" USUARIO;
    return $USUARIO;
}
function generaArchivo($USUARIO){
    echo "script CA - ejecutar como root" >> instrucciones.txt
    rm "instrucciones.txt"
    echo "Generando archivo instrucciones" >> instrucciones.txt
    echo 'touch /home/$USUARIO/instrucciones.txt' >> instrucciones.txt
    echo `touch /home/$USUARIO/instrucciones.txt`
   
    
}

function instalaEasyRSA(){
    echo `apt install openvpn easy-rsa`;
    echo "Instalando Easy-RSA" >> instrucciones.txt
    echo "apt install openvpn easy-rsa" >> instrucciones.txt
}

function creaEstructura($USUARIO){
    echo "Creando Estructura" >> instruccciones.txt
    echo `mkdir -p /home/$USUARIO/ca/easy-rsa`;
    echo 'mkdir -p /home/$USUARIO/ca/easy-rsa' >> instrucciones.txt
    echo "Creando enlace simbólico con Easy-rsa" >> instruccciones.txt
    echo `ln -s /usr/share/easy-rsa/* ca/easy-rsa/`;
    echo 'ln -s /usr/share/easy-rsa/* ca/easy-rsa/' >> instrucciones.txt

}

function permisosRoot($USUARIO){
    echo "Permisos para el usuario root" >> instrucciones.txt;
    echo 'chmod -R 700 /home/$USUARIO/ca/easy-rsa/' >> instrucciones.txt;
    echo `chmod -R 700 /home/$USUARIO/ca/easy-rsa/`;
}


function creaEntidadCertificacion($USUARIO){
    echo "Creando una entidad de certificación" >> instrucciones.txt;
    echo "cd /home/$USUARIO/ca/easy-rsa/" >> instrucciones.txt;

    echo `cd /home/$USUARIO/ca/easy-rsa/`;

    echo `./easyrsa init-pki`;
    echo "./easyrsa init-pki" >> instrucciones.txt
    echo "ls -la pki/"
    echo `ls -la pki/`

    echo `cp /home/$USUARIO/vars /home/$USUARIO/ca/easy-rsa/`
    echo "cp /home/$USUARIO/vars /home/$USUARIO/ca/easy-rsa/" >> instrucciones.txt

    echo "Vamos a crear el par de claves privada y pública" >> instrucciones.txt
    echo `./easyrsa build-ca`
    echo "./easyrsa build-ca" >> instrucciones.txt

    echo "Comprobamos la generación del fichero público del certificado" >> instrucciones.txt
    echo "cat /home/$USUARIO/ca/easy-rsa/pki/ca.crt" >> instrucciones.txt
    echo `cat /home/$USUARIO/ca/easy-rsa/pki/ca.crt`

    echo "Comprobamos la generación del fichero privado del certificado" >> instrucciones.txt
    echo "cat /home/$USUARIO/ca/easy-rsa/pki/private/ca.key" >> instrucciones.txt
    echo `cat /home/$USUARIO/ca/easy-rsa/pki/private/ca.key`

    echo "Hacemos una copia del certificado Raíz" >> instrucciones.txt
    cd ..
    mkdir raiz
    echo `cd /home/$USUARIO/ca/easy-rsa/pki/ `
    echo cp /home/$USUARIO/ca/easy-rsa/pki/ca.crt ../raiz/
    echo "creamos directorio raiz en /home/USUARIO/ca/easy-rsa/raiz" >> instrucciones.txt
    echo "cp /home/USUARIO/ca/easy-rsa/pki/ca.crt ../raiz/" >> instrucciones.txt

}

distrubuirCertificadoRaizADestino($USUARIO){
    echo "IP equipo destino"
    read -p "DESTINO" DESTINO;

    echo "Ruta del equipo destino"
    read -p "RUTAFICH" RUTAFICH;

    echo "Usuario destino"
    read -p "USUARIODESTINO" USUARIODESTINO;

    echo `scp /home/$USUARIO/ca/easy-rsa/raiz/ca.crt $USUARIODESTINO@$DESTINO:$RUTAFICH`
    echo "scp /home/$USUARIO/ca/easy-rsa/raiz/ca.crt $USUARIODESTINO@$DESTINO:$RUTAFICH" >> instrucciones.txt
}

function creaCARaiz(){
    $USUARIO=usuario();
    generaArchivo($USUARIO);
    instalaEasyRSA();
    creaEstructura($USUARIO);
    permisosRoot($USUARIO);
    creaEntidadCertificacion($USUARIO);
    echo "¿Distribuir fichero s/n?:"
    read -p "distF" distF;

    if [ "$distF" = "s" ];
    then
        distrubuirCertificadoRaizADestino($USUARIO);
        echo "Fichero distribuido en la carpeta raiz";
        echo `cat /home/$USUARIO/ca/easy-rsa/raiz/ca.crt`;
    else
        if [ "$distF" = "n" ];
        then  
            echo "Creado certificado Sin Distribuir";
            /home/$USUARIO/ca/easy-rsa/raiz/ca.crt
        fi
    fi
}

creaCARaiz();

