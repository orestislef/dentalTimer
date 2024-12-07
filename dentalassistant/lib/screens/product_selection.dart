import 'package:dentalassistant/screens/settings.dart';
import 'package:dentalassistant/screens/timer.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({
    Key? key,
    required this.products,
  }) : super(key: key);

  final List<Product> products;

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final List<Product> products = [];
  final List<Product> selectedProducts = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    products.addAll(widget.products);
  }

  bool get isNextButtonEnabled => selectedProducts.isNotEmpty;

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
        ),
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
                  products: List.from(selectedProducts),
                ),
              ),
            );
          }
              : null,
          child: Text(
            isNextButtonEnabled
                ? 'Next (${selectedProducts.length} Selected)'
                : 'Next',
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ReorderableListView.builder(
                itemCount: selectedProducts.length +
                    _filteredUnselectedProducts().length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    // Reordering only within selected products
                    if (oldIndex < selectedProducts.length &&
                        newIndex <= selectedProducts.length) {
                      if (newIndex > oldIndex) newIndex--;
                      final product = selectedProducts.removeAt(oldIndex);
                      selectedProducts.insert(newIndex, product);
                    }
                  });
                },
                itemBuilder: (context, index) {
                  if (index < selectedProducts.length) {
                    // Selected products
                    final product = selectedProducts[index];
                    return _buildSelectedProductCard(product);
                  } else {
                    // Remaining products (filtered)
                    final product = _filteredUnselectedProducts()[
                    index - selectedProducts.length];
                    return _buildUnselectedProductCard(product);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductCard(Product product) {
    return Card(
      key: ValueKey(product.id),
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            (selectedProducts.indexOf(product) + 1).toString(),
          ),
        ),
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(product.description),
        trailing: const Icon(Icons.drag_handle),
        onTap: () {
          setState(() {
            // Remove the product from selected products
            selectedProducts.remove(product);
            products.add(product);
          });
        },
      ),
    );
  }

  Widget _buildUnselectedProductCard(Product product) {
    return Card(
      key: ValueKey(product.id),
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(product.description),
        trailing: const Icon(Icons.circle_outlined),
        onTap: () {
          setState(() {
            // Add the product to selected products
            selectedProducts.add(product);
            products.remove(product);
          });
        },
      ),
    );
  }

  List<Product> _filteredUnselectedProducts() {
    return products
        .where((product) => product.title.toLowerCase().contains(searchQuery))
        .toList();
  }
}
