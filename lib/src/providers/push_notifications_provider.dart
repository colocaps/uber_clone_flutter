

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uber_clone_flutter_udemy/src/providers/client_provider.dart';
import 'package:uber_clone_flutter_udemy/src/providers/driver_provider.dart';
import 'package:uber_clone_flutter_udemy/src/utils/shared_pref.dart';

class PushNotificationsProvider{

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamController _streamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream;

  void initPushNotifications() {

    //ON LAUNCH
    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage message) {
      if(message != null){
        Map<String, dynamic> data = message.data;
        SharedPref sharedPref = new SharedPref();
        sharedPref.save('isNotification', 'true');
        _streamController.sink.add(data);
      }

    });

  //ON MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      Map<String, dynamic> data = message.data;

      print('Cuando estamos en primer plano');
      print('OnMessage: $data');
      _streamController.sink.add(data);


    });
    //ON RESUME
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Map<String, dynamic> data = message.data;
      print('OnResume $data');
      _streamController.sink.add(data);
    });

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true,
            badge: true,
            alert: true,
            provisional: true
        )
    );





  }

  void saveToken(String idUser, String typeUser)async{
    String token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = {
      'token': token
    };
    if(typeUser == 'client'){
      ClientProvider clientProvider = new ClientProvider();
      clientProvider.update(data, idUser);
    }else{
      DriverProvider driverProvider = new DriverProvider();
      driverProvider.update(data, idUser);
    }

  }

  Future<void> sendMessage(String to, Map<String, dynamic> data,String title, String body) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAipF0oSs:APA91bGFr66pvq3hOt5ANR-mF_1gTP0lFaHwZTwha6YE8zoqmW2naw-fIJhzZUaN9IC8CDgqLOi8mwUvt-ZlePxvYSd_Fjo_OcMOIecWu5g5p-9TZSOhrGtYYv8VZKO-jisNZSkdb3Tf'
      },
      body: jsonEncode(
        <String,dynamic>{
          'notification': <String,dynamic>{
            'body': body,
            'title': title
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to

      }
      )

    );
  }

  void dispose () {
    _streamController?.onCancel;
  }

}