#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TRUECHARTS_CATALOG_GIT="https://github.com/truecharts/catalog.git"
IX_VALUES_OVERWRITE_FILE="${SCRIPTPATH}/ix_values.overwrite.yaml"

function getTrueChartsCatalog() {
    echo -e "Getting latest TrueCharts catalog:"
    if [ ! -d "./truecharts_catalog" ]; then
        git clone "${TRUECHARTS_CATALOG_GIT}" truecharts_catalog
    else
        (
            cd ./truecharts_catalog \
            && git pull
        )
    fi
}

# 1. get latest trueCharts catalog
getTrueChartsCatalog

# 2. copy the new vaultwarden stable version
cp -a truecharts_catalog/stable/vaultwarden/ ./stable/vaultwarden

# 3. overwite the ix_values to use sqllite
find ./stable/vaultwarden -type f -name "ix_values.yaml" -print0 |
    while IFS= read -r -d '' ixValueFile; do
        echo "Updating: ${ixValueFile}"
        yq eval-all '. as $item ireduce ({}; . * $item )' "${ixValueFile}" "${IX_VALUES_OVERWRITE_FILE}" | sponge "${ixValueFile}"
    done

# 4. update catalog capabilities
echo "Updating: features capability"
cp -a truecharts_catalog/features_capability.json .
