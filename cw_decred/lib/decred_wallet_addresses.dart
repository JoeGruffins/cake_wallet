import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;
import 'package:cw_decred/electrum.dart';
import 'package:cw_decred/utils.dart';
import 'package:cw_decred/decred_address_record.dart';
import 'package:cw_decred/electrum_wallet_addresses.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'decred_wallet_addresses.g.dart';

class DecredWalletAddresses = DecredWalletAddressesBase
    with _$DecredWalletAddresses;

abstract class DecredWalletAddressesBase extends ElectrumWalletAddresses
    with Store {
  DecredWalletAddressesBase(
      WalletInfo walletInfo,
      {required bitcoin.HDWallet mainHd,
        required bitcoin.HDWallet sideHd,
        required bitcoin.NetworkType networkType,
        required ElectrumClient electrumClient,
        List<DecredAddressRecord>? initialAddresses,
        int initialRegularAddressIndex = 0,
        int initialChangeAddressIndex = 0})
      : super(
        walletInfo,
        initialAddresses: initialAddresses,
        initialRegularAddressIndex: initialRegularAddressIndex,
        initialChangeAddressIndex: initialChangeAddressIndex,
        mainHd: mainHd,
        sideHd: sideHd,
        electrumClient: electrumClient,
        networkType: networkType);

  @override
  String getAddress({required int index, required bitcoin.HDWallet hd}) =>
      generateP2WPKHAddress(hd: hd, index: index, networkType: networkType);
}
