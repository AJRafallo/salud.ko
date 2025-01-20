import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saludko/screens/AdminSide/Hotlines/hotlines_model.dart';

class HotlinesService {
  final CollectionReference _hotlinesCollection =
      FirebaseFirestore.instance.collection('hotlines');

  Stream<List<Hotline>> getHotlines() {
    return _hotlinesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Hotline.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> addHotline(Hotline hotline) async {
    await _hotlinesCollection.add(hotline.toMap());
  }

  Future<void> updateHotline(Hotline hotline) async {
    await _hotlinesCollection.doc(hotline.id).update(hotline.toMap());
  }

  Future<void> deleteHotline(String id) async {
    await _hotlinesCollection.doc(id).delete();
  }
}
