import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../NetworkService/firebase_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({Key? key}) : super(key: key);

  @override
  _NewTaskScreenState createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        Task newTask = Task(
          shopName: _shopNameController.text,
          productSold: _productController.text,
          quantity: int.parse(_quantityController.text),
          amount: double.parse(_amountController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          timestamp: DateTime.now(),
        );

        await _databaseService.insertTask(newTask);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task saved successfully!'),
              backgroundColor: Color(0xFF1E3A8A),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          'New Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          // Connection status indicator in app bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Connected' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9EFFD), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputField(
                    controller: _shopNameController,
                    labelText: 'Shop Name',
                    icon: Icons.store,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter shop name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _productController,
                    labelText: 'Product Sold',
                    icon: Icons.shopping_bag,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _quantityController,
                    labelText: 'Quantity',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Quantity must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _amountController,
                    labelText: 'Amount (\$)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _notesController,
                    labelText: 'Notes (Optional)',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Save Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF1E3A8A),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
}