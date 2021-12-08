import 'package:flutter/foundation.dart';
import '/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth.dart';

class OrderItem{
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime
  });
}



class Orders with ChangeNotifier{
    List<OrderItem> _orders = [];

    List<OrderItem> get orders{
      return [..._orders];
    }

    String authToken = "";
    String userId = "";

    void receiveToken(Auth auth, List<OrderItem> orders){
      authToken = auth.token ?? "";
      userId = auth.userId;
      _orders = orders;
    }


    Future<void> addOrder(List<CartItem> cartProducts, double total) async{
      final dateTime = DateTime.now();
      final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken';
      final response = await http.post(Uri.parse(url),body: json.encode({
        'amount' : total,
        'dateTime' :dateTime.toIso8601String(),
        'products': cartProducts.map((product) =>{
          'id' : product.id,
          'price' : product.price,
          'title': product.title,
          'quantity': product.quantity
        }).toList(),
      }),
      );
      _orders.insert(0, OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: dateTime,
      ),
      );
      notifyListeners();
    }

    Future<void> fetchAndSetOrders() async{
      final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?=auth$authToken';
      final response = await http.get(Uri.parse(url));
      final List<OrderItem> loadedItems = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null) {return;}
      extractedData.forEach((orderId, orderData) {
        loadedItems.add(
          OrderItem(
              id:orderId,
              amount: orderData['amount'],
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(id: item['id'], title: item['title'], quantity: item['quantity'], price: item['price']))
                  .toList(),
              dateTime: DateTime.parse(orderData['dateTime']
              ))
        );
      });
    _orders =   loadedItems.reversed.toList();
    notifyListeners();

    }


}