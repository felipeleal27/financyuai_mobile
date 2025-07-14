import 'dart:typed_data';

/// Modelo de dados para usuário autenticado via Google
/// 
/// Armazena informações do usuário Google no banco SQLite local,
/// incluindo a foto como BLOB para acesso offline.
class UsuarioGoogleModel {
  /// ID único do usuário (Firebase UID)
  final String uid;
  
  /// Nome do usuário
  final String? nome;
  
  /// Email do usuário
  final String? email;
  
  /// URL da foto de perfil (original)
  final String? photoURL;
  
  /// Dados binários da foto (para cache offline)
  final Uint8List? photoBlob;
  
  /// Data do primeiro login (timestamp)
  final int dataLogin;
  
  /// Data da última atualização (timestamp)
  final int dataAtualizacao;
  
  /// Se o usuário está ativo (para soft delete)
  final bool isAtivo;

  const UsuarioGoogleModel({
    required this.uid,
    this.nome,
    this.email,
    this.photoURL,
    this.photoBlob,
    required this.dataLogin,
    required this.dataAtualizacao,
    this.isAtivo = true,
  });

  /// Cria um modelo a partir de um Map (banco de dados)
  factory UsuarioGoogleModel.fromMap(Map<String, dynamic> map) {
    return UsuarioGoogleModel(
      uid: map['Uid'] as String,
      nome: map['Nome'] as String?,
      email: map['Email'] as String?,
      photoURL: map['PhotoURL'] as String?,
      photoBlob: map['PhotoBlob'] as Uint8List?,
      dataLogin: map['DataLogin'] as int,
      dataAtualizacao: map['DataAtualizacao'] as int,
      isAtivo: (map['IsAtivo'] as int) == 1,
    );
  }

  /// Converte o modelo para Map (para inserir no banco)
  Map<String, dynamic> toMap() {
    return {
      'Uid': uid,
      'Nome': nome,
      'Email': email,
      'PhotoURL': photoURL,
      'PhotoBlob': photoBlob,
      'DataLogin': dataLogin,
      'DataAtualizacao': dataAtualizacao,
      'IsAtivo': isAtivo ? 1 : 0,
    };
  }

  /// Cria uma cópia com novos valores
  UsuarioGoogleModel copyWith({
    String? uid,
    String? nome,
    String? email,
    String? photoURL,
    Uint8List? photoBlob,
    int? dataLogin,
    int? dataAtualizacao,
    bool? isAtivo,
  }) {
    return UsuarioGoogleModel(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      photoBlob: photoBlob ?? this.photoBlob,
      dataLogin: dataLogin ?? this.dataLogin,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      isAtivo: isAtivo ?? this.isAtivo,
    );
  }

  /// Verifica se tem foto disponível (BLOB ou URL)
  bool get hasPhoto => photoBlob != null || (photoURL != null && photoURL!.isNotEmpty);

  /// Retorna true se a foto está cacheada localmente
  bool get hasLocalPhoto => photoBlob != null && photoBlob!.isNotEmpty;

  @override
  String toString() {
    return 'UsuarioGoogleModel(uid: $uid, nome: $nome, email: $email, hasPhoto: $hasPhoto, hasLocalPhoto: $hasLocalPhoto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UsuarioGoogleModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
