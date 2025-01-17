#!/usr/bin/env bash
#stolen from https://serversforhackers.com/dockerized-app/compose-separated
#TODO: check if we are in correct directory
#TODO: check if compose files are available
#TODO: eve-universe sql import function

# https://mywiki.wooledge.org/glob
# https://sipb.mit.edu/doc/safe-shell/
set -Eeuo pipefail
shopt -s failglob

# import KISS-framework libs
source KISS-lib/kiss-basic.sh
source KISS-lib/kiss-backup-sql.sh

# backup location
BACKUP_LOCATION="/var/backups/"

# KISS-framework variables
# name of the database container (see docker-compose.yml)
KISS_DB_CONTAINERNAME="pfdb"
# name of pathfinder db in database container (static)
KISS_DB_NAME="pf"
# name of database user to connect with (static)
KISS_DB_USER="root"

# source CONTAINER_NAME from .env file
# shellcheck source=/dev/null (https://github.com/koalaman/shellcheck/wiki/SC1090)
source <(grep CONTAINER_NAME .env)

# check if we are root, if not use sudo
SUDO=''
if [ "${EUID}" != "0" ]; then
    SUDO='sudo'
fi

setup_colors

# Create docker-compose command to run
COMPOSE="docker-compose -f docker-compose.yml --env=.env"

# If we pass any arguments...
if [ $# -gt 0 ];then
    # "cron-backup-sql"
    if [ "$1" == "cron-backup-sql" ]; then
	    cron-backup-sql
    # "backup-sql"
    elif [ "$1" == "backup-sql" ]; then
        #shift 1
	echo -e "This will backup your MySQL database.\nDo you want to continue?"
        select yn in "Yes" "No"; do
            case ${yn} in
                Yes ) backup-sql; break;;
                No ) exit;;
		* ) exit;;
            esac
        done
    elif [ "$1" == "restore-sql" ]; then
        shift 1
	echo -e "This will restore a backup of your MySQL database. In this process ${RED}your containers will be stopped${NOFORMAT} and ${RED}all current data in the database will be lost.${NOFORMAT}\nDo you want to continue?"
        select yn in "Yes" "No"; do
            case ${yn} in
                Yes ) restore-sql "$@"; break;;
                No ) exit;;
		* ) exit;;
            esac
        done
    # Else, pass-thru args to docker-compose
    else
        ${COMPOSE} "$@"
    fi

else
    msg "${RED}ERROR${NOFORMAT} No commands received. Displaying script help and status of docker containers"
    msg "COMMANDS"
    msg "   backup-sql: creates a backup of the mysql database"
    msg "   cron-backup-sql: creates a backup of the mysql database without manual confirmation. For use with cronjobs"
    msg "   restore-sql: restores mysql database from a provided backup"
    msg "   up -d: start docker containers"
    msg "   stop: stop running docker containers"
    msg "   down: stop and remove docker containers"
    msg "   down -v: remove docker containers and volumes including application data. ${RED}Use with care${NOFORMAT}"
    msg "   logs -f: display logs for running containers"
    msg "   ps: display status of docker containers"
    msg "   --help: display docker-compose help\n"
    ${COMPOSE} ps
fi
