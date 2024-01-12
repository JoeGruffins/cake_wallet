import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:convert';

class PayloadResult {
  String payload;
  String err;
  int errCode;
  PayloadResult(this.payload, this.err, this.errCode);
}

// Returns payload, error code, and error.
PayloadResult payloadAndPointers({
  required Pointer<Char> fn(),
  required List<Pointer> ptrsToFree,
}) {
  final jsonStr = fn().toDartString();
  freePointers(ptrsToFree);
  if (jsonStr == null) throw Exception("no json return from wallet library");
  final decoded = json.decode(jsonStr);

  final payload = decoded["payload"] ?? "";
  final err = decoded["error"] ?? "";
  final errCode = decoded["errorcode"] ?? -1;

  return new PayloadResult(payload, err, errCode);
}

void freePointers(List<Pointer> ptrsToFree) {
  for (final ptr in ptrsToFree) {
    malloc.free(ptr);
  }
}

void checkErr(String err) {
  if (err == "") return;
  throw Exception(err);
}

extension StringUtil on String {
  Pointer<Char> toCString() => toNativeUtf8().cast<Char>();
}

extension CStringUtil on Pointer<Char> {
  bool get isNull => address == nullptr.address;

  free() {
    malloc.free(this);
  }

  String? toDartString() {
    if (isNull) return null;

    final str = cast<Utf8>().toDartString();
    free();
    return str;
  }
}
