import 'dart:io';
import 'package:cw_decred/decred_mnemonic.dart';
import 'package:cw_decred/decred_mnemonic_is_incorrect_exception.dart';
import 'package:cw_decred/decred_wallet_creation_credentials.dart';
import 'package:cw_core/unspent_coins_info.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:cw_decred/decred_wallet.dart';
import 'package:cw_core/pathForWallet.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class DecredWalletService extends WalletService<
    DecredNewWalletCredentials,
    DecredRestoreWalletFromSeedCredentials,
    DecredRestoreWalletFromWIFCredentials> {
  DecredWalletService(this.walletInfoSource, this.unspentCoinsInfoSource);

  final Box<WalletInfo> walletInfoSource;
  final Box<UnspentCoinsInfo> unspentCoinsInfoSource;

  @override
  WalletType getType() => WalletType.decred;

  @override
  Future<DecredWallet> create(DecredNewWalletCredentials credentials) async {
    final wallet = await DecredWalletBase.create(
        mnemonic: await generateMnemonic(),
        password: credentials.password!,
        walletInfo: credentials.walletInfo!,
        unspentCoinsInfo: unspentCoinsInfoSource);
    await wallet.save();
    await wallet.init();
    return wallet;
  }

  @override
  Future<bool> isWalletExit(String name) async =>
      File(await pathForWallet(name: name, type: getType())).existsSync();

  @override
  Future<DecredWallet> openWallet(String name, String password) async {
    final walletInfo = walletInfoSource.values.firstWhereOrNull(
        (info) => info.id == WalletBase.idFor(name, getType()))!;
    final wallet = await DecredWalletBase.open(
        password: password, name: name, walletInfo: walletInfo,
        unspentCoinsInfo: unspentCoinsInfoSource);
    await wallet.init();
    return wallet;
  }

  @override
  Future<void> remove(String wallet) async {
    File(await pathForWalletDir(name: wallet, type: getType()))
        .delete(recursive: true);
    final walletInfo = walletInfoSource.values.firstWhereOrNull(
        (info) => info.id == WalletBase.idFor(wallet, getType()))!;
    await walletInfoSource.delete(walletInfo.key);
  }

  @override
  Future<void> rename(String currentName, String password, String newName) async {
    final currentWalletInfo = walletInfoSource.values.firstWhereOrNull(
        (info) => info.id == WalletBase.idFor(currentName, getType()))!;
    final currentWallet = await DecredWalletBase.open(
        password: password,
        name: currentName,
        walletInfo: currentWalletInfo,
        unspentCoinsInfo: unspentCoinsInfoSource);

    await currentWallet.renameWalletFiles(newName);

    final newWalletInfo = currentWalletInfo;
    newWalletInfo.id = WalletBase.idFor(newName, getType());
    newWalletInfo.name = newName;

    await walletInfoSource.put(currentWalletInfo.key, newWalletInfo);
  }

  @override
  Future<DecredWallet> restoreFromKeys(
          DecredRestoreWalletFromWIFCredentials credentials) async =>
      throw UnimplementedError();

  @override
  Future<DecredWallet> restoreFromSeed(
      DecredRestoreWalletFromSeedCredentials credentials) async {
    if (!validateMnemonic(credentials.mnemonic)) {
      throw DecredMnemonicIsIncorrectException();
    }

    final wallet = await DecredWalletBase.create(
        password: credentials.password!,
        mnemonic: credentials.mnemonic,
        walletInfo: credentials.walletInfo!,
        unspentCoinsInfo: unspentCoinsInfoSource);
    await wallet.save();
    await wallet.init();
    return wallet;
  }
}
