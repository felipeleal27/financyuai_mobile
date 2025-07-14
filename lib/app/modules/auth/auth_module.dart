import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/auth/auth_viewmodel.dart';
import 'package:neo_financyuai/app/views/auth/auth_page.dart';

class AuthModule extends Module {
  @override
  void binds(Injector i) {
    i.addLazySingleton<AuthViewmodel>(() => AuthViewmodel(i()));
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const AuthPage());
  }
}
