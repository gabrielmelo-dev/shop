import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/order_list.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<OrderList>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshOrders(context),
        child: FutureBuilder(
          future: Provider.of<OrderList>(context, listen: false).loadOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              return const Center(
                child: Text('An Error has occured!'),
              );
            } else {
              return Consumer<OrderList>(
                builder: (ctx, orders, child) =>
                    ListView.builder(
                      itemCount: orders.itemsCount,
                      itemBuilder: (ctx, i) =>
                          OrderWidget(order: orders.items[i]),
                    ),
              );
            }
          },
        ),
      ),
    );
  }
}