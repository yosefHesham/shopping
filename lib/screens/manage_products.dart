import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/auth.dart';
import 'package:shopping/providers/product.dart';
import 'package:shopping/providers/products_provider.dart';
import 'package:shopping/screens/edit_product_screen.dart';
import 'package:shopping/widgets/app_drawer.dart';

class ManageProducts extends StatelessWidget {

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context,listen: false).fetchProducts();
  }
  static const routeName = '/manage_products';
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final product = Provider.of<ProductsProvider>(context).getUserItems();
    final provider = Provider.of<ProductsProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh:(){
          return _refreshProducts(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: ListView.builder(itemBuilder: (context, i) => _singleProduct(product[i], provider, context), itemCount: product.length,),
        ),
      ),
    );
  }
}

Widget _singleProduct(Product product, ProductsProvider p, BuildContext context){

  return ListTile(
    leading: CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage(product.imageUrl,),
    ),
    title: Text(product.title),
    trailing: Container(
      width:  100,
      child: Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.edit), onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: product);
          },),
          IconButton(icon: Icon(Icons.delete, color: Colors.red,), onPressed:(){
            p.removeProduct(product).catchError((error){
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Deleting Failed !'),
              ));
            });
          }),
        ],
      ),
    )
  );

}
