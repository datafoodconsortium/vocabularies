#!/bin/bash - 
#===============================================================================
#
#          FILE: synchronize.sh
# 
#         USAGE: ./synchronize.sh
# 
#   DESCRIPTION: Synchronizes a list of Semantic Turkey projects with remote
#                RDF/XML data.
# 
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ST_API_ROOT="/semanticturkey/it.uniroma2.art.semanticturkey/st-core-services"
CONFIG_FILE="${SCRIPT_PATH}/sync-config.json"

source "${SCRIPT_PATH}/st-requests.sh"

# Gets a session token.

function login() {
  local endpoint="$1" email="$2" password="$3" token

  token=$(send_login_request "$endpoint" "$email" "$password")
  if [[ -z "$token" ]]; then
    echo "Error: Login failed. Unable to retrieve session token." >&2
    exit 1
  fi

  echo "$token"
}

# Syncs a single project.

function sync_project() {
  local endpoint="$1" token="$2"                                  \
        project_name="${3-}" base_uri="${4-}" source_url="${5-}"  \
        response res_type trace

  echo
  echo "Source: ${source_url}"
  echo "Base URI: ${base_uri}"
  echo "Destination project: ${project_name}"
  echo

  response=$(
    send_sync_request       \
      "$endpoint" "$token"  \
      "$project_name" "$base_uri" "$source_url"
  )
  res_type=$(echo "$response" | jq -r '.stresponse.type')

  # We get 200 HTTP codes on error, so I had to be creative here:
  if [[ "${res_type}" == 'error' || "${res_type}" == 'exception' ]]; then
    trace=$(echo "$response" | jq -r '.stresponse.stackTrace')
    echo "Stack trace: " >&2
    echo -e "$trace\n" >&2
    echo "RDF sync failed." >&2
    return 1
  fi
}

# Syncs all projects listed in config file.

function sync_projects() {
  local endpoint="$1" token="$2"  \
        project_name base_uri source_url project

  jq -c '.projects[]' "${CONFIG_FILE}" | while read -r project; do
    project_name=$(echo "$project" | jq -r '.project_name // ""')
    base_uri=$(echo "$project" | jq -r '.base_uri // ""')
    source_url=$(echo "$project" | jq -r '.source_url // ""')

    if [[ -z "$project_name" || -z "$base_uri" || -z "$source_url" ]]; then
      echo "Warning: Skipping 1 project missing configuration." >&2
      echo "Ensure the following are set in ${CONFIG_FILE}:" >&2
      echo "    projects[].project_name" >&2
      echo "    projects[].base_uri" >&2
      echo "    projects[].source_url" >&2
    else
      echo "Processing $project_name..."
      sync_project \
        "$endpoint" "$token" \
        "$project_name" "$base_uri" "$source_url" || return 1
    fi
  done
}

# Entry point.

function main() {
  local showvoc_url u_email u_password endpoint token

  showvoc_url=$(jq -r '.global.showvoc_url // ""' "${CONFIG_FILE}")
  u_email=$(jq -r '.global.user_email  // ""' "${CONFIG_FILE}")
  u_password="${SHOWVOC_PASSWORD:-}"
  endpoint="${showvoc_url%/}${ST_API_ROOT}"

  if [[ -z "$showvoc_url" || -z "$u_email" ]]; then
    echo "Error: Missing required configuration." >&2
    echo "Ensure the following are set in ${CONFIG_FILE}:" >&2
    echo "    global.showvoc_url" >&2
    echo "    global.user_email" >&2
    echo "Optional: env variable SHOWVOC_PASSWORD will be prompted if not set." >&2
    exit 1
  fi

  [[ -z "$u_password" ]] && echo "SHOWVOC_PASSWORD not set or empty."

  echo "Logging in to ShowVoc..."
  [ -z "$u_password" ] && read -rsp "Password for $u_email: " u_password && echo
  token=$(login "$endpoint" "$u_email" "$u_password")
  [ -z "$token" ] && exit 1
  echo "Login successful."

  echo "Starting sync."
  echo
  sync_projects "$endpoint" "$token" && echo "🍺 RDF sync completed successfully."
}


main "$@"
