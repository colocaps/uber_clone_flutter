import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';


class DriverProvider {

   CollectionReference _ref;

  DriverProvider() {
    _ref = FirebaseFirestore.instance.collection('Drivers');
  }

  Future<void> create(Driver driver) async {
    var errorMessage;

    try {
      return _ref.doc(driver.id).set(driver.toJson());
    } catch (error) {
      print(error);


      errorMessage = error;
    }
    if (errorMessage != null) {
      return Future.error(errorMessage);
    }
  }

    Stream<DocumentSnapshot> getByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
    }

   Future<Driver> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      Driver driver = Driver.fromJson(document.data());
      return driver;
    } else {
      return null;
    }
  }
   Future<void> update (Map<String,dynamic> data, String id){
     return _ref.doc(id).update(data);
   }
}