import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:neo_financyuai/app/data/model/usuario_google_model.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';

/// Repositório para gerenciar dados de usuários Google no SQLite
/// 
/// Funcionalidades:
/// - Salvar/atualizar dados do usuário Google
/// - Baixar e cachear foto de perfil como BLOB
/// - Buscar usuário por UID
/// - Gerenciar estado ativo/inativo
class UsuarioGoogleRepository {
  static const String _tableName = 'usuario_google';

  /// Salva ou atualiza um usuário Google no banco
  /// 
  /// [usuario] Dados do usuário a serem salvos
  /// [downloadPhoto] Se deve baixar e salvar a foto
  /// 
  /// Retorna true se salvou com sucesso
  Future<bool> salvarUsuario(UsuarioGoogleModel usuario, {bool downloadPhoto = true}) async {
    try {
      final db = await DB.instance.database;
      
      // Se deve baixar a foto e tem URL, faz o download
      UsuarioGoogleModel usuarioFinal = usuario;
      if (downloadPhoto && usuario.photoURL != null && usuario.photoURL!.isNotEmpty) {
        final photoBlob = await _downloadPhoto(usuario.photoURL!);
        if (photoBlob != null) {
          usuarioFinal = usuario.copyWith(photoBlob: photoBlob);
        }
      }
      
      // Tenta atualizar primeiro
      final updateCount = await db.update(
        _tableName,
        usuarioFinal.toMap(),
        where: 'Uid = ?',
        whereArgs: [usuario.uid],
      );
      
      // Se não atualizou nenhum registro, insere novo
      if (updateCount == 0) {
        await db.insert(_tableName, usuarioFinal.toMap());
      }
      
      debugPrint('✅ Usuário Google salvo: ${usuario.uid}');
      return true;
      
    } catch (e) {
      debugPrint('❌ Erro ao salvar usuário Google: $e');
      return false;
    }
  }

  /// Busca um usuário Google por UID
  Future<UsuarioGoogleModel?> buscarUsuarioPorUid(String uid) async {
    try {
      final db = await DB.instance.database;
      
      final result = await db.query(
        _tableName,
        where: 'Uid = ? AND IsAtivo = 1',
        whereArgs: [uid],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        final usuario = UsuarioGoogleModel.fromMap(result.first);
        debugPrint('✅ Usuário Google encontrado: ${usuario.uid}');
        return usuario;
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ Erro ao buscar usuário Google: $e');
      return null;
    }
  }

  /// Busca o usuário ativo atual (último logado)
  Future<UsuarioGoogleModel?> buscarUsuarioAtivo() async {
    try {
      final db = await DB.instance.database;
      
      final result = await db.query(
        _tableName,
        where: 'IsAtivo = 1',
        orderBy: 'DataAtualizacao DESC',
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        return UsuarioGoogleModel.fromMap(result.first);
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ Erro ao buscar usuário ativo: $e');
      return null;
    }
  }

  /// Atualiza apenas a foto do usuário
  Future<bool> atualizarFoto(String uid, String photoURL) async {
    try {
      final photoBlob = await _downloadPhoto(photoURL);
      if (photoBlob == null) {
        return false;
      }
      
      final db = await DB.instance.database;
      
      final updateCount = await db.update(
        _tableName,
        {
          'PhotoURL': photoURL,
          'PhotoBlob': photoBlob,
          'DataAtualizacao': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'Uid = ?',
        whereArgs: [uid],
      );
      
      debugPrint('✅ Foto do usuário atualizada: $uid');
      return updateCount > 0;
      
    } catch (e) {
      debugPrint('❌ Erro ao atualizar foto: $e');
      return false;
    }
  }

  /// Marca usuário como inativo (soft delete)
  Future<bool> desativarUsuario(String uid) async {
    try {
      final db = await DB.instance.database;
      
      final updateCount = await db.update(
        _tableName,
        {
          'IsAtivo': 0,
          'DataAtualizacao': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'Uid = ?',
        whereArgs: [uid],
      );
      
      debugPrint('✅ Usuário desativado: $uid');
      return updateCount > 0;
      
    } catch (e) {
      debugPrint('❌ Erro ao desativar usuário: $e');
      return false;
    }
  }

  /// Limpa todos os usuários (útil para logout completo)
  Future<bool> limparUsuarios() async {
    try {
      final db = await DB.instance.database;
      
      await db.update(
        _tableName,
        {'IsAtivo': 0},
      );
      
      debugPrint('✅ Todos os usuários desativados');
      return true;
      
    } catch (e) {
      debugPrint('❌ Erro ao limpar usuários: $e');
      return false;
    }
  }

  /// Baixa uma foto da URL e retorna como Uint8List
  Future<Uint8List?> _downloadPhoto(String photoURL) async {
    try {
      debugPrint('📷 Baixando foto do usuário: $photoURL');
      
      final response = await http.get(
        Uri.parse(photoURL),
        headers: {
          'User-Agent': 'FinancyuaiApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Verifica se é uma imagem válida
        if (_isValidImage(bytes)) {
          debugPrint('✅ Foto baixada com sucesso: ${bytes.length} bytes');
          return bytes;
        } else {
          debugPrint('❌ Dados da foto inválidos');
        }
      } else {
        debugPrint('❌ Erro no download da foto: ${response.statusCode}');
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ Erro ao baixar foto: $e');
      return null;
    }
  }

  /// Verifica se os bytes representam uma imagem válida
  bool _isValidImage(Uint8List bytes) {
    if (bytes.length < 10) return false;
    
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && 
        bytes[1] == 0x50 && 
        bytes[2] == 0x4E && 
        bytes[3] == 0x47) {
      return true;
    }
    
    // WebP: 52 49 46 46
    if (bytes[0] == 0x52 && 
        bytes[1] == 0x49 && 
        bytes[2] == 0x46 && 
        bytes[3] == 0x46) {
      return true;
    }
    
    return false;
  }
}
