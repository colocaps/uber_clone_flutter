import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';



class DriverHistoryController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  ProgressDialog _progressDialog;

  TravelHistory _travelHisotry;
  AuthProvider _authProvider;
  TravelHistoryProvider _travelHistoryProvider;


  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _travelHisotry = new TravelHistory();
    _travelHistoryProvider = new TravelHistoryProvider();
    _authProvider = new AuthProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');


    refresh();
  }


  Future<List<TravelHistory>> getAll() async{
    return await _travelHistoryProvider.getByIdDriver(_authProvider.getUser().uid);

}


    void goToDetailHistory(String id) async {
    Navigator.pushNamed(context, 'driver/history/detail',arguments: id);

    }

}
