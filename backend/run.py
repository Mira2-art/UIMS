"""Run the API for local-network access.

Binds to 0.0.0.0 by default (all interfaces), so it's reachable from phones on
the same WiFi at this machine's LAN IP — currently http://10.216.91.251:8000.
(Find yours with `hostname -I`.) Point the mobile apps' ApiConfig.baseUrl at that
LAN IP. Binding to a specific IP that isn't assigned to a NIC fails with
"Cannot assign requested address" — so we bind 0.0.0.0, not a fixed IP.

    python run.py                       # 0.0.0.0:8000, reload on
    HOST=10.216.91.251 python run.py    # override host/port via env

Equivalent one-liners:
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
    fastapi dev app/main.py --host 0.0.0.0 --port 8000
"""

import os

import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000")),
        reload=os.getenv("RELOAD", "true").lower() == "true",
    )
