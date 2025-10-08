import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/service/user_photo_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';

/// Serviço responsável pela autenticação de usuários
/// 
/// Implementa padrão Singleton e fornece métodos para:
/// - Login com Google
/// - Login com email/senha
/// - Registro de novos usuários
/// - Logout
/// - Reset de senha
/// - Login anônimo
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  /// Retorna a instância singleton do serviço
  factory AuthService() => _instance;
  
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserPhotoCacheService _photoCacheService = UserPhotoCacheService();

  /// Usuário atual
  User? get currentUser => _auth.currentUser;
  
  /// Stream do estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// ID do usuário atual (para usar no Firebase Sync)
  String? get userId => _auth.currentUser?.uid;
  
  /// Email do usuário atual
  String? get userEmail => _auth.currentUser?.email;
  
  /// Nome do usuário atual
  String? get userName => _auth.currentUser?.displayName;
  
  /// URL da foto do usuário
  String? get userPhotoUrl => _auth.currentUser?.photoURL;

  /// Verifica se o usuário está logado
  bool get isAuthenticated => _auth.currentUser != null;

  /// Recupera o ID token JWT atual do usuário autenticado, quando existir.
  ///
  /// Retorna `null` quando não há usuário logado ou caso a obtenção falhe.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao obter ID token: $e');
      }
      return null;
    }
  }

  /// Login com Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🚀 Iniciando login com Google...');
        print('🔧 Google Sign-In disponível: ${await _googleSignIn.isSignedIn()}');
      }
      // Garante que o seletor de conta apareça (evita reutilizar conta anterior)
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        // ignore: just ensure a fresh sign-in flow
      }
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (kDebugMode) {
          print('❌ Login cancelado pelo usuário');
        }
        return null;
      }

      if (kDebugMode) {
        print('✅ Usuário Google obtido: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (kDebugMode) {
        print('✅ Auth tokens obtidos');
        print('📱 Access Token presente: ${googleAuth.accessToken != null}');
        print('🆔 ID Token presente: ${googleAuth.idToken != null}');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Garante que o documento do usuário existe no Firestore (idempotente)
      try {
        final uid = userCredential.user?.uid;
        if (uid != null) {
          final firestore = FirebaseFirestore.instance;
          final userDoc = firestore.collection('users').doc(uid);
          final snapshot = await userDoc.get();
          if (!snapshot.exists) {
            await userDoc.set({
              'createdAt': FieldValue.serverTimestamp(),
              'email': userCredential.user?.email,
              'displayName': userCredential.user?.displayName,
              'photoURL': userCredential.user?.photoURL,
            }, SetOptions(merge: true));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('ℹ️ Não foi possível garantir user doc no Firestore: $e');
        }
      }
      
      if (kDebugMode) {
        print('✅ Login realizado: ${userCredential.user?.displayName}');
        print('📧 Email: ${userCredential.user?.email}');
        print('🆔 UID: ${userCredential.user?.uid}');
      }

      // Persiste UID para uso em tarefas de background
      try {
        final prefs = await SharedPreferences.getInstance();
        final uid = userCredential.user?.uid;
        if (uid != null) {
          await prefs.setString('last_user_uid', uid);
        }
      } catch (e) {
        if (kDebugMode) {
          print('ℹ️ Não foi possível persistir last_user_uid: $e');
        }
      }

      if (kDebugMode) {
        print('🔐 Checando usuário após login:');
        print('   📧 Email: ${userCredential.user?.email}');
        print('   🆔 UID: ${userCredential.user?.uid}');
        print('   👤 Display Name: ${userCredential.user?.displayName}');
        print('   ✅ User authenticated: ${userCredential.user != null}');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login com Google: $e');
      }
      rethrow;
    }
  }

  /// Login com email e senha
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ Login realizado: ${userCredential.user?.email}');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login: $e');
      }
      rethrow;
    }
  }

  /// Registrar com email e senha
  Future<UserCredential?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualiza o nome do usuário
      await userCredential.user?.updateDisplayName(displayName);
      
      if (kDebugMode) {
        print('✅ Usuário registrado: $email');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no registro: $e');
      }
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      // Pega o ID do usuário antes do logout para limpar cache
      final String? currentUserId = userId;
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      // Limpa cache de foto do usuário após logout
      if (currentUserId != null) {
        _photoCacheService.clearUserPhotoCache(currentUserId);
      }

      // Limpa SQLite e SharedPreferences no logout
      try {
        await DB.instance.apagarBanco();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao apagar banco SQLite no logout: $e');
        }
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('last_user_uid');
        await prefs.clear();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao limpar SharedPreferences no logout: $e');
        }
      }
      
      if (kDebugMode) {
        debugPrint('✅ Logout realizado e dados locais limpos (SQLite + prefs)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no logout: $e');
      }
      rethrow;
    }
  }

  /// Reset de senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      if (kDebugMode) {
        print('✅ Email de reset enviado para: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao enviar email de reset: $e');
      }
      rethrow;
    }
  }

  /// Login anônimo (para teste)
  Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      
      if (kDebugMode) {
        print('✅ Login anônimo realizado: ${userCredential.user?.uid}');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login anônimo: $e');
      }
      rethrow;
    }
  }

  /// Login com GitHub (preparado para implementação futura)
  Future<UserCredential?> signInWithGitHub() async {
    try {
      if (kDebugMode) {
        print('🚀 Tentando login com GitHub...');
      }
      
      // Isso requer configuração adicional no Firebase Console
      // e implementação do GitHub OAuth provider
      
      throw UnimplementedError('GitHub OAuth não implementado ainda');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login com GitHub: $e');
      }
      rethrow;
    }
  }

  /// Login com Microsoft (preparado para implementação futura)
  Future<UserCredential?> signInWithMicrosoft() async {
    try {
      if (kDebugMode) {
        print('🚀 Tentando login com Microsoft...');
      }
      
      // Isso requer configuração adicional no Firebase Console
      // e implementação do Microsoft OAuth provider
      
      throw UnimplementedError('Microsoft OAuth não implementado ainda');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no login com Microsoft: $e');
      }
      rethrow;
    }
  }
}
