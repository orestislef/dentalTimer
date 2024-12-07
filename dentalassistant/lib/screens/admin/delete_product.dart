import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../../models/product.dart';
import '../../screens/admin/show_all_products.dart';

class DeleteProduct extends StatefulWidget {
  const DeleteProduct({Key? key}) : super(key: key);

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
            _onPressedDelete();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
      appBar: AppBar(
        title: const Text('Delete Product'),
      ),
      body: Center(
        child: isDeleting
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Deleting...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator.adaptive(),
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Are you sure you want to delete this product?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5.0,
                child: ListTile(
                  title: Text(
                    selectedProduct!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(selectedProduct!.description),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Durations:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(selectedProduct!.duration
                          .map((d) => '${d}s')
                          .join(', ')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPressedDelete() {
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
