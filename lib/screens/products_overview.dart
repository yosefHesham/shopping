import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:shopping/providers/products_provider.dart';
import 'package:shopping/screens/cart_screen.dart';
import 'package:shopping/widgets/app_drawer.dart';
import 'package:shopping/widgets/badge.dart';
import 'package:shopping/widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class ProductsHomeScreen extends StatefulWidget {
  static const routeName = '/s';
  @override
  _ProductsHomeScreenState createState() => _ProductsHomeScreenState();
}

class _ProductsHomeScreenState extends State<ProductsHomeScreen> {
  var _showFavourites = false;
  var _isInit = false;
  var _isLoading = false;

  @override
  void initState() {

    setState(() {
      _isInit = true;
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        print('isinit and is loading is true now');
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchProducts().then((_) {
        setState(() {
          print('isLoading Is False now');
          _isLoading = false;
        });
        setState(() {
          print('Is Init is False now');
          _isInit = false;

        });
      });
    }

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Home'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              if (selectedValue == FilterOptions.Favorites) {
                setState(() {
                  _showFavourites = true;
                });
              } else {
                setState(() {
                  _showFavourites = false;
                });
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              )
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Badge(
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(CartScreen.routeName);
                  },
                ),
                value: cart.getCount().toString()),
          )
        ],
      ),

      /// building our product gridview and sending Data to  ProductItem widget in itemBuilder
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showFavourites),
      drawer: AppDrawer(),
    );
  }
}
