class Movimentacao {
  final String? _id; // Mudado para String (UUID)
  final String _nome;
  final double _valor;
  final int _idCategoria;
  final bool _isSaida;
  final DateTime _dataMovimentacao;
  final String _descricao;
  final String _idUsuario; // Mudado de int para String para suportar Firebase UID

  Movimentacao({
    String? id,
    required String nome,
    required double valor,
    required int idCategoria,
    required bool isSaida,
    required DateTime dataMovimentacao,
    required String descricao,
    required String idUsuario,
  }) : _id = id,
       _nome = nome,
       _valor = valor,
       _idCategoria = idCategoria,
       _isSaida = isSaida,
       _dataMovimentacao = dataMovimentacao,
       _descricao = descricao,
       _idUsuario = idUsuario;

  String? get id => _id;
  String get nome => _nome;
  double get valor => _valor;
  int get idCategoria => _idCategoria;
  bool get isSaida => _isSaida;
  DateTime get dataMovimentacao => _dataMovimentacao;
  String get descricao => _descricao;
  String get idUsuario => _idUsuario;

  Movimentacao copyWith({
    String? id, // Mudado para String
    String? nome,
    double? valor,
    int? idCategoria,
    bool? isSaida,
    DateTime? dataMovimentacao,
    String? descricao,
    String? idUsuario, // Mudado de int para String
  }) {
    return Movimentacao(
      id: id ?? _id,
      nome: nome ?? _nome,
      valor: valor ?? _valor,
      idCategoria: idCategoria ?? _idCategoria,
      isSaida: isSaida ?? _isSaida,
      dataMovimentacao: dataMovimentacao ?? _dataMovimentacao,
      descricao: descricao ?? _descricao,
      idUsuario: idUsuario ?? _idUsuario,
    );
  }
}
