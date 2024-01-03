#!/bin/bash
set -e

# Generate the script for configuration and write to a temp file
configurator --secret $SECRET --client $CLIENT --application $APPLICATION --claim --pod $POD > /tmp/gen_configuration.sh
echo "Configuration load successful"
source /tmp/gen_configuration.sh
