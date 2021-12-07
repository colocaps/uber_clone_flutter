import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/map/client_map_controller.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
class ClientMapPage extends StatefulWidget {
  const ClientMapPage({Key key}) : super(key: key);

  @override
  _ClientMapPageState createState() => _ClientMapPageState();
}

class _ClientMapPageState extends State<ClientMapPage> {
  ClientMapController _con = new ClientMapController();
   Function function ;
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
                  _buttonDrawer(),
                  _cardGooglePlaces(),
                  _buttonChangeTo(),
                  _buttonCenterPosition(),

                  Expanded(child: Container()),
                  buttonRequest(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _iconMyLocation(),

            )
          ],
        )
    );
  }

  Widget _iconMyLocation(){
    return Image.asset(
        'assets/img/my_location_yellow.png',
      width: 45,
      height: 45,
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
                      _con.client?.username ?? 'Usuario',
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
                      _con.client?.email ?? 'Email',
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
                    backgroundImage:  _con.client?.image != null
                        ? NetworkImage(_con.client?.image)
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

            ),ListTile(
              title: Text('Cerrar Sesion'),
              trailing: Icon(Icons.power_settings_new),
              // leading: Icon(Icons.cancel),
              onTap: _con.signOut,

            )

          ],
        )

    );
  }



  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _con.centerPosition,
      child: Container(

        height: 50 ,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 18),
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
  Widget _buttonChangeTo(){
    return GestureDetector(
      onTap: _con.changeFromTO,
      child: Container(

        height: 50 ,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: Card(
          shape: CircleBorder(),
          color: utils.Colors.uberCloneColor,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20
            ),
          ),
        ),




      ),
    );
  }
  Widget _buttonDrawer(){
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

  Widget buttonRequest(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      height: 50 ,
      child: ButtonApp(
        onPressed: _con.requestDriver,
        text: 'SOLICITAR',
        color:  utils.Colors.uberCloneColor,
        textColor:  Colors.white,

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
        onCameraMove: (position){
          _con.initialPosition = position;
        },
        onCameraIdle: () async{
          await _con.setLocationDraggableInfo();
        },


    );


  }

  Widget _cardGooglePlaces(){

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start ,
          children: [
            _infoCardLocation('Desde',
            _con.from ?? 'Lugar de Origen',
                () async{
           await _con.showGoogleAutoComplete(true);
                }
        ),
            SizedBox(height: 5,),
            Container(

                child: Divider(

                    color: Colors.black,
                    height: 10)
            ),
            SizedBox(height: 5,),
            _infoCardLocation('Hasta',
                _con.to ?? 'Lugar de Destino',
                    () async{
                  await _con.showGoogleAutoComplete(false);
                }
            ),

          ],
        ),
      ),
      ),
    );
  }

  void refresh(){
    if (this.mounted) {

      setState(() {

      });

    }
  }
  Widget _infoCardLocation (String title , String value,  function){
    return GestureDetector(
      onTap: function,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 10
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,

            ),
            maxLines: 2,
          ),
        ],

      ),
    );
  }

}


