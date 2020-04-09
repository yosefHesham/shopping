import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/orders_provider.dart';
import 'package:shopping/widgets/app_drawer.dart';
import 'package:shopping/widgets/order_item_widget.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var isInit = true;
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<Orders>(context).fetchOrders().then((_) {
        setState(() {
          isInit = false;
        });
        setState(() {
          isLoading = false;
        });
      });
    }

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context).orders;
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (context, i) => OrderItemWidget(
                order: orders[i],
              ),
              itemCount: orders.length,
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        elevation: 2,
        tooltip: 'Clear Orders',
        onPressed: orders.isEmpty
            ? null
            : () {
                Provider.of<Orders>(context, listen: false)
                    .clearOrders()
                    .catchError((error) {
                  _showSnackbar(context);
                });
              },
      ),
    );
  }

  void _showSnackbar(BuildContext context) {
    SnackBar snackBar = SnackBar(
      content: Text('Clearing Orders Failed !'),
      backgroundColor: Colors.purpleAccent,
      duration: Duration(seconds: 2),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
