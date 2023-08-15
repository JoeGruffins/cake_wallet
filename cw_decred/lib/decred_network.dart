import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;

final decredMainnet = new bitcoin.NetworkType(
    messagePrefix: '\x18Decred Signed Message:\n',
    bech32: 'bc',
    bip32: new bitcoin.Bip32Type(public :0x02fda926, private: 0x02fda4e8),
    pubKeyHash: 0x073f,
    scriptHash: 0x071a,
    wif: 0x22de);
