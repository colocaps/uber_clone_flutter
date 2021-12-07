import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/client.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/storage_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class ClientEditController{

   BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  TextEditingController usernameController = new TextEditingController();

  AuthProvider _authProvider;
  ClientProvider _clientProvider;
  ProgressDialog _progressDialog;
  Function refresh;
  StorageProvider _storageProvider;
  Client client;

  PickedFile pickedFile;
  File imageFile;

   final ImagePicker _picker = ImagePicker();

  Future init(BuildContext context, Function refresh){
    this.context = context;
    this.refresh = refresh;
    _authProvider = new AuthProvider();
    _clientProvider = new ClientProvider();
    _storageProvider = new StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');
    getUserInfo();
  }

  void getUserInfo() async {
    client = await _clientProvider.getById(_authProvider.getUser().uid);
    usernameController.text = client.username;
    refresh();

  }

  void showAlertDialog(){
    Widget galleryButton = TextButton(
        onPressed:(){ getImageFromGallery(ImageSource.gallery);},
        child: Text('GALERIA')
    );

    Widget cameraButton = TextButton(
        onPressed:(){ getImageFromGallery(ImageSource.camera);},
        child: Text('CAMARA')
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona una Imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context){
        return alertDialog;
      }
    );
  }


  void update() async{
    String username = usernameController.text;


    if(username.isEmpty ){
      print('Debe completar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe completar todos los campos');
      return;

    }

    _progressDialog.show();


      if(pickedFile == null) {

        Map<String, dynamic> data = {
          'image': client?.image ?? null,
          'username': username,

        };

        await _clientProvider.update(data, _authProvider.getUser().uid);
        _progressDialog.hide();
      }else{
        TaskSnapshot snapshot = await _storageProvider.upoloadFile(pickedFile);
        String imageUrl = await snapshot.ref.getDownloadURL();
        Map<String, dynamic> data = {
          'image': imageUrl,
          'username': username,

        };

        await _clientProvider.update(data, _authProvider.getUser().uid);

      }



    _progressDialog.hide();
    utils.Snackbar.showSnackbar(context, key, 'Datos Actualizados Correctamente');

  }

  Future getImageFromGallery (ImageSource imageSource) async {

    pickedFile = await _picker.getImage(source: imageSource);

    if(pickedFile !=null){
      imageFile = File(pickedFile.path);

    }else{
      print('no se selecciono ninguna imagen');
    }
    Navigator.pop(context);

    refresh();
  }



}