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
function distribuirFirmados(){
	read -p "IP Equipo destino: " ipDestino
	read -p "Ruta completa Equipo destino: " rutaFich
	read -p "Usuario de IP destino: " usuarioDestino

	scp /home/$usuario/ca/easy-rsa/pki/issued/$serverClave".crt" $usuarioDestino@$ipDestino:$rutaFich

	scp /home/$usuario/ca/easy-rsa/pki/ca.crt $usuarioDestino@$ipDestino:$rutaFich

	echo "scp /home/$usuario/ca/easy-rsa/pki/issued/$serverClave".crt" $usuarioDestino@$ipDestino:$rutaFich" >> /home/$usuario/instrucciones.txt
	echo "scp /home/$usuario/ca/easy-rsa/pki/ca.crt $usuarioDestino@$ipDestino:$rutaFich" >> /home/$usuario/instrucciones.txt
}

function distribuirRevocados(){
	read -p "IP Equipo destino: " ipDestino
	read -p "Ruta completa Equipo destino: " rutaFich
	read -p "Usuario de IP destino: " usuarioDestino

	scp /home/$usuario/ca/easy-rsa/pki/crl.pem $usuarioDestino@$ipDestino:$rutaFich
	echo "scp /home/$usuario/ca/easy-rsa/pki/crl.pem $usuarioDestino@$ipDestino:$rutaFich"  >> /home/$usuario/instrucciones.txt
}	

function importarCA(){
	cd /home/$usuario/ca/easy-rsa/
	cp /home/$usuario/raiz/ca.crt /usr/local/share/ca-certificates/
	read -p "Importando certificado intermedia. Pulsa Enter " importando
	update-ca-certificates
	
	
	mkdir /home/$usuario/intermedia/
	cp /home/$usuario/scripts/ca.crt /home/$usuario/intermedia/ca.crt
	mv /home/$usuario/intermedia/ca.crt /home/$usuario/intermedia/raiz.crt
	cp /home/$usuario/intermedia/raiz.crt /usr/local/share/ca-certificates/
	read -p "Importando certificado raiz Pulsa Enter " importando

	update-ca-certificates



	echo "cd /home/$usuario/ca/easy-rsa/" >> /home/$usuario/instrucciones.txt
	echo "cp /home/$usuario/raiz/ca.crt /usr/local/share/ca-certificates/" >> /home/$usuario/instrucciones.txt
	echo "update-ca-certificates" >> /home/$usuario/instrucciones.txt

	echo "cp /home/$usuario/intermedia/ca.crt /usr/local/share/ca-certificates/" >>  /home/$usuario/instrucciones.txt
	echo "update-ca-certificates" >> /home/$usuario/instrucciones.txt

}

function crearCertificadoCRT(){
	cd /home/$usuario/ca/easy-rsa/

	echo "1 - Creamos clave privada" 
	
	read -p "Nombre Server Clave: Ej.upv-server: " serverClave
	openssl genrsa -out $serverClave".key"
	echo "Sea ha generado clave privada $serverClave.key"
	echo "en:/home/$usuario/ca/easy-rsa/ "

	echo "Crear certificadoCRT">> /home/$usuario/instrucciones.txt
	echo "1 - Creamos clave privada">> /home/$usuario/instrucciones.txt
	echo "openssl genrsa -out $serverClave" >> /home/$usuario/instrucciones.txt

	echo "2 - Crear CSR" 
	openssl req -new -key $serverClave".key" -out $serverClave".req"
	echo "2 - Crear CSR" >> /home/$usuario/instrucciones.txt
	echo 'openssl req -new -key $serverClave".key" -out $serverClave".req"' >> /home/$usuario/instrucciones.txt

	echo "3 - Validar " 
	echo "3 - Validar" >> /home/$usuario/instrucciones.txt
	openssl req -in $serverClave".req" -noout -subject
	echo 'openssl req -in $serverClave".req" -noout -subject'
}



function creaCARaiz(){
	creaUsuario
	limpiar
	generaArchivo
	instalarEasyRSA
	creaEstructura
	permisosRoot
	creaEntidadCertificacion
	echo "¿Quieres distribuir a otro equipo el certificado?- (ca.crt) s/n"
	read opcion 
	if [[ $opcion == "s" ]]
	then
		distribuirCerticado
	fi

}

function firmarCSR(){
	cd /home/$usuario/ca/easy-rsa/
	#read -p "Fichero req:" usuario
	./easyrsa import-req /home/$usuario/ca/easy-rsa/$serverClave".req" $serverClave
	echo "./easyrsa import-req /home/$usuario/ca/easy-rsa/$serverClave".req" $serverClave
">> /home/$usuario/instrucciones.txt

	./easyrsa sign-req server $serverClave
	echo "./easyrsa sign-req server $serverClave">> /home/$usuario/instrucciones.txt

}

function revocarCertificado(){
	cd /home/$usuario/ca/easy-rsa/
	echo "Revocamos certificado"
	./easyrsa revoke $serverClave
	echo "./easyrsa revoke $serverClave" >> /home/$usuario/instrucciones.txt

	echo "Generamos nueva lista CRL"
	./easyrsa gen-crl
	cat /home/$usuario/ca/easy-rsa/pki/crl.pem
	echo "./easyrsa gen-crl" >> /home/$usuario/instrucciones.txt
	echo "cat /home/$usuario/ca/easy-rsa/pki/crl.pem">> /home/$usuario/instrucciones.txt

	echo "Transferir lista de revocados crl.pem de la CA"
	distribuirRevocados

	echo "copiar crl.pem en la ubicación que el servicio espera y Reiniciar cliente ???? "
	echo "Reiniciar todos los servicios"

	echo "copiar crl.pem en la ubicación que el servicio espera y Reiniciar cliente ???? " >> /home/$usuario/instrucciones.txt
	echo "Reiniciar todos los servicios" >> /home/$usuario/instrucciones.txt

	echo "Examinar y Verificar componentes CRL "
	echo "Examinar y Verificar componentes CRL " >> /home/$usuario/instrucciones.txt
	openssl crl -in /home/$usuario/ca/easy-rsa/pki/crl.pem -noout -text
	echo "openssl crl -in /home/$usuario/ca/easy-rsa/pki/crl.pem -noout -text">> /home/$usuario/instrucciones.txt


}



creaCARaiz
importarCA
crearCertificadoCRT
echo "¿Quieres distribuir a otro equipo el certificado CRT (upv-server.req) ?- s/n"
	read opcion 
	if [[ $opcion == "s" ]]
	then
		distribuirCerticado
	fi
firmarCSR
echo "¿Quieres distribuir los certificados firmados (upv-server.crt) ?- s/n"
	read opcion 
	if [[ $opcion == "s" ]]
	then
		distribuirFirmados
	fi
echo "¿Quieres revocar los certificados?- s/n"
	read opcion 
	if [[ $opcion == "s" ]]
	then
		revocarCertificado
	fi
