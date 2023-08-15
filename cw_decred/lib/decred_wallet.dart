import 'package:cw_decred/decred_mnemonic.dart';
import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/unspent_coins_info.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;
import 'package:cw_decred/electrum_wallet_snapshot.dart';
import 'package:cw_decred/electrum_wallet.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_decred/decred_address_record.dart';
import 'package:cw_decred/electrum_balance.dart';
import 'package:cw_decred/decred_wallet_addresses.dart';
import 'package:cw_decred/decred_network.dart';

part 'decred_wallet.g.dart';

class DecredWallet = DecredWalletBase with _$DecredWallet;

abstract class DecredWalletBase extends ElectrumWallet with Store {
  DecredWalletBase(
      {required String mnemonic,
      required String password,
      required WalletInfo walletInfo,
      required Box<UnspentCoinsInfo> unspentCoinsInfo,
      required Uint8List seedBytes,
      List<DecredAddressRecord>? initialAddresses,
      ElectrumBalance? initialBalance,
      int initialRegularAddressIndex = 0,
      int initialChangeAddressIndex = 0})
      : super(
            mnemonic: mnemonic,
            password: password,
            walletInfo: walletInfo,
            unspentCoinsInfo: unspentCoinsInfo,
            networkType: decredMainnet,
            initialAddresses: initialAddresses,
            initialBalance: initialBalance,
            seedBytes: seedBytes,
            currency: CryptoCurrency.btc) {
    walletAddresses = DecredWalletAddresses(
        walletInfo,
        electrumClient: electrumClient,
        initialAddresses: initialAddresses,
        initialRegularAddressIndex: initialRegularAddressIndex,
        initialChangeAddressIndex: initialChangeAddressIndex,
        mainHd: hd,
        sideHd: bitcoin.HDWallet.fromSeed(seedBytes, network: networkType)
              .derivePath("m/0'/1"),
        networkType: networkType);
  }

  static Future<DecredWallet> create({
    required String mnemonic,
    required String password,
    required WalletInfo walletInfo,
    required Box<UnspentCoinsInfo> unspentCoinsInfo,
    List<DecredAddressRecord>? initialAddresses,
    ElectrumBalance? initialBalance,
    int initialRegularAddressIndex = 0,
    int initialChangeAddressIndex = 0
  }) async {
    return DecredWallet(
        mnemonic: mnemonic,
        password: password,
        walletInfo: walletInfo,
        unspentCoinsInfo: unspentCoinsInfo,
        initialAddresses: initialAddresses,
        initialBalance: initialBalance,
        seedBytes: await mnemonicToSeedBytes(mnemonic),
        initialRegularAddressIndex: initialRegularAddressIndex,
        initialChangeAddressIndex: initialChangeAddressIndex);
  }

  static Future<DecredWallet> open({
    required String name,
    required WalletInfo walletInfo,
    required Box<UnspentCoinsInfo> unspentCoinsInfo,
    required String password,
  }) async {
    final snp = await ElectrumWallletSnapshot.load(name, walletInfo.type, password);
    return DecredWallet(
        mnemonic: snp.mnemonic,
        password: password,
        walletInfo: walletInfo,
        unspentCoinsInfo: unspentCoinsInfo,
        initialAddresses: snp.addresses,
        initialBalance: snp.balance,
        seedBytes: await mnemonicToSeedBytes(snp.mnemonic),
        initialRegularAddressIndex: snp.regularAddressIndex,
        initialChangeAddressIndex: snp.changeAddressIndex);
  }
}
