import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

import '../../api/api.dart';
import '../../models/product.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Duration> durations = [];
  final _formKey = GlobalKey<FormState>();
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: isAdding ? null : _onPressedAddProduct,
          child: const Text('Add Product'),
        ),
      ],
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: isAdding
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
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
                  const SizedBox(height: 20.0),
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
                  const SizedBox(height: 20.0),
                  const Text(
                    'Durations (in seconds):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10.0),
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
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: _addDuration,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Duration'),
                  ),
                  const SizedBox(height: 20.0),
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
      baseUnit: BaseUnit.second,
      context: context,
      initialTime: Duration.zero,

    );

    if (pickedDuration != null && pickedDuration.inSeconds > 0) {
      setState(() {
        durations.add(pickedDuration);
      });
    }
  }

  void _onPressedAddProduct() {
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
        isAdding = true;
      });

      final product = Product(
        id: -1,
        title: titleController.text,
        description: descriptionController.text,
        duration: durations.map((d) => d.inSeconds).toList(),
        createdAt: DateTime.now(),
      );

      Api().createProduct(product: product).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add product'),
            ),
          );
        }
        setState(() {
          isAdding = false;
        });
      });
    }
  }
}
