import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/auth.dart';
import '/exceptions/http_exception.dart';
import 'product.dart';


class ProductsProvider with ChangeNotifier{
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   descr: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //   'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   descr: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   descr: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   descr: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //   'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // bool _showFavoritesOnly = false;

  String authToken = "";
  String userId = "";

  void receiveToken(Auth auth, List<Product> items){
    authToken = auth.token ?? "";
    userId = auth.userId;
    _items = items;
  }

  List<Product> get items {
    // if(_showFavoritesOnly){
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems  {
    return _items.where((element) => element.isFavorite).toList();
  }
  //
  // void showFavoritesOnly(){
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async{
     final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken';
     try {
       final response = await http.post(Uri.parse(url), body: json.encode({
         'title': product.title,
         'descr': product.descr,
         'price': product.price,
         'imageUrl': product.imageUrl,
         'creatorId' : userId,
       }));
         final newProduct = Product(id: json.decode(response.body)['name'], title: product.title, descr: product.descr, price: product.price, imageUrl: product.imageUrl);
         _items.add(newProduct);
     } catch (error) {
       print(error);
       throw error;
     }
      // at the beginning
      // _items.insert(0, newProduct);
      notifyListeners();
      //
      // print(error);
      // throw error;

  }

  Future<void> fetchAndSetProducts([bool filterUserProducts = false]) async{
    final filterString = filterUserProducts ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString';
    try{
      final List<Product> loadedProducts = [];
      final response  = await http.get(Uri.parse(url));
      // print(response);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
      url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodData) {  // key and value
          loadedProducts.add(
              Product(
                  id: prodId,
                  title: prodData['title'],
                  descr: prodData['descr'],
                  imageUrl: prodData['imageUrl'],
                  isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
                  price: prodData['price']));
      });
      _items = loadedProducts;
      notifyListeners();
    }
    catch(error){
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async{

   final prodIndex =  _items.indexWhere((element) => element.id == id);
   if(prodIndex >=0) {
     final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';

     await http.patch(Uri.parse(url),body: json.encode({
       'title' : newProduct.title,
       'descr' : newProduct.descr,
       'price' : newProduct.price,
       'imageUrl' : newProduct.imageUrl,
       // 'isFavorite' : newProduct.isFavorite,
     }));
     _items[prodIndex] = newProduct;
     notifyListeners();
   }else{
     print("Not right index");
   }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://fluttercourse1-432ba-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((element) =>element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if(response.statusCode >= 400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
      existingProduct = null;
  }
  
  Product findProductById(String id){
    return _items.firstWhere((product) => product.id == id);
  }

}