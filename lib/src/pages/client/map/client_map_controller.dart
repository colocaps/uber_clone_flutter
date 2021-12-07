import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light/light.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/api/environment.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_info.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/geofire_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_info_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:wakelock/wakelock.dart';

class ClientMapController {

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
  String _idTravel;

  String _luxString = 'Unknown';
  Light _light;
  StreamSubscription _lightSubscription;
  String _darkMapStyle;
  String _lightMapStyle;
  TravelInfoProvider _travelInfoProvider;

  BitmapDescriptor markerDriver;
  TravelInfo travelInfo;
  GeofireProvider _geofireProvider;
  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ClientProvider _clientProvider;
  SharedPref _sharedPref;
  PushNotificationsProvider _pushNotificationsProvider;

  bool isConnect = false;
  ProgressDialog _progressDialog;

  StreamSubscription<DocumentSnapshot> _statusSuscription;
  StreamSubscription<DocumentSnapshot> _clientInfoSubscription;
  StreamSubscription<DocumentSnapshot> _streamStatusSubscription;
  Stream<List<DocumentSnapshot>> stream;
  Client client;
  Driver driver;

  String from;
  LatLng fromLatLng;

  String to;
  LatLng toLatLng;

  bool isFromSelected = true;

  places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(apiKey: Environment.API_KEY_MAPS);

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _geofireProvider = new GeofireProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _clientProvider = new ClientProvider();
    _travelInfoProvider = new TravelInfoProvider();
    _pushNotificationsProvider = new PushNotificationsProvider();
    _sharedPref = new SharedPref();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectandose...');
    markerDriver = await createMarkerImageFromAsset('assets/img/icon_taxi.png');



    _loadMapStyles();
    startListening();
    checkGPS();
    saveToken();
    getClientInfo();
    Wakelock.enable();

    _idTravel = await _sharedPref.read('TravelInfoID');
    print('idTravel $_idTravel');
    if(client != null) {
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
  void goToHistoryPage(){
    Navigator.pushNamed(context, 'client/history');
  }

  void goToEditPage(){
    Navigator.pushNamed(context, 'client/edit');
  }
  

  void getClientInfo() {
    Stream<DocumentSnapshot> clientStream = _clientProvider.getByIdStream(_authProvider.getUser().uid);
    _clientInfoSubscription = clientStream.listen((DocumentSnapshot document) {
      client = Client.fromJson(document.data());
      refresh();
    });
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void dispose() {
    _positionStream?.cancel();
    _statusSuscription?.cancel();
    _clientInfoSubscription?.cancel();
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

  void updateLocation() async  {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition(); // UNA VEZ
      centerPosition();
      getNearbyDrivers();

    } catch(error) {
      print('Error en la localizacion: $error');
    }
  }

  void requestDriver() {
    if (fromLatLng != null && toLatLng != null) {
      Navigator.pushNamed(context, 'client/travel/info', arguments: {
        'from': from,
        'to': to,
        'fromLatLng': fromLatLng,
        'toLatLng': toLatLng,

      });
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Seleccione el lugar de origen y destino');
    }
  }

  void changeFromTO() {
    isFromSelected = !isFromSelected;

    if (isFromSelected) {
      utils.Snackbar.showSnackbar(context, key, 'Estas seleccionando el lugar de origen');
    }
    else {
      utils.Snackbar.showSnackbar(context, key, 'Estas seleccionando el lugar destino');
    }

  }

  Future<Null> showGoogleAutoComplete(bool isFrom) async {
    places.Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Environment.API_KEY_MAPS,
        language: 'es',
        strictbounds: true,
        radius: 15000,  //esto es en metros
        location: places.Location(-31.415772, -64.189339)

    );

    if (p != null) {
      places.PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId, language: 'es');
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      List<Address> address = await Geocoder.local.findAddressesFromQuery(p.description);
      if (address != null) {
        if (address.length > 0) {
          if (detail != null) {
            String direction = detail.result.name;
            String city = address[0].locality;
            String department = address[0].adminArea;

            if (isFrom) {
              from = '$direction, $city, $department';
              fromLatLng = new LatLng(lat, lng);
            }
            else {
              to = '$direction, $city, $department';
              toLatLng = new LatLng(lat, lng);
            }

            refresh();
          }
        }
      }


    }
  }

  Future<Null> setLocationDraggableInfo() async {
    if (initialPosition != null) {
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat, lng);

      if (address != null) {
        if (address.length > 0) {
          String direction = address[0].thoroughfare;
          String street = address[0].subThoroughfare;
          String city = address[0].locality;
          String department = address[0].administrativeArea;
          String country = address[0].country;

          if (isFromSelected) {
            from = '$direction N° $street, $city, $department';
            fromLatLng = new LatLng(lat, lng);
          }
          else {
            to = '$direction N° $street, $city, $department';
            toLatLng = new LatLng(lat, lng);
          }

          refresh();
        }
      }
    }
  }

  void saveToken() {
    _pushNotificationsProvider.saveToken(_authProvider.getUser().uid, 'client');
  }

  void getNearbyDrivers() {
    stream = _geofireProvider.getNearbyDrivers(_position.latitude, _position.longitude, 50);

    stream.listen((List<DocumentSnapshot> documentList) {

      for (DocumentSnapshot d in documentList) {
        print('DOCUMENT: $d');
      }

      for (MarkerId m in markers.keys) {
        bool remove = true;

        for (DocumentSnapshot d in documentList) {
          if (m.value == d.id) {
            remove = false;
          }
        }

        if (remove) {
          markers.remove(m);
          refresh();
        }

      }

      for (DocumentSnapshot d in documentList) {
        GeoPoint point = d.data()['position']['geopoint'];
        addMarker(
            d.id,
            point.latitude,
            point.longitude,
            'Conductor disponible',
            '',
            markerDriver
        );
      }

      refresh();

    });
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
              zoom: 14
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
  void _checkTravel() {
    print('checktravel');
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_idTravel);
    _streamStatusSubscription = stream.listen((DocumentSnapshot document) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data());


      if(travelInfo.status == 'accepted' ){
        print('travelmap');
        Navigator.pushNamed(context, 'client/travel/map',  arguments: _idTravel);

      }
      if(travelInfo.status == 'started' ){
        print('travelmap');
        Navigator.pushNamed(context, 'client/travel/map', arguments: _idTravel);

      }

      refresh();
    });
  }


}