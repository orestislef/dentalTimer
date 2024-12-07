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

  final searchController = TextEditingController();

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
        bottom: products.isEmpty
            ? null
            : PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchQuery = "";
                    });
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
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
        if (products.isNotEmpty || selectedProducts.isNotEmpty)
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
      body: products.isEmpty && selectedProducts.isEmpty
          ? const Center(
        child: Text(
          "No products available.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < selectedProducts.length &&
                        newIndex <= selectedProducts.length) {
                      // Reorder only within the selected products
                      if (newIndex > oldIndex) newIndex--;
                      final product = selectedProducts.removeAt(oldIndex);
                      selectedProducts.insert(newIndex, product);
                    }
                  });
                },
                children: [
                  ...selectedProducts.map((product) =>
                      _buildSelectedProductCard(product)).toList(),
                  ..._filteredUnselectedProducts().map((product) =>
                      _buildUnselectedProductCard(product)).toList(),
                ],
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
        trailing: ReorderableDragStartListener(
          index: selectedProducts.indexOf(product),
          child: const Icon(Icons.drag_handle),
        ),
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
