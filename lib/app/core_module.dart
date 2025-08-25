import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:neo_financyuai/app/database/local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository_impl.dart';
import 'package:neo_financyuai/app/repository/splash_screen_repository/splash_screen_repository.dart';
import 'package:neo_financyuai/app/repository/splash_screen_repository/splash_screen_repository_impl.dart';
import 'package:neo_financyuai/app/service/dio/dio_rest_client.dart';
import 'package:neo_financyuai/app/service/exceptions/rest_client.dart';
import 'package:neo_financyuai/app/service/initialization_service.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/saldo_service.dart';
import 'package:neo_financyuai/app/utils/theme_manager.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';

/// Módulo central da aplicação.
/// 
/// Define todas as dependências principais que serão compartilhadas
/// entre os módulos da aplicação, incluindo repositórios, serviços,
/// gerenciador de temas e ViewModels.
class CoreModule extends Module {

  @override
  void exportedBinds(Injector i) {
    // Rest Client
    i.addSingleton<RestClient>(DioRestClient.new);

    // Repositories
    i.addSingleton<LocalStorage>(SharedPreferencesLocalStorageImpl.new);
    i.addSingleton<HomeRepository>(HomeRepositoryImpl.new);
    i.addSingleton<SplashScreenRepository>(SplashScreenRepositoryImpl.new);
    
    // Services
    i.addSingleton<InitializationService>(InitializationService.new);
    i.addSingleton<FirebaseSyncService>(() => FirebaseSyncService());
    i.addSingleton<NotificationService>(() => NotificationService());
    i.addSingleton<AuthService>(() => AuthService());
    i.addSingleton<SaldoService>(() {
      final saldoService = SaldoService();
      saldoService.initialize(
        homeRepository: i.get<HomeRepository>(),
        authService: i.get<AuthService>(),
      );
      return saldoService;
    });
    
    // Theme Manager
    i.addSingleton<ThemeManager>(ThemeManager.new);
    
    // ViewModels
    i.addSingleton(HomeViewmodel.new);
  }
}