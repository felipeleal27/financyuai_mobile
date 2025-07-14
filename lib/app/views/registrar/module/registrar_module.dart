import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/registrar/registrar_viewmodel.dart';
import 'package:neo_financyuai/app/views/registrar/module/registar_nome_rotas.dart';
import 'package:neo_financyuai/app/views/registrar/registrar_page.dart';

class RegistrarModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton(RegistrarViewmodel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(RegistrarNomeRotas.inicial, child: (context) => const RegistrarPage());
  }
}
