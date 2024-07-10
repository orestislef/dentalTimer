import 'package:dentalassistant/api/api.dart';
import 'package:flutter/material.dart';

import '../../models/product.dart';

class ShowAllProducts extends StatelessWidget {
  const ShowAllProducts({super.key, this.onTapOnProduct});

  final Function(Product product)? onTapOnProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text(onTapOnProduct != null ? 'Select Product' : 'All Products'),
        ),
        body: FutureBuilder(
            future: Api().getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    children: [
                      Text('Loading Products...'),
                      SizedBox(height: 20),
                      CircularProgressIndicator.adaptive(),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                List<Product> products = snapshot.data as List<Product>;
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No Products Found'),
                  );
                }
                return Scrollbar(
                  child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(products[index].title),
                          subtitle: Text(products[index].description),
                          trailing: Text(
                              'Time: ${products[index].duration.inSeconds}s'),
                          leading: Text(products[index].forFirstList
                              ? 'First'
                              : 'Second'),
                          onTap: onTapOnProduct != null
                              ? () {
                                  onTapOnProduct!(products[index]);
                                }
                              : null,
                        );
                      }),
                );
              } else {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
            }));
  }
}
