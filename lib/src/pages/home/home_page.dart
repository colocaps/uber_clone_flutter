import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone_flutter_udemy/src/pages/home/home_controller.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController _con = new HomeController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);

    });
  }
  @override
Widget build(BuildContext context){

    return Scaffold(

      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue,  Colors.blue]

            )

          ),
          child: Column(
          children: [

            _bannerApp(context),
            SizedBox(height: 50),
            _selectYourRole(),
            SizedBox(height: 50),
            _imageTypeUser(context,'assets/img/pasajero.png','client'),
            SizedBox(height: 10),
            _textTypeUser('Pasajero'),
            SizedBox(height: 40),
            _imageTypeUser(context,'assets/img/driver.png','driver'),
            SizedBox(height: 10),
            _textTypeUser('Chofer')
  ],

),
        ),
      ),
    );
}

    Widget _bannerApp(BuildContext context){
    return ClipPath(
      clipper: DiagonalPathClipperTwo(),
      child:Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/img/Logo J&E para fondos claros.png',
              width: 150,
              height: 100,

            ),

            Text (
              'Drivers',
              style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28,
                  fontWeight: FontWeight.w700
              ),
            )

          ],

        ),
      ),

    );
    }

    Widget _selectYourRole(){
    return Text('SELECCIONA TU ROL',
      style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w700
      ),
    );
    }

    Widget _imageTypeUser(BuildContext context, String image,String typeUser){
    return GestureDetector(
      onTap: () {
        _con.goToLoginPage(typeUser);
      },
      child: CircleAvatar(
        backgroundImage: AssetImage(image),
        radius: 50,
        backgroundColor: Colors.white24,
      ),
    );
    }

    Widget _textTypeUser(String typeUser){
     return Text(
       typeUser,
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
        ),

      );
    }
}