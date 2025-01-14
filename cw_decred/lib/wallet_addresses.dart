import 'dart:convert';
import 'dart:developer';

import 'package:cw_core/wallet_addresses.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_decred/api/libdcrwallet.dart' as libdcrwallet;

class DecredWalletAddresses extends WalletAddresses {
  DecredWalletAddresses(WalletInfo walletInfo) : super(walletInfo);

  String currentAddr = '';

  @override
  String get address {
    final cAddr = libdcrwallet.currentReceiveAddress(walletInfo.name) ?? '';
    if (cAddr != '') {
      currentAddr = cAddr;
    }
    return currentAddr;
  }

  String generateNewAddress() {
    final nAddr = libdcrwallet.newExternalAddress(walletInfo.name) ?? '';
    if (nAddr != '') {
      currentAddr = nAddr;
    }
    return nAddr;
  }

  List<String> addresses() {
    final res = libdcrwallet.addresses(walletInfo.name);
    final addrs = (json.decode(res) as List<dynamic>).cast<String>();
    return addrs;
  }

  @override
  set address(String addr) {}

  @override
  Future<void> init() async {
    address = walletInfo.address;
    await updateAddressesInBox();
  }

  @override
  Future<void> updateAddressesInBox() async {
    try {
      addressesMap.clear();
      addressesMap[address] = '';
      await saveAddressesInBox();
    } catch (e) {
      log(e.toString());
    }
  }
}
