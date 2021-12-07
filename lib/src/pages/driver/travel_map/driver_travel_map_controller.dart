import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:light/light.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/api/environment.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/prices_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/models/prices.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/bottom_sheet_driver_info.dart';
import 'package:wakelock/wakelock.dart';


class DriverTravelMapController {

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

  BitmapDescriptor markerDriver;
  BitmapDescriptor fromMarker;
  BitmapDescriptor toMarker;
  SharedPref _sharedPref;


  String _luxString = 'Unknown';
  Light _light;
  StreamSubscription _lightSubscription;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;
  String _darkMapStyle;
  String _lightMapStyle;


  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  PushNotificationsProvider _pushNotificationsProvider;
  TravelInfoProvider _travelInfoProvider;
  PricesProvider _pricesProvider;
  ClientProvider _clientProvider;
  TravelHistoryProvider _travelHistoryProvider;

  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _driverInfoSuscription;

  Set<Polyline> polylines = {};
  List<LatLng> points = new List();

  Driver driver;
  Client _client;

  String _idTravel;
  TravelInfo travelInfo;

  String currentStatus = 'INICIAR VIAJE';
  Color colorStatus = Colors.white;

  double _distanceBetween = 0 ;

  Timer _timer;
  int seconds = 0;
  int minutes = 0;
  double mt = 0;
  double km = 0;
  int secondsPassed = 0;
  int hours = 0;
  int tiempoQuePaso = 0;

  String idClient;
  Client client;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;


  

      _idTravel = ModalRoute.of(context).settings.arguments as String;

    print('idTravel: $_idTravel');
    _geofireProvider = new GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _pricesProvider = new PricesProvider();
    _clientProvider = new ClientProvider();
    _travelHistoryProvider = new TravelHistoryProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');

    markerDriver = await createMarkerImageFromAsset('assets/img/taxi_icon.png');
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    _sharedPref = new SharedPref();



    _checkClientResponse();

    getClientInfo();


    _loadMapStyles();
    startListening();

    checkGPS();
    getDriverInfo();

    Wakelock.enable();


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


  void getClientInfo() async {
    _client = await _clientProvider.getById(_idTravel);

  }

  Future<double> calculatePrice() async {
    Prices prices = await _pricesProvider.getAll();

    if (seconds < 60) seconds = 60;
    if (km == 0) km = 0.1;

    int min = seconds ~/ 60;

    print('=========== MIN TOTALES ==============');
    print(min.toString());

    print('=========== KM TOTALES ==============');
    print(km.toString());

    double priceMin = min * prices.min;
    double priceKm = km * prices.km;

    double total = priceMin + priceKm;

    if (total < prices.minValue) {
      total = prices.minValue;
    }

    print('=========== TOTAL ==============');
    print(total.toString());

    return total;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds = timer.tick;
      secondsPassed = secondsPassed + 1;
      seconds = secondsPassed * 60;
      minutes = secondsPassed ~/ 60;
      hours = secondsPassed ~/ (60 * 60);

      // String durationToString(int minutes) {
      //   var d = Duration(minutes:minutes);
      //   List<String> parts = d.toString().split(':');
      //   return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      // }
      //
      // print(durationToString(minutes));


      refresh();
    });
  }
  void saveTime() async {

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('HH:mm:ss');
    final String formatted = formatter.format(now);
    await _sharedPref.save('myTimestampKey', formatted);

    print('tiempo:$formatted');



  }



  void isCloseToPickupPosition(LatLng from, LatLng to) {
    _distanceBetween = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude
    );
    print('------ DISTANCE: $_distanceBetween--------');
  }

  void updateStatus () {
    if (travelInfo.status == 'accepted') {
      startTravel();
    }
    else if (travelInfo.status == 'started') {
      finishTravel();
    }
  }



  void startTravel() async {
    if (_distanceBetween <= 100) {
      Map<String, dynamic> data = {
        'status': 'started'
      };
      await _travelInfoProvider.update(data, _idTravel);
      travelInfo.status = 'started';
      currentStatus = 'FINALIZAR VIAJE';
      colorStatus = Colors.white;

      polylines = {};
      points = List();
      // markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
          'to',
          travelInfo.toLat,
          travelInfo.toLng,
          'Destino',
          '',
          toMarker
      );

      LatLng from = new LatLng(_position.latitude, _position.longitude);
      LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLng);

      setPolylines(from, to);
      saveTime();

      startTimer();
      refresh();
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Debes estar cerca a la posicion del cliente para iniciar el viaje');
    }

    refresh();
  }

  void finishTravel() async {
    _timer?.cancel();

    double total = await calculatePrice();


    saveTravelHistory(total);

    _travelInfoProvider.delete( _idTravel);

  }

  void saveTravelHistory(double price)async {
    TravelHistory travelHistory = new TravelHistory(
      from: travelInfo.from,
      to: travelInfo.to,
      idDriver: _authProvider.getUser().uid,
      idClient: _idTravel,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      price: price


    );

   String id = await _travelHistoryProvider.create(travelHistory);
    Map<String, dynamic> data = {
      'status': 'finished',
      'idTravelHistory': id,
      'price': price,
    };
    await _travelInfoProvider.update(data, _idTravel);
    travelInfo.status = 'finished';
    Navigator.pushNamedAndRemoveUntil(context, 'driver/travel/calification', (route) => false, arguments: id);

  }

  void _getTravelInfo() async {

    travelInfo = await _travelInfoProvider.getById(_idTravel);
    if(travelInfo.status == 'started' ){
      print('started');
      currentStatus = 'FINALIZAR VIAJE';
      colorStatus = Colors.white;
      polylines = {};
      points = List();
      // markers.remove(markers['from']);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addSimpleMarker(
          'to',
          travelInfo.toLat,
          travelInfo.toLng,
          'Destino',
          '',
          toMarker
      );
      addSimpleMarker(
          'from',
          travelInfo.fromLat,
          travelInfo.fromLng,
          'Origen',
          '',
          fromMarker
      );

      LatLng from = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
      LatLng to = new LatLng(travelInfo.toLat, travelInfo.toLng);

      setPolylines(from, to);

      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('HH:mm:ss');
      final String tiempoASumar = formatter.format(now);

      String tiempoInical = await _sharedPref.read('myTimestampKey');

      DateTime dtInicial =  new DateFormat("HH:mm:ss").parse(tiempoInical);
      DateTime dtASumar =  new DateFormat("HH:mm:ss").parse(tiempoASumar);

      print('tiempoinicial $dtInicial');
      print('tiempoasumar $dtASumar');

      String tiempoFinal = dtASumar.difference(dtInicial).toString();
      int tmFinal = dtASumar.difference(dtInicial).inMilliseconds ~/1000;

      print('tiempofinal $tiempoFinal');
      print('tiempofinal $tmFinal');

      secondsPassed = tmFinal;
      startTimer();





    }else {
      LatLng from = new LatLng(_position.latitude, _position.longitude);
      LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
      addSimpleMarker(
          'from', to.latitude, to.longitude, 'Recoger aqui', '', fromMarker);
      setPolylines(from, to);
      // getClientInfo();

    }

  }

  Future<void> setPolylines(LatLng from, LatLng to) async {
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

  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser().uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data());
      refresh();
    });
  }

  void dispose() {
    _lightSubscription?.cancel();
    _streamStatusSubscription?.cancel();
    _timer?.cancel();
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _driverInfoSuscription?.cancel();


  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle('[]');
    _mapController.complete(controller);
  }

  void saveLocation() async {
    await _geofireProvider.createWorking(
        _authProvider.getUser().uid,
        _position.latitude,
        _position.longitude
    );
    _progressDialog.hide();
  }

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();

      _getTravelInfo();
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

      _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) async {

        if (travelInfo?.status == 'started') {
          mt = mt + Geolocator.distanceBetween(
              _position.latitude,
              _position.longitude,
              position.latitude,
              position.longitude
          );
          Map<String, dynamic> data = {
            'metrosRecorridos': mt ?? null


          };
          _travelInfoProvider.update(data, travelInfo.id);

         double metros = travelInfo.metrosRecorridos;

          km = (metros+ mt) / 1000;
        }

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

        if (travelInfo.fromLat != null && travelInfo.fromLng != null) {
          LatLng from = new LatLng(_position.latitude, _position.longitude);
          LatLng to = new LatLng(travelInfo.fromLat, travelInfo.fromLng);
          isCloseToPickupPosition(from, to);
        }

        saveLocation();
        refresh();
      });

    } catch(error) {
      print('Error en la localizacion: $error');
    }
  }

  void openBottomSheet() {
    if (_client == null) return;

    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetDriverInfo(
          imageUrl: _client?.image,
          username: _client?.username,
          email: _client?.email,
        )
    );
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
    }
    else {
      print('GPS DESACTIVADO');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
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

  void _checkClientResponse() {
    print('idTravel: $_idTravel');
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_idTravel);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());

      if(travelInfo.clientStatus == 'acc' ){
        Map<String, dynamic> data = {

          'clientStatus': 'ac'
        };

        _travelInfoProvider.update(data, _idTravel);
        utils.Snackbar.showSnackbar(context, key, 'El cliente cancelo el viaje');
        print('El cliente cancelo el viaje');
        Future.delayed(Duration(milliseconds: 3000),(){
          Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);

        });

      }

      refresh();
    });
  }
}