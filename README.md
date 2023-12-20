# scriptCAs
# Copiar scripts desde cualquier gnu/linux -scp
* scp script-CA-preliminar.sh USUARIO@IP:RUTA
* scp script-Intermedia-preliminar.sh USUARIO@IP:RUTA
* scp vars USUARIO@IP:RUTA

## CA Raíz
* bash script-CA-preliminar.sh ó ./script-CA-preliminar.sh
* scp vars USUARIO@IP:RUTA


## En CA Intermedia
* bash script-Intermedia-preliminar.sh ó ./script-Intermedia-preliminar.sh
* scp vars USUARIO@IP:RUTA
* scp /home/USUARIO/raiz/ca.crt USUARIO@IP:RUTA
* mkdir /home/USUARIO/intermedia
