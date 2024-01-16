import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cw_decred/api/libdcrwallet_bindings.dart';
import 'package:cw_decred/api/util.dart';

final int ErrCodeNotSynced = 1;

final String libraryName =
    Platform.isAndroid || Platform.isLinux // TODO: Linux.
        ? 'libdcrwallet.so'
        : 'cw_decred.framework/cw_decred';

final dcrwalletApi = libdcrwallet(DynamicLibrary.open(libraryName));

/// initLibdcrwallet initializes libdcrwallet using the provided logDir and gets
/// it ready for use. This must be done before attempting to create, load or use
/// a wallet.
void initLibdcrwallet(String logDir) {
  final cLogDir = logDir.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.initialize(cLogDir),
    ptrsToFree: [cLogDir],
  );
  checkErr(res.err);
}

/// createWalletAsync calls the libdcrwallet's createWallet function
/// asynchronously.
Future<void> createWalletAsync(
    {required String name, required String dataDir, required String password}) {
  final args = <String, String>{
    "name": name,
    "dataDir": dataDir,
    "password": password,
  };
  return compute(createWalletSync, args);
}

/// createWalletSync calls the libdcrwallet's createWallet function
/// synchronously.
void createWalletSync(Map<String, String> args) {
  final name = args["name"]!.toCString();
  final dataDir = args["dataDir"]!.toCString();
  final password = args["password"]!.toCString();
  final network = "simnet".toCString();

  final res = payloadAndPointers(
    fn: () => dcrwalletApi.createWallet(name, dataDir, network, password),
    ptrsToFree: [name, dataDir, network, password],
  );
  checkErr(res.err);
}

/// loadWalletAsync calls the libdcrwallet's loadWallet function asynchronously.
Future<void> loadWalletAsync({required String name, required String dataDir}) {
  final args = <String, String>{
    "name": name,
    "dataDir": dataDir,
  };
  return compute(loadWalletSync, args);
}

/// loadWalletSync calls the libdcrwallet's loadWallet function synchronously.
void loadWalletSync(Map<String, String> args) {
  final name = args["name"]!.toCString();
  final dataDir = args["dataDir"]!.toCString();
  final network = "simnet".toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.loadWallet(name, dataDir, network),
    ptrsToFree: [name, dataDir, network],
  );
  checkErr(res.err);
}

Future<void> startSyncAsync({required String name, required String peers}) {
  final args = <String, String>{
    "name": name,
    "peers": peers,
  };
  return compute(startSync, args);
}

void startSync(Map<String, String> args) {
  final name = args["name"]!.toCString();
  final peers = args["peers"]!.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.syncWallet(name, peers),
    ptrsToFree: [name, peers],
  );
  checkErr(res.err);
}


void closeWallet(String walletName) {
  final name = walletName.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.closeWallet(name),
    ptrsToFree: [name],
  );
  checkErr(res.err);
}

Future<void> changeWalletPassword(
    String walletName, String currentPassword, String newPassword) async {
  // TODO.
}

String? walletSeed(String walletName, String walletPassword) {
  final cName = walletName.toCString();
  final pass = walletPassword.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.walletSeed(cName, pass),
    ptrsToFree: [cName, pass],
  );
  checkErr(res.err);
  return res.payload;
}

String? currentReceiveAddress(String walletName) {
  final cName = walletName.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.currentReceiveAddress(cName),
    ptrsToFree: [cName],
  );

  if (res.errCode == ErrCodeNotSynced) {
    // Wallet is not synced. We do not want to give out a used address so give
    // nothing.
    return null;
  }
  checkErr(res.err);
  return res.payload;
}

String syncStatus(String walletName) {
  final cName = walletName.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.syncWalletStatus(cName),
    ptrsToFree: [cName],
  );
  checkErr(res.err);
  return res.payload;
}

Map balance(String walletName) {
  final cName = walletName.toCString();
  final res = payloadAndPointers(
    fn: () => dcrwalletApi.walletBalance(cName),
    ptrsToFree: [cName],
  );
  checkErr(res.err);
  return jsonDecode(res.payload);
}

int calculateEstimatedFeeWithFeeRate(int feeRate, int amount) {
  // Ideally we create a tx with wallet going to this amount and just return
  // the fee we get back. TODO.
  return 123000;
}
