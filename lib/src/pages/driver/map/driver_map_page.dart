import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/map/driver_map_controller.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;


class DriverMapPage extends StatefulWidget {
  const DriverMapPage({Key key}) : super(key: key);

  @override
  _DriverMapPageState createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {

  DriverMapController _con = new DriverMapController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    _con.init(context, refresh);

    });
  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();

    print('SE EJECUTO EL DISPOSE');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      drawer: _drawer(),
      body: Stack(
        children: [
          googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buttonDrawer(),
                    buttonCenterPosition()
                  ],
                ),
                Expanded(child: Container()),
                buttonConnect(),

              ],


            ),
          ),

        ],


      )


    );
  }

  Widget _drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                    _con.driver?.username ?? 'Usuario',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                      maxLines: 1,
                   ),


                  ),
                  Container(
                    child: Text(
                      _con.driver?.email ?? 'Email',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      maxLines: 1,
                    ),


                  ),
                  SizedBox(height: 10),
                  CircleAvatar(
                    backgroundImage:  _con.driver?.image != null
                        ? NetworkImage(_con.driver?.image)
                        : AssetImage('assets/img/profile.jpg'),
                    radius: 40,
                  )
                ],
              ),
              decoration: BoxDecoration(
                color:utils.Colors.uberCloneColor,
              ),
          ),
          ListTile(
            title: Text('Editar Perfil'),
            trailing: Icon(Icons.edit),
           // leading: Icon(Icons.cancel),
            onTap: _con.goToEditPage,

          ),ListTile(
            title: Text('Historial de Viajes'),
            trailing: Icon(Icons.timer),
           // leading: Icon(Icons.cancel),
            onTap: _con.goToHistoryPage,

          ),
          ListTile(
            title: Text('Cerrar Sesion'),
            trailing: Icon(Icons.power_settings_new),
            // leading: Icon(Icons.cancel),
            onTap: _con.singOut,

          )

        ],
      )

    );
  }



  Widget buttonCenterPosition(){
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

  Widget buttonDrawer(){
    return Container(
        height: 50 ,
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: _con.openDrawer,
          icon: Icon(
              Icons.menu,
              color: Colors.blue,
          ),
        ),
      );
  }

  Widget buttonConnect(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      height: 50 ,
          child: ButtonApp(
            onPressed: _con.connect,
            text: _con.isConnect ? 'DESCONECTARSE' : 'CONECTARSE',
            color: _con.isConnect ? Colors.grey : utils.Colors.uberCloneColor,
            textColor: _con.isConnect ? Colors.black : Colors.white,

          ),


    );
  }

  Widget googleMapsWidget() {
    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _con.initialPosition,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        markers: Set<Marker>.of(_con.markers.values),
        onMapCreated:  _con.onMapCreated
    );

  }

  @override
  void refresh(){
      setState(() {


      });
  }

}
