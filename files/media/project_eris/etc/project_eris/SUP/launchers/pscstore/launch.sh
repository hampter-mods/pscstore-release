#!/bin/sh
. "/var/volatile/project_eris.cfg"

# PSCSTORE_TEXT_UPDATE_TEST=launch-sh-marker-2026-05-29

echo 2 > "/data/power/disable"
echo "none" > "/tmp/launchfilecommand"

LOG_DIR="/tmp/pscstore_logs"

# Resolve the install directory of this launcher (persistent path).
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"

# Runtime bootstrap: always execute from tmpfs/volatile storage when possible.
# Install remains persistent under /media, but runtime binary execution moves off USB.
RUNTIME_DIR="${PSCSTORE_RUNTIME_DIR:-/tmp/pscstore_runtime}"
if ! mkdir -p "$RUNTIME_DIR" 2>/dev/null; then
  # Fallback for older environments.
  if [ -d "/var/volatile/launchtmp" ]; then
    RUNTIME_DIR="/var/volatile/launchtmp"
  else
    RUNTIME_DIR="$SCRIPT_DIR"
  fi
fi
export PSCSTORE_RUNTIME_DIR="$RUNTIME_DIR"
cd "$RUNTIME_DIR" || exit 1

# PSCSTORE_LOGGING_BLOCK_BEGIN
# Release channel: suppress shell/app stdout and disable helper logs.
exec >/dev/null 2>&1
unset PSCSTORE_LOGGING
unset PSC_DOWNLOAD_LOG
export PSC_CURL_VERBOSE=0
export PSC_UI_DIAG_INPUT=0
export PSC_UI_DIAG_INPUT_OVERLAY=0
# PSCSTORE_LOGGING_BLOCK_END

# Keep UI menu assets deterministic: prefer Eris stock menu_files first.
# Some installs have /usr/sony/share/data/menu_files replaced by custom theme assets.
export PSC_THEME_MENU="${THEMES_PATH}/stock/menu_files"
export PSC_THEME_STOCK="/usr/sony/share/data/menu_files"
export PSC_CONTROLLER_DB="/tmp/._bleemsync/etc/boot_menu/gamecontrollerdb.txt"

export PSC_DB_PATH="/media/project_eris/opt/psc_transfer_tools/pcsx_data.db"
export PSC_COVERS_DIR="/media/project_eris/opt/psc_transfer_tools/covers"
unset PSC_PSC_GAME_ADD_BIN
export PSC_CURL_INSECURE=0
export PSC_CURL_DNS="${PSC_CURL_DNS:-1.1.1.1,8.8.8.8}"
export PSC_CURL_CONNECT_TIMEOUT="${PSC_CURL_CONNECT_TIMEOUT:-10}"
export PSC_CURL_SPEED_TIME="${PSC_CURL_SPEED_TIME:-25}"
export PSC_CURL_SPEED_LIMIT="${PSC_CURL_SPEED_LIMIT:-128}"
export PSC_CURL_GET_MAX_TIME="${PSC_CURL_GET_MAX_TIME:-35}"
export PSC_CURL_HEAD_MAX_TIME="${PSC_CURL_HEAD_MAX_TIME:-20}"
export PSCSTORE_UPDATE_GITHUB_REPO="hampter-mods/pscstore-release"
export PSCSTORE_UPDATE_GITHUB_BRANCH="main"
export PSCSTORE_UPDATE_MANIFEST_URL="https://raw.githubusercontent.com/${PSCSTORE_UPDATE_GITHUB_REPO}/${PSCSTORE_UPDATE_GITHUB_BRANCH}/manifest.tsv"
export PSCSTORE_UPDATE_BASE_URL="https://raw.githubusercontent.com/${PSCSTORE_UPDATE_GITHUB_REPO}/${PSCSTORE_UPDATE_GITHUB_BRANCH}/files"
PSC_TLS_HELPER="/media/project_eris/etc/project_eris/SUP/scripts/psc_tls_bundle.sh"
if [ -r "$PSC_TLS_HELPER" ]; then
  . "$PSC_TLS_HELPER"
  psc_tls_prepare_bundle >/dev/null 2>&1 || true
fi
if [ -z "${PSC_CURL_CA_BUNDLE:-}" ]; then
  for _ca in \
    /media/project_eris/etc/project_eris/SUP/keys/cacert.pem \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/cert.pem \
    /etc/pki/tls/certs/ca-bundle.crt
  do
    if [ -r "$_ca" ]; then
      export PSC_CURL_CA_BUNDLE="$_ca"
      break
    fi
  done
fi
if [ "${PSCSTORE_LOGGING:-0}" = "1" ] && [ -z "${PSC_CURL_CA_BUNDLE:-}" ]; then
  echo "[launch][warn] no CA bundle found; HTTPS verification may fail if curl has no built-in trust store"
fi

# Persistent paths for history/time-sync status.
# Prefer the installed launcher directory, not /var/volatile/launchtmp.
DEFAULT_LAUNCHER_DIR="/media/project_eris/etc/project_eris/SUP/launchers/pscstore"
case "$SCRIPT_DIR" in
  /media/project_eris/etc/project_eris/SUP/launchers/*)
    DEFAULT_LAUNCHER_DIR="$SCRIPT_DIR"
    ;;
esac
case "${PSCSTORE_LAUNCHER_DIR:-}" in
  ""|/tmp/*|/var/volatile/launchtmp*)
    PSCSTORE_LAUNCHER_DIR="$DEFAULT_LAUNCHER_DIR"
    ;;
esac
export PSCSTORE_LAUNCHER_DIR
mkdir -p "$PSCSTORE_LAUNCHER_DIR" 2>/dev/null || true
mkdir -p "$PSCSTORE_LAUNCHER_DIR/assets/sfx" 2>/dev/null || true

# Back-compat: older scripts/binaries use PSC_UI_TEST_LAUNCHER_DIR.
if [ -z "${PSC_UI_TEST_LAUNCHER_DIR:-}" ]; then
  PSC_UI_TEST_LAUNCHER_DIR="$PSCSTORE_LAUNCHER_DIR"
fi

# Never treat launchtmp as the persistent launcher dir.
case "${PSC_UI_TEST_LAUNCHER_DIR}" in
  /var/volatile/launchtmp*|"")
    PSC_UI_TEST_LAUNCHER_DIR="$PSCSTORE_LAUNCHER_DIR"
    ;;
esac

export PSC_UI_TEST_LAUNCHER_DIR
PSC_HISTORY_DB_PATH_CANONICAL="/media/project_eris/etc/project_eris/SUP/launchers/pscstore/history.db"
mkdir -p "/media/project_eris/etc/project_eris/SUP/launchers/pscstore" 2>/dev/null || true
export PSC_HISTORY_DB_PATH="$PSC_HISTORY_DB_PATH_CANONICAL"

# Updater state lives under cache. Migrate the old root marker once, and allow
# local test launches to seed their fixed "Test" version without installing a
# new app binary first.
mkdir -p "$PSCSTORE_LAUNCHER_DIR/cache" 2>/dev/null || true
if [ -f "$PSCSTORE_LAUNCHER_DIR/release_version.txt" ]; then
  if [ ! -f "$PSCSTORE_LAUNCHER_DIR/cache/release_version.txt" ]; then
    cp -f "$PSCSTORE_LAUNCHER_DIR/release_version.txt" "$PSCSTORE_LAUNCHER_DIR/cache/release_version.txt" 2>/dev/null || true
  fi
  rm -f "$PSCSTORE_LAUNCHER_DIR/release_version.txt" "$PSCSTORE_LAUNCHER_DIR/release_version.txt.update_bak" 2>/dev/null || true
fi

# One-time migration from the old launcher directory name.
OLD_LAUNCHER_DIR="/media/project_eris/etc/project_eris/SUP/launchers/psc_ui_test_launch"
if [ "$PSC_UI_TEST_LAUNCHER_DIR" != "$OLD_LAUNCHER_DIR" ] && [ -d "$OLD_LAUNCHER_DIR" ]; then
  if [ -f "$OLD_LAUNCHER_DIR/settings.cfg" ] && [ ! -f "$PSC_UI_TEST_LAUNCHER_DIR/settings.cfg" ]; then
    cp -f "$OLD_LAUNCHER_DIR/settings.cfg" "$PSC_UI_TEST_LAUNCHER_DIR/settings.cfg" 2>/dev/null || true
  fi
  if [ -f "$OLD_LAUNCHER_DIR/history.db" ] && [ ! -f "$PSC_HISTORY_DB_PATH_CANONICAL" ]; then
    cp -f "$OLD_LAUNCHER_DIR/history.db" "$PSC_HISTORY_DB_PATH_CANONICAL" 2>/dev/null || true
  fi
fi

export LD_LIBRARY_PATH="/usr/sony/lib:/media/project_eris/lib:/media/project_eris/bin:${LD_LIBRARY_PATH}"

# Wayland env can be missing when launched via Eris
[ -z "$XDG_RUNTIME_DIR" ] && export XDG_RUNTIME_DIR="/run/user/0"
[ -z "$WAYLAND_DISPLAY" ] && export WAYLAND_DISPLAY="wayland-0"

# GLES / Wayland
export SDL_VIDEODRIVER="wayland"
export SDL_OPENGL_ES_DRIVER=1

# Always sync launch binaries from the installed launcher dir into runtime.
RUNTIME_BIN="${PSCSTORE_RUNTIME_DIR}/pscstore"
RUNTIME_LOGGER="${PSCSTORE_RUNTIME_DIR}/pscstore_logger"
RUNTIME_PSC_CURL="${PSCSTORE_RUNTIME_DIR}/psc_curl_static"
RUNTIME_LCP="${PSCSTORE_RUNTIME_DIR}/lcp"
RUNTIME_7ZR="${PSCSTORE_RUNTIME_DIR}/7zr"
RUNTIME_7ZA="${PSCSTORE_RUNTIME_DIR}/psc_7za_static"
RUNTIME_GAME_MANAGER="${PSCSTORE_RUNTIME_DIR}/game_manager"
RUNTIME_PCSX_DB="${PSCSTORE_RUNTIME_DIR}/pcsx_data.db"

PERSIST_BIN="${PSCSTORE_LAUNCHER_DIR}/pscstore"
if [ -f "$PERSIST_BIN" ]; then
  echo "[launch] syncing pscstore -> ${PSCSTORE_RUNTIME_DIR} from $PERSIST_BIN"
  cp -f "$PERSIST_BIN" "$RUNTIME_BIN" 2>/dev/null || true
elif [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/pscstore" ]; then
  echo "[launch] syncing pscstore -> ${PSCSTORE_RUNTIME_DIR} from ${SCRIPT_DIR}/pscstore"
  cp -f "${SCRIPT_DIR}/pscstore" "$RUNTIME_BIN" 2>/dev/null || true
fi

PERSIST_LOGGER="${PSCSTORE_LAUNCHER_DIR}/pscstore_logger"
if [ -f "$PERSIST_LOGGER" ]; then
  cp -f "$PERSIST_LOGGER" "$RUNTIME_LOGGER" 2>/dev/null || true
elif [ -n "$SCRIPT_DIR" ] && [ -f "${SCRIPT_DIR}/pscstore_logger" ]; then
  cp -f "${SCRIPT_DIR}/pscstore_logger" "$RUNTIME_LOGGER" 2>/dev/null || true
fi

PERSIST_SUP_BIN_DIR="/media/project_eris/etc/project_eris/SUP/binaries"
PERSIST_TOOLS_DIR="/media/project_eris/opt/psc_transfer_tools"
PERSIST_PCSX_DB="/media/project_eris/opt/psc_transfer_tools/pcsx_data.db"

# Stage helper binaries and DBs into tmpfs runtime to reduce USB read contention.
if [ -f "${PERSIST_SUP_BIN_DIR}/psc_curl_static" ]; then cp -f "${PERSIST_SUP_BIN_DIR}/psc_curl_static" "$RUNTIME_PSC_CURL" 2>/dev/null || true; fi
if [ -f "${PERSIST_SUP_BIN_DIR}/lcp" ]; then cp -f "${PERSIST_SUP_BIN_DIR}/lcp" "$RUNTIME_LCP" 2>/dev/null || true; fi
if [ -f "${PERSIST_SUP_BIN_DIR}/7zr" ]; then cp -f "${PERSIST_SUP_BIN_DIR}/7zr" "$RUNTIME_7ZR" 2>/dev/null || true; fi
if [ -f "${PERSIST_SUP_BIN_DIR}/psc_7za_static" ]; then cp -f "${PERSIST_SUP_BIN_DIR}/psc_7za_static" "$RUNTIME_7ZA" 2>/dev/null || true; fi
if [ -f "${PERSIST_TOOLS_DIR}/game_manager" ]; then cp -f "${PERSIST_TOOLS_DIR}/game_manager" "$RUNTIME_GAME_MANAGER" 2>/dev/null || true; fi
if [ -f "$PERSIST_PCSX_DB" ]; then cp -f "$PERSIST_PCSX_DB" "$RUNTIME_PCSX_DB" 2>/dev/null || true; fi

chmod +x "$RUNTIME_BIN" 2>/dev/null || true
chmod +x "$RUNTIME_LOGGER" 2>/dev/null || true
chmod +x "$RUNTIME_PSC_CURL" 2>/dev/null || true
chmod +x "$RUNTIME_LCP" 2>/dev/null || true
chmod +x "$RUNTIME_7ZR" 2>/dev/null || true
chmod +x "$RUNTIME_7ZA" 2>/dev/null || true
chmod +x "$RUNTIME_GAME_MANAGER" 2>/dev/null || true

# Point runtime helpers at staged binaries/DBs when present.
if [ -x "$RUNTIME_PSC_CURL" ]; then export PSC_CURL_BIN="$RUNTIME_PSC_CURL"; fi
if [ -x "$RUNTIME_LCP" ]; then export PSC_LCP_BIN="$RUNTIME_LCP"; fi
if [ -x "$RUNTIME_7ZR" ]; then export PSC_7ZR_BIN="$RUNTIME_7ZR"; fi
if [ -x "$RUNTIME_7ZA" ]; then export PSC_7ZA_BIN="$RUNTIME_7ZA"; fi
if [ -x "$RUNTIME_GAME_MANAGER" ]; then export PSC_GAME_MANAGER_BIN="$RUNTIME_GAME_MANAGER"; fi
if [ -f "$RUNTIME_PCSX_DB" ]; then export PSC_DB_PATH="$RUNTIME_PCSX_DB"; fi
# Keep history DB persistent (do not stage into /tmp).
export PSC_HISTORY_DB_PATH="$PSC_HISTORY_DB_PATH_CANONICAL"

export PATH="${PSCSTORE_RUNTIME_DIR}:${PATH}"

ulimit -c unlimited 2>/dev/null || true

if [ ! -x "$RUNTIME_BIN" ]; then
  # Last-resort fallback: run the persistent binary directly if runtime sync failed.
  if [ -x "$PERSIST_BIN" ]; then
    echo "[launch][warn] runtime pscstore missing; falling back to $PERSIST_BIN"
    RUNTIME_BIN="$PERSIST_BIN"
  elif [ -n "$SCRIPT_DIR" ] && [ -x "${SCRIPT_DIR}/pscstore" ]; then
    echo "[launch][warn] runtime pscstore missing; falling back to ${SCRIPT_DIR}/pscstore"
    RUNTIME_BIN="${SCRIPT_DIR}/pscstore"
  fi
fi
if [ ! -x "$RUNTIME_BIN" ]; then
  echo "[launch][fatal] no executable pscstore found in runtime or persistent locations"
  exit 127
fi

if [ -f "$RUNTIME_BIN" ]; then
  echo "[launch] pscstore: $(ls -l "$RUNTIME_BIN" 2>/dev/null)"
  echo "[launch] pscstore_bytes: $(wc -c < "$RUNTIME_BIN" 2>/dev/null || echo '?')"
  if command -v sha256sum >/dev/null 2>&1; then
    echo "[launch] pscstore_sha256: $(sha256sum "$RUNTIME_BIN" 2>/dev/null | awk '{print $1}')"
  elif command -v md5sum >/dev/null 2>&1; then
    echo "[launch] pscstore_md5: $(md5sum "$RUNTIME_BIN" 2>/dev/null | awk '{print $1}')"
  fi
fi

echo "ENV: SDL_VIDEODRIVER=$SDL_VIDEODRIVER SDL_OPENGL_ES_DRIVER=$SDL_OPENGL_ES_DRIVER XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
sync

"$RUNTIME_BIN"
rc=$?

set +x
echo "=== exit $(date) rc=$rc ==="
sync
if [ "$rc" = "42" ]; then
  echo "[launch] restart requested by updater; relaunching PSC Store"
  RESTART_LAUNCH="${PSCSTORE_LAUNCHER_DIR}/launch.sh"
  if [ ! -f "$RESTART_LAUNCH" ]; then
    RESTART_LAUNCH="/media/project_eris/etc/project_eris/SUP/launchers/pscstore/launch.sh"
  fi
  if [ -x "$RESTART_LAUNCH" ]; then
    exec "$RESTART_LAUNCH" "$@"
  fi
  exec /bin/sh "$RESTART_LAUNCH" "$@"
fi
exit $rc
