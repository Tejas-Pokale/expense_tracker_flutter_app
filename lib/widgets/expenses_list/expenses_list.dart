import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key, required this.expenses, required this.onRemoveExpense});

  final List<Expense> expenses;
  final Function(Expense expense,BuildContext ctx) onRemoveExpense;
  

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Dismissible(
        background: Container(
          color: Colors.redAccent.withOpacity(0.75),
          margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
        ),
          onDismissed: (direction) {
            onRemoveExpense(expenses[index],context);
          },
          key: ValueKey(expenses[index]),
          child: ExpenseItem(expense: expenses[index])),
      itemCount: expenses.length,
    );
  }
}
