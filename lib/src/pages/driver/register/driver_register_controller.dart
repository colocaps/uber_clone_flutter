import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class DriverRegisterController{

   BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller = new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();

  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  ProgressDialog _progressDialog;

  Future init(BuildContext context){
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');
    
  }

  void register() async{
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();

    String plate = '$pin1$pin2$pin3$pin4$pin5$pin6';

    print('Email: $email');
    print('Password: $password');

    if(username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty){
      print('Debe completar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe completar todos los campos');
      return;

    }
    if(password != confirmPassword){
      print('Las contraseñas deben coincidir');
      utils.Snackbar.showSnackbar(context, key, 'Las contraseñas deben coincidir');
      return;
    }
    if(password.length > 6){
      print('La contraseña debe tener al menos 6 caracteres');
      utils.Snackbar.showSnackbar(context, key, 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    _progressDialog.show();


    try{
     bool isRegister = await _authProvider.register(email, password);

     if(isRegister){
       Driver driver = new Driver(
         id: _authProvider.getUser().uid,
         email: _authProvider.getUser().email,
         username: username,
         password: password,
         plate: plate,



       );

       await _driverProvider.create(driver);
       _progressDialog.hide();
       //Navigator.pushNamedAndRemoveUntil(context, 'driver/map', (route) => false);
       Navigator.pushNamedAndRemoveUntil(context, 'verify', (route) => false);
       print('El usuario se registro correctemente');
       utils.Snackbar.showSnackbar(context, key, 'El usuario se registro correctemente');
     }else{
       _progressDialog.hide();
       print('El usuario no se pudo registrar');
       utils.Snackbar.showSnackbar(context, key, 'El usuario no se pudo registrar');
     }
    }catch(error){
      _progressDialog.hide();
      print('Error: $error');
      utils.Snackbar.showSnackbar(context, key, 'Error: $error');
    }



  }



}