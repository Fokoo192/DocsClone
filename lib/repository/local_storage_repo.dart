import 'package:shared_preferences/shared_preferences.dart';

//presistent storage for simple data
class LocalStorageRepo {

  void setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("x-auth-token", token);
  }

  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("x-auth-token");
    return token;
  }

}