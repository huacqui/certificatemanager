#/bin/bash
#Es necesario instalar el paquete gnutls-utils
#Recibe como parametro el nombre del servidor ejemplo reposerver.example.com tener encuenta que el archivo que generar el certificado debe ser el mismo que se le pasa por parametro al script
SERVER_NAME=$1
### Valida que no venga vac�o el parametro ####
if [ -z $SERVER_NAME ]; then
        echo "Falta el nombre del template"
        exit 1
fi

### Valida que el temaplta exista
if [ ! -f "$SERVER_NAME.cfg" ]; then
        echo "No existe el template que introdujo"
        exit 1
fi

### Crea la CA para firmar los certificados ####
if [ $SERVER_NAME = "ca"  ]; then
        certtool --generate-privkey --outfile ca.key
        certtool --generate-self-signe --load-privkey ca.key --template ca.cfg --outfile ca.crt
        cp -fv ca.crt /etc/pki/ca-trust/source/anchors/
        update-ca-trust
        exit 0
fi

### Crear el certificado firmado con la CA creado en el paso uno
mkdir $SERVER_NAME.d
cd $SERVER_NAME.d
certtool --generate-privkey --outfile $SERVER_NAME.key
certtool --generate-request --load-privkey $SERVER_NAME.key --template ../$SERVER_NAME.cfg --outfile $SERVER_NAME.csr
certtool --generate-certificate --load-request $SERVER_NAME.csr --outfile $SERVER_NAME.crt --load-ca-certificate ../CA/ca.crt --load-ca-privkey ../CA/ca.key --template ../$SERVER_NAME.cfg
cd ..
