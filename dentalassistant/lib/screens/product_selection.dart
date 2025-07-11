import 'package:dentalassistant/screens/settings.dart';
import 'package:dentalassistant/screens/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _ProductSelectionScreenState extends State<ProductSelectionScreen> 
    with TickerProviderStateMixin {
  final List<Product> products = [];
  final List<Product> selectedProducts = [];
  String searchQuery = "";
  final searchController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    products.addAll(widget.products);
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  bool get isNextButtonEnabled => selectedProducts.isNotEmpty;

  Widget _buildSearchCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Find Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedProducts.isNotEmpty)
                  Chip(
                    label: Text('${selectedProducts.length}'),
                    backgroundColor: Theme.of(context).primaryColor,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            searchQuery = "";
                          });
                          searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProductCard(Product product) {
    final index = selectedProducts.indexOf(product);
    
    return Card(
      key: ValueKey('selected_${product.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Order Number
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.duration.length} timer${product.duration.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Actions
            Column(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle_rounded),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selectedProducts.remove(product);
                      products.add(product);
                    });
                  },
                  icon: Icon(
                    Icons.remove_circle_rounded,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnselectedProductCard(Product product) {
    return Card(
      key: ValueKey('unselected_${product.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.add_rounded),
        ),
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${product.duration.length} timer${product.duration.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.radio_button_unchecked_rounded),
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            selectedProducts.add(product);
            products.remove(product);
          });
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedProducts.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${selectedProducts.length} product${selectedProducts.length > 1 ? 's' : ''} selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          'Total: ${selectedProducts.fold<int>(0, (sum, p) => sum + p.duration.length)} timers',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isNextButtonEnabled
                          ? () {
                              HapticFeedback.mediumImpact();
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
                      icon: Icon(
                        isNextButtonEnabled 
                            ? Icons.play_arrow_rounded 
                            : Icons.timer_rounded,
                      ),
                      label: Text(
                        isNextButtonEnabled
                            ? 'Start Timers'
                            : 'Select Products',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Products Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection or contact admin to add products',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Product> _filteredUnselectedProducts() {
    return products
        .where((product) => product.title.toLowerCase().contains(searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              HapticFeedback.lightImpact();
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
      body: products.isEmpty && selectedProducts.isEmpty
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: _buildEmptyState(),
            )
          : Column(
              children: [
                // Search Section
                _buildSearchCard(),
                
                // Products List
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ReorderableListView(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.only(bottom: 16),
                      onReorder: (oldIndex, newIndex) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          if (oldIndex < selectedProducts.length &&
                              newIndex <= selectedProducts.length) {
                            if (newIndex > oldIndex) newIndex--;
                            final product = selectedProducts.removeAt(oldIndex);
                            selectedProducts.insert(newIndex, product);
                          }
                        });
                      },
                      children: [
                        ...selectedProducts.map(
                          (product) => _buildSelectedProductCard(product),
                        ),
                        ..._filteredUnselectedProducts().map(
                          (product) => _buildUnselectedProductCard(product),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}