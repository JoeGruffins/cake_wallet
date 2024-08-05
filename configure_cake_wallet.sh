#!/bin/bash

IOS="ios"
ANDROID="android"
MACOS="macos"

PLATFORMS=($IOS $ANDROID $MACOS)
PLATFORM=$1

if ! [[ " ${PLATFORMS[*]} " =~ " ${PLATFORM} " ]]; then
    echo "specify platform: ./configure_cake_wallet.sh ios|android|macos"
    exit 1
fi

if [ "$PLATFORM" == "$IOS" ]; then
    echo "Configuring for iOS"
    cd scripts/ios
fi

if [ "$PLATFORM" == "$MACOS" ]; then
    echo "Configuring for macOS"
    cd scripts/macos
fi

if [ "$PLATFORM" == "$ANDROID" ]; then
    echo "Configuring for Android"
    cd scripts/android
fi

echo "============================ BUILDING DEPS ============================"

source ./app_env.sh cakewallet
./app_config.sh
./build_decred.sh

if [ "$PLATFORM" == "$MACOS" ]; then
   ./gen.sh
fi

echo "=================== generate secrets, localization ===================="

cd ../.. && flutter pub get
flutter packages pub run tool/generate_localization.dart # If this fails, add --force flag to the command

# NOTE: You only need to do this the first time you are trying to run the app.
# If you have done it before and have created a wallet after then, please skip.
# Else, you'll not be able to login that wallet again and will have to create a
# new wallet. If the command below fails, add --force flag and try again.

# flutter packages pub run tool/generate_new_secrets.dart 


echo "================================ MBOX ================================="

./model_generator.sh

if [ "$PLATFORM" == "$IOS" ] || [ "$PLATFORM" == "$MACOS"  ]; then
    cd $PLATFORM && pod install
fi

echo "
============================ ALL DONE. NEXT STEPS: ====================
=                                                                     =
= UPDATE TEAM AND BUNDLE IDENTIFIER IN XCODE > SIGNING & CAPABILITIES =
=                                                                     =
=======================================================================
"