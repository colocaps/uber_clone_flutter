import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

import 'client_register_controller.dart';

class ClientRegisterPage extends StatefulWidget {
  const ClientRegisterPage({Key key}) : super(key: key);

  @override
  _ClientRegisterPageState createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {

  ClientRegisterController _con = new ClientRegisterController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(toolbarHeight: 40,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(),
            _textRegister(),

            _textFieldUsername(),
            _textFieldEmail(),
            _textFieldPassword(),
            _textFieldConfirmPassword(),
            _buttonRegister()

          ],

        ),
      )

    );
  }



  Widget _textRegister(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical:15),
      child: Text (
        'Registro de Pasajero',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize:  25,
          fontFamily: 'NimbusSans',
        ),

      ),
    );

  }

  Widget _textFieldEmail(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _con.emailController,
         decoration: InputDecoration(
           hintText: 'correo@gmail.com',
           labelText: 'Correo Electronico',
               suffixIcon: Icon(
                 Icons.email_outlined,
                 color: utils.Colors.uberCloneColor,

          )

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


  Widget _textFieldPassword(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
      child: TextField(
        obscureText: true,
        controller: _con.passwordController,
        decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: Icon(
              Icons.lock_open_outlined,
              color: utils.Colors.uberCloneColor,

          )

        ),

      ),
    );
  }
  Widget _textFieldConfirmPassword(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
      child: TextField(
        obscureText: true,
        controller: _con.confirmPasswordController,
        decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            suffixIcon: Icon(
              Icons.lock_open_outlined,
              color: utils.Colors.uberCloneColor,

            )

        ),

      ),
    );
  }

   Widget _buttonRegister(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 25),
      child: ButtonApp(
        onPressed: _con.register,
        text: 'Registrarse'
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
            Image.asset('assets/img/Logo J&E para fondos oscuros.png',
              width: 150,
              height: 100,

            ),

            Text (
              'Drivers',
              style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w100
              ),
            )

          ],

        ),
      ),

    );
  }
}
