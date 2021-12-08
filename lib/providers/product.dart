import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Product with ChangeNotifier{
  final String id;
  final String title;
  final String descr;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.descr,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false});

   Future<void> toggleFavoriteStatus(String token, String userId) async{
    final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token';
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try{
    final response = await http.put(Uri.parse(url),body:
      json.encode(isFavorite));
    if (response.statusCode >=400){
      isFavorite = oldStatus;
      notifyListeners();
    }
  }catch(error){
      isFavorite = oldStatus;
      notifyListeners();
      }

   }


}