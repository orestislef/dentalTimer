import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../../models/product.dart';
import '../../screens/admin/show_all_products.dart';
import 'package:duration_picker/duration_picker.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({Key? key}) : super(key: key);

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  Product? selectedProduct;
  bool isEditing = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Duration> durations = [];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return selectedProduct == null
        ? ShowAllProducts(
      onTapOnProduct: (product) {
        titleController.text = product.title;
        descriptionController.text = product.description;
        durations = product.duration
            .map((seconds) => Duration(seconds: seconds))
            .toList();
        setState(() {
          selectedProduct = product;
        });
      },
    )
        : _buildEditProduct();
  }

  Widget _buildEditProduct() {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: isEditing ? null : _onPressedSave,
          child: const Text('Save'),
        ),
      ],
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: isEditing
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Updating product..'),
            SizedBox(height: 20),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Product Title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Durations (in seconds):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: durations.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          'Duration ${index + 1}: ${durations[index].inSeconds} seconds',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              durations.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addDuration,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Duration'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addDuration() async {
    Duration? pickedDuration = await showDurationPicker(
      context: context,
      baseUnit: BaseUnit.second,
      initialTime: Duration.zero,
    );

    if (pickedDuration != null && pickedDuration.inSeconds > 0) {
      setState(() {
        durations.add(pickedDuration);
      });
    }
  }

  void _onPressedSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (durations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one duration'),
          ),
        );
        return;
      }
      setState(() {
        isEditing = true;
      });

      final updatedProduct = Product(
        id: selectedProduct!.id,
        title: titleController.text,
        description: descriptionController.text,
        duration: durations.map((d) => d.inSeconds).toList(),
        createdAt: selectedProduct!.createdAt,
      );

      Api().updateProduct(product: updatedProduct).then((allOK) {
        if (allOK) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update product'),
            ),
          );
        }
        setState(() {
          isEditing = false;
        });
      });
    }
  }
}
