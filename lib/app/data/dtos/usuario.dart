class Usuario {
  final int _id;
  final String _nome;
  final String _email;
  final String _senha;

  Usuario({
    required int id,
    required String nome,
    required String email,
    required String senha,
  }) : _id = id,
       _nome = nome,
       _email = email,
       _senha = senha;

  int get id => _id;
  String get nome => _nome;
  String get email => _email;
  String get senha => _senha;

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
  }) {
    return Usuario(
      id: id ?? _id,
      nome: nome ?? _nome,
      email: email ?? _email,
      senha: senha ?? _senha,
    );
  }
}
