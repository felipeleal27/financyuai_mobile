import 'dart:convert';

import 'package:neo_financyuai/app/data/dtos/categoria.dart';

class CategoriaModel extends Categoria {
  /// Ícone da categoria (nome do ícone do Material Icons)
  final String icone;
  /// ID do usuário que criou a categoria (null para categorias padrão)
  final String? idUsuario;
  
  CategoriaModel({
    required super.id,
    required super.nome,
    this.icone = 'category', // Ícone padrão
    this.idUsuario,
  });

  @override
  String toString() => nome;

  String get value => super.nome;

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Nome': nome,
      'Icone': icone,
      'IdUsuario': idUsuario,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map, {bool sqlLite = false}) {
    return CategoriaModel(
      id: map['Id'] as int,
      nome: map['Nome'] as String,
      icone: map['Icone'] as String? ?? 'category', // Valor padrão se null
      idUsuario: map['IdUsuario'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriaModel.fromJson(String source) => CategoriaModel.fromMap(json.decode(source));
}