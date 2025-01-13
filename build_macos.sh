cd scripts/macos/
source ./app_env.sh cakewallet
./app_config.sh
./build_decred.sh # ./build_all.sh
cd ../../
flutter pub get
dart run tool/generate_new_secrets.dart
flutter packages pub run tool/generate_localization.dart
./model_generator.sh
(cd macos && pod install)
echo "all done, update team and bundle id in xcode, then build or run"