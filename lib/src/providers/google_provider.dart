import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uber_clone_flutter_udemy/src/api/environment.dart';
import 'package:uber_clone_flutter_udemy/src/models/directions.dart';

class GoogleProvider{

  Future<dynamic> getGoogleMapsDirections (
      double fromLat, double fromLng,
      double toLat, double toLng) async{
    Uri uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/directions/json',
        {
          'key': Environment.API_KEY_MAPS,
          'origin': '$fromLat,$fromLng',
          'destination': '$toLat,$toLng',
          'traffic_models': 'best_guess',
          'departure_time': DateTime.now().millisecondsSinceEpoch.toString(),
          'mode': 'driving',
          'transit_routing_preferences': 'less_driving'


      }
    );
    print('URI: $uri');

    final response = await http.get(uri);
    final decodedData = json.decode(response.body);
    final leg = new Direction.fromJsonMap(decodedData['routes'][0]['legs'][0]);
    return leg;
  }
}