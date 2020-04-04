#!/bin/bash

# setup global environment with defaults
prepare_env() {
    # paths
    # adapted from pandoractl with minor modifications

    # bin/lib
    : "${PANDORA_EXPRESS_ROOT:=/home/pdr}"
    : "${PANDORA_EXPRESS_BIN_PATH:=$PANDORA_EXPRESS_ROOT/lib/pandora}"

    # persistent data
    : "${PANDORA_EXPRESS_DATA_ROOT:=$PANDORA_EXPRESS_ROOT/.pandora}"
    : "${PANDORA_EXPRESS_CONF_PATH:=$PANDORA_EXPRESS_DATA_ROOT/conf}"
    # NOTE: this is outside the data dir in original pandoractl
    # : "${PANDORA_EXPRESS_LOG_PATH:=$PANDORA_EXPRESS_ROOT/log}"
    : "${PANDORA_EXPRESS_LOG_PATH:=$PANDORA_EXPRESS_DATA_ROOT/log}"
    : "${PANDORA_EXPRESS_DATA_PATH:=$PANDORA_EXPRESS_DATA_ROOT/data}"
    : "${PANDORA_EXPRESS_STATUS_PATH:=$PANDORA_EXPRESS_DATA_ROOT/status}"
    : "${PANDORA_EXPRESS_APP_PATH:=$PANDORA_EXPRESS_DATA_ROOT/apps}"

    # service metadata
    : "${PANDORA_EXPRESS_CLUSTER_NAME:=pandora}"
    : "${PANDORA_EXPRESS_NODE_NAME:-pandora-1}"
    : "${PANDORA_EXPRESS_HOST:=0.0.0.0}"
    : "${PANDORA_EXPRESS_HTTP_PORT:=9999}"
    : "${PANDORA_EXPRESS_TCP_PORT:=9300}"

    : "${PANDORA_EXPRESS_MYSQL_DB_ADDR:?mysql db address must be set}"
    : "${PANDORA_EXPRESS_MYSQL_DB_PORT:?mysql db port must be set}"
    : "${PANDORA_EXPRESS_MYSQL_DB_NAME:=phoenix}"
    : "${PANDORA_EXPRESS_MYSQL_DB_USER:=phoenix}"
    : "${PANDORA_EXPRESS_MYSQL_DB_PASS:?mysql password must be set}"

    # make necessary dirs
    mkdir -p \
        "$PANDORA_EXPRESS_CONF_PATH" \
        "$PANDORA_EXPRESS_LOG_PATH" \
        "$PANDORA_EXPRESS_STATUS_PATH" \
        "$PANDORA_EXPRESS_APP_PATH" \
        "$PANDORA_EXPRESS_DATA_PATH/pandora"
}

render_conf() {
    local output_path="$PANDORA_EXPRESS_CONF_PATH/elasticsearch.yml"

    cat > "$output_path" <<EOF
cluster.name: "$PANDORA_EXPRESS_CLUSTER_NAME"
node.name: "$PANDORA_EXPRESS_NODE_NAME"
path.data: "$PANDORA_EXPRESS_DATA_PATH/pandora"
path.logs: "$PANDORA_EXPRESS_LOG_PATH"
http.port: $PANDORA_EXPRESS_HTTP_PORT
transport.tcp.port: $PANDORA_EXPRESS_TCP_PORT

network.host: "$PANDORA_EXPRESS_HOST"

phoenix.environment: distribution
phoenix.database.mysql.url: "$PANDORA_EXPRESS_MYSQL_DB_ADDR:$PANDORA_EXPRESS_MYSQL_DB_PORT"
phoenix.database.mysql.database: "$PANDORA_EXPRESS_MYSQL_DB_NAME"
phoenix.database.mysql.user: "$PANDORA_EXPRESS_MYSQL_DB_USER"
phoenix.database.mysql.password: "$PANDORA_EXPRESS_MYSQL_DB_PASS"
phoenix.static.file.root.path: ./webapp
phoenix.app.home: "$PANDORA_EXPRESS_APP_PATH"

cluster.routing.allocation.disk.watermark.low: 10gb
cluster.routing.allocation.disk.watermark.high: 5gb
cluster.routing.allocation.disk.watermark.flood_stage: 1gb

bootstrap.system_call_filter: false
EOF

    cp "$PANDORA_EXPRESS_ROOT/conf/*" "$PANDORA_EXPRESS_CONF_PATH/"
}

start_pandora() {
    pushd "$PANDORA_EXPRESS_ROOT"
    export ES_PATH_CONF="$PANDORA_EXPRESS_CONF_PATH"
    "$PANDORA_EXPRESS_BIN_PATH/bin/elasticsearch"
    popd
}

main() {
    prepare_env
    render_conf
    start_pandora
}

main
