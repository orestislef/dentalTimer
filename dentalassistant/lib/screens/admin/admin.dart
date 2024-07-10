import 'package:dentalassistant/screens/admin/show_all_products.dart';
import 'package:flutter/material.dart';

import 'add_product.dart';
import 'delete_product.dart';
import 'edit_product.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Show All Products'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    onTapOnShowAllProducts(context: context);
                  },
                ),
                ListTile(
                  title: const Text('Add Product'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    onTapOnAddProduct(context: context);
                  },
                ),
                ListTile(
                  title: const Text('Edit Product'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    onTapOnEditProduct(context: context);
                  },
                ),
                ListTile(
                    title: const Text('Delete Product'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      onTapOnDeleteProduct(context: context);
                    })
              ],
            ),
          ),
        ));
  }

  void onTapOnShowAllProducts({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShowAllProducts()),
    );
  }

  void onTapOnAddProduct({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProduct()),
    );
  }

  void onTapOnEditProduct({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProduct()),
    );
  }

  void onTapOnDeleteProduct({required BuildContext context}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteProduct()),
    );
  }
}
