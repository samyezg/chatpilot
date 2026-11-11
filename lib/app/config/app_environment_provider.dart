import 'package:chatpilot_app/app/config/app_environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  return AppEnvironment.fromDefines();
});
