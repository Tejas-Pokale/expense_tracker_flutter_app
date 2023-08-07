import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMMMd();
const uuid = Uuid();

enum Category { food, travel, leisure, work }

const CategoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
};

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense(
      {required this.title,
      required this.amount,
      required this.date,
      required this.category})
      : id = uuid.v4();

  Expense.withId(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.category});

  String get formattedDate {
    return formatter.format(date).toString();
  }

  static String? getFormattedDate(DateTime? date) {
    return ((date == null) ? null : formatter.format(date).toString());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toString(),
      'category': category.toString(),
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense.withId(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        category: stringToEnum(map['category']));
  }

  static Category stringToEnum(String value) {
    return Category.values.firstWhere(
      (enumValue) => enumValue.toString() == value,
    );
  }
}

class ExpenseBucket {
  final Category category;
  final List<Expense> expenses;

  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpense, this.category)
      : expenses = allExpense
            .where((element) => element.category == category)
            .toList();

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}