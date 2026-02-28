import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setData(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).set(data);
  }

  Future<DocumentSnapshot> getData(String path) async {
    return await _firestore.doc(path).get();
  }

  Stream<QuerySnapshot> collectionStream(String path) {
    return _firestore.collection(path).snapshots();
  }
}