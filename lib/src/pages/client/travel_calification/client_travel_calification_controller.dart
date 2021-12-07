import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class ClientTravelCalificationController{

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey();

  String idTravelHistory;
  TravelHistory travelHistory;

  double calification;

  TravelHistoryProvider _travelHistoryProvider;

  Future init(BuildContext context, Function refresh){
    this.context = context;
    this.refresh = refresh;

    _travelHistoryProvider = new TravelHistoryProvider();


    idTravelHistory = ModalRoute.of(context).settings.arguments as String;

    print('idTravelHisotry: $idTravelHistory');
    getTravelHistory();
  }


  void calificate () async {
    if (calification == null || calification == 0) {
      utils.Snackbar.showSnackbar(
          context, key, 'Por favor califica a tu conductor');
      return;
    }
   else if ( calification < 1) {
      utils.Snackbar.showSnackbar(
          context, key, 'La calificacion minima debe ser 1');
      return;
    } else {
      Map<String, dynamic> data = {

        'calificationDriver': calification
      };

      await _travelHistoryProvider.update(data, idTravelHistory);
      Navigator.pushNamedAndRemoveUntil(
          context, 'client/map', (route) => false);
    }
  }

  void getTravelHistory() async{
    travelHistory =  await _travelHistoryProvider.getById(idTravelHistory);
    refresh();
  }

}