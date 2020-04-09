import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/cart_provider.dart';

class CartItemWidget extends StatefulWidget {
  final String title;
  final double price;
  final int quantity;
  final String id;
  final String productId;
  bool showSwipeInfo = false;
  CartItemWidget({this.title, this.quantity, this.price, this.id, this.productId});

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {


  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (Direction){
       //     deleteOptions(context, widget.productId);
      },
      confirmDismiss: (bool){
            deleteOptions(context, widget.productId);
      },

      key: ValueKey(widget.id),
      background: Container(
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      direction: DismissDirection.endToStart,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(

            onTap: () {
              setState(() {
                widget.showSwipeInfo = !widget.showSwipeInfo;
              });
            },
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text('${widget.price}'),
              radius: 40,
            ),
            title: Text(widget.title),
            subtitle: Text('${widget.price * widget.quantity}'),
            trailing: widget.showSwipeInfo
                ? Text(
                    'Swipe To Remove',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 14),
                  )
                : Text('x ${widget.quantity}'),
          ),
        ),
      ),
    );
  }
}

void deleteOptions(BuildContext context, String productId) {

    final cart = Provider.of<Cart>(context, listen: false);
   var alert =  AlertDialog(
    content: Text('Are You Sure?'),
    actions: <Widget>[
      FlatButton(
        child: Text(
          'Delete One Item',
          style: TextStyle(fontSize: 18),
        ),
        textColor: Theme.of(context).primaryColor,
        onPressed: (){
          cart.removeOneProduct(productId);
          Navigator.of(context).pop();

        },
      ),
      FlatButton(
        child: Text(
          'Delete All cart',
          style: TextStyle(fontSize: 18),
        ),
        textColor: Theme.of(context).primaryColor,
        onPressed: () {
          cart.removeCart(productId);
          Navigator.of(context).pop();
        },
      )
    ],
  );
   showDialog(
     context: context,
     builder: (context){
       return alert;
     }
   );
}
