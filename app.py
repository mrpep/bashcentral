from flask import Flask, jsonify
import requests
from pathlib import Path
import json
from flask_cors import CORS

app = Flask(__name__)

CORS(app)
config_path = Path(Path(__file__).parent, 'config')
with open(config_path, 'r') as f:
    config = f.read().splitlines()
    config_d = {k.split(':')[0].strip(): k.split(':')[1].strip() for k in config}
with open(config_d['CREDENTIALS_PATH'], 'r') as f:
    credentials = f.read().splitlines()
    NEXTCLOUD_URL = credentials[0]
    NEXTCLOUD_USERNAME = credentials[1]
    NEXTCLOUD_PASSWORD = credentials[2]

LOGS_PATH = 'bashcentral/'

@app.route("/logs")
def get_logs():
    logs = []
    # Find all client logs in the folder:
    headers = {
        "Depth": "1"  # 1 to list files in the folder, 0 for just the folder itself
    }
    response = requests.request("PROPFIND", f"{NEXTCLOUD_URL}/remote.php/dav/files/{NEXTCLOUD_USERNAME}/{LOGS_PATH}/", auth=(NEXTCLOUD_USERNAME, NEXTCLOUD_PASSWORD), headers=headers)
    # Check for a successful response
    if response.status_code == 207:  # 207 Multi-Status is the expected code for PROPFIND
        print("Files in the folder:")
        # Parse the response XML to extract file names (using simple parsing)
        from xml.etree import ElementTree
        tree = ElementTree.ElementTree(ElementTree.fromstring(response.text))
        root = tree.getroot()

        # Extract file names from the XML response
        for response_element in root.findall("{DAV:}response"):
            href = response_element.find("{DAV:}href").text
            if href.endswith('.json'):
                hostname = href.split('/')[-1].split('.log.json')[0]
                response_log_i = requests.get(
                    f"{NEXTCLOUD_URL}{href}",
                    auth=(NEXTCLOUD_USERNAME, NEXTCLOUD_PASSWORD)
                )
                if response_log_i.status_code == 200:
                    for l in response_log_i.text.splitlines():
                        ld = json.loads(l)
                        ld['hostname'] = hostname
                        logs.append(ld)
                else:
                    print(f"Error: {response_log_i.status_code} - {response_log_i.text}")
    else:
        print(f"Error: {response.status_code} - {response.text}")
    
    return jsonify(logs)

if __name__ == "__main__":
    app.run(debug=True)
