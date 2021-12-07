import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/models/driver.dart';
import 'package:uber_clone_flutter_udemy/src/providers/auth_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/storage_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/my_progress_dialog.dart';
import 'package:uber_clone_flutter_udemy/src/utils/snackbar.dart' as utils;

class DriverEditController{

   BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  TextEditingController usernameController = new TextEditingController();


  TextEditingController pin1Controller = new TextEditingController();
  TextEditingController pin2Controller = new TextEditingController();
  TextEditingController pin3Controller = new TextEditingController();
  TextEditingController pin4Controller = new TextEditingController();
  TextEditingController pin5Controller = new TextEditingController();
  TextEditingController pin6Controller = new TextEditingController();

  AuthProvider _authProvider;
  DriverProvider _driverProvider;
  StorageProvider _storageProvider;
  ProgressDialog _progressDialog;
   PickedFile pickedFile;
   File imageFile;
   Driver driver;
   final ImagePicker _picker = ImagePicker();
   Function refresh;

  Future init(BuildContext context, Function refresh){
    this.context = context;
    this.refresh = refresh;
    _authProvider = new AuthProvider();
    _driverProvider = new DriverProvider();
    _storageProvider = new StorageProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un Momento...');
    getUserInfo();
  }
   void getUserInfo() async {
     driver = await _driverProvider.getById(_authProvider.getUser().uid);
     usernameController.text = driver.username;
     pin1Controller.text = driver.plate[0];
     pin2Controller.text = driver.plate[1];
     pin3Controller.text = driver.plate[2];
     pin4Controller.text = driver.plate[3];
     pin5Controller.text = driver.plate[4];
     pin6Controller.text = driver.plate[5];
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

    String pin1 = pin1Controller.text.trim();
    String pin2 = pin2Controller.text.trim();
    String pin3 = pin3Controller.text.trim();
    String pin4 = pin4Controller.text.trim();
    String pin5 = pin5Controller.text.trim();
    String pin6 = pin6Controller.text.trim();

    String plate = '$pin1$pin2$pin3$pin4$pin5$pin6';


    if(username.isEmpty ){
      print('Debe completar todos los campos');
      utils.Snackbar.showSnackbar(context, key, 'Debe completar todos los campos');
      return;

    }

    _progressDialog.show();


    if(pickedFile == null) {

      Map<String, dynamic> data = {
        'image': driver?.image ?? null,
        'username': username,
        'plate': plate

      };

      await _driverProvider.update(data, _authProvider.getUser().uid);
      _progressDialog.hide();
    }else{
      TaskSnapshot snapshot = await _storageProvider.upoloadFile(pickedFile);
      String imageUrl = await snapshot.ref.getDownloadURL();
      Map<String, dynamic> data = {
        'image': imageUrl,
        'username': username,
        'plate': plate

      };

      await _driverProvider.update(data, _authProvider.getUser().uid);

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