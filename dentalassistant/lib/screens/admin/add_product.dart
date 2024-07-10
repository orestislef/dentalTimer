import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../api/api.dart';
import '../../models/product.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  int selectedList = 0;
  Duration duration = Duration.zero;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: isAdding
              ? null
              : () {
                  onPressedOnAdd();
                },
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
                        const SizedBox(height: 20.0),
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
                        const SizedBox(height: 20.0),
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
                        const SizedBox(height: 20.0),
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

  void onPressedOnAdd() {
    if (_formKey.currentState?.validate() ?? false) {
      if (duration.inSeconds == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a duration'),
          ),
        );
        return;
      }
      setState(() {
        isAdding = true;
      });
      Api()
          .createProduct(
              product: Product(
        id: -1,
        title: titleController.text,
        description: descriptionController.text,
        forFirstList: selectedList == 0,
        duration: duration,
        createdAt: DateTime.now(),
      ))
          .then((allOK) {
        if (allOK) {
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
          setState(() {
            isAdding = false;
          });
        }
      });
    } else {
      debugPrint('Validation failed');
    }
  }
}
