import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/auth.dart';
import 'package:shopping/screens/cart_screen.dart';
import 'package:shopping/screens/manage_products.dart';
import 'package:shopping/screens/orders_screen.dart';
import 'package:shopping/screens/products_overview.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: Column(
        children: <Widget>[

          AppBar(
            title: Text('Hello Friend !'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(leading: Icon(Icons.shop), title: Text('Shop'),
          onTap: (){
            Navigator.of(context).pushReplacementNamed('/');
          },
          ),
          ListTile(leading: Icon(Icons.shopping_cart), title: Text('Cart'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(CartScreen.routeName);
            },
          ),
          ListTile(leading: Icon(Icons.attach_money), title: Text('Orders'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
            },
          ),
          ListTile(leading: Icon(Icons.edit), title: Text('Manage Products'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(ManageProducts.routeName);
            },
          ),
          ListTile(leading: Icon(Icons.exit_to_app), title: Text('Log out'),
            onTap: (){
              Provider.of<Auth>(context,listen: false).logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
