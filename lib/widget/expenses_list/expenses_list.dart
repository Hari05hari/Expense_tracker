import 'package:expense_tracker/widget/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key, required this.expense, required this.removeData});
  final List<Expense> expense;
  final void Function(Expense data) removeData;
  @override
  Widget build(context) {
    return ListView.builder(
      itemCount: expense.length,
      itemBuilder: (ctx, index) => Dismissible(
        background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
            margin: Theme.of(context).cardTheme.margin),
        key: ValueKey(expense[index].id),
        onDismissed: (direction) {
          removeData(expense[index]);
        },
        child: ExpenseItem(
          expense: expense[index],
        ),
      ),
    );
  }
}
