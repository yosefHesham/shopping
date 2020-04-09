// we are building a product item so  we can build the gridview in products home screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shopping/providers/auth.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:shopping/providers/product.dart';
import 'package:shopping/screens/product_details_screen.dart';
class ProductItem extends StatelessWidget {
  /// defining necessary data  field to build the product item
  @override
  Widget build(BuildContext context) {
    Product singleProduct = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context,listen: false);
    // material widget to add elevation
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 5,
      child: ClipRRect(
        /// the product will be displayed on with gridtile
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              /// going to product detail screen and sending a product id as an argument
              Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,
                  arguments: singleProduct.id);
            },
            child: Hero(
              tag: singleProduct.id,
              child: CachedNetworkImage(
                imageUrl: singleProduct.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 500),
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.ease,
              ),
            )
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
              singleProduct.title,
              textAlign: TextAlign.center,
            ),

            /// by adding consumer only this widget will be rebuilt instead of building all the screen by  running build method
            leading: Consumer<Product>(
              builder: (context, singleProduct, _) => IconButton(
                icon: singleProduct.isFavourite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  singleProduct.toggleFavorite(authData.token, authData.userId).catchError((error){
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Changing status  failed'),
                    ));
                  });
                },
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Theme.of(context).accentColor,
              onPressed: () {
                cart.addItem(
                    singleProduct.id, singleProduct.price, singleProduct.title);
                Scaffold.of(context).hideCurrentSnackBar();

                _showSnackbar(context, singleProduct.id);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String productId) {
    SnackBar snackBar = SnackBar(
      content: Text('Product Added To Cart !'),
      backgroundColor: Colors.purpleAccent,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        textColor: Colors.white,
        label: "UNDO",
        onPressed: () {
          Provider.of<Cart>(context, listen: false).removeOneProduct(productId);
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
