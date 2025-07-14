import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/data/model/usuario_google_model.dart';
import 'package:neo_financyuai/app/repository/usuario_google_repository.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget personalizado para exibir a foto do usuário com cache SQLite
/// 
/// Funcionalidades:
/// - Carrega foto do banco SQLite (offline-first)
/// - Fallback para URL online se necessário
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
  final UsuarioGoogleRepository _repository = UsuarioGoogleRepository();
  final AuthService _authService = AuthService();
  
  UsuarioGoogleModel? _usuario;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega os dados do usuário do SQLite
  Future<void> _loadUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Busca no SQLite primeiro
      final usuario = await _repository.buscarUsuarioPorUid(currentUser.uid);
      
      if (mounted) {
        setState(() {
          _usuario = usuario;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final currentUser = _authService.currentUser;
    
    // Se não há usuário logado, mostra ícone padrão
    if (currentUser == null) {
      return _buildFallbackAvatar(helper);
    }

    // Se está carregando, mostra loading
    if (_isLoading) {
      return _buildLoadingAvatar(helper);
    }

    // PRIORIDADE 1: Se tem dados do usuário no SQLite e foto em BLOB, usa ela (offline-first)
    if (_usuario != null && _usuario!.hasLocalPhoto) {
      return _buildBlobAvatar(helper, _usuario!.photoBlob!);
    }

    // PRIORIDADE 2: Se não tem cache local MAS tem URL, mostra fallback por enquanto
    // (evita tentar carregar da rede quando offline)
    if (currentUser.photoURL != null) {
      // Em vez de tentar carregar da rede, mostra fallback
      // A foto será baixada em background pelo repositório
      return _buildFallbackAvatar(helper);
    }

    // Fallback final: ícone padrão
    return _buildFallbackAvatar(helper);
  }

  /// Constrói avatar com foto do BLOB (SQLite)
  Widget _buildBlobAvatar(AppThemeHelper helper, Uint8List photoBlob) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: helper.colorScheme.primary,
      backgroundImage: MemoryImage(photoBlob),
      onBackgroundImageError: (exception, stackTrace) {
        // Se erro ao carregar do BLOB, tenta recarregar
        Future.microtask(() => _loadUserData());
      },
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
