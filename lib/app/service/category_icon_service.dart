import 'package:flutter/material.dart';

/// Serviço responsável por gerenciar ícones de categorias
/// 
/// Fornece uma lista de ícones disponíveis para categorias de transações
/// e métodos para converter nomes de ícones em objetos IconData.
class CategoryIconService {
  /// Mapa de ícones disponíveis para categorias
  /// Chave: nome do ícone (string), Valor: IconData correspondente
  static const Map<String, IconData> _availableIcons = {
    // Categorias gerais
    'category': Icons.category,
    'wallet': Icons.account_balance_wallet,
    'money': Icons.attach_money,
    
    // Alimentação
    'restaurant': Icons.restaurant,
    'local_dining': Icons.local_dining,
    'fastfood': Icons.fastfood,
    'coffee': Icons.local_cafe,
    'cake': Icons.cake,
    'pizza': Icons.local_pizza,
    
    // Transporte
    'car': Icons.directions_car,
    'bus': Icons.directions_bus,
    'subway': Icons.directions_subway,
    'bike': Icons.directions_bike,
    'taxi': Icons.local_taxi,
    'gas_station': Icons.local_gas_station,
    'flight': Icons.flight,
    
    // Casa e Utilidades
    'home': Icons.home,
    'lightbulb': Icons.lightbulb,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'phone': Icons.phone,
    'tv': Icons.tv,
    'cleaning': Icons.cleaning_services,
    
    // Compras
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'store': Icons.store,
    'local_mall': Icons.local_mall,
    'card_giftcard': Icons.card_giftcard,
    
    // Saúde
    'medical': Icons.medical_services,
    'local_hospital': Icons.local_hospital,
    'local_pharmacy': Icons.local_pharmacy,
    'fitness': Icons.fitness_center,
    'spa': Icons.spa,
    
    // Educação
    'school': Icons.school,
    'book': Icons.book,
    'library': Icons.local_library,
    'science': Icons.science,
    
    // Entretenimento
    'movie': Icons.local_movies,
    'games': Icons.games,
    'music': Icons.music_note,
    'theater': Icons.theater_comedy,
    'sports': Icons.sports_soccer,
    'beach': Icons.beach_access,
    
    // Trabalho
    'work': Icons.work,
    'business': Icons.business,
    'computer': Icons.computer,
    'email': Icons.email,
    
    // Finanças
    'savings': Icons.savings,
    'investment': Icons.trending_up,
    'credit_card': Icons.credit_card,
    'bank': Icons.account_balance,
    'receipt': Icons.receipt,
    
    // Outros
    'gift': Icons.card_giftcard,
    'pet': Icons.pets,
    'baby': Icons.child_care,
    'elderly': Icons.elderly,
    'volunteer': Icons.volunteer_activism,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'security': Icons.security,
    'insurance': Icons.security,
  };

  /// Retorna todos os ícones disponíveis
  static Map<String, IconData> get availableIcons => Map.from(_availableIcons);

  /// Converte um nome de ícone em IconData
  /// 
  /// [iconName] Nome do ícone como string
  /// 
  /// Retorna o IconData correspondente ou um ícone padrão se não encontrado
  static IconData getIconData(String iconName) {
    return _availableIcons[iconName] ?? Icons.category;
  }

  /// Verifica se um ícone existe na lista de disponíveis
  /// 
  /// [iconName] Nome do ícone para verificar
  /// 
  /// Retorna true se o ícone existe, false caso contrário
  static bool hasIcon(String iconName) {
    return _availableIcons.containsKey(iconName);
  }

  /// Retorna uma lista de ícones por categoria para facilitar a seleção
  static Map<String, List<MapEntry<String, IconData>>> getIconsByCategory() {
    return {
      'Geral': [
        const MapEntry('category', Icons.category),
        const MapEntry('wallet', Icons.account_balance_wallet),
        const MapEntry('money', Icons.attach_money),
      ],
      'Alimentação': [
        const MapEntry('restaurant', Icons.restaurant),
        const MapEntry('local_dining', Icons.local_dining),
        const MapEntry('fastfood', Icons.fastfood),
        const MapEntry('coffee', Icons.local_cafe),
        const MapEntry('cake', Icons.cake),
        const MapEntry('pizza', Icons.local_pizza),
      ],
      'Transporte': [
        const MapEntry('car', Icons.directions_car),
        const MapEntry('bus', Icons.directions_bus),
        const MapEntry('subway', Icons.directions_subway),
        const MapEntry('bike', Icons.directions_bike),
        const MapEntry('taxi', Icons.local_taxi),
        const MapEntry('gas_station', Icons.local_gas_station),
        const MapEntry('flight', Icons.flight),
      ],
      'Casa': [
        const MapEntry('home', Icons.home),
        const MapEntry('lightbulb', Icons.lightbulb),
        const MapEntry('water_drop', Icons.water_drop),
        const MapEntry('wifi', Icons.wifi),
        const MapEntry('phone', Icons.phone),
        const MapEntry('tv', Icons.tv),
        const MapEntry('cleaning', Icons.cleaning_services),
      ],
      'Compras': [
        const MapEntry('shopping_cart', Icons.shopping_cart),
        const MapEntry('shopping_bag', Icons.shopping_bag),
        const MapEntry('store', Icons.store),
        const MapEntry('local_mall', Icons.local_mall),
        const MapEntry('card_giftcard', Icons.card_giftcard),
      ],
      'Saúde': [
        const MapEntry('medical', Icons.medical_services),
        const MapEntry('local_hospital', Icons.local_hospital),
        const MapEntry('local_pharmacy', Icons.local_pharmacy),
        const MapEntry('fitness', Icons.fitness_center),
        const MapEntry('spa', Icons.spa),
      ],
      'Educação': [
        const MapEntry('school', Icons.school),
        const MapEntry('book', Icons.book),
        const MapEntry('library', Icons.local_library),
        const MapEntry('science', Icons.science),
      ],
      'Entretenimento': [
        const MapEntry('movie', Icons.local_movies),
        const MapEntry('games', Icons.games),
        const MapEntry('music', Icons.music_note),
        const MapEntry('theater', Icons.theater_comedy),
        const MapEntry('sports', Icons.sports_soccer),
        const MapEntry('beach', Icons.beach_access),
      ],
      'Trabalho': [
        const MapEntry('work', Icons.work),
        const MapEntry('business', Icons.business),
        const MapEntry('computer', Icons.computer),
        const MapEntry('email', Icons.email),
      ],
      'Finanças': [
        const MapEntry('savings', Icons.savings),
        const MapEntry('investment', Icons.trending_up),
        const MapEntry('credit_card', Icons.credit_card),
        const MapEntry('bank', Icons.account_balance),
        const MapEntry('receipt', Icons.receipt),
      ],
      'Outros': [
        const MapEntry('gift', Icons.card_giftcard),
        const MapEntry('pet', Icons.pets),
        const MapEntry('baby', Icons.child_care),
        const MapEntry('elderly', Icons.elderly),
        const MapEntry('volunteer', Icons.volunteer_activism),
        const MapEntry('favorite', Icons.favorite),
        const MapEntry('star', Icons.star),
        const MapEntry('security', Icons.security),
      ],
    };
  }

  /// Retorna sugestões de ícones baseadas no nome da categoria
  /// 
  /// [categoryName] Nome da categoria para buscar sugestões
  /// 
  /// Retorna uma lista de nomes de ícones sugeridos
  static List<String> getSuggestedIcons(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    final suggestions = <String>[];

    // Mapeamento de palavras-chave para ícones
    final keywordMapping = {
      'alimentação': ['restaurant', 'local_dining', 'fastfood'],
      'comida': ['restaurant', 'local_dining', 'fastfood'],
      'restaurante': ['restaurant', 'local_dining'],
      'lanche': ['fastfood', 'local_dining'],
      'café': ['coffee'],
      'transporte': ['car', 'bus', 'subway'],
      'carro': ['car', 'gas_station'],
      'gasolina': ['gas_station', 'car'],
      'combustível': ['gas_station'],
      'ônibus': ['bus'],
      'metrô': ['subway'],
      'bicicleta': ['bike'],
      'casa': ['home', 'lightbulb', 'water_drop'],
      'luz': ['lightbulb'],
      'água': ['water_drop'],
      'internet': ['wifi'],
      'telefone': ['phone'],
      'compras': ['shopping_cart', 'shopping_bag'],
      'mercado': ['shopping_cart'],
      'loja': ['store'],
      'saúde': ['medical', 'local_hospital'],
      'médico': ['medical', 'local_hospital'],
      'farmácia': ['local_pharmacy'],
      'academia': ['fitness'],
      'escola': ['school'],
      'educação': ['school', 'book'],
      'livro': ['book'],
      'trabalho': ['work', 'business'],
      'cinema': ['movie'],
      'filme': ['movie'],
      'música': ['music'],
      'esporte': ['sports'],
      'jogo': ['games'],
      'viagem': ['flight', 'car'],
      'avião': ['flight'],
      'dinheiro': ['money', 'wallet'],
      'carteira': ['wallet'],
      'banco': ['bank'],
      'cartão': ['credit_card'],
      'presente': ['gift'],
      'pet': ['pet'],
      'animal': ['pet'],
    };

    // Busca por palavras-chave no nome da categoria
    for (final entry in keywordMapping.entries) {
      if (lowerName.contains(entry.key)) {
        suggestions.addAll(entry.value);
      }
    }

    // Se não encontrou sugestões, retorna alguns ícones padrão
    if (suggestions.isEmpty) {
      suggestions.addAll(['category', 'wallet', 'money']);
    }

    // Remove duplicatas e retorna apenas os 3 primeiros
    return suggestions.toSet().take(3).toList();
  }
}
