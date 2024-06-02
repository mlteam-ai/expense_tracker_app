import 'package:expense_tracker_app/models/expense.dart';
import 'package:expense_tracker_app/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense) removeExpenseFunction;

  const ExpensesList(
      {super.key, required this.expenses, required this.removeExpenseFunction});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) => Dismissible(
              key: ValueKey(expenses[index]),
              background: Container(
                alignment: Alignment.centerRight,
                color: Theme.of(context).colorScheme.error.withOpacity(0.75),
                margin: EdgeInsets.symmetric(
                    horizontal: Theme.of(context).cardTheme.margin!.horizontal),
                child: const Icon(Icons.delete, color: Colors.white, size: 40),
              ),
              child: ExpenseItem(expense: expenses[index]),
              onDismissed: (direction) {
                removeExpenseFunction(expenses[index]);
              },
            ),
        itemCount: expenses.length);
  }
}
