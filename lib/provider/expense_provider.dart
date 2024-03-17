import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

Future<Database> _getDatabase() async {
  final dbpath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbpath, 'expenses.db'),
    onCreate: (db, version) {
      return db.execute(
          'Create table expense_list(title Text, amount Real, Category Text, date Text,id Text PRIMARY KEY)');
    },
    version: 1,
  );
  return db;
}

class ExpenseProvider extends StateNotifier<List<Expense>> {
  ExpenseProvider() : super([]);

  Future<void> loadExpense() async {
    final db = await _getDatabase();
    final data = await db.query('expense_list');
    final expenses = data.map((row) {
      Category category;
      switch (row['Category'] as String) {
        case 'food':
          category = Category.food;
          break;
        case 'leisure':
          category = Category.leisure;
          break;
        case 'travel':
          category = Category.travel;
          break;
        case 'work':
          category = Category.work;
          break;
        default:
          category = Category.leisure;
          break;
      }

      return Expense(
        title: row['title'] as String,
        amount: row['amount'] as double,
        category: category,
        date: row['date'] as DateTime,
      );
    }).toList();
    state = expenses;
    print(state);
  }

  void addPlace(Expense newExpense) async {
    final db = await _getDatabase();
    db.insert('expense_list', {
      'title': newExpense.title,
      'amount': newExpense.amount,
      'Category': newExpense.category.name,
      'date': newExpense.date.toString(),
      'id': newExpense.id,
    });
    state = [newExpense, ...state];
    print(state);
  }

  void removePlace(Expense expense) async {
    final db = await _getDatabase();
    db.delete('expense_list', where: 'id = ?', whereArgs: [expense.id]);
  }
}

final dataProvider =
    StateNotifierProvider<ExpenseProvider, List<Expense>>((ref) {
  return ExpenseProvider();
});
