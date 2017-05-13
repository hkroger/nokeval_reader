#!/bin/bash

set -e

cd `dirname $0`
ROOT=`pwd`
rm -rf debroot
TARGET=$ROOT/debroot/nokeval_reader/
READER_TARGET=$TARGET/opt/nokeval_reader/
SERVICE_TARGET=$TARGET/etc/systemd/system/
LOGROTATE_TARGET=$TARGET/etc/logrotate.d
mkdir -p "$TARGET"
mkdir -p "$READER_TARGET"
mkdir -p "$SERVICE_TARGET"
mkdir -p "$LOGROTATE_TARGET"

cp -r DEBIAN "$TARGET"
cp -r Gemfile* "$READER_TARGET"
cp -r LICE* "$READER_TARGET"
cp -r READ* "$READER_TARGET"
cp -r config.yaml.example "$READER_TARGET"
cp -r lib "$READER_TARGET"
cp -r reader.rb "$READER_TARGET"
cp -r nokeval_reader.logrotate "$LOGROTATE_TARGET/nokeval_reader"
cp nokeval_reader.service "$SERVICE_TARGET"

cd debroot

dpkg -b nokeval_reader

VERSION=`dpkg -I nokeval_reader.deb |grep Version|sed -e 's/Version: //g' -e 's/ //g'`

mv nokeval_reader.deb nokeval_reader_$VERSION.deb

