import 'package:dentalassistant/screens/settings.dart';
import 'package:dentalassistant/screens/timer.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  Product? selectedProduct1;
  Product? selectedProduct2;

  bool get isNextButtonEnabled =>
      selectedProduct1 != null && selectedProduct2 != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: isNextButtonEnabled
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(
                        product1: selectedProduct1!,
                        product2: selectedProduct2!,
                      ),
                    ),
                  );
                }
              : null,
          child: const Text('Next'),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildProductList(1),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildProductList(2),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select Product $index',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _buildProductListWidget(widget.products, index),
        ),
      ],
    );
  }

  Widget _buildProductListWidget(List<Product> products, int index) {
    List<Product> products1 =
        products.where((product) => product.forFirstList).toList();
    List<Product> products2 =
        products.where((product) => !product.forFirstList).toList();

    if ((index == 1 && products1.isEmpty) ^ (index == 2 && products2.isEmpty)) {
      return const Text('No products available');
    }
    return Scrollbar(
      child: ListView.builder(
        itemCount: index == 1 ? products1.length : products2.length,
        itemBuilder: (context, idx) {
          final product = index == 1 ? products1[idx] : products2[idx];
          final isSelected = (index == 1 && selectedProduct1 == product) ||
              (index == 2 && selectedProduct2 == product);
          return Card(
            elevation: 2.0,
            child: ListTile(
              title: Text(product.title),
              subtitle: Text(product.description),
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined),
              selected: isSelected,
              onTap: () {
                setState(() {
                  if (index == 1) {
                    selectedProduct1 = product;
                  } else {
                    selectedProduct2 = product;
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}
