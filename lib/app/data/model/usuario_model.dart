import 'dart:convert';
import 'package:neo_financyuai/app/data/dtos/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.senha,
  });

  @override
  String toString() => nome;

  String get value => super.nome;

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Nome': nome,
      'Email': email,
      'Senha': senha,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map, {bool sqlLite = false}) {
    return UsuarioModel(
      id: map['Id'] as int,
      nome: map['Nome'] as String,
      email: map['Email'] as String,
      senha: map['Senha'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UsuarioModel.fromJson(String source) => UsuarioModel.fromMap(json.decode(source));
}
