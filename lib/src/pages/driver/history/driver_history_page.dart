import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:uber_clone_flutter_udemy/src/models/travel_history.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/history/driver_history_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/relative_time_util.dart';

class DriverHistoryPage extends StatefulWidget {
  const DriverHistoryPage({Key key}) : super(key: key);

  @override
  _DriverHistoryPageState createState() => _DriverHistoryPageState();
}

class _DriverHistoryPageState extends State<DriverHistoryPage> {

  DriverHistoryController _con = new DriverHistoryController();

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
      appBar: AppBar(title: Text('Historial de Viajes'),),
      body: FutureBuilder(
        future: _con.getAll(),
        builder: (context, AsyncSnapshot<List<TravelHistory>> snapshot){
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
                itemBuilder:
                    (_,index)
                {
                    return _cardHistoryInfo(
                      snapshot.data[index].from,
                      snapshot.data[index].to,
                      snapshot.data[index].nameClient,
                      snapshot.data[index].price?.toString(),
                      snapshot.data[index].calificationClient?.toString(),
                 RelativeTimeUtil.getRelativeTime(snapshot.data[index].timestamp ?? 0) ,
                      snapshot.data[index].id,

                    );

            } );
        },
      )



    );
  }

  Widget _cardHistoryInfo(
      String from,
      String to,
      String name,
      String price,
      String calification,
      String timestamp,
      String idTravelHistory


      )
  {
    return GestureDetector(
      onTap: (){_con.goToDetailHistory(idTravelHistory);},
      child: Container(

        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Row(

              children: [

                SizedBox(width: 5,),
                Icon(Icons.drive_eta),
                SizedBox(width: 5,),
                Text('Nombre del Cliente :  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(

              children: [

                SizedBox(width: 5,),
                Icon(Icons.location_on),
                SizedBox(width: 5,),
                Text('Lugar de Origen :  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(from ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(width: 5,),
                Icon(Icons.location_searching),
                SizedBox(width: 5,),
                Text('Lugar de Destino :  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(to ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(width: 5,),
                Icon(Icons.monetization_on),
                SizedBox(width: 5,),
                Text('Costo del Viaje :  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(' \$ $price' ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(width: 5,),
                Icon(Icons.star),
                SizedBox(width: 5,),
                Text('Calificacion :  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(calification ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(width: 5,),
                Icon(Icons.timer),
                SizedBox(width: 5,),
                Text('Hace :  ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(timestamp ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
