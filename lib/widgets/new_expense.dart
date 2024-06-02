import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/models/expense.dart';

final formatter = DateFormat.yMd();

class NewExpense extends StatefulWidget {
  final void Function(Expense) addExpenseFunction;
  const NewExpense(this.addExpenseFunction, {super.key});

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  ExpenseCategory? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate as DateTime;
    });
  }

  void _presentErrorDialog(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: const Text('Invalid Input'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Invalid Input'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
    }
  }

  _submitExpenseData() {
    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.tryParse(_amountController.text);
    List<String> errorMessages = [];

    if (enteredTitle.isEmpty) {
      errorMessages.add('Please enter a valid title...');
    }

    if (enteredAmount == null || enteredAmount <= 0) {
      errorMessages.add('Please enter a valid amount...');
    }

    if (_selectedDate == null) {
      errorMessages.add('Please select a valid date...');
    }

    if (_selectedCategory == null) {
      errorMessages.add('Please select a valid category...');
    }
    if (errorMessages.isNotEmpty) {
      _presentErrorDialog(errorMessages.join('\n'));
      return;
    }

    widget.addExpenseFunction(Expense(
      title: enteredTitle,
      amount: enteredAmount!,
      date: _selectedDate!,
      category: _selectedCategory!,
    ));
    Navigator.pop(context);
  }

  Widget get titleField {
    return TextField(
        controller: _titleController,
        maxLength: 50,
        decoration: const InputDecoration(
          label: Text('Title'),
        ));
  }

  Widget get amountField {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        label: Text('Amount'),
        prefixText: '\$ ',
      ),
    );
  }

  Widget getCategoryField(bool isExpanded) {
    return DropdownButton(
        isExpanded: isExpanded,
        value: _selectedCategory,
        items: ExpenseCategory.values
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category.name.toUpperCase(),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value as ExpenseCategory;
          });
        });
  }

  Widget get dateField {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text((_selectedDate == null)
            ? 'No date selected'
            : formatter.format(_selectedDate!)),
        IconButton(
          onPressed: _presentDatePicker,
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }

  Widget get cancelButton {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Cancel'),
    );
  }

  Widget get saveButton {
    return ElevatedButton(
      onPressed: _submitExpenseData,
      child: const Text('Save Expense'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
            child: Column(
              children: [
                if (width >= 600)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: titleField,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: amountField,
                      ),
                    ],
                  )
                else
                  titleField,
                Row(
                  children: [
                    Expanded(
                        child: (width >= 600)
                            ? getCategoryField(true)
                            : amountField),
                    const SizedBox(width: 16),
                    Expanded(child: dateField)
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (width < 600) getCategoryField(false),
                    const Spacer(),
                    cancelButton,
                    saveButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
