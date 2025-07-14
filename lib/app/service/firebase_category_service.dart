import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço para buscar categorias (padrão e do usuário) no Firebase
class FirebaseCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca categorias padrão no Firebase (coleção 'categoriasPadrao')
  Future<List<Map<String, String>>> fetchDefaultCategories() async {
    final snapshot = await _firestore.collection('categoriasPadrao').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'Nome': data['nome'] as String? ?? '',
        'Icone': data['icone'] as String? ?? 'category',
      };
    }).toList();
  }

  /// Busca categorias do usuário no Firebase (coleção 'users/{userId}/categorias')
  Future<List<Map<String, String>>> fetchUserCategories(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categorias')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'Nome': data['nome'] as String? ?? '',
        'Icone': data['icone'] as String? ?? 'category',
        'IdUsuario': userId,
      };
    }).toList();
  }

  /// Salva uma categoria personalizada do usuário no Firebase
  Future<bool> saveUserCategory(String userId, String nome, String icone) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categorias')
          .add({
        'nome': nome,
        'icone': icone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove uma categoria personalizada do usuário no Firebase
  Future<bool> deleteUserCategory(String userId, String categoryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categorias')
          .doc(categoryId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
