#!/bin/bash
function creaUsuario (){
    echo "el fichero vars hay que copiarlo en /home/USUARIO"
    echo "Antes de comenzar.... Introduce nombre del usuario que usas en el sistema"
    read -p "Dime el usuario del sistema: " usuario
    echo $usuario
}

function limpiarResiduales()
function generaArchivo (){
    echo $usuario
    rm instrucciones.txt
    touch /home/$usuario/instrucciones.txt
    echo "script CA - ejecutar como root" >> /home/$usuario/instrucciones.txt
    
    echo "Generando archivo instrucciones" >> /home/$usuario/instrucciones.txt
    echo 'touch /home/$usuario/instrucciones.txt' >> /home/$usuario/instrucciones.txt
}

function instalaEasyRSA (){
    apt install openvpn easy-rsa
    echo "Instalando Easy-RSA" >> /home/$usuario/instrucciones.txt
    echo "apt install openvpn easy-rsa" >> /home/$usuario/instrucciones.txt
}

function creaEstructura (){
    echo "Creando Estructura" >> instruccciones.txt
    echo `mkdir -p /home/$usuario/ca/easy-rsa`
    echo 'mkdir -p /home/$usuario/ca/easy-rsa' >> /home/$usuario/instrucciones.txt
    echo "Creando enlace simbólico con Easy-rsa" >> /home/$usuario/instruccciones.txt
    ln -s /usr/share/easy-rsa/* ca/easy-rsa/
    echo 'ln -s /usr/share/easy-rsa/* ca/easy-rsa/' >> /home/$usuario/instrucciones.txt
    
}

function permisosRoot (){
    echo "Permisos para el usuario root" >> /home/$usuario/instrucciones.txt;
    echo 'chmod -R 700 /home/$usuario/ca/easy-rsa/' >> /home/$usuario/instrucciones.txt;
    chmod -R 700 /home/$usuario/ca/easy-rsa/
}


function creaEntidadCertificacion (){
    echo "Creando una entidad de certificación" >> /home/$usuario/instrucciones.txt;
    echo "cd /home/$usuario/ca/easy-rsa/" >> /home/$usuario/instrucciones.txt;
    
    cd /home/$usuario/ca/easy-rsa/
    
    ./easyrsa init-pki
    echo "./easyrsa init-pki" >> /home/$usuario/instrucciones.txt
    echo "ls -la pki/"
    ls -la pki/
    
    cp /home/$usuario/vars /home/$usuario/ca/easy-rsa/
    echo "cp /home/$usuario/vars /home/$usuario/ca/easy-rsa/" >> /home/$usuario/instrucciones.txt
    
    echo "Vamos a crear el par de claves privada y pública" >> /home/$usuario/instrucciones.txt
    ./easyrsa build-ca
    echo "./easyrsa build-ca" >> instrucciones.txt
    
    echo "Comprobamos la generación del fichero público del certificado" >> /home/$usuario/instrucciones.txt
    echo "cat /home/$usuario/ca/easy-rsa/pki/ca.crt" >> /home/$usuario/instrucciones.txt
    cat /home/$usuario/ca/easy-rsa/pki/ca.crt
    
    echo "Comprobamos la generación del fichero privado del certificado" >> /home/$usuario/instrucciones.txt
    echo "cat /home/$usuario/ca/easy-rsa/pki/private/ca.key" >> /home/$usuario/instrucciones.txt
    cat /home/$usuario/ca/easy-rsa/pki/private/ca.key
    
    echo "Hacemos una copia del certificado Raíz" >> /home/$usuario/instrucciones.txt
    cd ..
    mkdir raiz
    cd /home/$usuario/ca/easy-rsa/pki/
    cp /home/$usuario/ca/easy-rsa/pki/ca.crt ../raiz/
    echo "creamos directorio raiz en /home/USUARIO/ca/easy-rsa/raiz" >> /home/$usuario/instrucciones.txt
    echo 'cp /home/$usuario/ca/easy-rsa/pki/ca.crt ../raiz/' >> /home/$usuario/instrucciones.txt
}

function distrubuirCertificadoRaizADestino (){
    echo "IP equipo destino: "
    read -p "destino" destino;
    
    echo "Ruta del equipo destino: "
    read -p "rutafich" rutafich;
    
    echo "Usuario destino: "
    read -p "usuariodestino" usuariodestino;
    
    scp /home/$usuario/ca/easy-rsa/raiz/ca.crt $usuariodestino@$destino:$rutafich
    echo 'scp /home/$usuario/ca/easy-rsa/raiz/ca.crt $usuariodestino@$destino:$rutafich' >> /home/$usuario/
}

function creaCARaiz (){
    creaUsuario
    generaArchivo
    instalaEasyRSA
    creaEstructura
    permisosRoot
    creaEntidadCertificacion
    echo "¿Distribuir fichero s/n?:"
    read -p "distF" distF;
    
    if [[  "$distF" == "s"  ]];
    then
        distrubuirCertificadoRaizADestino;
        echo "Fichero distribuido en la carpeta raiz";
        cat /home/$usuario/ca/easy-rsa/raiz/ca.crt
    else
        if [ "$distF" = "n" ];
        then
            echo "Creado certificado Sin Distribuir"
            cat /home/$usuario/ca/easy-rsa/raiz/ca.crt
        fi
    fi
}

#creaCARaiz
creaUsuario