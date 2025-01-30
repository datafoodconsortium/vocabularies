#!/bin/bash - 
#===============================================================================
#
#          FILE: st-requests.sh
# 
#         USAGE: source st-requests.sh
# 
#   DESCRIPTION: Helper functions to send requests to a Semantic Turkey API.
# 
#===============================================================================

# Sends a login request, returns a session token.

function send_login_request() {
  local endpoint="$1" email="$2" password="$3" response

  response=$(
    curl -s -D - "${endpoint%/}/Auth/login" \
      -F "email=${email}" \
      -F "password=${password}" \
      -F "_spring_security_remember_me=false" \
      --insecure
  )
  
  echo "$response" | sed -n 's/set-cookie: JSESSIONID=\([^;]*\).*/\1/p'
}

# Builds loader specification parameter value.

function _get_loader_spec() {
  jq -n \
    --arg source_url "$1" \
    '{
      "factoryId": "it.uniroma2.art.semanticturkey.extension.impl.loader.http.HTTPLoader",
      "configType": "it.uniroma2.art.semanticturkey.extension.impl.loader.http.HTTPLoaderConfiguration",
      "configuration": {
        "@type": "it.uniroma2.art.semanticturkey.extension.impl.loader.http.HTTPLoaderConfiguration",
        "endpoint": $source_url,
        "enableContentNegotiation": true,
        "reportContentType": false
      }
    }'
}

# Builds lifter specification parameter value

function _get_lifter_spec() {
  jq -n \
    '{
      "factoryId": "it.uniroma2.art.semanticturkey.extension.impl.rdflifter.rdfdeserializer.RDFDeserializingLifter"
    }'
}

# Sends a sync request, returns the raw response.

function send_sync_request() {
  local endpoint="$1" token="$2"  \
        project_name="$3" base_uri="$4" source_url="$5"

  curl -s "${endpoint%/}/InputOutput/loadRDF?ctx_project=${project_name}"  \
    -H "Cookie: JSESSIONID=${token}"                                       \
    -F "baseURI=${base_uri}"                                               \
    -F "transitiveImportAllowance=web"                                     \
    -F "format=RDF/XML"                                                    \
    -F "loaderSpec=$(_get_loader_spec $source_url)"                        \
    -F "rdfLifterSpec=$(_get_lifter_spec)"                                 \
    -F "transformationPipeline=[]"                                         \
    --insecure
}
