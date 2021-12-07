import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/history_detail/client_history_detail_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;

class ClientHistoryDetailPage extends StatefulWidget {
  const ClientHistoryDetailPage({Key key}) : super(key: key);

  @override
  _ClientHistoryDetailPageState createState() => _ClientHistoryDetailPageState();
}

class _ClientHistoryDetailPageState extends State<ClientHistoryDetailPage> {

  ClientHistoryDetailController _con = new ClientHistoryDetailController();

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
      appBar: AppBar(title: Text('Detalle del Historial'),),
      body: SingleChildScrollView(

        child: Column(
        children: [
          _bannerInfoDriver(),
          listTileInfo('Lugar de origen', _con.travelHistory?.from, Icons.location_on),
          listTileInfo('Lugar de destino', _con.travelHistory?.to, Icons.location_searching),
          listTileInfo('Mi Calificacion', _con.travelHistory?.calificationClient?.toString(), Icons.star_border),
          listTileInfo('Calificacion del Conductor', _con.travelHistory?.calificationDriver?.toString(), Icons.star),
          listTileInfo('Costo del viaje', '\$ ${_con.travelHistory?.price?.toString()}' ?? '\$ 0', Icons.monetization_on),
        ],
        ),
      ),


    );
  }

  Widget listTileInfo(String title, String value, IconData icon){
    return ListTile(
      title: Text(title ?? ''),
      subtitle: Text(value ?? ''),
      leading: Icon(icon),

    );

  }


  Widget _bannerInfoDriver(){
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.27,
        width: double.infinity,
        color: utils.Colors.uberCloneColor,
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15,),
            CircleAvatar(
              backgroundImage:  _con.driver?.image != null
                  ? NetworkImage(_con.driver?.image)
                  : AssetImage('assets/img/profile.jpg'),
              radius: 40,
            ),SizedBox(height: 10,),
            Text(
              _con.driver?.username ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}
