import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class ClientRegisterController{

   BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  ProgressDialog _progressDialog;

  Future init(BuildContext context){
    this.context = context;
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');
    
  }

  void register() async{
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
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
       Client client = new Client(
         id: _authProvider.getUser().uid,
         email: _authProvider.getUser().email,
         username: username,
         password: password



       );

       await _clientProvider.create(client);
       _progressDialog.hide();
       // Navigator.pushNamedAndRemoveUntil(context, 'client/map', (route) => false);

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