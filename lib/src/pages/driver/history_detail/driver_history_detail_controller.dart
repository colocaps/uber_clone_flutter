import 'package:daylight/daylight.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';



class DriverHistoryDetailController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();


  AuthProvider _authProvider;
  TravelHistoryProvider _travelHistoryProvider;
  String idTravelHistory;
  TravelHistory travelHistory;
  ClientProvider _clientProvider;
  Client client;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context).settings.arguments as String;

    _travelHistoryProvider = new TravelHistoryProvider();
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();

      getTravelHistoryinfo();


  }



    void getTravelHistoryinfo()async{
     travelHistory = await _travelHistoryProvider.getById(idTravelHistory);
     getClientInfo(travelHistory.idClient);
    }

     void getClientInfo(String idClient) async{
        client = await _clientProvider.getById(idClient);
        refresh();
      }


}
