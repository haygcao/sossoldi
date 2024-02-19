import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/providers/budgets_provider.dart';

import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import 'widget/budget_category_selector.dart';
import '../../../providers/categories_provider.dart';

class ManageBudgetPage extends ConsumerStatefulWidget {
  final Function() onRefreshBudgets;
  const ManageBudgetPage({required this.onRefreshBudgets, super.key});

  @override
  ConsumerState<ManageBudgetPage> createState() => _ManageBudgetPageState();
}

class _ManageBudgetPageState extends ConsumerState<ManageBudgetPage> {
  List<CategoryTransaction> categories = [];
  List<Budget> budgets = [];
  List<Budget> deletedBudgets = [];

  void _loadCategories() async {
    categories = await ref.read(categoriesProvider.notifier).getCategories();
    budgets = await ref.read(budgetsProvider.notifier).getBudgets();
    setState(() {});
  }

  void updateBudget(Budget updatedBudget, int index) {
    //deletedBudgets.add(budgets[index]);
    budgets[index] = updatedBudget;
  }

  void deleteBudget(Budget removedBudget, int index) {
    setState(() {
      budgets.removeAt(index);
      deletedBudgets.add(removedBudget);
    });
  }

  @override
  void initState() {
    _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(15),
            child: Text("Select the categories to create your budget",
                style: Theme.of(context).textTheme.titleLarge)),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category',
                  textAlign: TextAlign.left,
                ),
                Text(
                  'Amount',
                  textAlign: TextAlign.right,
                ),
              ],
            )),
        Expanded(
            child: ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: Key(budgets[index].idCategory.toString()),
                background: Container(
                  padding: const EdgeInsets.only(right: 20.0),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Text(
                    'Delete',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onDismissed: (direction) {
                  deleteBudget(budgets[index], index);
                },
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: BudgetCategorySelector(
                      categories: categories,
                      budget: budgets[index],
                      initSelectedCategory: categories
                              .where((element) =>
                                  element.id == budgets[index].idCategory)
                              .isEmpty
                          ? categories[0]
                          : categories
                              .where((element) =>
                                  element.id == budgets[index].idCategory)
                              .first,
                      onBudgetChanged: (updatedBudget) {
                        updateBudget(updatedBudget, index);
                      },
                    )));
          },
        )),
        ListTile(
          leading: const Icon(Icons.add_box),
          title: const Text("Add category budget"),
          onTap: () {
            setState(() {
              budgets.add(Budget(
                  active: true,
                  amountLimit: 100,
                  idCategory: categories[0].id!,
                  name: categories[0].name));
            });
          },
        ),
        Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    for (var item in deletedBudgets) {
                      BudgetMethods().deleteByCategory(item.idCategory);
                    }
                    for (var item in budgets) {
                      BudgetMethods().insertOrUpdate(item);
                    }
                    setState(() {
                      widget.onRefreshBudgets();
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text("Save budget"),
                )))
      ],
    );
  }
}
