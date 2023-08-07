import 'dart:io';

//import 'package:expense_tracker/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  final Function(Expense expense) onAddExpense;

  const NewExpense({super.key, required this.onAddExpense});

  @override
  State<StatefulWidget> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    Widget mainWidget = orientation == Orientation.portrait
        ? Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('title'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '\$',
                        label: Text('amount'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(Expense.getFormattedDate(_selectedDate) ??
                            'selected date'),
                        IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(Icons.calendar_month)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton(
                    value: _selectedCategory,
                    items: Category.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: _submitExpenseData,
                      child: const Text('Save Expense')),
                ],
              )
            ],
          )
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        label: Text('title'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _amountController,
                      maxLength: 15,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '\$',
                        label: Text('amount'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButton(
                      value: _selectedCategory,
                      items: Category.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(Expense.getFormattedDate(_selectedDate) ??
                            'selected date'),
                        IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(Icons.calendar_month)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: _submitExpenseData,
                      child: const Text('Save Expense')),
                ],
              )
            ],
          );

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: SizedBox(
        height: orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.5
            : MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(child: mainWidget),
      ),
    );
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month - 1, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);
    if (pickedDate != null) {
      setState(() {
        TimeOfDay time = TimeOfDay.now();
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _submitExpenseData() {
    final amount = double.tryParse(_amountController.text);
    final amountIsInValid = (amount == null || amount <= 0);
    if (_titleController.text.trim().isEmpty ||
        amountIsInValid ||
        _selectedDate == null) {
      showPlatformDialog();
      return;
    }

    final expense = Expense(
        title: _titleController.text,
        amount: amount,
        date: _selectedDate!,
        category: _selectedCategory);

    widget.onAddExpense(expense);

    print(expense.toMap());

    Navigator.of(context).pop();
  }

  void showPlatformDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invalid input'),
              content: const Text('Please make sure all entries are filled!!!'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay')),
              ],
            );
          },
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Invalid input'),
              content: const Text('Please make sure all entries are filled!!!'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay')),
              ],
            );
          },
        ),
      );
    }
  }
}
