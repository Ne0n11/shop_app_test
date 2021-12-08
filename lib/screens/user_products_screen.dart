import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/edit_product_screen.dart';

import '/widgets/app_drawer.dart';
import '/widgets/user_product_item.dart';
import '/providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";

  Future<void> _refreshProducts(BuildContext context) async{
   await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your product"),
      actions: <Widget>[
        IconButton(onPressed: () => Navigator.of(context).pushNamed(EditProductScreen.routeName) , icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) => dataSnapshot.connectionState == ConnectionState.waiting ?
        Center(child: CircularProgressIndicator(),)
            :
        RefreshIndicator(
          onRefresh: ()=> _refreshProducts(context),
          child: Consumer<ProductsProvider>(
            builder: (ctx, productData, child) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  itemBuilder: (ctx, index) => Column(
                    children: <Widget>[
                    UserProductItem(
                        productData.items[index].id,
                        productData.items[index].title,
                        productData.items[index].imageUrl
                    ),
                      Divider(),
                  ],
                  ),
                itemCount:productData.items.length ,),
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
