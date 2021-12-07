import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';

class ClientTravelRequestController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey();

   String from;
  String to;
  LatLng fromLatLng;
 LatLng toLatLng;
  Driver driver;
  String idDriver;
  int contador = 0;



  TextEditingController usernameController = new TextEditingController();
  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller = new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();


  SharedPref _sharedPref;
  TravelInfoProvider _travelInfoProvider;
  AuthProvider _authProvider;
   DriverProvider _driverProvider;
   GeofireProvider _geofireProvider;
   PushNotificationsProvider _pushNotificationsProvider;
  List<String> nearbyDrivers = new List.empty(growable: true);
   StreamSubscription<List<DocumentSnapshot>> _streamSubscription;
   StreamSubscription<DocumentSnapshot> _streamStatusSubscription;

  Future init(BuildContext context, Function refresh)async {
    this.context = context;
    this.refresh = refresh;

    _travelInfoProvider = new TravelInfoProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _geofireProvider = new GeofireProvider();
    _sharedPref = new SharedPref();
    _pushNotificationsProvider = new PushNotificationsProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    from = arguments['from'];
    to = arguments['to'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    driver = arguments['idDriver'];

    _createTravelInfo();
    _getNearbyDrivers();

    utils.Snackbar.showSnackbar(context, key, 'El conductor no acepto tu solicitud');

  }



  void _checkDriverResponse(){
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());

      if(travelInfo.idDriver != null && travelInfo.status == 'accepted'){
        _sharedPref.save('TravelInfoID', _authProvider.getUser().uid);
       Navigator.pushNamedAndRemoveUntil(context, 'client/travel/map', (route) => false);
  //  Navigator.pushReplacementNamed(context, 'client/travel/map');
      }else if(travelInfo.status == 'no_accepted') {
        utils.Snackbar.showSnackbar(context, key, 'El conductor no acepto tu solicitud');
        print('El conductor no acepto tu solici');
        Future.delayed(Duration(milliseconds: 3000),(){
        Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

        });
        
      }


    });
  }

  void dispose(){
    _streamSubscription?.cancel();
    _streamStatusSubscription?.cancel();
    _streamStatusSubscription?.cancel();
  }

  void _getNearbyDrivers(){
    Stream<List<DocumentSnapshot>> stream = _geofireProvider.getNearbyDrivers(
        fromLatLng.latitude,
        fromLatLng.longitude,
        5
    );
     _streamSubscription = stream.listen((List<DocumentSnapshot> documentList) {
        for(DocumentSnapshot d in documentList){
          print('Conductor encontrado ${d.id}');
          utils.Snackbar.showSnackbar(context, key, 'Conductor encontrado');

          contador = contador + 1;
          print('Contador $contador');
          nearbyDrivers.add(d.id);

        }
        getDriverInfo(nearbyDrivers[0]);
        getDriInfo(nearbyDrivers[0]);
        _streamSubscription?.cancel();
      });

  }

  void cancelarViaje(){
    dispose();
    Map<String, dynamic> data = {

      'clientStatus': 'no_accepted',
      'status': 'no_accepted'
    };

    _travelInfoProvider.update(data, _authProvider.getUser().uid);
    Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

  }



  void _createTravelInfo() async {
    TravelInfo travelInfo = new TravelInfo(
        id: _authProvider.getUser().uid,
        from: from,
        to: to,
        fromLat: fromLatLng.latitude,
        fromLng: fromLatLng.longitude,
        toLat: toLatLng.latitude,
        toLng: toLatLng.longitude,
        status: 'created',
        clientStatus: 'created',
    );


    await _travelInfoProvider.create(travelInfo);
    _checkDriverResponse();
  }

    Future<void> getDriverInfo(String idDriver) async {
     Driver driver = await _driverProvider.getById(idDriver);
    _sendNotification(driver.token);
    }

  void getDriInfo(String idDriver)async{
    driver = await _driverProvider.getById(idDriver);
    print('Driver: ${driver.username}');

    refresh();
  }

  void _sendNotification(String token){
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'idClient': _authProvider.getUser().uid,
      'origin': from,
      'destination': to,
    };

      _pushNotificationsProvider.sendMessage(
          token,
          data,
          'Solicitud de Viaje',
          'Un pasajero esta solicitando un viaje');
  }
  void saveTravelInfo(String travelInfoID) async {
    await _sharedPref.save('TravelInfoID', travelInfoID);
  }

}