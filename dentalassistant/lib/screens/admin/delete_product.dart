import 'package:dentalassistant/api/api.dart';
import 'package:dentalassistant/models/product.dart';
import 'package:dentalassistant/screens/admin/show_all_products.dart';
import 'package:flutter/material.dart';

class DeleteProduct extends StatefulWidget {
  const DeleteProduct({super.key});

  @override
  State<DeleteProduct> createState() => _DeleteProductState();
}

class _DeleteProductState extends State<DeleteProduct> {
  Product? selectedProduct;
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return selectedProduct == null
        ? ShowAllProducts(
            onTapOnProduct: (product) {
              setState(() {
                selectedProduct = product;
              });
            },
          )
        : _buildDeleteProduct();
  }

  Widget _buildDeleteProduct() {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: isDeleting
              ? null
              : () {
                  onPressedOnDelete();
                },
          child: const Text('Delete'),
        ),
      ],
      appBar: AppBar(
        title: const Text('Delete Product'),
      ),
      body: Center(
        child: isDeleting
            ? const Column(
                children: [
                  Text('Deleting...'),
                  SizedBox(height: 20),
                  CircularProgressIndicator.adaptive(),
                ],
              )
            : Column(
                children: [
                  const Text(
                    'Are you sure you want to delete this product?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 2.0,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 5.0,
                      child: ListTile(
                        title: Text(selectedProduct!.title),
                        subtitle: Text(selectedProduct!.description),
                        trailing: Text(
                            'Time: ${selectedProduct!.duration.inSeconds}s'),
                        leading: Text(
                            selectedProduct!.forFirstList ? 'First' : 'Second'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void onPressedOnDelete() {
    setState(() {
      isDeleting = true;
    });

    Api().deleteProduct(id: selectedProduct!.id).then((allOK) {
      if (allOK) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete product'),
          ),
        );
        setState(() {
          isDeleting = false;
        });
      }
    });
  }
}
