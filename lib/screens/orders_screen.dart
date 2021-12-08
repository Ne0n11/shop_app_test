import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/orders.dart' show Orders;
import '/widgets/order_item.dart';
import '/widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {



  late Future _ordersFuture;

  Future _obtainOrdersFuture(){
    return Provider.of<Orders>(context,listen: false).fetchAndSetOrders();
  }


  @override
  void initState() {
   _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Your orders"),),
      drawer: AppDrawer(),
      body: FutureBuilder(
        builder: (context, dataSnapshot) {
          if(dataSnapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else{
            if(dataSnapshot.error == null){
              // .. do error handling
              return Center(child: Text("Error occurred"),);
            }else{
              return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(itemBuilder: (ctx,index) => OrderItem(orderData.orders[index]),
                itemCount: orderData.orders.length,)
              );
            }
          }
        } ,
        future: _ordersFuture,
      )
    );
  }
}

