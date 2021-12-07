import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/edit/client_edit_controller.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:uber_clone_flutter_udemy/src/widgets/button_app.dart';

class ClientEditPage extends StatefulWidget {
  const ClientEditPage({Key key}) : super(key: key);

  @override
  _ClientEditPageState createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {

  ClientEditController _con = new ClientEditController();

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

            _textFieldUsername(),



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
                  width: 100,
                  child: Image.file(
                  _con.imageFile ?? 'assets/img/profile.jpg' ,
                    fit: BoxFit.cover,
                  ),
                ),
              ): _con.client?.image != null ?
              Card(
                child: Container(
                  height: 110.0,
                  width: 100,
                  padding: EdgeInsets.all(3.0),
                  child: Image.network(
                      _con.client?.image,

                  ),
                ),

              ):Card(
                child: Container(
                  height: 110.0,
                  width: 100,
                  padding: EdgeInsets.all(3.0),
                  child: Image(
                    image: AssetImage(_con.imageFile?.path ?? 'assets/img/profile.jpg'),

                  ),
                ),

              )
            ),

            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text (
                _con.client?.email ?? '',
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
