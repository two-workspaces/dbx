#!/bin/sh
# Maps Railway onto DBX Web. Everything here guards against a variable that would
# otherwise open the login or stop the server from starting.

# Listen on Railway's port unless DBX_PORT is set explicitly.
if [ -z "${DBX_PORT:-}" ]; then
  export DBX_PORT="${PORT:-4224}"
fi

# An empty DBX_PASSWORD is not "no password" to DBX: it becomes a valid empty
# password and anyone can log in. Treat empty as unset, so DBX falls back to the
# password saved in the UI, or asks for one on first visit.
if [ -n "${DBX_PASSWORD+x}" ] && [ -z "$DBX_PASSWORD" ]; then
  echo "railway: DBX_PASSWORD is empty, ignoring it (set a password in the variable, or on first visit)"
  unset DBX_PASSWORD
fi

# Native MCP at /mcp: DBX refuses to start on an empty or whitespace token, or a
# token without allowed Hosts. Drop an unusable token with a log line instead.
if [ -n "${DBX_WEB_MCP_TOKEN+x}" ]; then
  DBX_WEB_MCP_TOKEN="$(printf '%s' "$DBX_WEB_MCP_TOKEN" | tr -d '[:space:]')"
  if [ -z "$DBX_WEB_MCP_TOKEN" ]; then
    unset DBX_WEB_MCP_TOKEN
  else
    export DBX_WEB_MCP_TOKEN
    if [ -z "$(printf '%s' "${DBX_WEB_MCP_ALLOWED_HOSTS:-}" | tr -d '[:space:],')" ]; then
      if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
        export DBX_WEB_MCP_ALLOWED_HOSTS="$RAILWAY_PUBLIC_DOMAIN"
      else
        echo "railway: DBX_WEB_MCP_TOKEN is set but there is no public domain or DBX_WEB_MCP_ALLOWED_HOSTS, MCP stays off"
        unset DBX_WEB_MCP_TOKEN
      fi
    fi
  fi
fi
[ -n "${DBX_WEB_MCP_TOKEN_FILE+x}" ] && [ -z "$DBX_WEB_MCP_TOKEN_FILE" ] && unset DBX_WEB_MCP_TOKEN_FILE
if [ -n "${DBX_WEB_MCP_TOKEN:-}" ] && [ -n "${DBX_WEB_MCP_TOKEN_FILE:-}" ]; then
  echo "railway: both DBX_WEB_MCP_TOKEN and DBX_WEB_MCP_TOKEN_FILE are set, using DBX_WEB_MCP_TOKEN"
  unset DBX_WEB_MCP_TOKEN_FILE
fi

mkdir -p "${DBX_DATA_DIR:-/app/data}" "${DBX_BACKUP_ROOT:-/app/data/backups}"
exec "$@"
