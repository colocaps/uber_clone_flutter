

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataInfo {
  String text;
  int value;

  DataInfo({

    this.text,
    this.value

});
DataInfo.fromJsonMap(Map<String, dynamic> json){
  text = json['text'];
  value = json['value'];

}


}


class Direction {

  DataInfo distance;
  DataInfo duration;
  String startAdress;
  String endAdress;
  LatLng startLocation;
  LatLng endLocation;

  Direction({
    this.startAdress,
    this.endAdress,
    this.startLocation,
    this.endLocation

  });

  Direction.fromJsonMap(Map<String, dynamic> json){

    distance = new DataInfo.fromJsonMap(json['distance']);
    duration = new DataInfo.fromJsonMap(json['duration']);
    startAdress = json['start_adress'];
    endAdress = json['end_adress'];

    startLocation = new LatLng(
        json['start_location']['lat'],
        json['start_location']['lng']
    );
    endLocation = new LatLng(
        json['end_location']['lat'],
        json['end_location']['lng']
    );

  }

  Map<String, dynamic> toJson() =>{
    'distance': distance.text,
    'duration': duration.text

  };

}