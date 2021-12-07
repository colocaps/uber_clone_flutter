import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/history/client_history_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/history_detail/client_history_detail_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/map/client_map_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/register/client_register_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/travel_calification/client_travel_calification_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/travel_info/client_travel_info_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/travel_map/client_travel_map_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/travel_request/client_travel_request_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/edit/driver_edit_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/history/driver_history_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/history_detail/driver_history_detail_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/map/driver_map_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/register/driver_register_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_calification/driver_travel_calification_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_map/driver_travel_map_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/home/home_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/login/verify_registration.dart';
import 'package:uber_clone_flutter_udemy/src/pages/login/login_page.dart';
import 'package:uber_clone_flutter_udemy/src/pages/client/edit/client_edit_page.dart';
import 'package:uber_clone_flutter_udemy/src/providers/push_notifications_provider.dart';
import 'package:uber_clone_flutter_udemy/src/pages/driver/travel_request/driver_travel_request_page.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
import 'package:last_state/last_state.dart';

Future<void> _firebaseMessagingBackgroudHandler(RemoteMessage message) async{

  await Firebase.initializeApp();
  print('Handling background message ${message.messageId}');
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SavedLastStateData.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroudHandler);
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PushNotificationsProvider pushNotificationsProvider = new PushNotificationsProvider();
    pushNotificationsProvider.initPushNotifications();

    pushNotificationsProvider.message.listen((data) {
      print('-------------NOTIFICACION-------------');
      print(data);
      navigatorKey.currentState.pushNamed('driver/travel/request',arguments: data);

    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      restorationScopeId: 'root',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      title: 'Drivers',
      navigatorKey: navigatorKey,
      initialRoute: 'home',
      theme: ThemeData(
        fontFamily: 'NimbusSans',
        appBarTheme: AppBarTheme(
          elevation: 0

        ),
        primaryColor: utils.Colors.uberCloneColor

      ),
      routes: {
        'home' : (BuildContext context) => HomePage(),
        'login' : (BuildContext context) => LoginPage(),
        'client/register' : (BuildContext context) => ClientRegisterPage(),
        'driver/register' : (BuildContext context) => DriverRegisterPage(),
        'driver/travel/request' : (BuildContext context) => DriverTravelRequestPage(),
        'driver/travel/map' : (BuildContext context) => DriverTravelMapPage(),
        'driver/travel/calification' : (BuildContext context) => DriverTravelCalificationPage(),
        'driver/map' : (BuildContext context) => DriverMapPage(),
        'client/map' : (BuildContext context) => ClientMapPage(),
        'client/travel/info' : (BuildContext context) => ClientTravelInfoPage(),
        'client/travel/request' : (BuildContext context) => ClientTravelRequestPage(),
        'client/travel/map' : (BuildContext context) => ClientTravelMapPage(),
        'client/travel/calification' : (BuildContext context) => ClientTravelCalificationPage(),
        'client/edit' : (BuildContext context) => ClientEditPage(),
        'driver/edit' : (BuildContext context) => DriverEditPage(),
        'client/history' : (BuildContext context) => ClientHistoryPage(),
        'driver/history' : (BuildContext context) => DriverHistoryPage(),
        'client/history/detail' : (BuildContext context) => ClientHistoryDetailPage(),
        'driver/history/detail' : (BuildContext context) => DriverHistoryDetailPage(),
        'verify' : (BuildContext context) => VerifyScreen(),
      },

    );
  }
}



