class Categoria {
  final int _id;
  final String _nome;

  Categoria({
    required int id,
    required String nome,
  }) : _id = id, _nome = nome;

  int get id => _id;
  String get nome => _nome;

  Categoria copyWith({
    int? id,
    String? nome,
    String? descricao,
  }) {
    return Categoria(
      id: id ?? _id,
      nome: nome ?? _nome,
    );
  }
}