#!/bin/sh

. ./config.sh
LIBWALLET_PATH="${EXTERNAL_IOS_SOURCE_DIR}/libwallet"
LIBWALLET_URL="https://github.com/itswisdomagain/libwallet.git"

git clone $LIBWALLET_URL $LIBWALLET_PATH --branch cgo
cd $LIBWALLET_PATH

SYSROOT=`xcrun --sdk iphoneos --show-sdk-path`
CLANG="clang -isysroot ${SYSROOT}"
CLANGXX="clang++ -isysroot ${SYSROOT}"

rm -rf ./build
CGO_ENABLED=1 GOOS=ios GOARCH=arm64 CC=$CLANG CXX=$CLANGXX \
go build -buildmode=c-archive -o ./build/libdcrwallet.a ./cgo || exit 1

CW_DECRED_DIR=${CW_ROOT}/cw_decred
HEADER_DIR=$CW_DECRED_DIR/lib/api
mv ${LIBWALLET_PATH}/build/libdcrwallet.h $HEADER_DIR

DEST_LIB_DIR=${CW_DECRED_DIR}/ios/External/lib
mkdir -p $DEST_LIB_DIR
mv ${LIBWALLET_PATH}/build/libdcrwallet.a $DEST_LIB_DIR

cd $CW_DECRED_DIR
dart run ffigen
