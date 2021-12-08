import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/products.dart';
import 'product_item.dart';

class ProductGrid extends StatelessWidget{
  final bool showOnlyFavorites;

  ProductGrid(this.showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showOnlyFavorites ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3/2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
          value: products[index],
          child:
            ProductItem(
              // products[index].id,
              // products[index].title,
              // products[index].imageUrl,
            ),

      ),
    );
  }

}