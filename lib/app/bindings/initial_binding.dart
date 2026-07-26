import 'package:get/get.dart';

/// Global dependencies are registered in [main] before [runApp].
/// This binding remains as an extension point for future app-wide DI.
class InitialBinding extends Bindings {
  @override
  void dependencies() {}
}
