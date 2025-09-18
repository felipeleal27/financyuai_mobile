import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'classifier.dart';
import 'auto_categorize.dart';

/// Run quick AI smoke tests. Call this in DEBUG only (e.g., after login), then check console logs.
Future<void> runAiSmokeTests(String uid) async {
  if (!kDebugMode) return;

  dev.log('🧪 AI Smoke Test: start');

  // 1) Classifier quick tests
  final cases = [
    ('iFood pedido 123', 'ifood', -42.9),
    ('Corrida Uber centro', 'uber', -18.0),
    ('Salário Empresa X', '', 4500.0),
    ('Assinatura Netflix', 'netflix', -39.9),
  ];
  for (final c in cases) {
    final res = TransactionClassifier.classify(
      descricao: c.$1,
      merchant: c.$2,
      valor: c.$3,
    );
    dev.log('🔎 classify("${c.$1}", merchant="${c.$2}", valor=${c.$3}) => cat=${res.categoriaId}, conf=${res.confidence}');
  }

  // 2) Create a Firestore transaction with auto-category
  try {
    await createTransactionWithAutoCategory(
      uid: uid,
      descricao: 'Teste AI ${DateTime.now().toIso8601String()}',
      merchant: 'ifood',
      valor: -25.50,
      data: DateTime.now(),
    );
    dev.log('✅ Firestore test transaction created with auto-category');
  } catch (e) {
    dev.log('❌ Failed to create Firestore test transaction: $e');
  }

  // 3) Read back last 1 transaction for sanity (optional)
  try {
    final fs = FirebaseFirestore.instance;
    final snap = await fs
        .collection('users')
        .doc(uid)
        .collection('transacoes')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      dev.log('📥 Last transaction: ${snap.docs.first.data()}');
    } else {
      dev.log('ℹ️ No transactions found to read back');
    }
  } catch (e) {
    dev.log('❌ Failed to read back transaction: $e');
  }

  dev.log('🧪 AI Smoke Test: end');
}
