#!/usr/bin/env bash

# ==============================================================================
# btrsd-backup-now.sh
# External Btrfs USB Manual Backup Script
#
# github.com/cygn-193/btrsd-backup-architecture
#
## LOGGING CONTEXT ##
# - log() and stdout are sent to journald and to local LOG_FILE
# - error() and stderr are sent to journald and to local ERROR_LOG_FILE
#
## SOURCING CONTEXT ##
# This script sources:
# - btrsd.conf
# - btrsd-lib.sh
#
## EXECUTION CONTEXT ##
# - This script is only ever executed manually by the user
#
# This script:
# - Manually creates the 'backup-due' flag file, rather than waiting
#       for the btrsd-reminder.timer to do so
#       - btrsd-reminder.timer is unaffected by this
# - Manually attempts to execute btrsd-main.sh, which will operate
#       normally
# ==============================================================================

################################################################################
# INITIALIZE
################################################################################

set -euo pipefail
set -o errtrace
IFS=$'\n\t'
umask 077

################################################################################
# SOURCE CONF & LIB
################################################################################

_CONF_FILE="/etc/btrsd.conf"
_LIB_FILE="/usr/lib/btrsd/btrsd-lib.sh"

if [[ -f "$_CONF_FILE" ]]; then

    source "$_CONF_FILE"

    if [[ -z "$USER_UID" && -n "$USER_NAME" ]]; then

        USER_UID=$(id -u "$USER_NAME")

    fi

else

    echo "btrsd.conf not found - exiting" >&2
    exit 1

fi

if [[ -f "$_LIB_FILE" ]]; then

    source "$_LIB_FILE"

else

    echo "btrsd-lib.sh not found - exiting" >&2
    exit 1

fi

################################################################################
# LOGGING
################################################################################

stdout_stderr_log_to_file

################################################################################
# ERROR & CLEANUP HANDLER
################################################################################

cleanup_handler() {

    notify "Manual backup error"
    log_declare "btrsd-backup-now.sh exited with errors"

}

trap error_handler ERR

################################################################################
# PREPARE LOCAL DIRECTORIES
################################################################################

prepare_local_directories

################################################################################
# DECLARATION
################################################################################

log_declare "btrsd-backup-now.sh started"
notify "Manual backup requested"

################################################################################
# VALIDATE CONF
################################################################################

validate_user_name_conf
validate_high_priority_conf

################################################################################
# CHECK IF EXECUTED AS ROOT
################################################################################

if [[ "$EUID" -ne 0 ]]; then

    printf "This script must be run as root\n" >&2
    printf "Use a privilege escalation utility such as sudo\n" >&2
    error "btrsd-backup-now.sh not executed as root"
    exit 1

fi

################################################################################
# CREATE FLAG backup-due
################################################################################

touch "$BACKUP_DUE_FLAG"

log "Created backup-due flag"

################################################################################
# PROMPT FOR BACKUP
################################################################################

printf "Manually prompting for backup\n"
log "Launching btrsd-main.service, which will launch btrsd-main.sh"

systemctl start btrsd-main.service

################################################################################
# FINALIZE
################################################################################

log_declare "btrsd-backup-now.sh finished"
