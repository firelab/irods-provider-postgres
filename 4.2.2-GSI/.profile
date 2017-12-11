
MYPROXY_SERVER_DN="/C=US/O=Globus Consortium/OU=Globus Connect Service/CN=34fd0cf8-92f8-11e6-b087-22000b92c261"

X509_CERT_DIR="/var/lib/irods/.globus/certificates"
X509_USER_CERT="/var/lib/irods/.globus/usercert.pem"
X509_USER_KEY="/var/lib/irods/.globus/userkey.pem"
#IRODS_AUTHENTICATION_SCHEME="GSI"
#ZONE_AUTH_SCHEME=GSI

export X509_CERT_DIR
export X509_USER_CERT
export X509_USER_KEY
#export IRODS_AUTHENTICATION_SCHEME
#export ZONE_AUTH_SCHEME

export MYPROXY_SERVER_DN
