import 'dart:convert';

import 'package:neo_financyuai/app/data/dtos/movimentacao.dart';

class MovimentacaoModel extends Movimentacao {
  MovimentacaoModel({
    super.id,
    required super.nome,
    required super.valor,
    required super.idCategoria,
    required super.isSaida,
    required super.dataMovimentacao,
    required super.descricao,
    required super.idUsuario,
  });

  double get value => super.valor;

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Nome': nome,
      'Valor': valor,
      'IdCategoria': idCategoria,
      'IsSaida': isSaida ? 1 : 0,
      'DataMovimentacao': dataMovimentacao.millisecondsSinceEpoch,
      'Descricao': descricao,
      'IdUsuario': idUsuario,
    };
  }

  factory MovimentacaoModel.fromMap(Map<String, dynamic> map, {bool sqlLite = false}) {
    return MovimentacaoModel(
      id: map['Id'] as String?, // Mudado para String
      nome: map['Nome'] as String,
      valor: map['Valor'] as double,
      idCategoria: map['IdCategoria'] as int,
      isSaida: sqlLite ? map['IsSaida'] == 1 : map['IsSaida'] as bool, // Corrigido: 1 = true, 0 = false
      dataMovimentacao: sqlLite
          ? DateTime.fromMillisecondsSinceEpoch(map['DataMovimentacao'] as int)
          : DateTime.parse(map['DataMovimentacao'] as String),
      descricao: map['Descricao'] as String,
      idUsuario: map['IdUsuario'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MovimentacaoModel.fromJsonString(String source) =>
      MovimentacaoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
