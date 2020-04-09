/// we will make our gridview of the products here  here
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/product.dart';
import 'package:shopping/providers/products_provider.dart';
import 'product_item.dart';

class ProductGrid extends StatelessWidget {

  bool showFavorite;
  ProductGrid(this.showFavorite);

  @override
  Widget build(BuildContext context) {
    /// getting our products from the data  container (Provider)
    var products = showFavorite? Provider.of<ProductsProvider>(context).favouriteItems : Provider.of<ProductsProvider>(context).items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      /// by adding change notifier provider we are providing ProductItem widget with each product we have so product item will be built i times each time it send a product data
      itemBuilder: (context, i) => ChangeNotifierProvider<Product>.value(
          value:  products[i],
          child: ProductItem(
      )),
      itemCount: products.length,
    );
  }
}
