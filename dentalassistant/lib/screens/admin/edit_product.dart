import 'package:dentalassistant/api/api.dart';
import 'package:dentalassistant/models/product.dart';
import 'package:dentalassistant/screens/admin/show_all_products.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  Product? selectedProduct;
  bool isEditing = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late int selectedList;
  late Duration duration;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return selectedProduct == null
        ? ShowAllProducts(
            onTapOnProduct: (product) {
              selectedList = product.forFirstList ? 0 : 1;
              titleController.text = product.title;
              descriptionController.text = product.description;
              duration = product.duration;
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
          onPressed: isEditing
              ? null
              : () {
                  onPressedSave();
                },
          child: const Text('Save'),
        ),
      ],
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: isEditing
          ? const Center(
              child: Column(
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
                    children: [
                      ToggleSwitch(
                        activeBgColor: const [Colors.blue],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        minWidth: 200.0,
                        initialLabelIndex: selectedList,
                        totalSwitches: 2,
                        labels: const ['First', 'Second'],
                        onToggle: (index) {
                          setState(() {
                            selectedList = index ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
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
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
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
                      DurationPicker(
                        baseUnit: BaseUnit.second,
                        onChange: (value) {
                          setState(() {
                            duration = value;
                          });
                        },
                        duration: duration,
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

  void onPressedSave() {
    if (_formKey.currentState!.validate()) {
      if (duration.inSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid duration'),
          ),
        );
        return;
      }
      setState(() {
        isEditing = true;
      });
      Api()
          .updateProduct(
        product: Product(
            id: selectedProduct!.id,
            title: titleController.text,
            description: descriptionController.text,
            forFirstList: selectedList == 0 ? true : false,
            duration: duration,
            createdAt: DateTime.now()),
      )
          .then((allOK) {
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
          setState(() {
            isEditing = false;
          });
        }
      });
    }
  }
}
