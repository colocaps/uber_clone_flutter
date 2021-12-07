import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light/light.dart';
import 'package:uber_clone_flutter_udemy/src/api/environment.dart';
import 'package:uber_clone_flutter_udemy/src/models/directions.dart';
import 'package:uber_clone_flutter_udemy/src/models/prices.dart';
import 'package:uber_clone_flutter_udemy/src/providers/google_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/prices_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:wakelock/wakelock.dart';

class ClientTravelInfoController {



  String _luxString = 'Unknown';
  Light _light;
  StreamSubscription _lightSubscription;
  String _darkMapStyle;
  String _lightMapStyle;

   GoogleProvider _googleProvider;
   PricesProvider _pricesProvider;
   BuildContext context;
    Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = CameraPosition(
      target: LatLng(-31.415772, -64.189339),
      zoom: 14.0
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

   String from = '';
   String to = '';
   LatLng fromLatLng;
   LatLng toLatLng;
   double minTotal ;
   double maxTotal ;
  Set<Polyline> polylines = {};

  List<LatLng> points = new List.empty(growable: true);

    BitmapDescriptor fromMarker;
    BitmapDescriptor toMarker;
    Direction _directions;
    String min = '';
    String km = '';

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    from = arguments['from'];
    to = arguments['to'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    _googleProvider = new GoogleProvider();
    _pricesProvider = new PricesProvider();
    fromMarker = await createMarkerImageFromAsset('assets/img/map_pin_red.png');
    toMarker = await createMarkerImageFromAsset('assets/img/map_pin_blue.png');

    animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
    getGoogleMapDirections(fromLatLng, toLatLng);

    _loadMapStyles();
    startListening();
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
  Future<void> setPolylines() async {
    PointLatLng pointFromLatLng = PointLatLng(fromLatLng.latitude, fromLatLng.longitude);
    PointLatLng pointToLatLng = PointLatLng(toLatLng.latitude, toLatLng.longitude);

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
        color: utils.Colors.uberCloneColor,
        points: points,
        width: 8
    );


    polylines.add(polyline);
    addMarker('from', fromLatLng.latitude, fromLatLng.longitude, 'Recoger aqui', '', fromMarker);
    addMarker('to', toLatLng.latitude, toLatLng.longitude, 'Destino', '', toMarker);

    refresh();
  }

  void getGoogleMapDirections(LatLng from, LatLng to) async {
    _directions = await _googleProvider.getGoogleMapsDirections(
        from.latitude, from.longitude,
        to.latitude, to.longitude
    );
    min = _directions.duration.text;
    km = _directions.distance.text;
    calculatePrices();
    refresh();
  }
  void dispose() {

    _lightSubscription?.cancel();
  }
  void goToRequest(){

    Navigator.pushNamed(context, 'client/travel/request',arguments: {
      'from': from,
      'to': to,
      'fromLatLng': fromLatLng,
      'toLatLng': toLatLng,


    });
  }

  void calculatePrices() async {
    Prices prices = await _pricesProvider.getAll();
    double kmValue = double.parse(km.split(" ")[0]) * prices.km;
    double minValue = double.parse(min.split(" ")[0]) * prices.min;
    double total = kmValue + minValue;

    if (total <= prices.minValue) {
      minTotal = prices.minValue;
      maxTotal = prices.minValue + 50;
    }
    else {
      minTotal = total ;
      maxTotal = total + 50;
    }

    refresh();
  }


  Future animateCameraToPosition(double latitude, double longitude) async {
    GoogleMapController controller = await _mapController.future;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              bearing: 0,
              target: LatLng(latitude, longitude),
              zoom: 15
          )
      ));
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle('[]');
    _mapController.complete(controller);
    await setPolylines();
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
    );

    markers[id] = marker;

  }

}