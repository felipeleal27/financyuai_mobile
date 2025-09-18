import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUserCorrection({
  required String uid,
  required String transactionId,
  required String categoriaCorretaId,
}) async {
  final fs = FirebaseFirestore.instance;
  await fs
      .collection('labels')
      .doc(uid)
      .collection('transacoes')
      .doc(transactionId)
      .set({
    'categoriaCorretaId': categoriaCorretaId,
    'timestamp': FieldValue.serverTimestamp(),
    'origem': 'app',
  }, SetOptions(merge: true));
}
