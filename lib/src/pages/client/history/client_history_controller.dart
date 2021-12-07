import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/travel_history_provider.dart';



class ClientHistoryController {

  BuildContext context;
  Function refresh;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TravelHistory _travelHisotry;
  AuthProvider _authProvider;
  TravelHistoryProvider _travelHistoryProvider;


  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    _travelHisotry = new TravelHistory();
    _travelHistoryProvider = new TravelHistoryProvider();
    _authProvider = new AuthProvider();

    refresh();
  }


  Future<List<TravelHistory>> getAll() async{
    return await _travelHistoryProvider.getByIdClient(_authProvider.getUser().uid);

}


    void goToDetailHistory(String id){
    Navigator.pushNamed(context, 'client/history/detail',arguments: id);

    }

}
