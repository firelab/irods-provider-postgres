#!/usr/bin/env bash
set -e

RODS_CONFIG_FILE=/irods.config
ISETUP_IRODS=false
REJOIN_IRODS=false
FirstArg="$1"

set_postgres_params() {
    # set postgres-docker-entrypoint.sh variables to coincide with iRODS variables unless explicitly defined
    if [[ -z "${POSTGRES_PASSWORD}" ]]; then
        gosu root sed -i 's/POSTGRES_PASSWORD/IRODS_DATABASE_PASSWORD/g' /postgres-docker-entrypoint.sh
    fi
    if [[ -z "${POSTGRES_USER}" ]]; then
        gosu root sed -i 's/POSTGRES_USER/IRODS_DATABASE_USER_NAME/g' /postgres-docker-entrypoint.sh
    fi
    if [[ -z "${POSTGRES_DB}" ]]; then
        gosu root sed -i 's/POSTGRES_DB/IRODS_DATABASE_NAME/g' /postgres-docker-entrypoint.sh
    fi
}

update_uid_gid() {
    #groupadd -r irods --gid=998
    #useradd -r -g irods -d /var/lib/irods --uid=998 irods
    #gosu root usermod -u ${UID_IRODS} irods
    #gosu root groupmod -g ${GID_IRODS} irods
    gosu root chown -R irods:irods /var/lib/irods
    gosu root chown -R irods:irods /etc/irods
}

generate_config() {
    DATABASE_HOSTNAME_OR_IP=$(/sbin/ip -f inet -4 -o addr | grep eth | cut -d '/' -f 1 | rev | cut -d ' ' -f 1 | rev)
    echo "${IRODS_SERVICE_ACCOUNT_NAME}" > ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVICE_ACCOUNT_GROUP}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ROLE}" >> ${IRODS_CONFIG_FILE} # 1. provider, 2. consumer
    echo "${ODBC_DRIVER_FOR_POSTGRES}" >> ${IRODS_CONFIG_FILE} # 1. PostgreSQL ANSI, 2. PostgreSQL Unicode
    echo "${IRODS_DATABASE_SERVER_HOSTNAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_SERVER_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_USER_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "yes" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_PASSWORD}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_DATABASE_USER_PASSWORD_SALT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_ZONE_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT_RANGE_BEGIN}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_PORT_RANGE_END}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_CONTROL_PLANE_PORT}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SCHEMA_VALIDATION}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ADMINISTRATOR_USER_NAME}" >> ${IRODS_CONFIG_FILE}
    echo "yes" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ZONE_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_NEGOTIATION_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_CONTROL_PLANE_KEY}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_SERVER_ADMINISTRATOR_PASSWORD}" >> ${IRODS_CONFIG_FILE}
    echo "${IRODS_VAULT_DIRECTORY}" >> ${IRODS_CONFIG_FILE}
}

if [[ "$FirstArg" = 'setup_irods.py' ]]; then
    SETUP_IRODS=true
fi
if [[ "$FirstArg" = 'rejoin_irods' ]]; then
    REJOIN_IRODS=true
fi


if $SETUP_IRODS; then
    # Configure PostgreSQL
    set_postgres_params
    ./postgres-docker-entrypoint.sh postgres &
    sleep 10s

    # Generate iRODS config file
    generate_config

    # Setup iRODS
    if [[ "$1" = 'setup_irods.py' ]] && [[ "$#" -eq 1 ]]; then
        # Configure with environment variables
        gosu root python /var/lib/irods/scripts/setup_irods.py < ${IRODS_CONFIG_FILE}
    else
        # TODO: Configure with file
        gosu root python /var/lib/irods/scripts/setup_irods.py < ${IRODS_CONFIG_FILE}
    fi

    # Keep container alive
    tail -f /dev/null
elif $REJOIN_IRODS; then
    # Configure PostgreSQL
    #gosu postgres /etc/init.d/psql start
    # set_postgres_params
    ./postgres-docker-entrypoint.sh postgres &
    sleep 10s

    #generate_config
    update_uid_gid
    gosu root /etc/init.d/irods start
    tail -f /dev/null
    echo"You're in! Welcome back to irods."
else
    echo"What just happened??? I think it is beacuse both Setup and Rejoin variables are still false."
    exec "$@"
fi

exit 0;
