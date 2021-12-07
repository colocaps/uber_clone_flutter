import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:light/light.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/map_style.dart';
import 'package:wakelock/wakelock.dart';

class DriverMapController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(-31.415772, -64.189339),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Position _position;
  StreamSubscription<Position> _positionStream;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;



  String _luxString = 'Unknown';
   Light _light;
   StreamSubscription _lightSubscription;
  String _darkMapStyle;
  String _lightMapStyle;

  GoogleMapController mapController;
  BitmapDescriptor markerDriver;
  SharedPref _sharedPref;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  TravelInfoProvider _travelInfoProvider;
  PushNotificationsProvider _pushNotificationsProvider;
  String _idTravel;
  TravelInfo travelInfo;
  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Driver driver;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = new GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _sharedPref = new SharedPref();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/taxi_icon.png');




    _loadMapStyles();
    startListening();
    checkGPS();
    saveToken();
    getDriverInfo();

    Wakelock.enable();
    _idTravel = await _sharedPref.read('TravelInfoID');
    print('idTravel $_idTravel');
    if(driver != null) {
      _checkTravel();
    }

  }
  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
  }





  void startListening() {
    _light = new Light();
    try {
      _lightSubscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }
  void onData(int luxValue) async {
    print("Lux value: $luxValue");
    final controller = await _mapController.future;
    if(luxValue > 60) {
      controller.setMapStyle(_lightMapStyle);


      // refresh();
    }
    else if(luxValue < 5) {
      controller.setMapStyle(_darkMapStyle);

      //  refresh();
    }


  }

  void singOut() async{
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);

  }
  void goToHistoryPage()async{
    try {
      _progressDialog.show();
     await Navigator.pushNamed(context, 'driver/history');
    }catch(error){

    }finally{

    }
  }
  void goToEditPage(){
    Navigator.pushNamed(context, 'driver/edit');
  }
  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser().uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    _lightSubscription?.cancel();
  }

  void signOut() async {
    await _authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }


  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[]');
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider.create(
        _authProvider.getUser().uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();
  }

  void connect() {
    if (isConnect) {
      disconnect();
    }
    else {
      _progressDialog.show();
      updateLocation();
    }
  }

  void disconnect() {
    _positionStream?.cancel();
    _geofireProvider.delete(_authProvider.getUser().uid);
  }

  void checkIfIsConnect() {
    Stream<DocumentSnapshot> status =
    _geofireProvider.getLocationByIdStream(_authProvider.getUser().uid);

    _statusSuscription = status.listen((DocumentSnapshot document) {
      if (document.exists) {
        isConnect = true;

      }
      else {
        isConnect = false;
      }

      refresh();
    });

  }

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();
      saveLocation();

      addMarker(
          'driver',
          _position.latitude,
          _position.longitude,
          'Tu posicion',
          '',
          markerDriver
      );
      refresh();

      _positionStream = Geolocator.getPositionStream(
          desiredAccuracy: LocationAccuracy.best,
          distanceFilter: 1
      ).listen((Position position) {
        _position = position;
        addMarker(
            'driver',
            _position.latitude,
            _position.longitude,
            'Tu posicion',
            '',
            markerDriver
        );
        animateCameraToPosition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();
      });

    } catch(error) {
      print('Error en la localizacion: $error');
    }
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position.latitude, _position.longitude);
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Activa el GPS para obtener la posicion');
    }
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      updateLocation();
      checkIfIsConnect();
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        checkIfIsConnect();
        print('ACTIVO EL GPS');
      }
    }

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude, longitude),
              zoom: 17
          )
      ));
    }
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ) {

    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        rotation: _position.heading
    );

    markers[id] = marker;

  }
  void saveToken(){
    _pushNotificationsProvider.saveToken(
        _authProvider.getUser().uid,
        'driver'
    );
  }
  void _checkTravel() {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_idTravel);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());


      if(travelInfo.status == 'accepted' ){
        Navigator.pushNamed(context, 'driver/travel/map', arguments: _idTravel);

      }
      if(travelInfo.status == 'started' ){
        print('travelmap');
        Navigator.pushNamed(context, 'driver/travel/map', arguments: _idTravel);

      }


    });
  }


}