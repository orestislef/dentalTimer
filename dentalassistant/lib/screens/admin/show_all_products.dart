import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../../models/product.dart';

class ShowAllProducts extends StatelessWidget {
  const ShowAllProducts({Key? key, this.onTapOnProduct}) : super(key: key);

  final Function(Product product)? onTapOnProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(onTapOnProduct != null ? 'Select Product' : 'All Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: Api().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading Products...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator.adaptive(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading products: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            List<Product> products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'No Products Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }
            return Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Durations: ${product.duration.map((d) => '${d}s').join(', ')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: onTapOnProduct != null
                          ? () {
                        onTapOnProduct!(product);
                      }
                          : null,
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }
        },
      ),
    );
  }
}
