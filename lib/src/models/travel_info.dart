// To parse this JSON data, do
//
//     final travelInfo = travelInfoFromJson(jsonString);

import 'dart:convert';

TravelInfo travelInfoFromJson(String str) => TravelInfo.fromJson(json.decode(str));

String travelInfoToJson(TravelInfo data) => json.encode(data.toJson());

class TravelInfo {
  TravelInfo({
    this.id ,
    this.status ,
    this.idDriver,
    this.from ,
    this.to ,
    this.idTravelHistory,
    this.fromLat,
    this.fromLng,
    this.toLat ,
    this.toLng ,
    this.price ,
    this.clientStatus,
    this.metrosRecorridos,

  });

  String id;
  String status;
  String idDriver;
  String from;
  String to;
  String idTravelHistory;
  double fromLat;
  double fromLng;
  double toLat;
  double toLng;
  double price;
  String clientStatus;
  double metrosRecorridos;

  factory TravelInfo.fromJson(Map<String, dynamic> json) => TravelInfo(
    id: json["id"],
    status: json["status"],
    idDriver: json["idDriver"],
    from: json["from"],
    to: json["to"],
    idTravelHistory: json["idTravelHistory"],
    fromLat: json["fromLat"]?.toDouble() ?? 0,
    fromLng: json["fromLng"]?.toDouble() ?? 0,
    toLat: json["toLat"]?.toDouble() ?? 0,
    toLng: json["toLng"]?.toDouble() ?? 0,
    price: json["price"]?.toDouble() ?? 0,
    metrosRecorridos: json["metrosRecorridos"]?.toDouble() ?? 0,
    clientStatus: json["clientStatus"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "idDriver": idDriver,
    "from": from,
    "to": to,
    "idTravelHistory": idTravelHistory,
    "fromLat": fromLat,
    "fromLng": fromLng,
    "toLat": toLat,
    "toLng": toLng,
    "price": price,
    "clientStatus": clientStatus,
    "metrosRecorridos" : metrosRecorridos,
  };
}