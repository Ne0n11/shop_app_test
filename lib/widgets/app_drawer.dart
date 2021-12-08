import 'package:flutter/material.dart';
import '/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import '/providers/auth.dart';
import '/helpers/custom_route.dart';

class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Hello friend"),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/');
            },),
            Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Manage your products"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/user-products');
            },),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //     CustomRoute(builder:
              //         (ctx) => OrdersScreen(),settings: null)
              // );             Some custom route???
            },),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Logout"),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
              Provider.of<Auth>(context, listen: false).logout();
            },),
        ],
      ),
    );
  }
}
