# irods pluggable authentication

Pluggable authentication for irods provider in Docker

irods has three pluggable authentication methods

- GSI (Grid Security Infrastructure)
- KRB (Kerberos)
- PAM (Pluggable Authentication Module)  

([irods documentation](https://docs.irods.org/4.2.0/plugins/pluggable_authentication/))

In order to use plugable authentication such as GSI, PAM, and Kerberos you will need to include certificate files to your directory to be copied into the container. Certificates are generated from a trusted authentication source. Needed packages and container copy paths can be found in the 4.2.2 Dockerfile.

GSI Authentication files - files generated from GSI server
 Map files from host docker directory to container `/var/lib/irods/.globus`
- usercert.pem 
- userkey.pem
- dhparams.pem

PAM Authentication file - file created with needed configuration for etc/pam.d
 Map file from host docker directory to container `/etc/pam.d`
- irods

Kerberos Authentication files - files generated from Key Distribution Center on Kerberos admin server
 Map files from host docker directory to container `/etc`
- krb5.conf
- krb5.keytab


Needed files for irods catalog provider with pluggable authenication modules. These files are not included in docker image and must be provided.

- usercert.pem
- userkey.pem
- dhparams.pem
- irods
- krb5.conf
- krb5.keytab
- irods-provider.env
- irods_environment.json
- .profile

