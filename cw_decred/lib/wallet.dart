import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cw_core/transaction_direction.dart';
import 'package:cw_decred/pending_transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import 'package:cw_decred/api/libdcrwallet.dart' as libdcrwallet;
import 'package:cw_decred/transaction_history.dart';
import 'package:cw_decred/wallet_addresses.dart';
import 'package:cw_decred/transaction_priority.dart';
import 'package:cw_decred/balance.dart';
import 'package:cw_decred/transaction_info.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/transaction_priority.dart';
import 'package:cw_core/pending_transaction.dart';
import 'package:cw_core/pathForWallet.dart';
import 'package:cw_core/sync_status.dart';
import 'package:cw_core/node.dart';
import 'package:cw_core/unspent_transaction_output.dart';

part 'wallet.g.dart';

class DecredWallet = DecredWalletBase with _$DecredWallet;

abstract class DecredWalletBase extends WalletBase<DecredBalance,
    DecredTransactionHistory, DecredTransactionInfo> with Store {
  DecredWalletBase(WalletInfo walletInfo, String password)
      : _password = password,
        syncStatus = NotConnectedSyncStatus(),
        balance = ObservableMap.of({CryptoCurrency.dcr: DecredBalance.zero()}),
        super(walletInfo) {
    walletAddresses = DecredWalletAddresses(walletInfo);
    transactionHistory = DecredTransactionHistory();
  }

  // password is currently only used for seed display, but would likely also be
  // required to sign inputs when creating transactions.
  final String _password;
  bool connecting = false;
  String persistantPeer = "";
  Timer? syncTimer;

  // TODO: Set up a way to change the balance and sync status when dcrlibwallet
  // changes. Long polling probably?
  @override
  @observable
  SyncStatus syncStatus;

  @override
  @observable
  late ObservableMap<CryptoCurrency, DecredBalance> balance;

  @override
  late DecredWalletAddresses walletAddresses;

  @override
  String? get seed {
    return libdcrwallet.walletSeed(walletInfo.name, _password);
  }

  @override
  Object get keys {
    // throw UnimplementedError();
    return {};
  }

  Future<void> init() async {
    updateBalance();
    // TODO: update other wallet properties such as syncStatus, walletAddresses
    // and transactionHistory with data from libdcrwallet.
  }

  void checkSync() {
    final syncStatusJSON = libdcrwallet.syncStatus(walletInfo.name);
    final decoded = json.decode(syncStatusJSON);

    final syncStatusCode = decoded["syncstatuscode"] ?? 0;
    final syncStatusStr = decoded["syncstatus"] ?? "";
    final targetHeight = decoded["targetheight"] ?? 1;
    final numPeers = decoded["numpeers"] ?? 0;
    // final cFiltersHeight = decoded["cfiltersheight"] ?? 0;
    final headersHeight = decoded["headersheight"] ?? 0;
    final rescanHeight = decoded["rescanheight"] ?? 0;

    if (numPeers == 0) {
      syncStatus = NotConnectedSyncStatus();
      return;
    }

    // Sync codes:
	  // NotStarted = 0
	  // FetchingCFilters = 1
	  // FetchingHeaders = 2
	  // DiscoveringAddrs = 3
	  // Rescanning = 4
	  // Complete = 5

    if (syncStatusCode > 4) {
      syncStatus = ConnectedSyncStatus();
      return;
    }

    if (syncStatusCode == 1) {
      syncStatus = SyncingSyncStatus(targetHeight,0.0);
    }

    if (syncStatusCode == 2) {
      syncStatus = SyncingSyncStatus(targetHeight-headersHeight,headersHeight/targetHeight);
    }

    // TODO: This step takes a while so should really get more info to the UI
    // that we are discovering addresses.
    if (syncStatusCode == 3) {
      syncStatus = SyncingSyncStatus(100,99);
    }

    if (syncStatusCode == 4) {
      syncStatus = SyncingSyncStatus(targetHeight-rescanHeight,rescanHeight/targetHeight);
    }
  }

  @action
  @override
  Future<void> connectToNode({required Node node}) async {
    // Is this thread safe? Dart has no compare and swap?
    if (connecting) {
      throw "decred already connecting";
    }
    connecting = true;
    String addr = "";
    if (node.uri.host != "") {
      addr = node.uri.host;
      if (node.uri.port != "") {
        addr += ":" + node.uri.port.toString();
      }
    }
    if (addr != persistantPeer) {
      if (syncTimer != null) {
        syncTimer!.cancel();
        syncTimer = null;
      }
      persistantPeer = addr;
      libdcrwallet.closeWallet(walletInfo.name);
      libdcrwallet.loadWalletSync({
        "name": walletInfo.name,
        "dataDir": walletInfo.dirPath,
      });
    }
    await this._startSync();
    connecting = false;
  }

  @action
  @override
  Future<void> startSync() async {
    if (connecting) {
      throw "decred already connecting";
    }
    connecting = true;
    await this._startSync();
    connecting = false;
  }

  Future<void> _startSync() async {
    if (syncTimer != null) {
      return;
    }
    try {
      syncStatus = ConnectingSyncStatus();
      libdcrwallet.startSyncAsync(
        name: walletInfo.name,
        peers: persistantPeer,
      );
      syncTimer = Timer.periodic(Duration(seconds: 5), (Timer t) => checkSync());
    } catch (e) {
      print(e.toString());
      syncStatus = FailedSyncStatus();
    }
  }

  @override
  Future<PendingTransaction> createTransaction(Object credentials) async {
    return DecredPendingTransaction(
        txid:
            "3cbf3eb9523fd04e96dbaf98cdbd21779222cc8855ece8700494662ae7578e02",
        amount: 12345678,
        fee: 1234,
        rawHex: "baadbeef");
  }

  int feeRate(TransactionPriority priority) {
    // TODO
    return 1000;
  }

  @override
  int calculateEstimatedFee(TransactionPriority priority, int? amount) {
    if (priority is DecredTransactionPriority) {
      return libdcrwallet.calculateEstimatedFeeWithFeeRate(
          this.feeRate(priority), amount ?? 0);
    }

    return 0;
  }

  @override
  Future<Map<String, DecredTransactionInfo>> fetchTransactions() async {
    // TODO: Read from libdcrwallet.
    final txInfo = DecredTransactionInfo(
      id: "3cbf3eb9523fd04e96dbaf98cdbd21779222cc8855ece8700494662ae7578e02",
      amount: 1234567,
      fee: 123,
      direction: TransactionDirection.outgoing,
      isPending: true,
      date: DateTime.now(),
      height: 0,
      confirmations: 0,
      to: "DsT4qJPPaYEuQRimfgvSKxKH3paysn1x3Nt",
    );
    return {
      "3cbf3eb9523fd04e96dbaf98cdbd21779222cc8855ece8700494662ae7578e02": txInfo
    };
  }

  @override
  Future<void> save() async {}

  @override
  Future<void> rescan({required int height}) async {
    // TODO.
  }

  @override
  void close() {
    libdcrwallet.closeWallet(walletInfo.name);
  }

  @override
  Future<void> changePassword(String password) async {
    await libdcrwallet.changeWalletPassword(
        walletInfo.name, _password, password);
  }

  @override
  Future<void>? updateBalance() async {
    final balanceMap = libdcrwallet.balance(walletInfo.name);
    balance[CryptoCurrency.dcr] = DecredBalance(
      confirmed: balanceMap["confirmed"] ?? 0,
      unconfirmed: balanceMap["unconfirmed"] ?? 0,
    );
  }

  @override
  void setExceptionHandler(void Function(FlutterErrorDetails) onError) =>
      onError;

  Future<void> renameWalletFiles(String newWalletName) async {
    final currentWalletPath =
        await pathForWallet(name: walletInfo.name, type: type);
    final currentWalletFile = File(currentWalletPath);

    final currentDirPath =
        await pathForWalletDir(name: walletInfo.name, type: type);

    // TODO: Stop the wallet, wait, and restart after.

    // Copies current wallet files into new wallet name's dir and files
    if (currentWalletFile.existsSync()) {
      final newWalletPath =
          await pathForWallet(name: newWalletName, type: type);
      await currentWalletFile.copy(newWalletPath);
    }

    // Delete old name's dir and files
    await Directory(currentDirPath).delete(recursive: true);
  }

  @override
  String signMessage(String message, {String? address = null}) {
    return ""; // TODO
  }

  List<Unspent> unspents() {
    return [
      Unspent(
          "DsT4qJPPaYEuQRimfgvSKxKH3paysn1x3Nt",
          "3cbf3eb9523fd04e96dbaf98cdbd21779222cc8855ece8700494662ae7578e02",
          1234567,
          0,
          null)
    ];
  }
}
