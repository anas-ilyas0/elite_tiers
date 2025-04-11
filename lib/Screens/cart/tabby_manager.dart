import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class TabbyManager {
  static final TabbyManager _instance = TabbyManager._internal();

  late TabbySDK tabbySDK;
  bool _isInitialized = false;

  TabbyManager._internal();

  factory TabbyManager() {
    return _instance;
  }

  void initialize() {
    if (!_isInitialized) {
      tabbySDK = TabbySDK();
      tabbySDK.setup(
        withApiKey: 'pk_test_019010e7-f08e-9fe1-1b56-f48ae62cfa80',
        environment: Environment.production,
      );
      _isInitialized = true;
      print('Tabby Initialized');
    } else {
      print('TabbySDK already initialized');
    }
  }
}
