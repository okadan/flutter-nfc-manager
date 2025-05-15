# nfc_manager_ndef

A Flutter package that provides NDEF abstraction using `nfc_manager` plugin.

## Setup

See the `nfc_manager` plugin's [Setup](https://github.com/okadan/flutter-nfc-manager/tree/main/packages/nfc_manager/README.md#setup) section.

## Usage

```dart
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

final ndef = Ndef.from(tag);

if (ndef == null) {
  print('Tha tag is not compatible with NDEF.');
  return;
}

// Do something with a Ndef instance...
print(ndef);
```
