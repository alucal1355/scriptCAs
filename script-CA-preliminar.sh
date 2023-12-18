#!/bin/bash

function creaUsuario () {
	echo "Necesito el nombre del usuario del sistema para continuar"
	read -p "Dime usuario sistema:" usuario
	echo "el fichero vars hay que copiarlo en /home/$usuario"
}
function generaArchivo(){
	echo $usuario
	touch /home/$usuario/instrucciones.txt
	echo "Se ha creado fichero instrucciones"
	echo "Generando archivo instrucciones" >> /home/$usuario/instrucciones.txt
	echo 'touch /home/$usuario/instrucciones.txt'
}
function limpiar(){
	rm /home/$usuario/instrucciones.txt
	rm -rf /home/$usuario/ca/
	apt purge easy-rsa
	rm -rf /home/$usuario/raiz/
}

function instalarEasyRSA (){
	apt install openvpn easy-rsa
	echo "Instalando EasyRSA " >> /home/$usuario/instrucciones.txt
	echo 'apt install openvpn easy-rsa' >> /home/$usuario/instrucciones.txt
}
function creaEstructura(){
	mkdir -p /home/$usuario/ca/easy-rsa/
	ln -s /usr/share/easy-rsa/* /home/$usuario/ca/easy-rsa/

	echo "Creando estructura" >> /home/$usuario/instrucciones.txt
	echo 'mkdir -p /home/$usuario/ca/easy-rsa'
	echo "Creando enlace simbólico - acceso directo"
	echo 'ln -s /usr/share/easy-rsa/* ca/easy-rsa/' >> /home/$usuario/instrucciones.txt
	
}
function permisosRoot(){
	chmod -R 700 home/$usuario/ca/easy-rsa/
	echo "Permisos para el usuario root" >> /home/$usuario/instrucciones.txt
	echo 'chmod -R 700 home/$usuario/ca/easy-rsa/'
}
function creaEntidadCertificacion(){
	cd /home/$usuario/ca/easy-rsa/
	./easyrsa init-pki
	ls -la pki/
	cp /home/$usuario/vars /home/$usuario/ca/easy-rsa/
	./easyrsa build-ca
	echo "Clave pública"
	cat /home/$usuario/ca/easy-rsa/pki/ca.crt
	echo "Clave privada"
	cat /home/$usuario/ca/easy-rsa/pki/private/ca.key
	echo "Hacemos copia del certificado raiz"
	mkdir /home/$usuario/raiz
	cp /home/$usuario/ca/easy-rsa/pki/ca.crt /home/$usuario/raiz/ca.crt
	
	echo "Creando una entidad de certificación" >> /home/$usuario/instrucciones.txt
	echo 'cd /home/$usuario/ca/easy-rsa/' >> /home/$usuario/instrucciones.txt
	echo './easyrsa init-pki' >> /home/$usuario/instrucciones.txt
	echo 'ls -la pki/'
	echo "Copiamos el contenido de vars a home/$usuario/ca/easy-rsa" >> /home/$usuario/instrucciones.txt
	echo "Creamos el par de claves privada y pública" >> /home/$usuario/instrucciones.txt
	echo './easyrsa build-ca' >> /home/$usuario/instrucciones.txt
	echo 'cat /home/$usuario/ca/easy-rsa/pki/ca.crt'
	echo 'cat /home/$usuario/ca/easy-rsa/pki/private/ca.key'
	echo "Hacemos copia del certificado raiz" >> /home/$usuario/instrucciones.txt
	echo 'mkdir /home/$usuario/raiz'
	echo 'cp /home/$usuario/ca/easy-rsa/pki/ca.crt /home/$usuario/raiz/'
	

}

function distribuirCerticado(){
	read -p "IP Equipo destino: " ipDestino
	read -p "Ruta completa Equipo destino: " rutaFich
	read -p "Usuario de IP destino: " usuarioDestino

	scp /home/$usuario/raiz/ca.crt $usuarioDestino@$ipDestino:$rutaFich

	echo "scp /home/$usuario/raiz/ca.crt $usuarioDestino@$ipDestino:$rutaFich" >> /home/$usuario/instrucciones.txt
}

function creaCARaiz(){
	creaUsuario
	limpiar
	generaArchivo
	instalarEasyRSA
	creaEstructura
	permisosRoot
	creaEntidadCertificacion
	echo "¿Quieres distribuir a otro equipo el certificado?- s/n"
	read opcion 
	if [[ $opcion == "s" ]]
	then
		distribuirCerticado
	fi
}

creaCARaiz