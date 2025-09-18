import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/views/estatisticas/pages/estatisticas_page.dart';
import 'package:neo_financyuai/app/views/estatisticas/module/estatisticas_nome_rotas.dart';

class EstatisticasModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void routes(RouteManager r) {
    r.child(EstatisticasNomeRotas.inicial, child: (_) => const EstatisticasPage());
  }
}
