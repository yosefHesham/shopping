import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopping/providers/auth.dart';
import 'package:shopping/providers/product.dart';
import 'package:shopping/providers/products_provider.dart';
import 'package:shopping/screens/manage_products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-procuts';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imgFocusNode = FocusNode();
  File imgFile;
  String imgUrl;

  Product _editedProduct = Product(
      title: null, description: null, id: null, price: null, imageUrl: null);

  var isInit = false;

  var isLoading = false;
  /// initial values for form fields
  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
    'id': null
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isInit = true;
  }

  @override
  void didChangeDependencies() {
    /// here we receive the product which the user wanna edit
    Product product = ModalRoute.of(context).settings.arguments;
    if (isInit && product != null) {
      _editedProduct = product;
      _initValues = {
        'title': product.title,
        'price': product.price.toString(),
        'description': product.description,
        'imageUrl': product.imageUrl,
        'id': product.id
      };
    }
    isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imgFocusNode.dispose();
    super.dispose();
  }

  /// getting img from the gallery
  Future getImageFromGallery() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgFile = tempImage;
    });
  }

  /// used in the on submit
  void _saveForm()  {
    final formState = _formKey.currentState;

    print('helloooooo');
    /// if the form fields are valid and the user picked an image
    if (formState.validate()) {
      /// if the user picked a new image it will be uploaded to fire store and then save the form
      formState.save();
      setState(() {
        isLoading = true;
      });
      /// if the user is updating  a product
      if (_initValues['id'] != null) {
        print('id: ${_editedProduct.id}');
        Provider.of<ProductsProvider>(context, listen: false)
          .updateProducts(_initValues['id'], _editedProduct, imgFile).then((_){
            setState(() {
              isLoading = false;
              Navigator.of(context).pushReplacementNamed(ManageProducts.routeName);

            });

        }) ;
      }

      /// if the user is adding a new one
      else {
        Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct, imgFile, ).catchError((error){
                    return showDialog(context: context, builder: (ctx) => AlertDialog(
                      content: Text('Something Went Wrong'),
                      title: Text('An Error Occurred'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        )
                      ],

                    ));
            })
            .then((_) {
              setState(() {
                isLoading = false;
              });
          Navigator.of(context).pushReplacementNamed(ManageProducts.routeName);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _saveForm();
            },
          )
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),):Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) async {
                  _editedProduct = Product(
                      title: value,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      id: null);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Title must not be empty';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                  initialValue: _initValues['price'],
                  decoration: InputDecoration(
                    labelText: 'Price',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) return 'Price must not be empty';
                    return null;
                  },
                  onSaved: (value) async {
                    _editedProduct = Product(
                        title: _editedProduct.title,
                        price: double.parse(value),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        id: null);
                  }),
              TextFormField(
                  initialValue: _initValues['description'],
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  focusNode: _descriptionFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_imgFocusNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Description must not be empty';
                    } else if (value.length < 10) {
                      return 'Description must be more than  10';
                    }
                    return null;
                  },
                  onSaved: (value) async {
                    _editedProduct = Product(
                        title: _editedProduct.title,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        description: value,
                        id: null);
                  }),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      onSaved: (_) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            imageUrl:
                                imgUrl == null ? _initValues['imageUrl'] : imgUrl,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            id: null);
                      },
                      onFieldSubmitted: (_) async {
                        await _saveForm();
                        Navigator.of(context).pushReplacementNamed('/');
                      },

                      /// if the user is adding a new product and did not choose an image ? true, else false
                      readOnly: imgFile == null && _editedProduct.imageUrl == null
                          ? true
                          : false,
                      onTap: imgFile == null
                          ? () {
                              setState(() {
                                _initValues['imageUrl'] = '';
                              });
                              getImageFromGallery();
                            }
                          : () {},
                      focusNode: _imgFocusNode,
                      decoration: InputDecoration(
                        hintText: imgFile == null
                            ? 'Choose an image for your product'
                            : 'Press on the icon to change the photo',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.image),
                          color: Colors.redAccent,
                          onPressed: () {
                            setState(() {
                              _initValues['imageUrl'] = '';
                            });
                            getImageFromGallery();
                          },
                        ),
                      ),
                      validator: (_) {
                        if (imgFile != null || _initValues['imageUrl'] != '') {
                          return null;
                        }
                        return 'please pick an image';
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: _initValues['imageUrl'] == ''
                            ? imgFile == null
                                ? Center(
                                    child: Text('Pick an image'),
                                  )
                                : Image.file(
                                    imgFile,
                                    fit: BoxFit.cover,
                                  )
                            : Image.network(_initValues['imageUrl'])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
