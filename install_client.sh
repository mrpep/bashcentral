#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
#Gather auth info:
echo "Enter your nextcloud url"
read NEXTCLOUD_URL
echo "Enter your nextcloud user"
read NEXTCLOUD_USER
echo "Enter your nextcloud password"
read NEXTCLOUD_PWD
echo "Credential files path: [~/.nextcloud_credentials]"
read CREDENTIALS_PATH

#Create credentials file:
if [[ "$CREDENTIALS_PATH" == "" ]]; then
    CREDENTIALS_PATH=~/.nextcloud_credentials
fi

cat > $CREDENTIALS_PATH << EOF
$NEXTCLOUD_URL
$NEXTCLOUD_USER
$NEXTCLOUD_PWD
EOF

#Create config file:
config_path=$SCRIPT_DIR/config
echo "How often in minutes do you want to upload the logs to nextcloud? [1]"
read UPLOAD_TIME
if [[ "$UPLOAD_TIME" == "" ]]; then
    UPLOAD_TIME=1
fi

echo "Where do you want to store the logs locally? [~/.bashcentral_logs]"
read LOCAL_LOG_DIR
if [[ "$LOCAL_LOG_DIR" == "" ]]; then
    LOCAL_LOG_DIR=~/.bashcentral_logs
fi
mkdir -p $LOCAL_LOG_DIR

cat > $config_path << EOF
CREDENTIALS_PATH: $CREDENTIALS_PATH
LOG_DIR: $LOCAL_LOG_DIR
EOF

# Add nextcloud cronjob:
chmod +x $SCRIPT_DIR/upload_nc.sh
CRON_JOB="*/$UPLOAD_TIME * * * * $SCRIPT_DIR/upload_nc.sh"

# Add the cron job if it doesn't already exist
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# Edit .bashrc
SEP_LINE="# Bashcentral custom variables:"
if ! grep -q "$SEP_LINE" "$HOME/.bashrc"; then
    cat <<EOL >> "$HOME/.bashrc"
$SEP_LINE
source $SCRIPT_DIR/log_command.sh
export PROMPT_COMMAND="log_command"
EOL
else
    echo "Changes already exist in .bashrc"
fi

source $HOME/.bashrc
