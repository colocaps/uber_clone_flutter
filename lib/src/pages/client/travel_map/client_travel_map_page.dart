import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_map/driver_travel_map_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';
import 'client_travel_map_controller.dart';

class ClientTravelMapPage extends StatefulWidget {
  const ClientTravelMapPage({Key key}) : super(key: key);

  @override
  _ClientTravelMapPage createState() => _ClientTravelMapPage();
}

class _ClientTravelMapPage extends State<ClientTravelMapPage> {

  ClientTravelMapController _con = new ClientTravelMapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.key,
        body: Stack(
          children: [
            googleMapsWidget(),
            SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buttonUserInfo(),
                      _cardStatusInfo(_con.currentStatus ),
                      _buttonCenterPosition(),

                    ],
                  ),
                  Expanded(child: Container()),
                  _buttonStatus()

                ],


              ),

            ),

          ],


        ),


    );
  }


  Widget _cardStatusInfo(String status){
    return SafeArea(
      child: Container(
        width: 110,
        padding: EdgeInsets.symmetric(vertical:10 ),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: _con.colorStatus,
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Text(
          '${ status ?? ''} ',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white
          ),
        ),

      ),
    );
  }

  Widget _buttonUserInfo(){
    return GestureDetector(
      onTap: _con.openBottomSheet,
      child: Container(

        height: 50 ,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: utils.Colors.uberCloneColor,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20
            ),
          ),
        ),




      ),
    );
  }



  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(

        height: 50 ,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: utils.Colors.uberCloneColor,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.location_searching,
                color: Colors.white,
                size: 20
            ),
          ),
        ),




      ),
    );
  }




  Widget googleMapsWidget(){



    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,


    );


  }
  Widget _buttonStatus(){
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      height: 50 ,
      child: ButtonApp(
        onPressed: _con.cancelarViaje,
        text:  'Cancelar Viaje',
        color: utils.Colors.uberCloneColor,
        textColor:  Colors.white,

      ),


    );
  }

  void refresh(){
    setState(() {
    });
  }
}
