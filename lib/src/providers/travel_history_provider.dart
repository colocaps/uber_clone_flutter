import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';



class TravelHistoryProvider{

  CollectionReference _ref;

  TravelHistoryProvider(){
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String> create(TravelHistory travelHistory)async {
    var errorMessage;

    try {
      String id = _ref.doc().id;
      travelHistory.id = id;
      await _ref.doc(travelHistory.id).set(travelHistory.toJson());
      return id;
    } catch (error) {
      print(error);


      errorMessage = error;
    }
    if(errorMessage != null){
      return Future.error(errorMessage);
    }

  }

  Future<List<TravelHistory>> getByIdClient(String idClient) async{
    QuerySnapshot querySnapshot =
    await _ref.where('idClient', isEqualTo: idClient).orderBy('timestamp', descending: true).get();
    List<Map<String,dynamic>> allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<TravelHistory> travelHistoryList = new List();

    for (Map<String,dynamic> data in allData){
      travelHistoryList.add(TravelHistory.fromJson(data));
    }
    for (TravelHistory travelHistory in travelHistoryList){
      DriverProvider driverProvider = new DriverProvider();
      Driver driver = await driverProvider.getById(travelHistory.idDriver);
      travelHistory.nameDriver = driver.username;
    }

    return travelHistoryList;
  }
  Future<List<TravelHistory>> getByIdDriver(String idDriver) async{
    QuerySnapshot querySnapshot =
    await _ref.where('idDriver', isEqualTo: idDriver).orderBy('timestamp', descending: true).get();
    List<Map<String,dynamic>> allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<TravelHistory> travelHistoryList = new List();

    for (Map<String,dynamic> data in allData){
      travelHistoryList.add(TravelHistory.fromJson(data));
    }
    for (TravelHistory travelHistory in travelHistoryList){
      ClientProvider clientProvider = new ClientProvider();
      Client client = await clientProvider.getById(travelHistory.idClient);
      travelHistory.nameClient = client.username;
    }

    return travelHistoryList;
  }

  Stream<DocumentSnapshot> getByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory> getById(String id) async{

    DocumentSnapshot document = await _ref.doc(id).get();

    if(document.exists){
      TravelHistory  travelHistory = TravelHistory.fromJson(document.data());
      return travelHistory;
    }
    return null;



  }

  Future<void> update (Map<String,dynamic> data, String id){
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id){
    return _ref.doc(id).delete();
  }

}