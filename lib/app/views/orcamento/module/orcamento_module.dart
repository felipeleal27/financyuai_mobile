import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/views/orcamento/module/orcamento_nome_rotas.dart';
import 'package:neo_financyuai/app/views/orcamento/pages/orcamento_page.dart';

class OrcamentoModule extends Module {
  @override
  void binds(i) {}

  @override
  List<Module> get imports => [CoreModule()];

  @override
  void routes(RouteManager r) {
    r.child(
      OrcamentoNomeRotas.inicial,
      child: (_) => const OrcamentoPage(),
      transition: TransitionType.noTransition,
    );
  }
}
