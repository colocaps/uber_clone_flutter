import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone_flutter_udemy/src/pages/login/login_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  LoginController _con = new LoginController();

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
            _textDescription(),
            _textLogin(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.07),
            _textFieldEmail(),
            _textFieldPassword(),
            _buttonLogin(),
            _dontHaveAccount(),
            _forgotPassword(),

          ],

        ),
      )

    );
  }

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text (
        'Continua con tu',
        style: TextStyle(
          color: Colors.black,
          fontSize:  24,
          fontFamily: 'NimbusSans',
        ),

      ),
    );

  }
  Widget _textLogin(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text (
        'Login',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize:  28,
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
  Widget _dontHaveAccount(){
    return GestureDetector(
      onTap: _con.goToRegisterPage,
      child: Container(

        margin: EdgeInsets.only(bottom: 20),
        child: Text(
                   '¿ No tienes Cuenta ?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black

          ),
         )
      ),
    );
  }

  Widget _forgotPassword(){
    return GestureDetector(
      onTap: _con.sendResetPassword,
      child: Container(

          margin: EdgeInsets.only(bottom: 20),
          child: Text(
            '¿ Olvidaste tu Contraseña ?',
            style: TextStyle(
                fontSize: 15,
                color: Colors.black

            ),
          )
      ),
    );
  }
  Widget _reSendVerificationMail(){
    return GestureDetector(
      onTap: (){},
      child: Container(

          margin: EdgeInsets.only(bottom: 20),
          child: Text(
            'Reenviar Mail de Verificacion',
            style: TextStyle(
                fontSize: 15,
                color: Colors.black

            ),
          )
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
   Widget _buttonLogin(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 25),
      child: ButtonApp(
        onPressed: _con.login,
        text: 'Iniciar Sesion'
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
