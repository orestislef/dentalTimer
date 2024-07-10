import 'package:dentalassistant/models/product.dart';
import 'package:dentalassistant/screens/admin/admin.dart';
import 'package:dentalassistant/screens/product_selection.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<Product>> _futureProduct;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _futureProduct = Api().getProducts();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ),
              ).then((_) {
                Api().getProducts();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.75, // 3/4 of the screen height
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 10, // Shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Placeholder(
                          fallbackHeight: 150, // Placeholder height
                          fallbackWidth: double.infinity, // Full width
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<Product>>(
                          future: _futureProduct,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Column(
                                children: [
                                  Text('Fetching data...'),
                                  SizedBox(height: 20),
                                  CircularProgressIndicator.adaptive(),
                                ],
                              );
                            } else if (snapshot.hasData) {
                              return ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductSelectionScreen(
                                        products: snapshot.data!,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Continue'),
                              );
                            } else {
                              return const Text('No data');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
