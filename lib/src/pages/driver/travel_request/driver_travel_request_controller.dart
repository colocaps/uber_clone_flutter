import 'dart:async';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';

class DriverTravelRequestController{

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey();
  SharedPref _sharedPref;
  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
  GeofireProvider _geofireProvider;

  String from;
  String to;
  String idClient;
  Client client;
  Timer _timer;
  int seconds = 30;


  ClientProvider _clientProvider;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;

  Future init(BuildContext context, Function refresh){
    this.context = context;
    this.refresh = refresh;

    _clientProvider = new ClientProvider();
    _sharedPref = new SharedPref();
    _sharedPref.save('isNotification', 'false');
    _travelInfoProvider = new TravelInfoProvider();
    _authProvider = new AuthProvider();
    _geofireProvider = new GeofireProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    from = arguments['origin'];
    to = arguments['destination'];
    idClient = arguments['idClient'];

    getClientInfo();
    startTimer();
    _checkClientResponse();

  }


    void dispose(){
     _timer?.cancel();
     _streamStatusSubscription?.cancel();
    }

  void startTimer(){
     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
       seconds = seconds-1;
       refresh();
       if(seconds == 0){
         cancelTravel();
       }

     });
  }

    void acceptTravel(){

    Map<String, dynamic> data = {
      'idDriver': _authProvider.getUser().uid,
      'status': 'accepted'
    };

    _timer?.cancel();
    _travelInfoProvider.update(data, idClient);
    _geofireProvider.delete(_authProvider.getUser().uid);
    _sharedPref.save('TravelInfoID', idClient);
    Navigator.pushNamedAndRemoveUntil(context, 'driver/travel/map', (route) => false, arguments: idClient);
  //  Navigator.pushReplacementNamed(context, 'driver/travel/map', arguments: idClient);

    }

  void saveTravelInfo(String travelInfoID) async {
    await _sharedPref.save('TravelInfoID', travelInfoID);
  }


    void cancelTravel(){
    dispose();
      Map<String, dynamic> data = {

        'status': 'no_accepted',

      };
      _timer?.cancel();
      _travelInfoProvider.update(data, idClient);

      Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
    }

  void _checkClientResponse() {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(idClient);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());

      if(travelInfo.clientStatus == 'no_accepted' ){
        Map<String, dynamic> data = {


          'clientStatus': 'acc'
        };

        _travelInfoProvider.update(data, idClient);
        utils.Snackbar.showSnackbar(context, key, 'El cliente cancelo el viaje');
        print('El cliente cancelo el viaje');
        Future.delayed(Duration(milliseconds: 3000),(){
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);

        });

      }

      refresh();
    });
  }
   void getClientInfo()async{
     client = await _clientProvider.getById(idClient);
      print('Cliente: ${client.toJson()}');
      refresh();
   }


}