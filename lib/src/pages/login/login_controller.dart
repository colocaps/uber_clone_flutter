import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class LoginController{

   BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  AuthProvider _authProvider;
  ProgressDialog _progressDialog;
   DriverProvider _driverProvider;
   ClientProvider _clientProvider;

   SharedPref _sharedPref;
   String _typeUser = '' ;


   User user;
   Timer timer;
   final auth = FirebaseAuth.instance;

  Future init(BuildContext context) async{
    this.context = context;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _clientProvider = new ClientProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');
    _sharedPref = new SharedPref();
    _typeUser = await _sharedPref.read('typeUser');

    print('=========TIPO DE USUARIO=======');
    print(_typeUser);
    user = _authProvider.getUser();



  }

  void goToRegisterPage(){
    if(_typeUser == 'client'){
      Navigator.pushNamed(context, 'client/register');
    }
    else{

      utils.Snackbar.showSnackbar(context, key, 'Para ser conductor debes comunicarte con la Emppresa');
      //Navigator.pushNamed(context, 'driver/register');
    }


  }

  void sendResetPassword() async{
    String _email = emailController.text.trim();
    await auth.sendPasswordResetEmail(email: _email);
    print("Password reset email sent");
    utils.Snackbar.showSnackbar(context, key, 'Se Envio un mail a: $_email');

  }




  void login() async{
    String error2 = '';
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(email == '' || password == '' ){
      utils.Snackbar.showSnackbar(context, key, 'Complete los campos');

    } else if(emailValid == false) {

      utils.Snackbar.showSnackbar(context, key, 'Email Invalido');
      print('Email: $emailValid');
    }


    else {
      print('Email: $email');
      print('Password: $password');
      _progressDialog.show();

        try {
          bool isLogin = await _authProvider.login(email, password);
          _progressDialog.hide();
          if (isLogin) {
            print('El usuario esta logueado');
            if (_typeUser == 'client') {
              Client client = await _clientProvider.getById(_authProvider
                  .getUser()
                  .uid);
              print('CLIENTE: $client');
              if (client != null) {
                if(_authProvider.isEmailVerified()) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, 'client/map', (route) => false);
                }else{
                  utils.Snackbar.showSnackbar(
                      context, key, 'El email no esta verificado, revise su casilla');
                      User user = _authProvider.getUser();
                      user.sendEmailVerification();
                }

              } else {
                print('El usuario no es valido');
                utils.Snackbar.showSnackbar(
                    context, key, 'El usuario no es valido');
                await _authProvider.signOut();
              }
            } else if (_typeUser == 'driver') {
              Driver driver = await _driverProvider.getById(_authProvider
                  .getUser()
                  .uid);
              print('DRIVER: $driver');
              if (driver != null) {
                if(_authProvider.isEmailVerified()) {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'driver/map', (route) => false);
                }else{
                  utils.Snackbar.showSnackbar(
                      context, key, 'El email no esta verificado, revise su casilla');
                  User user = _authProvider.getUser();
                  user.sendEmailVerification();
                }

              } else {
                utils.Snackbar.showSnackbar(
                    context, key, 'El usuario no es valido');
                await _authProvider.signOut();
              }
            }
          } else {
            utils.Snackbar.showSnackbar(
                context, key, 'El usuario no se pudo autenticar');
            print('El usuario no se pudo autenticar');
          }
        } catch (error) {
          if (error.toString() ==
              '[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.') {
            error2 = 'Usuario Bloqueado por muchos intentos';
          }
          if (error.toString() ==
              '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.') {
            error2 = 'Contraseña Invalida';
          }
          if (error.toString() ==
              '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.') {
            error2 = 'Usuario Inexistente';
          }
          _progressDialog.hide();
          utils.Snackbar.showSnackbar(context, key, 'Error: $error2');
          print('Error: $error2');
        }
      }

  }



}