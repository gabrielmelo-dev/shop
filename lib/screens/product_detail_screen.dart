import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;
    final cart = Provider.of<Cart>(context, listen: false);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.name),
              centerTitle: true,
              background: Stack(fit: StackFit.expand, children: [
                Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0, 0.8),
                      end: Alignment(0, 0),
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.6),
                        Color.fromRGBO(0, 0, 0, 0),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 25,
              ),
              Text(
                '\$ ${product.price}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 45),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    cart.addItem(product);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Product added to cart'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          },
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add to cart',
                    style: TextStyle(fontSize: 21),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
