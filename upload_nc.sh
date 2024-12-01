SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
CONFIG_PATH=$SCRIPT_DIR/config

CREDENTIALS_PATH=$(grep "^CREDENTIALS_PATH:" "$CONFIG_PATH" | cut -d':' -f2 | xargs)
LOCAL_LOG_DIR=$(grep "^LOG_DIR:" "$CONFIG_PATH" | cut -d':' -f2 | xargs)

HOSTNAME=$(hostname)  # Get the system's hostname
LOCAL_LOG_FILE="$LOCAL_LOG_DIR/$HOSTNAME.log.json"

NEXTCLOUD_URL=$(awk "NR==1" "$CREDENTIALS_PATH")
NEXTCLOUD_USER=$(awk "NR==2" "$CREDENTIALS_PATH")
NEXTCLOUD_PWD=$(awk "NR==3" "$CREDENTIALS_PATH")
NEXTCLOUD_FOLDER="bashcentral"

NEXTCLOUD_URL=$NEXTCLOUD_URL/remote.php/dav/files/$NEXTCLOUD_USER/

# Check if the folder exists using PROPFIND
if ! curl -u "$NEXTCLOUD_USER:$NEXTCLOUD_PWD" -X PROPFIND "$NEXTCLOUD_URL$NEXTCLOUD_FOLDER" --silent --fail --show-error > /dev/null; then
    # If the folder does not exist, create it using MKCOL
    echo "Folder does not exist. Creating folder..."
    curl -u "$NEXTCLOUD_USER:$NEXTCLOUD_PWD" -X MKCOL "$NEXTCLOUD_URL$NEXTCLOUD_FOLDER" --silent --show-error --fail
    echo "Folder created."
else
    echo "Folder already exists."
fi

REMOTE_FILE="${NEXTCLOUD_URL}${NEXTCLOUD_FOLDER}/${HOSTNAME}.log.json"
echo $REMOTE_FILE
curl -u "$NEXTCLOUD_USER:$NEXTCLOUD_PWD" -T "$LOCAL_LOG_FILE" "$REMOTE_FILE" \
    --silent --show-error --fail || echo "Failed to upload logs to Nextcloud."
