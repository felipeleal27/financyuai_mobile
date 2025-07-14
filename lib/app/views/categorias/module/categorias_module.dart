import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/viewmodel/categorias/categorias_viewmodel.dart';
import 'package:neo_financyuai/app/views/categorias/categorias_page.dart';
import 'package:neo_financyuai/app/views/categorias/module/categorias_nome_rotas.dart';
import 'package:neo_financyuai/app/service/firebase_category_service.dart';

/// Módulo responsável pela configuração de Categorias.
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade de gerenciamento de categorias da aplicação.
class CategoriasModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton(FirebaseCategoryService.new);
    i.addLazySingleton(CategoriasViewmodel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(CategoriasNomeRotas.inicial, child: (context) => const CategoriasPage());
  }
}
