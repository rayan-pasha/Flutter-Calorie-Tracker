import 'package:flutter/material.dart';

void main() {
  runApp(CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<FoodEntry> foodEntries = [];
  int dailyLimit = 2000; // Initialize daily limit to 2000

  int getTotalCalories() {
    return foodEntries.fold(0, (total, entry) => total + entry.getTotalCalories());
  }

  @override
  Widget build(BuildContext context) {
    int totalCalories = getTotalCalories();
    bool exceedLimit = totalCalories > dailyLimit;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Calorie Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(Duration(days: 1));
                      // Load food entries for the selected date
                      // You may want to fetch data from a database or other source
                      // and update foodEntries accordingly.
                      // For simplicity, we'll assume foodEntries is empty initially.
                      foodEntries = [];
                    });
                  },
                ),
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(Duration(days: 1));
                      // Load food entries for the selected date
                      // You may want to fetch data from a database or other source
                      // and update foodEntries accordingly.
                      // For simplicity, we'll assume foodEntries is empty initially.
                      foodEntries = [];
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                exceedLimit
                    ? Text(
                  'You have exceeded your daily limit: $dailyLimit cal',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                )
                    : Text(
                  'Daily Limit: $dailyLimit cal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final newLimit = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(dailyLimit: dailyLimit),
                      ),
                    );
                    if (newLimit != null) {
                      setState(() {
                        dailyLimit = newLimit;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          foodEntries.isEmpty
              ? Expanded(child: Center(child: Text('No food items added.')))
              : Expanded(
            child: ListView.builder(
              itemCount: foodEntries.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    title: Text(foodEntries[index].foodItem.name),
                    subtitle: Text(
                        '${foodEntries[index].servingSize} servings - ${foodEntries[index].getTotalCalories()} cal'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final editedEntry = await Navigator.push<FoodEntry>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewFoodItemScreen(
                                  editMode: true,
                                  foodEntry: foodEntries[index],
                                  foodItems: predefinedFoodItems,
                                ),
                              ),
                            );
                            if (editedEntry != null) {
                              setState(() {
                                foodEntries[index] = editedEntry;
                              });
                            }
                          },
                          child: Icon(Icons.edit, color: Colors.blue),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              foodEntries.removeAt(index);
                            });
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Calories: ${getTotalCalories()}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEntry = await Navigator.push<FoodEntry>(
            context,
            MaterialPageRoute(
              builder: (context) => NewFoodItemScreen(foodItems: predefinedFoodItems),
            ),
          );
          if (newEntry != null) {
            setState(() {
              foodEntries.add(newEntry);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NewFoodItemScreen extends StatefulWidget {
  final bool editMode;
  final FoodEntry? foodEntry;
  final List<FoodItem> foodItems;

  NewFoodItemScreen({this.editMode = false, this.foodEntry, required this.foodItems});

  @override
  _NewFoodItemScreenState createState() => _NewFoodItemScreenState();
}

class _NewFoodItemScreenState extends State<NewFoodItemScreen> {
  late FoodItem selectedFood;
  TextEditingController servingSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editMode && widget.foodEntry != null) {
      selectedFood = widget.foodEntry!.foodItem;
      servingSizeController.text = widget.foodEntry!.servingSize.toString();
    } else {
      selectedFood = widget.foodItems.first; // Default to the first food item
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editMode ? 'Edit Food Entry' : 'Add Food Entry'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<FoodItem>(
              value: selectedFood,
              onChanged: (value) {
                setState(() {
                  selectedFood = value!;
                });
              },
              items: widget.foodItems
                  .map((foodItem) => DropdownMenuItem(
                value: foodItem,
                child: Text('${foodItem.name} - ${foodItem.calories} cal'),
              ))
                  .toList(),
              decoration: InputDecoration(labelText: 'Select Food'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: servingSizeController,
              decoration: InputDecoration(labelText: 'Serving Size (decimal)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final servingSize = double.tryParse(servingSizeController.text);
                if (servingSize != null && servingSize > 0) {
                  Navigator.pop(
                    context,
                    FoodEntry(foodItem: selectedFood, servingSize: servingSize),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid serving size.'),
                    ),
                  );
                }
              },
              child: Text(widget.editMode ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final int dailyLimit;

  SettingsScreen({Key? key, required this.dailyLimit}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController limitController;
  late String errorMessage;

  @override
  void initState() {
    super.initState();
    limitController = TextEditingController(text: widget.dailyLimit.toString());
    errorMessage = '';
  }

  void validateLimit(String value) {
    setState(() {
      if (int.tryParse(value) != null && int.parse(value) > 0) {
        errorMessage = '';
      } else {
        errorMessage = 'Please enter a valid number greater than 0.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Daily Calorie Limit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: limitController,
              onChanged: validateLimit,
              decoration: InputDecoration(labelText: 'Daily Calorie Limit'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: errorMessage.isEmpty
                  ? () {
                final newLimit = int.tryParse(limitController.text);
                if (newLimit != null) {
                  Navigator.pop(context, newLimit);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid number.'),
                    ),
                  );
                }
              }
                  : null,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final int calories;

  FoodItem({required this.name, required this.calories});
}

class FoodEntry {
  final FoodItem foodItem;
  final double servingSize;

  FoodEntry({required this.foodItem, required this.servingSize});

  int getTotalCalories() {
    return (foodItem.calories * servingSize).round();
  }
}

List<FoodItem> predefinedFoodItems = [
  FoodItem(name: 'Apple (4 oz.)', calories: 80),
  FoodItem(name: 'Banana (5 oz.)', calories: 105),
  FoodItem(name: 'Orange (4 oz.)', calories: 60),
  FoodItem(name: 'Pear (5 oz.)', calories: 80),
  FoodItem(name: 'Beef (2 oz.)', calories: 140),
  FoodItem(name: 'Chicken (2 oz.)', calories: 120),
  FoodItem(name: 'Tofu (4 oz.)', calories: 90),
  FoodItem(name: 'Fish (2 oz.)', calories: 135),
  FoodItem(name: 'Pork (2 oz.)', calories: 145),
  FoodItem(name: 'Shrimp (2 oz.)', calories: 55),
  FoodItem(name: 'Egg (1 large)', calories: 70),
  FoodItem(name: 'Broccoli (1 cup)', calories: 45),
  FoodItem(name: 'Carrots (1 cup)', calories: 50),
  FoodItem(name: 'Cucumber (4 oz.)', calories: 15),
  FoodItem(name: 'Lettuce (1 cup)', calories: 5),
  FoodItem(name: 'Tomato (1 cup)', calories: 20),
  FoodItem(name: 'Potato (6 oz.)', calories: 130),
  FoodItem(name: 'Rice (1 cup cooked)', calories: 200),
  FoodItem(name: 'Milk (2%)', calories: 120),
];
