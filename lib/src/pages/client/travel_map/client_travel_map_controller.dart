import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light/light.dart';
import 'package:location/location.dart' as location;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/api/environment.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/bottom_sheet_client_info.dart';
import 'package:wakelock/wakelock.dart';

class ClientTravelMapController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(-31.415772, -64.189339),
      zoom: 15.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};



  String _luxString = 'Unknown';
  Light _light;
  StreamSubscription _lightSubscription;
  String _darkMapStyle;
  String _lightMapStyle;

  Position _position;
  StreamSubscription<Position> _positionStream;
  
  BitmapDescriptor markerDriver;
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;

  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  PushNotificationsProvider _pushNotificationsProvider;
  TravelInfoProvider _travelInfoProvider;

  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverInfoSuscription;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;

  Set<Polyline> polylines = {};
  List<LatLng> points = new List();

  Driver driver;
  LatLng _driverLatLng;
  TravelInfo travelInfo;

  bool isRouteReady = false;
  String _idTravel;
  String currentStatus = '';
  Color colorStatus = Colors.blue;

  bool isPickupTravel = false;
  bool isStartTravel = false;
  bool isFinishTravel = false;

  StreamSubscription<DocumentSnapshot> _streamLocationController;

  StreamSubscription<DocumentSnapshot> _streamTravelController;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _geofireProvider = new GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');

    markerDriver = await createMarkerImageFromAsset('assets/img/icon_taxi.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

   // _idTravel = ModalRoute.of(context).settings.arguments as String;

   // print('idTravelClient: $_idTravel');
    _loadMapStyles();
    startListening();
    Wakelock.enable();
    checkGPS();
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
  void getDriverLocation(String idDriver) {
    Stream<DocumentSnapshot> stream = _geofireProvider.getLocationByIdStream(idDriver);
  _streamLocationController =  stream.listen((DocumentSnapshot document) {
      GeoPoint geoPoint = document.data()['position']['geopoint'];
      _driverLatLng = new LatLng(geoPoint.latitude, geoPoint.longitude);
      addSimpleMarker(
          'driver',
          _driverLatLng.latitude,
          _driverLatLng.longitude,
          'Tu conductor',
          '',
          markerDriver
      );

      refresh();

      if (!isRouteReady) {
        isRouteReady = true;
        checkTravelStatus();
      }

    });

  }

  void finishTravel(){
    if (!isFinishTravel) {
      isFinishTravel = true;
      Navigator.pushNamedAndRemoveUntil(context, 'client/travel/calification', (route) => false, arguments: travelInfo.idTravelHistory);
    }
  }

  void pickupTravel() {
    if (!isPickupTravel) {
      isPickupTravel = true;
      LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
      addSimpleMarker('from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker);
      setPolylines(from, to);
    }
  }

  void checkTravelStatus() async {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_authProvider.getUser().uid);
   _streamTravelController = stream.listen((DocumentSnapshot document) {
      travelInfo = TravelInfo.fromJson(document.data());

      if (travelInfo.status == 'accepted') {
        currentStatus = 'Viaje Aceptado';
        colorStatus = Colors.blue;
        pickupTravel();
      }
      else if (travelInfo.status == 'started') {
        currentStatus = 'Viaje Iniciado';
        colorStatus = Colors.blue;
        startTravel();
      }
      else if (travelInfo.status == 'finished') {
        currentStatus = 'Viaje Finalizado';
        colorStatus = Colors.blue;
        finishTravel();
      }

      refresh();

    });
  }

  void openBottomSheet() {
    if (driver == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetClientInfo(
          imageUrl: driver?.image,
          username: driver?.username,
          email: driver?.email,
          plate: driver?.plate,
        )
    );
  }

  void startTravel() {
    if (!isStartTravel) {
      isStartTravel = true;
      polylines = {};
      points = List();
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
          'to',
          travelInfo.toLat,
          travelInfo.toLng,
          'Destino',
          '',
          toMarker
      );

      LatLng from = new LatLng(_driverLatLng.latitude, _driverLatLng.longitude);
      LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLng);

      setPolylines(from, to);

      refresh();
    }
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider.getById(_authProvider.getUser().uid);
    animateCameraToPosition(travelInfo.fromLat, travelInfo.fromLng);
    getDriverInfo(travelInfo.idDriver);
    getDriverLocation(travelInfo.idDriver);
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {

    print('------------------ENTRO SET POLYLINES------------------');

    PointLatLng pointFromLatLng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatLng = PointLatLng(to.latitude, to.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        Environment.API_KEY_MAPS,
        pointFromLatLng,
        pointToLatLng
    );

    for (PointLatLng point in result.points) {
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.blue,
        points: points,
        width: 6
    );

    polylines.add(polyline);

    // addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

    refresh();
  }

  void getDriverInfo(String id) async {
    driver = await _driverProvider.getById(id);
    refresh();
  }

  void dispose() {
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();
    _streamLocationController?.cancel();
    _streamTravelController?.cancel();
    _lightSubscription?.cancel();
    _positionStream?.cancel();


  }
  void cancelarViaje(){

    dispose();
    Map<String, dynamic> data = {

      'clientStatus': 'acc',
      'status': 'no_accepted'
    };

    _travelInfoProvider.update(data, _authProvider.getUser().uid);
    if(currentStatus == 'Viaje Iniciado') {
      utils.Snackbar.showSnackbar(context, key, 'No puede cancelar el viaje una vez iniciado');

    }else
    Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[]');
    _mapController.complete(controller);

    _getTravelInfo();
  }
  void centerPosition() {

      animateCameraToPosition(travelInfo.fromLat, travelInfo.fromLng);


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
  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();

      _getTravelInfo();
      centerPosition();
      saveLocation();



      _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) async {



        _position = position;

        animateCameraToPosition(_position.latitude, _position.longitude);



        saveLocation();
        refresh();
      });

    } catch(error) {
      print('Error en la localizacion: $error');
    }
  }
  void saveLocation() async {
    await _geofireProvider.createWorking(
        _authProvider.getUser().uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();
  }
  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS ACTIVADO');
      updateLocation();
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        print('ACTIVO EL GPS');
        updateLocation();
      }
    }

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
  void addSimpleMarker(
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
    );

    markers[id] = marker;
  }

}