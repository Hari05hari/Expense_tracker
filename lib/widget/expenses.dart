import 'package:expense_tracker/provider/expense_provider.dart';
import 'package:expense_tracker/widget/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widget/new_expense.dart';
import 'package:flutter/material.dart';
import "package:expense_tracker/models/expense.dart";
import 'package:expense_tracker/widget/chart/chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});
  @override
  ConsumerState<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends ConsumerState<Expenses> {
  final List<Expense> _registerExpenses = [];

  @override
  void initState() {
    super.initState();
    _registerExpenses.addAll(ref.read(dataProvider));

  }
  void _addNewData(Expense data) {
    setState(() {
      _registerExpenses.add(data);
    });
  }

  void _removeData(Expense data) {
    final expenseIndex = _registerExpenses.indexOf(data);
    setState(
      () {
        _registerExpenses.remove(data);
      },
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(
              () {
                _registerExpenses.insert(expenseIndex, data);
              },
            );
          },
        ),
      ),
    );
  }

  void _addNew() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(addToList: _addNewData),
    );
  }

  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(_registerExpenses, Category.food),
      ExpenseBucket.forCategory(_registerExpenses, Category.leisure),
      ExpenseBucket.forCategory(_registerExpenses, Category.travel),
      ExpenseBucket.forCategory(_registerExpenses, Category.work),
    ];
  }

  double get totalExpense {
    double sum = 0;

    for (final bucket in buckets) {
      sum += bucket.totalExpenses;
    }

    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some'),
    );

    if (_registerExpenses.isNotEmpty) {
      mainContent =
          ExpensesList(expense: _registerExpenses, removeData: _removeData);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Flutter ExpenseTracker",
            style: TextStyle(fontSize: 19),
          ),
          actions: [
            IconButton(
              onPressed: _addNew,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: width < 600
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toolbar with Add button => Row()
                  Chart(expenses: _registerExpenses),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Row(children: [
                        Text(
                          "Total Expense :  ",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text("₹ ${totalExpense.toStringAsFixed(2)}")
                      ]),
                    ),
                  ),

                  Expanded(child: mainContent),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toolbar with Add button => Row()
                  Expanded(child: Chart(expenses: _registerExpenses)),

                  Expanded(
                    child: Column(children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 60),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Total Expense :  ",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text("₹ ${totalExpense.toStringAsFixed(2)}")
                              ]),
                        ),
                      ),
                      Expanded(child: mainContent),
                    ]),
                  ),
                ],
              ));
  }
}
