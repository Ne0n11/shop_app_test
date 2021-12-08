import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/custom_route.dart';

import '/screens/splash_screen.dart';
import '/screens/auth_screen.dart';
import '/screens/edit_product_screen.dart';
import '/screens/user_products_screen.dart';
import '/screens/orders_screen.dart';
import '/screens/cart_screen.dart';
import '/screens/product_detail_screen.dart';
import '/screens/products_overview_screen.dart';

import '/providers/products.dart';
import '/providers/cart.dart';
import '/providers/orders.dart';
import '/providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers:
    [
      ChangeNotifierProvider(create: (ctx) => Auth(),),
      ChangeNotifierProxyProvider<Auth,ProductsProvider>(
        update: (ctx, auth, prevProducts) =>  ProductsProvider()
          ..receiveToken(auth, prevProducts == null ? [] : prevProducts.items),
      create: (ctx) => ProductsProvider(),),
      ChangeNotifierProvider(create: (ctx) =>  Cart(),),
      ChangeNotifierProxyProvider<Auth, Orders>(
        update: (ctx, auth, prevOrders) => Orders()
        ..receiveToken(auth, prevOrders == null ? [] : prevOrders.orders),
        create: (ctx) =>  Orders(),),
    ],
      child: Consumer<Auth>(builder: (ctx, authData, child) => MaterialApp(
        title: 'ZShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(builders:{
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          })
        ),
        home: authData.isAuth ? ProductOverviewScreen() :
        FutureBuilder(
            future: authData.tryAutoLogin(),
            builder:
                (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ?
                    SplashScreen() : AuthScreen()) ,
        routes:{
          ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
        },
      ),
    )

    );
  }
}


