import 'package:flutter/material.dart';
import 'package:shopping/providers/orders_provider.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  OrderItemWidget({this.order});

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool expands = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(title: Text('total amount: \$${widget.order.amount}'),
          subtitle: Text('${widget.order.dateTime}'),
          trailing:  IconButton(icon:Icon(!expands?Icons.expand_more: Icons.expand_less), onPressed: (){
            setState(() {
              expands = !expands;
            });
          },) ,),
          expands?Container(
            height: 150 ,
            child: ListView.builder(
              itemCount: widget.order.products.length,
              itemBuilder:(context, i) => orderDetails(widget.order.products[i].price,widget.order.products[i].quantity, widget.order.products[i].title )),
          ) : SizedBox(height: 10,)
        ],
      ),
    );
  }
}

Widget orderDetails(double price, int quantity, String title) {
        return Row(
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Spacer(),
            Text('$quantity X'),
            Text('$price')
          ],
        );

}