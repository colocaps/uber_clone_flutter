import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_calification/driver_travel_calification_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

class DriverTravelCalificationPage extends StatefulWidget {
  const DriverTravelCalificationPage({Key key}) : super(key: key);

  @override
  _DriverTravelCalificationPageState createState() => _DriverTravelCalificationPageState();
}

class _DriverTravelCalificationPageState extends State<DriverTravelCalificationPage> {

  DriverTravelCalificationController _con = new DriverTravelCalificationController();

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
      bottomNavigationBar: _buttonCalificate(),
      body: Column(

        children: [
          _bannerPriceInfo(),
          _listTileTravelInfo(
              'Desde', ''
              '${_con.travelHistory?.from ?? ''}',
              Icons.location_on),
          _listTileTravelInfo(
              'Hasta',
              '${_con.travelHistory?.to ?? ''}',
              Icons.directions_subway),
          SizedBox(height: 30),
          _textCalificateYourDriver(),
          SizedBox(height: 15),
          _ratingBar()
        ],

      ),


    );
  }

  Widget _buttonCalificate(){
    return Container(
      height: 50,
      margin: EdgeInsets.all(30),
      child: ButtonApp(
        onPressed: _con.calificate,
        text: 'CALIFICAR',
        textColor: Colors.white,
      ),
    );
  }

  Widget _ratingBar(){
    return Center(
      child: RatingBar.builder(
          itemBuilder: (context,_) => Icon(
              Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          initialRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemPadding: EdgeInsets.symmetric(horizontal: 4),
          unratedColor: Colors.grey[300],
          onRatingUpdate: (rating){
            _con.calification = rating;
            print('rating: $rating');
          }
      ),
    );
  }

  Widget _textCalificateYourDriver(){
    return Text(
      'CALIFICA A TU CLIENTE',
      style: TextStyle(
        color: Colors.cyan,
        fontWeight: FontWeight.bold,
        fontSize: 18
      ),
    );
  }

  Widget _listTileTravelInfo(String title, String value, IconData icon){
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
          maxLines: 1,
        ),
        subtitle:  Text(
          value,
          style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
          maxLines: 2,
        ),
        leading: Icon(icon),
      ),
    );

  }

  Widget _bannerPriceInfo (){
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.42,
        width: double.infinity,
        color: utils.Colors.uberCloneColor ,
        child: SafeArea(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 100),
              SizedBox(height: 20),
              Text(
                'TU VIAJE HA FINALIZADO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Valor del viaje',
                style: TextStyle(
                    fontSize: 16,

                    color: Colors.white
                ),
              ),
              SizedBox(height: 10),
              Text(
                '\$${_con.travelHistory?.price?.toStringAsFixed(2) ?? ''}',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              )
            ],
          ),
        ),
      ),

    );
  }

  void refresh(){
    setState(() {

    });
  }
}
