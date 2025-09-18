

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_financyuai/app/app_moudle.dart';
import 'package:neo_financyuai/app/app_widget.dart';
import 'package:neo_financyuai/app/utils/environments.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neo_financyuai/firebase_options.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/service/background_task_service.dart';
import 'package:neo_financyuai/app/service/ai_routine_service.dart';
import 'package:neo_financyuai/app/service/ai_holiday_service.dart';
import 'package:neo_financyuai/app/service/foreground_daily_scheduler.dart';
import 'package:neo_financyuai/app/service/ai_balance_forecast_service.dart';

/// Função principal da aplicação.
/// 
/// Inicializa Firebase, serviços em segundo plano, configurações de ambiente
/// e executa a aplicação com tratamento de erros customizado.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializa serviços em segundo plano
  await _initializeServices();
  
  // Carrega configurações de ambiente
  await Environments.loadEnvs();
  GoogleFonts.config.allowRuntimeFetching = true;
  
  // Configura tratamento de erros
  _setupErrorHandling();

  runApp(
    ResponsiveApp(
      builder: (context) {
        return ModularApp(
          module: AppModule(),
          child: const AppWidget(),
        );
      },
    ),
  );
}

/// Inicializa todos os serviços necessários da aplicação.
Future<void> _initializeServices() async {
  try {
    await FirebaseSyncService().initialize();
    debugPrint('✅ Firebase Sync Service inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Firebase Sync Service: $e');
  }
  
  try {
    await NotificationService().initialize();
    debugPrint('✅ Notification Service inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Notification Service: $e');
  }
  
  // Roda uma análise leve da IA (sem background), após inicializar notificações
  try {
    await AiRoutineService().runDailyAnalysis();
    debugPrint('✅ AI Routine Service analisou rotinas');
  } catch (e) {
    debugPrint('⚠️ Erro ao rodar AI Routine Service: $e');
  }

  // Análise de datas comemorativas (também leve)
  try {
    await AiHolidayService().runDailyAnalysis();
    debugPrint('✅ AI Holiday Service analisou datas comemorativas');
  } catch (e) {
    debugPrint('⚠️ Erro ao rodar AI Holiday Service: $e');
  }

  // Previsão de saldo do mês (execução única no startup)
  try {
    await AiBalanceForecastService().runDailyForecast();
    debugPrint('✅ AI Balance Forecast analisou saldo previsto');
  } catch (e) {
    debugPrint('⚠️ Erro ao rodar AI Balance Forecast: $e');
  }
  
  try {
    await BackgroundTaskService.initialize();
    debugPrint('✅ Background Task Service inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Background Task Service: $e');
  }

  // Agenda também em foreground (app aberto) às ~09:00
  try {
    ForegroundDailyScheduler().start(hour: 9, minute: 0);
    debugPrint('✅ ForegroundDailyScheduler iniciado para 09:00');
  } catch (e) {
    debugPrint('⚠️ Erro ao iniciar ForegroundDailyScheduler: $e');
  }
  
  debugPrint('🚀 Todos os serviços processados (com possíveis limitações)');
}

/// Configura o tratamento customizado de erros.
void _setupErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false; 
    assert(() {
      inDebug = true;
      return true;
    }());
    
    if (inDebug) {
      return ErrorWidget(details.exception);
    }
    
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error: ${details.exception}',
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  };
}
