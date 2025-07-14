import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Serviço responsável por gerenciar cache local de fotos de usuários
/// 
/// Funcionalidades:
/// - Download e cache de fotos de perfil
/// - Verificação de fotos em cache
/// - Limpeza de cache antigo
/// - Fallback para imagem padrão
class UserPhotoCacheService {
  static const String _cacheFolder = 'user_photos';
  static const Duration _cacheExpiry = Duration(days: 7); // Cache por 7 dias
  
  /// Retorna o diretório de cache das fotos
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheFolder');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }
  
  /// Gera um nome de arquivo baseado na URL da foto
  String _generateFileName(String photoUrl) {
    final bytes = utf8.encode(photoUrl);
    final hash = sha256.convert(bytes);
    return '${hash.toString()}.jpg';
  }
  
  /// Baixa e salva uma foto no cache local
  /// 
  /// [photoUrl] URL da foto a ser baixada
  /// [userId] ID do usuário para organização
  /// 
  /// Retorna o caminho do arquivo salvo ou null se falhar
  Future<String?> cacheUserPhoto(String photoUrl, String userId) async {
    try {
      debugPrint('UserPhotoCache: Iniciando download da foto do usuário $userId');
      
      // Faz o download da imagem
      final response = await http.get(
        Uri.parse(photoUrl),
        headers: {
          'User-Agent': 'FinancyuaiApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        debugPrint('UserPhotoCache: Erro no download - Status: ${response.statusCode}');
        return null;
      }
      
      // Verifica se é uma imagem válida
      if (!_isValidImageData(response.bodyBytes)) {
        debugPrint('UserPhotoCache: Dados da imagem inválidos');
        return null;
      }
      
      // Salva no cache
      final cacheDir = await _getCacheDirectory();
      final fileName = '${userId}_${_generateFileName(photoUrl)}';
      final file = File('${cacheDir.path}/$fileName');
      
      await file.writeAsBytes(response.bodyBytes);
      
      debugPrint('UserPhotoCache: Foto salva em: ${file.path}');
      return file.path;
      
    } catch (e) {
      debugPrint('UserPhotoCache: Erro ao cachear foto: $e');
      return null;
    }
  }
  
  /// Verifica se os dados são de uma imagem válida
  bool _isValidImageData(Uint8List data) {
    if (data.length < 10) {
      return false;
    }
    
    // Verifica assinaturas de formato de imagem
    // JPEG: FF D8 FF
    if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
      return true;
    }
    
    // PNG: 89 50 4E 47
    if (data[0] == 0x89 && 
        data[1] == 0x50 && 
        data[2] == 0x4E && 
        data[3] == 0x47) {
      return true;
    }
    
    // WebP: 52 49 46 46 (RIFF)
    if (data[0] == 0x52 && 
        data[1] == 0x49 && 
        data[2] == 0x46 && 
        data[3] == 0x46) {
      return true;
    }
    
    return false;
  }
  
  /// Busca uma foto no cache local
  /// 
  /// [photoUrl] URL original da foto
  /// [userId] ID do usuário
  /// 
  /// Retorna o caminho do arquivo em cache ou null se não encontrar
  Future<String?> getCachedPhoto(String photoUrl, String userId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = '${userId}_${_generateFileName(photoUrl)}';
      final file = File('${cacheDir.path}/$fileName');
      
      if (!await file.exists()) {
        return null;
      }
      
      // Verifica se o cache não expirou
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      
      if (age > _cacheExpiry) {
        debugPrint('UserPhotoCache: Cache expirado, removendo arquivo');
        await file.delete();
        return null;
      }
      
      debugPrint('UserPhotoCache: Foto encontrada em cache: ${file.path}');
      return file.path;
      
    } catch (e) {
      debugPrint('UserPhotoCache: Erro ao buscar foto em cache: $e');
      return null;
    }
  }
  
  /// Baixa e armazena foto do usuário, com fallback para cache
  /// 
  /// [photoUrl] URL da foto do usuário
  /// [userId] ID do usuário
  /// 
  /// Retorna o caminho da foto (cache ou recém-baixada) ou null
  Future<String?> getOrCacheUserPhoto(String photoUrl, String userId) async {
    // Primeiro tenta buscar no cache
    final cachedPath = await getCachedPhoto(photoUrl, userId);
    if (cachedPath != null) {
      return cachedPath;
    }
    
    // Se não encontrou no cache, baixa e salva
    return await cacheUserPhoto(photoUrl, userId);
  }
  
  /// Remove todas as fotos em cache de um usuário específico
  Future<void> clearUserPhotoCache(String userId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final files = await cacheDir.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.contains('${userId}_')) {
          await file.delete();
          debugPrint('UserPhotoCache: Removido ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('UserPhotoCache: Erro ao limpar cache do usuário: $e');
    }
  }
  
  /// Remove todo o cache de fotos (limpeza geral)
  Future<void> clearAllPhotoCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('UserPhotoCache: Cache limpo completamente');
      }
    } catch (e) {
      debugPrint('UserPhotoCache: Erro ao limpar todo o cache: $e');
    }
  }
  
  /// Remove arquivos de cache antigos (mais velhos que o limite)
  Future<void> cleanExpiredCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final files = await cacheDir.list().toList();
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = DateTime.now().difference(stat.modified);
          
          if (age > _cacheExpiry) {
            await file.delete();
            debugPrint('UserPhotoCache: Cache expirado removido: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('UserPhotoCache: Erro ao limpar cache expirado: $e');
    }
  }
}
