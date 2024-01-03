#! /bin/bash
set -e

if [[ -z "${CONFIGURATION_SERVER_ENABLED}" ]]; then
  echo "Configuration server not enabled only using environment"
else
  echo "Configuration server enabled"
  if [[ -z "${POD}" ]]; then
    echo "Missing POD unable to fetch configuration"
    exit -1
  fi
  if [[ -z "${SECRET}" ]]; then
    echo "Missing SECRET unable to fetch configuration"
    exit -1
  fi
  if [[ -z "${CLIENT}" ]]; then
    echo "Missing CLIENT unable to fetch configuration"
    exit -1
  fi
  if [[ -z "${APPLICATION}" ]]; then
    echo "Missing APPLICATION unable to fetch configuration"
    exit -1
  fi
  echo "Configuration server enabled. Requesting Configuration for $POD/$APPLICATION for Client: $CLIENT"
  source /usr/bin/configuration.sh
  ruby /usr/bin/generate_secrets_yml.rb
fi

exec "$@"
