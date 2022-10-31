import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/product_list.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();

  final _imageURlController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageURlController.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final product = args as Product;
      _formData['id'] = product.id;
      _formData['name'] = product.name;
      _formData['description'] = product.description;
      _formData['price'] = product.price;
      _formData['imageUrl'] = product.imageUrl;

      _imageURlController.text = product.imageUrl;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageURlController.removeListener(updateImage);
    _imageUrlFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endWithFile = RegExp(r"(.*?)(jpg|jpeg|png)$").hasMatch(url);
    return isValidUrl && endWithFile;
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error has occurred'),
          content:
              const Text('An error occurred while trying to save the product'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            )
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Product Form'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: (_formData['name']?.toString()),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocus);
                      },
                      textInputAction: TextInputAction.next,
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (name) {
                        if (name!.trim().isEmpty) {
                          return 'The name field is required';
                        }

                        if (name.trim().length < 3) {
                          return 'The name must have at least 3 characters';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: (_formData['price']?.toString()),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      focusNode: _priceFocus,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descriptionFocus);
                      },
                      textInputAction: TextInputAction.next,
                      onSaved: (price) => _formData['price'] = price ?? '',
                      validator: (priceString) {
                        final price = double.tryParse(priceString!) ?? -1;

                        if (price <= 0) {
                          return 'Enter a valid price';
                        }

                        return null;
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextFormField(
                      initialValue: (_formData['description']?.toString()),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      focusNode: _descriptionFocus,
                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      keyboardType: TextInputType.multiline,
                      validator: (description) {
                        if (description!.trim().isEmpty) {
                          return 'The Description field is required';
                        }

                        if (description.trim().length < 10) {
                          return 'The Description must have at least 10 characters';
                        }

                        return null;
                      },
                      maxLines: 3,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                            ),
                            focusNode: _imageUrlFocus,
                            controller: _imageURlController,
                            onFieldSubmitted: (_) => _submitForm(),
                            textInputAction: TextInputAction.done,
                            onSaved: (imageUrl) =>
                                _formData['imageUrl'] = imageUrl ?? '',
                            validator: (image) {
                              return !isValidImageUrl(image!)
                                  ? 'Enter a valid URL'
                                  : null;
                            },
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )),
                          alignment: Alignment.center,
                          child: _imageURlController.text.isEmpty
                              ? const Text('Enter a Url')
                              : Image.network(
                                  _imageURlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
