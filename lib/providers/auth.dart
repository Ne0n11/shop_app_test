import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/exceptions/http_exception.dart';

class Auth with ChangeNotifier{
  String? _token;
  DateTime _expireDate = DateTime.now();
  String _userId = "";
  Timer? _authTimer;

  bool get isAuth{
      return token != null;
  }

  String? get token{
    if(_expireDate.isAfter(DateTime.now())){
      if(_token != null) return _token;
    }
    return null;
  }

  String get userId{
    return _userId;
  }


  Future<void> _authenticate(String email, String password, String urlFragment) async{
    final url = "https://identitytoolkit.googleapis.com/v1/accounts:$urlFragment?key=YOUR_KEY_HERE";
   try{
     final response = await http.post(Uri.parse(url), body:
     json.encode({
       'email': email,
       'password': password,
       'returnSecureToken' : true,
     })
     );
     final responseData = json.decode(response.body);
     if(responseData['error']!=null){
       throw HttpException(responseData['error']['message']);
     }
     _token = responseData['idToken'];
     _userId = responseData['localId'];
     _expireDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
    _autoLogout();
     notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token'  :_token,
      'userId' : _userId,
      'expireDate' : _expireDate.toIso8601String(),
    });
    prefs.setString('userData', userData);
    print(userData);
   }catch(error){
     throw error;
   }
    // print(json.decode(response.body));

  }


  Future<void> signup(String email, String password) async {
    const urlFrag = "signUp";
    return _authenticate(email, password, urlFrag);
  }

  Future<void> login(String email, String password) async {
    const urlFrag = "signInWithPassword";
    return _authenticate(email, password, urlFrag);
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
     // print(prefs.getString('userData'));
    if(!prefs.containsKey('userData')){
      // print("doesn't have");
      return false;
    }
    try{
      final extractFromPrefs = prefs.getString('userData');
      // print(extractFromPrefs);
      if(extractFromPrefs==null){return false;}
      final extractedUserData =  json.decode(extractFromPrefs) as Map<String, dynamic>;

    //print(extractedUserData);
    final expireDate = DateTime.parse(extractedUserData['expireDate'] as String);
    // print(expireDate);

    if(expireDate.isBefore(DateTime.now())){
      // print("wrong date");
      return false;
    }
    _token = extractedUserData["token"] as String;
    _userId = extractedUserData['userId'] as String;
    _expireDate = expireDate;
    // print("success");
    // print(_token);
    notifyListeners();
    }catch(error){
      print("Some error" + error.toString());
      return false;
    }
    _autoLogout();
    return true;
  }


  Future<void> logout() async{

    _token = null;
    _userId = "";
    _expireDate = DateTime.now();
    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs  = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout(){
    if(_authTimer != null){
      _authTimer!.cancel();
    }
    var timeToExpiry = _expireDate.difference(DateTime.now()).inSeconds;
   _authTimer = Timer(Duration(seconds: timeToExpiry), logout );
  }

}