import 'dart:async';

import 'package:expense_tracker/database_helper.dart';
import 'package:expense_tracker/widgets/common/circular_progress.dart';
import 'package:expense_tracker/widgets/common/error_message.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';

class Expenses extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final dbHelper = DatabaseHelper();

  List<Expense> _registeredExpenses = [];
  late Future<List<Expense>> _pendingData;

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: NewExpense(onAddExpense: addExpense)),
    );
  }

  void addExpense(Expense expense) async {
    setState(() {
      _registeredExpenses.insert(0, expense);
    });
    await dbHelper.insertExpense(expense);
  }

  void removeExpense(Expense expense, BuildContext ctx) async {
    final int index = _registeredExpenses.indexOf(expense);
    bool delete = true;

    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'undo',
          onPressed: () {
            delete = false;
            setState(() {
              _registeredExpenses.insert(index, expense);
            });
          },
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 51, 15, 112),
      ),
    );

    Timer(const Duration(milliseconds: 2500), () {
      if (delete) {
        dbHelper.removeExpense(expense);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pendingData = getAllExpenses();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = _registeredExpenses.isEmpty
        ? const Center(
            child: Text('no expenses added, try adding new expenses'),
          )
        : ExpensesList(
            expenses: _registeredExpenses,
            onRemoveExpense: removeExpense,
          );

    final orientation = MediaQuery.of(context).orientation;

    Widget orientationWidget = orientation == Orientation.portrait
        ? Column(
            children: [
              Chart(expenses: _registeredExpenses),
              Expanded(child: mainWidget),
            ],
          )
        : Row(
            children: [
              Expanded(child: Chart(expenses: _registeredExpenses)),
              Expanded(child: mainWidget),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense tracker',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
              onPressed: _openAddExpenseOverlay, icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: _pendingData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _registeredExpenses = snapshot.data!;
            return orientationWidget;
          } else if (snapshot.hasError) {
            return CustomErrorMessage(
              message: 'failed to load data',
            );
          }
          return const CustomCircularProgress();
        },
      ),
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    _registeredExpenses.clear();
    _registeredExpenses = await dbHelper.getAllExpenses();
    if (_registeredExpenses.isEmpty) {
      return [];
    }
    print(_registeredExpenses);
    setState(() {});
    return _registeredExpenses;
  }
}
