#!/bin/bash
set -e

python3.10 - <<'PY'
import json
import os
import uuid
from pathlib import Path

auth_key = os.environ.get("CRAWLAB_GRPC_AUTHKEY")
if not auth_key:
    raise SystemExit("CRAWLAB_GRPC_AUTHKEY is required")

config_path = Path("/root/.crawlab/config.json")
if config_path.exists():
    with config_path.open("r", encoding="utf-8") as file:
        config = json.load(file)
else:
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config = {
        "key": str(uuid.uuid1()),
        "is_master": os.environ.get("CRAWLAB_NODE_MASTER", "N").upper() == "Y",
        "name": os.environ.get("CRAWLAB_NODE_NAME", ""),
        "ip": "",
        "mac": "",
        "hostname": "",
        "description": "",
        "auth_key": auth_key,
        "max_runners": int(os.environ.get("CRAWLAB_TASK_HANDLER_MAXRUNNERS", "8")),
    }

if config.get("auth_key") != auth_key:
    config["auth_key"] = auth_key

temp_path = config_path.with_suffix(".json.tmp")
with temp_path.open("w", encoding="utf-8") as file:
    json.dump(config, file, ensure_ascii=True, separators=(",", ":"))
os.replace(temp_path, config_path)
PY

exec /bin/bash /app/bin/docker-init.sh
