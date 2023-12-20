# scriptCAs
# Copiar scripts desde cualquier gnu/linux -scp
* scp script-CA-preliminar.sh USUARIO@IP:RUTA
* scp script-Intermedia-preliminar.sh USUARIO@IP:RUTA
* scp vars USUARIO@IP:RUTA

## CA Raíz
Cliente Gnu/Linux
* scp vars USUARIO@IP:RUTA
* scp script-CA-preliminar.sh USUARIO@IP:RUTA

Servidor Gnu/Linux    
* bash script-CA-preliminar.sh ó ./script-CA-preliminar.sh

## En CA Intermedia
Cliente Gnu/Linux

* scp vars USUARIO@IP:RUTA
* scp /home/USUARIO/raiz/ca.crt USUARIO@IP:RUTA lo guardaré en intermedia en equipo ubuntu server

Servidor Gnu/Linux
* mkdir /home/USUARIO/intermedia
* cp /home/USUARIO/intermedia/ca.crt

* bash script-Intermedia-preliminar.sh ó ./script-Intermedia-preliminar.sh
