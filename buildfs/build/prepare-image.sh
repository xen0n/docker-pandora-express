#!/bin/bash

tarball="$1"
destdir="$2"

unpack() {
    pushd "$destdir"
    # all paths are like ./pandora-express/* so strip that out
    tar xf "$tarball" --strip-components=2
    popd
}

verify() {
    local signature_file="${tarball}.sig"
    pushd "$destdir"
    if ! ./verifySignature.sh \
        -i "$tarball" \
        -s "$signature_file" \
        -p public.pem
    then
        exit 1
    fi
    popd
}

trim() {
    pushd "$destdir"
    # tree -L 3  # for pandora-express v0.5.1, top-level dir not stripped
    # .
    # └── pandora-express
    #     ├── conf
    #     │   ├── elasticsearch.yml
    #     │   ├── jvm.options
    #     │   └── log4j2.properties
    #     ├── lib
    #     │   ├── jdk-11.0.5
    #     │   ├── mysql
    #     │   └── pandora
    #     ├── log
    #     │   └── phoenix-mysql-error.log
    #     ├── pandoractl
    #     ├── public.pem
    #     ├── security.check
    #     ├── start.bat
    #     ├── startService.sh
    #     ├── start.sh
    #     ├── uninstall.sh
    #     ├── verifySignature.sh
    #     └── version
    #
    # 7 directories, 13 files

    # un-bundle things
    # XXX there's a f**king manifest check during app init
    # so these files must be left alone atm
    #rm -rf lib/jdk-*
    #rm -rf lib/mysql

    # this is injected on container creation
    rm conf/elasticsearch.yml

    # our log is inside persistent volume so kill off the outside log dir
    rm -rf log

    # remove useless scripts
    rm pandoractl start.bat startService.sh start.sh uninstall.sh

    # this is useless after installation
    rm verifySignature.sh public.pem

    # this seems only used on macOS
    rm security.check

    popd
}

main() {
    mkdir -p "$destdir"
    unpack
    # don't have openssl in builder image
    # verify
    trim
}

main
