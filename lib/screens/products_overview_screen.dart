import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shop_app/screens/edit_product_screen.dart';


import '/screens/cart_screen.dart';
import 'package:shop_app/providers/products.dart';
import '/widgets/product_grid.dart';
import '/widgets/badge.dart';
import '/widgets/app_drawer.dart';
import '/providers/cart.dart';


enum FilterOptions {
  Favorites,
  All
}

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = "/products-overview";

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}


class _ProductOverviewScreenState extends State<ProductOverviewScreen> {

  @override
  void initState() {
    super.initState();
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    // Future.delayed(Duration.zero).then((ctx){
    //   Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((value) {
        _isLoading = false;
      }).catchError((error){
        setState(() {
          _isLoading = false;
        });
        // showDialog(context: context, builder: (ctx) => AlertDialog(
        //   title: Text("Would you like to add new product?"),
        //   actions: [
        //     TextButton(onPressed: () => Navigator.of(context).pushNamed(EditProductScreen.routeName), child: Text("Yes")),
        //     TextButton(onPressed: ()=>{
        //       Navigator.of(context).pop()
        //     }, child: Text("No"))
        //   ],
        // ));
      });
    }
    _isInit = false;
  }

  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<ProductsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(

        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading?(Center(child: CircularProgressIndicator(),)) :ProductGrid(_showOnlyFavorites),
    );
  }
}



