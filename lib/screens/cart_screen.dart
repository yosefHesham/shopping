import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:shopping/providers/orders_provider.dart';
import 'package:shopping/widgets/app_drawer.dart';
import 'package:shopping/widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cartScreen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {


  var isOrdered = true;
  @override
  Widget build(BuildContext context) {
    /// accessing cart data
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      drawer: AppDrawer(),
        appBar: AppBar(title: Text('Your Card')),
        body: Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cart.totalAmount}',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    /// wrapping the button with consumer to access the orders data
                    Consumer<Orders>(
                      builder: (context, order, child) =>
                    FlatButton(
                      child: child,
                      textColor: Theme.of(context).primaryColor,
                      onPressed:cart.items.isNotEmpty?(){
                        setState(() {
                          isOrdered = false;
                        });
                        order.addOrder(cart.items.values.toList(), cart.totalAmount).then((_){
                          setState(() {
                            isOrdered = true;
                            cart.clear();

                          });
                        });
                      }:null,
                    ),
                      child: isOrdered? Text('Order Now', style: TextStyle(fontSize: 20),):CircularProgressIndicator(),
                    )
                  ],

                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            /// building the cart item
            Expanded(
                child: ListView.builder(
              itemBuilder: (ctx, i) => CartItemWidget(
                productId: cart.items.keys.toList()[i], /// product id
                price: cart.items.values.toList()[i].price,
                title: cart.items.values.toList()[i].title,
                quantity: cart.items.values.toList()[i].quantity,
                id: cart.items.values.toList()[i].id /// the id of cart
              ),
              itemCount: cart.getCount(),
            ))
          ],
        ));
  }
}
