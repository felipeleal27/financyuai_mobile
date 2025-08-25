import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:neo_financyuai/app/repository/splash_screen_repository/splash_screen_repository.dart';
import 'package:neo_financyuai/app/service/initialization_service.dart';

part 'splash_screen_viewmodel.g.dart';

/// ViewModel responsável pela lógica da tela de splash
/// 
/// Gerencia:
/// - Inicialização dos serviços do aplicativo
/// - Cálculo do saldo inicial
/// - Configuração de categorias padrão
/// - Timer de exibição da splash screen
class SplashScreenViewmodel = SplashScreenViewmodelBase
    with _$SplashScreenViewmodel;

/// Classe base do ViewModel da splash screen
abstract class SplashScreenViewmodelBase with Store {
  // final SplashScreenRepository _splashScreenRepository;
  final InitializationService _initializationService;

  SplashScreenViewmodelBase({
    required SplashScreenRepository splashScreenRepository,
    required InitializationService initializationService,
  }) : //_splashScreenRepository = splashScreenRepository,
       _initializationService = initializationService;

  @observable
  Duration? timer;

  Future<void> calcularSaldo() async {
    // await _splashScreenRepository.calcularSaldoTotal();
  }

  /// Inicializa categorias padrão se for primeiro acesso
  Future<void> inicializarCategoriasPadrao(String idUsuario) async {
    try {
      await _initializationService.popularCategoriasSePrimeiroAcesso(idUsuario);
    } catch (e) {
      debugPrint('Erro ao inicializar categorias: $e');
    }
  }
}
