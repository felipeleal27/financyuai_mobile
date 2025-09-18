import 'package:cloud_firestore/cloud_firestore.dart';
import 'classifier.dart';

Future<void> createTransactionWithAutoCategory({
  required String uid,
  required String descricao,
  String merchant = '',
  required double valor,
  required DateTime data,
}) async {
  final res = TransactionClassifier.classify(
    descricao: descricao,
    merchant: merchant,
    valor: valor,
  );

  final fs = FirebaseFirestore.instance;
  final doc = fs.collection('users').doc(uid).collection('transacoes').doc();
  await doc.set({
    'id': doc.id,
    'descricao': descricao,
    'nome': descricao.isNotEmpty ? descricao : merchant,
    'merchant': merchant,
    'valor': valor,
    'isSaida': valor < 0,
    'idCategoria': res.categoriaId,
    'confidence': res.confidence,
    'dataMovimentacao': Timestamp.fromDate(data),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'autoCategorySource': res.source,
  });
}
