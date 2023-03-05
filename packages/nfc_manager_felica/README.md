# nfc_manager_felica

A Flutter package that provides FeliCa abstraction using `nfc_manager` plugin.

## Setup

See the `nfc_manager` plugin's [Setup](https://github.com/okadan/flutter-nfc-manager/packages/nfc_manager/README.md#setup) section.

## Usage

```dart
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_felica/nfc_manager_felica.dart';

final felica = FeliCa.from(tag);

if (felica == null) {
  print('Tha tag is not compatible with FeliCa.');
  return;
}

// Do something with a FeliCa instance...
print(felica);
```
