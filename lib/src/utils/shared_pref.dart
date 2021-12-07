import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class SharedPref{

  Future<dynamic> save(String key, String value) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString(key) == null) return null;

    return json.decode(prefs.getString(key));
  }

  //existe una key con un valor establecido
 Future<bool> contains(String key) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);

  }

  Future<bool> remove (String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}