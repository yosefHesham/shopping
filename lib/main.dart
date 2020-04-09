import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shopping/providers/auth.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:shopping/providers/orders_provider.dart';
import 'package:shopping/screens/cart_screen.dart';
import 'package:shopping/screens/edit_product_screen.dart';
import 'package:shopping/screens/manage_products.dart';
import 'package:shopping/screens/orders_screen.dart';
import 'package:shopping/screens/products_overview.dart';
import 'package:shopping/screens/splash_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/products_provider.dart';

void main() => runApp(DevicePreview(
  builder:(context) => MyApp()
));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            update: (context, auth, previousProducts) => ProductsProvider(
                auth.userId,
                auth.token,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (context, auth, previousOrders) => Orders(
                auth.userId,
                auth.token,
                previousOrders == null ? [] : previousOrders.orders),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.purple, accentColor: Colors.deepOrange),
            home: auth.isAuth
                ? ProductsHomeScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              ManageProducts.routeName: (ctx) => ManageProducts(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
