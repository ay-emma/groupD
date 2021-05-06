import 'package:gallery/studies/shrine/model/authentication.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = ChangeNotifierProvider<AuthUser>((ref) {
  return AuthUser();
});
