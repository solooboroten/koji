#!/bin/bash

echo Creating User Koji environment 
if [ ! -d ~/.koji ]; then
mkdir  ~/.koji
fi
if [ -f ~/.fedora.cert ] && [ -f ~/.koji/client.crt ]; then
    if [ ~/.fedora.cert -nt ~/.koji/client.crt ]; then 
        rm ~/.koji/client.crt
    fi
fi

if [ ! -f ~/.koji/client.crt ]; then
    if [ -f ~/.fedora.cert ]; then
        cp -l ~/.fedora.cert  ~/.koji/client.crt
    else
        echo "you need a client cert please download one from https://admin.fedoraproject.org/accounts/gen-cert.cgi"
        echo "Save it to ~/.koji/client.crt"
        echo "Then run this script again"
        exit
    fi
fi

if [ -f ~/.fedora-upload-ca.cert ]; then
    cp -l ~/.fedora-upload-ca.cert ~/.koji/clientca.crt
else
    wget "http://fedoraproject.org/wiki/PackageMaintainers/BuildSystemClientSetup?action=AttachFile&do=get&target=fedora-upload-ca.cert" -O ~/.koji/clientca.crt
fi

if [ -f ~/.fedora-server-ca.cert ]; then
    cp -l ~/.fedora-server-ca.cert ~/.koji/serverca.crt
else
    wget "http://fedoraproject.org/wiki/PackageMaintainers/BuildSystemClientSetup?action=AttachFile&do=get&target=fedora-server-ca.cert" -O ~/.koji/serverca.crt
fi


cat > ~/.koji/config <<EOF
[koji]

;configuration for koji cli tool

;url of XMLRPC server
server = http://koji.fedoraproject.org/kojihub

;url of web interface
weburl = http://koji.fedoraproject.org/koji

;path to the koji top directory
;topdir = /mnt/koji

;configuration for SSL athentication

;client certificate
cert = ~/.koji/client.crt

;certificate of the CA that issued the client certificate
ca = ~/.koji/clientca.crt

;certificate of the CA that issued the HTTP server certificate
serverca = ~/.koji/serverca.crt

EOF

echo "Creating an SSL Certificate to import into your browser to allow user authentication on at http://koji.fedoraproject.org/koji.
Choose your own passphrase,  you will be prompted for this when using the certificate.

- To import the Certificate into Firefox:

Edit -> Preferences -> Advanced
Click "View Certificates"
On "Your Certificates" tab, click "Import"
Select fedora-client-cert.p12 (from the directory you ran this script in)
Type the export passphrase (if you specified one)

Once imported, you should see a certificate named "Fedora Project"
Your username should appear underneath this.
 
- You should now be able to click the "login" link at http://koji.fedoraproject.org/koji successfully"
openssl pkcs12 -export -in ~/.koji/client.crt -CAfile ~/.koji/clientca.crt -out fedora-client-cert.p12
