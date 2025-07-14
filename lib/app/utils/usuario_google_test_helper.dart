import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/usuario_google_model.dart';
import 'package:neo_financyuai/app/repository/usuario_google_repository.dart';

/// Script de teste para verificar o funcionamento do cache de usuário Google
/// 
/// Este arquivo demonstra como usar o repositório e pode ser usado
/// para testar o funcionamento offline.
class UsuarioGoogleTestHelper {
  static final UsuarioGoogleRepository _repository = UsuarioGoogleRepository();

  /// Testa o salvamento e recuperação de um usuário Google
  static Future<void> testarCacheUsuario() async {
    debugPrint('🧪 Iniciando teste de cache de usuário Google...');

    try {
      // 1. Criar um usuário de teste
      final usuarioTeste = UsuarioGoogleModel(
        uid: 'test_uid_123',
        nome: 'Usuário Teste',
        email: 'teste@gmail.com',
        photoURL: 'https://lh3.googleusercontent.com/test-photo.jpg',
        dataLogin: DateTime.now().millisecondsSinceEpoch,
        dataAtualizacao: DateTime.now().millisecondsSinceEpoch,
        isAtivo: true,
      );

      // 2. Salvar no banco (sem download de foto para teste)
      debugPrint('💾 Salvando usuário de teste...');
      final salvou = await _repository.salvarUsuario(usuarioTeste, downloadPhoto: false);
      
      if (salvou) {
        debugPrint('✅ Usuário salvo com sucesso!');
      } else {
        debugPrint('❌ Falha ao salvar usuário');
        return;
      }

      // 3. Buscar usuário por UID
      debugPrint('🔍 Buscando usuário por UID...');
      final usuarioEncontrado = await _repository.buscarUsuarioPorUid(usuarioTeste.uid);
      
      if (usuarioEncontrado != null) {
        debugPrint('✅ Usuário encontrado: ${usuarioEncontrado.nome}');
        debugPrint('📧 Email: ${usuarioEncontrado.email}');
        debugPrint('🖼️ Tem foto local: ${usuarioEncontrado.hasLocalPhoto}');
      } else {
        debugPrint('❌ Usuário não encontrado');
        return;
      }

      // 4. Buscar usuário ativo
      debugPrint('🔍 Buscando usuário ativo...');
      final usuarioAtivo = await _repository.buscarUsuarioAtivo();
      
      if (usuarioAtivo != null) {
        debugPrint('✅ Usuário ativo: ${usuarioAtivo.nome}');
      } else {
        debugPrint('❌ Nenhum usuário ativo encontrado');
      }

      // 5. Simular atualização de foto
      debugPrint('📸 Atualizando foto...');
      await _repository.atualizarFoto(usuarioTeste.uid, usuarioTeste.photoURL!);

      // 6. Verificar se foto foi atualizada
      final usuarioComFoto = await _repository.buscarUsuarioPorUid(usuarioTeste.uid);
      if (usuarioComFoto?.hasLocalPhoto == true) {
        debugPrint('✅ Foto atualizada com sucesso! Tamanho: ${usuarioComFoto!.photoBlob!.length} bytes');
      } else {
        debugPrint('⚠️ Foto não foi baixada (normal se offline)');
      }

      debugPrint('🎉 Teste concluído com sucesso!');

    } catch (e) {
      debugPrint('❌ Erro durante o teste: $e');
    }
  }

  /// Lista todos os usuários cadastrados
  static Future<void> listarUsuarios() async {
    debugPrint('📋 Listando todos os usuários...');
    
    try {
      // Busca apenas o usuário ativo (método disponível)
      final usuarioAtivo = await _repository.buscarUsuarioAtivo();
      
      if (usuarioAtivo == null) {
        debugPrint('📭 Nenhum usuário ativo encontrado');
        return;
      }

      debugPrint('� Usuário ativo encontrado:');
      debugPrint('---');
      debugPrint('🆔 UID: ${usuarioAtivo.uid}');
      debugPrint('👤 Nome: ${usuarioAtivo.nome ?? "N/A"}');
      debugPrint('📧 Email: ${usuarioAtivo.email ?? "N/A"}');
      debugPrint('📅 Login: ${DateTime.fromMillisecondsSinceEpoch(usuarioAtivo.dataLogin)}');
      debugPrint('🎯 Ativo: ${usuarioAtivo.isAtivo ? "Sim" : "Não"}');
      debugPrint('🖼️ Tem foto: ${usuarioAtivo.hasLocalPhoto ? "Sim" : "Não"}');
      
    } catch (e) {
      debugPrint('❌ Erro ao listar usuários: $e');
    }
  }

  /// Limpa todos os dados de teste
  static Future<void> limparDadosTeste() async {
    debugPrint('🧹 Limpando dados de teste...');
    
    try {
      final sucesso = await _repository.limparUsuarios();
      
      if (sucesso) {
        debugPrint('✅ Dados limpos com sucesso!');
      } else {
        debugPrint('❌ Falha ao limpar dados');
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados: $e');
    }
  }
}

/// Como usar este helper no seu código:
/// 
/// ```dart
/// // Em algum lugar do seu app (ex: botão de debug)
/// await UsuarioGoogleTestHelper.testarCacheUsuario();
/// await UsuarioGoogleTestHelper.listarUsuarios();
/// 
/// // Para limpar dados de teste
/// await UsuarioGoogleTestHelper.limparDadosTeste();
/// ```
