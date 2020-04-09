import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    /// receiving product id which was sent from product over view screen
    final String productId =
        ModalRoute.of(context).settings.arguments.toString();
    /// getting the product details
    final product = Provider.of<ProductsProvider>(context, listen: false).findById(productId);

    return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 300,
                    width: double.infinity,

                      child: Hero(
                        tag: productId,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),

                  ),
                ),
                SizedBox(height: 10,)
                ,Text('\$${product.price}',style: TextStyle(color: Colors.grey, fontSize: 20),),
                SizedBox(height: 10,),
                Text(product.description,textAlign: TextAlign.center, softWrap:true)
              ],
            ),
          ),
        ));
  }
}
