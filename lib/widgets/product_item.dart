import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/product_list.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/exceptions/app_http_exception.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.name),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.productsForm,
                  arguments: product,
                );
              },
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm delete'),
                    content: Text(
                        'Are you sure you want to delete "${product.name}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      )
                    ],
                  ),
                ).then(
                  (value) async {
                    if (value ?? false) {
                      try {
                        await Provider.of<ProductList>(context, listen: false)
                            .removeProduct(product);
                      } on AppHttpException catch (error) {
                        msg.showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      }
                    }
                  },
                );
              },
              color: Theme.of(context).errorColor,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
