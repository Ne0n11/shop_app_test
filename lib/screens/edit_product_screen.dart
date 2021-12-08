import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import '/providers/product.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageEditingController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: "", title: "", descr: "", price: 0, imageUrl: "");
  var _isLoading = false;
  var _isInit = true;
  var _initValues = {
    'title' : '',
    'descr' : '',
    'price' : '',
    'imageUrl' : ''
  };

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_isInit) {
      final route = ModalRoute.of(context);
      if (route == null) {return;}
      else
          {
            if(route.settings.arguments!=null) {
              final productId = route.settings.arguments as String;
              final product = Provider.of<ProductsProvider>(
                  context, listen: false)
                  .findProductById(productId);
              _editedProduct = product;
              _initValues = {
                'title': _editedProduct.title,
                'descr': _editedProduct.descr,
                'price': _editedProduct.price.toString(),
                // 'imageUrl': _editedProduct.imageUrl,
                'imageUrl':'',
              };
              _imageEditingController.text = _editedProduct.imageUrl;
            }
      }
    }
    _isInit = false;
  }

  void _updateImageUrl(){
    if(!_imageUrlFocusNode.hasFocus){
    if(
    (!_imageEditingController.text.startsWith('http') && !_imageEditingController.text.startsWith('https')
    ) ||
        (!_imageEditingController.text.endsWith('.png') && !_imageEditingController.text.endsWith('jpg') && !_imageEditingController.text.endsWith('jpeg'))
    ){return;}
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageEditingController.dispose();

  }

  Future<void> _saveForm() async{
    final _isValid = _form.currentState!.validate();
    if(!_isValid) return;
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if(_editedProduct.id==""){
      try{ await Provider.of<ProductsProvider>(context, listen: false).addProduct(_editedProduct);}
      catch (error){
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Error occurred"),
              content: Text("Something went wrong"),
              actions: [
                TextButton(onPressed: ()=> Navigator.of(ctx).pop, child: Text("Ok"))
              ],));
      }
    }
    else{
      try{
     await Provider.of<ProductsProvider>(context, listen: false).updateProduct(_editedProduct.id,_editedProduct);}
     catch (error){} // TODO implement some error catch
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit product"),
      actions: [
        IconButton(onPressed: _saveForm, icon: Icon(Icons.save))
      ],),
      body:_isLoading? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
              initialValue: _initValues['title'],
              textInputAction: TextInputAction.next,
                validator: (value){
                  if(value!.isEmpty){
                    return "Please provide a value";
                  }
                  return null;
                },
                onFieldSubmitted: (value){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value){
                  _editedProduct = Product(
                      title: value!,
                      descr: _editedProduct.descr,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Price"),
                initialValue: _initValues['price'],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                validator: (value){
                  if(value!.isEmpty){ return "Please enter a price";}
                  if(double.tryParse(value) == null){
                    return "Please enter a valid number";
                  }
                  if(double.parse(value)<=0.0){
                    return "Please enter valid number greater that 0.00";
                  }
                  return null;
                },
                onSaved: (value){
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      descr: _editedProduct.descr,
                      price: double.parse(value!),
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite);
                },
                onFieldSubmitted: (value){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
                initialValue: _initValues['descr'],
                focusNode: _descriptionFocusNode,
                validator: (value){
                  if(value!.isEmpty){
                    return "Please enter description";
                  }
                  if(value.length<10){
                    return "Should be at least 10 characters long";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                onSaved: (value){
                  _editedProduct = Product(
                      title: _editedProduct.title,
                      descr: value!,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite);
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8,right: 10),
                    decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey),),
                    child: _imageEditingController.text.isEmpty ?
                    Text("Enter URL")
                        :
                    FittedBox(
                       child: Image.network(_imageEditingController.text, fit: BoxFit.cover,),
                    ) , //image
                  ),
                  Expanded(
                    child: TextFormField(

                        decoration: InputDecoration(labelText: "Image URL"),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageEditingController,
                        focusNode: _imageUrlFocusNode,
                      validator: (value){
                          if(value!.isEmpty){return "Please enter a image URL";}
                          if(!value.startsWith('http') && !value.startsWith('https')){
                            return "Please enter a valid URL";
                          }
                          if(!value.endsWith('.png') && !value.endsWith('jpg') && !value.endsWith('jpeg')){
                            return "Please enter a valid picture URL";
                          }
                          return null;
                      },
                      onSaved: (value){
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            descr: _editedProduct.descr,
                            price: _editedProduct.price,
                            imageUrl: value!,
                            id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite);
                      },
                        onFieldSubmitted: (value){ _saveForm();},
                        onEditingComplete: () {
                          setState(() {});
                        },
                    ),
                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
