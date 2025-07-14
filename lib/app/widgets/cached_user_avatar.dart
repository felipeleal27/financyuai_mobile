import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/service/user_photo_cache_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget personalizado para exibir a foto do usuário com cache local
/// 
/// Funcionalidades:
/// - Tenta carregar da URL (se online)
/// - Fallback para cache local (se offline)
/// - Placeholder padrão se não houver foto
/// - Indicador de carregamento
class CachedUserAvatar extends StatefulWidget {
  /// Raio do avatar
  final double radius;
  
  /// Ícone a ser exibido quando não há foto
  final IconData? fallbackIcon;
  
  /// Tamanho do ícone de fallback
  final double? fallbackIconSize;

  const CachedUserAvatar({
    super.key,
    this.radius = 32,
    this.fallbackIcon = Icons.person,
    this.fallbackIconSize,
  });

  @override
  State<CachedUserAvatar> createState() => _CachedUserAvatarState();
}

class _CachedUserAvatarState extends State<CachedUserAvatar> {
  final UserPhotoCacheService _cacheService = UserPhotoCacheService();
  final AuthService _authService = AuthService();
  
  String? _cachedImagePath;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserPhoto();
  }

  /// Carrega a foto do usuário (cache ou download)
  Future<void> _loadUserPhoto() async {
    final user = _authService.currentUser;
    if (user == null || user.photoURL == null) {
      debugPrint('CachedUserAvatar: Usuário não logado ou sem foto');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      debugPrint('CachedUserAvatar: Carregando foto para ${user.uid}');
      
      // Primeiro verifica se há cache local
      final cachedPath = await _cacheService.getCachedPhoto(
        user.photoURL!,
        user.uid,
      );

      if (cachedPath != null && File(cachedPath).existsSync()) {
        debugPrint('CachedUserAvatar: Foto encontrada no cache: $cachedPath');
        if (mounted) {
          setState(() {
            _cachedImagePath = cachedPath;
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint('CachedUserAvatar: Cache não encontrado, tentando baixar');
      
      // Se não há cache, tenta baixar
      final downloadedPath = await _cacheService.cacheUserPhoto(
        user.photoURL!,
        user.uid,
      );

      if (mounted) {
        setState(() {
          _cachedImagePath = downloadedPath;
          _isLoading = false;
          _hasError = downloadedPath == null;
        });
      }
    } catch (e) {
      debugPrint('CachedUserAvatar: Erro ao carregar foto: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final user = _authService.currentUser;
    
    // Se não há usuário logado, mostra ícone padrão
    if (user == null) {
      return _buildFallbackAvatar(helper);
    }

    // Se está carregando, mostra loading
    if (_isLoading) {
      return _buildLoadingAvatar(helper);
    }

    // Se há foto em cache local, usa ela
    if (_cachedImagePath != null && File(_cachedImagePath!).existsSync()) {
      return _buildCachedAvatar(helper);
    }

    // Se há URL da foto, tenta carregar diretamente (com fallback)
    if (user.photoURL != null) {
      return _buildNetworkAvatar(helper, user.photoURL!);
    }

    // Fallback final: ícone padrão
    return _buildFallbackAvatar(helper);
  }

  /// Constrói avatar com foto do cache local
  Widget _buildCachedAvatar(AppThemeHelper helper) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: helper.colorScheme.primary,
      backgroundImage: FileImage(File(_cachedImagePath!)),
      onBackgroundImageError: (exception, stackTrace) {
        // Se erro ao carregar do cache, tenta recarregar
        Future.microtask(() => _loadUserPhoto());
      },
    );
  }

  /// Constrói avatar com foto da rede (com fallback para cache)
  Widget _buildNetworkAvatar(AppThemeHelper helper, String photoUrl) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: helper.colorScheme.primary,
      backgroundImage: NetworkImage(photoUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Se falhar ao carregar da rede, tenta usar cache
        if (!_hasError) {
          setState(() => _hasError = true);
          _loadUserPhoto();
        }
      },
      child: _hasError ? _buildFallbackIcon(helper) : null,
    );
  }

  /// Constrói avatar com indicador de carregamento
  Widget _buildLoadingAvatar(AppThemeHelper helper) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: helper.colorScheme.primary,
      child: SizedBox(
        width: widget.radius * 0.6,
        height: widget.radius * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            helper.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// Constrói avatar com ícone padrão
  Widget _buildFallbackAvatar(AppThemeHelper helper) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: helper.colorScheme.primary,
      child: _buildFallbackIcon(helper),
    );
  }

  /// Constrói o ícone de fallback
  Widget _buildFallbackIcon(AppThemeHelper helper) {
    return Icon(
      widget.fallbackIcon ?? Icons.person,
      size: widget.fallbackIconSize ?? (widget.radius * 0.8),
      color: helper.colorScheme.onPrimary,
    );
  }
}
