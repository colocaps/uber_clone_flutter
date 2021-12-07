import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/utils/otp_widget.dart';
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

import 'driver_edit_controller.dart';

class DriverEditPage extends StatefulWidget {
  const DriverEditPage({Key key}) : super(key: key);

  @override
  _DriverEditPageState createState() => _DriverEditPageState();
}

class _DriverEditPageState extends State<DriverEditPage> {

  DriverEditController _con = new DriverEditController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context,refresh);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(toolbarHeight: 40,),
      bottomNavigationBar: _buttonRegister(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textRegister(),
            _textLicensePlate(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 27),
              child: OTPFields(
                pin1: _con.pin1Controller,
                pin2: _con.pin2Controller,
                pin3: _con.pin3Controller,
                pin4: _con.pin4Controller,
                pin5: _con.pin5Controller,
                pin6: _con.pin6Controller,
              ),

            ),
            _textFieldUsername(),



          ],

        ),
      )

    );
  }

  Widget _textLicensePlate(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical:10),
      child: Text (
        'Numero de Movil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize:  17,
          fontFamily: 'NimbusSans',
        ),

      ),
    );

  }

  Widget _textRegister(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical:15),
      child: Text (
        'Editar Perfil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize:  25,
          fontFamily: 'NimbusSans',
        ),

      ),
    );

  }


  Widget _textFieldUsername(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.usernameController,
        decoration: InputDecoration(
            hintText: 'Juan Perez',
            labelText: 'Nombre de Usuario',
            suffixIcon: Icon(
              Icons.person_outline,
              color: utils.Colors.uberCloneColor,

            )

        ),

      ),
    );
  }


   Widget _buttonRegister(){

    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 25),
      child: ButtonApp(
        onPressed: _con.update,
        text: 'Actualizar Datos'
      ),
    );
   }
  Widget _bannerApp(){
    return ClipPath(
      clipper: WaveClipperTwo(),
      child:Container(
        color: utils.Colors.uberCloneColor,
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
                onTap: _con.showAlertDialog,
                child: _con.imageFile != null ?
                Card(
                  child: Container(
                    height: 110.0,
                    width: 90.0,
                    child: Image.file(
                      _con.imageFile ?? 'assets/img/profile.jpg' ,
                      fit: BoxFit.cover,
                    ),
                  ),
                ): _con.driver?.image != null ?
                Card(
                  child: Container(
                    height: 110.0,
                    width: 90.0,
                    padding: EdgeInsets.all(0.5),
                    child: Image.network(
                      _con.driver?.image,

                    ),
                  ),

                ):Card(
                  child: Container(
                    height: 110.0,
                    width: 90.0,
                    padding: EdgeInsets.all(0.5),
                    child: Image(
                      image: AssetImage(_con.imageFile?.path ?? 'assets/img/profile.jpg'),

                    ),
                  ),

                )
            ),

            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text (
                _con.driver?.email ?? '',
                style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w100
                ),
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
