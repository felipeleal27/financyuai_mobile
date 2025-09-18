// Lightweight on-device classifier using keyword rules.
// Later you can plug a TFLite model without changing call sites.

class ClassificationResult {
  final String categoriaId; // e.g., '1' Alimentação, '2' Transporte, etc.
  final double confidence; // 0.0 - 1.0
  final String source; // 'rules' | 'tflite'
  const ClassificationResult(this.categoriaId, this.confidence, this.source);
}

class TransactionClassifier {
  // Map categoriaId -> lista de padrões
  // Align IDs with your CategoriaModel defaults:
  // 1=Alimentação, 2=Transporte, 8=Salário (receita), 9=Outros
  static final Map<String, List<RegExp>> _rules = {
    '1': [RegExp(r'\b(ifood|ubereats|restaurante|pizza|lanche|mercado|supermercado)\b', caseSensitive: false)],
    '2': [RegExp(r'\b(uber|99|cabify|metro|onibus|combustivel|gasolina|posto)\b', caseSensitive: false)],
    '8': [RegExp(r'\b(salario|pagamento|holerite|provento|receita|pix entrada)\b', caseSensitive: false)],
    '9': [RegExp(r'\b(netflix|spotify|prime|assinatura|mensalidade)\b', caseSensitive: false)],
  };

  static String _normalize(String s) {
    final lower = s.toLowerCase();
    const withDia = 'áàãâäéèêëíìîïóòõôöúùûüçñ';
    const without = 'aaaaaeeeeiiiiooooouuuucn';
    var out = lower;
    for (int i = 0; i < withDia.length; i++) {
      out = out.replaceAll(withDia[i], without[i]);
    }
    return out;
  }

  static ClassificationResult classify({
    required String descricao,
    required String merchant,
    required double valor,
  }) {
    final text = _normalize('$descricao $merchant');

    // 1) Regras rápidas
    for (final entry in _rules.entries) {
      final hit = entry.value.any((rx) => rx.hasMatch(text));
      if (hit) return ClassificationResult(entry.key, 0.85, 'rules');
    }

    // 2) Heurística simples para receitas
    if (valor > 0 && RegExp(r'\b(salario|receita|bonus|provento)\b').hasMatch(text)) {
      return const ClassificationResult('8', 0.7, 'rules');
    }

    // 3) Fallback: '9' = Outros
    return const ClassificationResult('9', 0.4, 'rules');
  }
}
