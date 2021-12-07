import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';



class ClientHistoryDetailController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();


  AuthProvider _authProvider;
  TravelHistoryProvider _travelHistoryProvider;
  String idTravelHistory;
  TravelHistory travelHistory;
  DriverProvider _driverProvider;
  Driver driver;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context).settings.arguments as String;

    _travelHistoryProvider = new TravelHistoryProvider();
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();

      getTravelHistoryinfo();


  }


    void getTravelHistoryinfo()async{
     travelHistory = await _travelHistoryProvider.getById(idTravelHistory);
     getDriverInfo(travelHistory.idDriver);
    }

     void getDriverInfo(String idDriver) async{
        driver = await _driverProvider.getById(idDriver);
        refresh();
      }


}
