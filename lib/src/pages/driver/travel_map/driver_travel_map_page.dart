import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_map/driver_travel_map_controller.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

class DriverTravelMapPage extends StatefulWidget {
  const DriverTravelMapPage({Key key}) : super(key: key);

  @override
  _DriverTravelMapPageState createState() => _DriverTravelMapPageState();
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Give your RootRestorationScope an id, defaults to null.
      restorationScopeId: 'driver/travel/map',

    );
  }
}
class _DriverTravelMapPageState extends State<DriverTravelMapPage>
    with RestorationMixin {

  final RestorableInt _index = RestorableInt(0);
  DriverTravelMapController _con = new DriverTravelMapController();

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
                      Column(
                        children: [
                          _cardKmInfo(_con.km?.toStringAsFixed(1)),
                          _cardMinInfo(_con.minutes?.toString())
                      ]
                      ),

                      _buttonCenterPosition()
                    ],
                  ),
                  Expanded(child: Container()),
                  _buttonStatus(),

                ],


              ),
            ),

          ],


        )


    );
  }

  Widget _cardKmInfo(String km){
    return SafeArea(
      child: Container(
        width: 110,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
        color: utils.Colors.uberCloneColor,
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Text(
            '${ km ?? ''} km',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white
          ),
        ),

      ),
    );
  }
  Widget _cardMinInfo(String min){
    return SafeArea(
      child: Container(
        width: 110,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: utils.Colors.uberCloneColor,
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Text(
          '${ min ?? ''} min',
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



  Widget _buttonStatus(){
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      height: 50 ,
      child: ButtonApp(
        onPressed: _con.updateStatus,
        text:  _con.currentStatus,
        color: utils.Colors.uberCloneColor,
        textColor:  _con.colorStatus,

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

  void refresh(){
    setState(() {
    });
  }

  @override
  // TODO: implement restorationId
  String get restorationId => 'driver/travel/map';

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    // Register our property to be saved every time it changes,
    // and to be restored every time our app is killed by the OS!
    registerForRestoration(_index, 'nav_bar_index');
  }

}
