import 'package:flutter/material.dart';
import 'package:flutter_todolist_sqflite/models/todo.dart';
import 'package:flutter_todolist_sqflite/screens/home_screen.dart';
import 'package:flutter_todolist_sqflite/services/category_service.dart';
import 'package:flutter_todolist_sqflite/services/todo_service.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  var _todoTitleController = TextEditingController();
  var _todoDescriptionController = TextEditingController();
  var _todoDateController = TextEditingController();
  var _selectedValue;
  var _categories = List<DropdownMenuItem>.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    var _categoryService = CategoryService();
    var categories = await _categoryService.readCategories();
    categories.forEach((category) {
      setState(() {
        _categories.add(DropdownMenuItem(
          child: Text(category['name']),
          value: category['name'],
        ));
      });
    });
  }

  DateTime _dateTime = DateTime.now();

  _selectedTodoDate(BuildContext context) async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (_pickedDate != null) {
      setState(() {
        _dateTime = _pickedDate;
        _todoDateController.text = DateFormat('yyyy-MM-dd').format(_pickedDate);
      });
    }
  }

  _showSuccessSnackBar(message) {
    var _snackBar = SnackBar(content: message);
    //_globalKey.currentState!.(_snackBar);
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Todo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _todoTitleController,
                decoration: InputDecoration(
                    labelText: 'Title', hintText: 'Write Todo Title'),
              ),
              TextField(
                controller: _todoDescriptionController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Write Todo Descriptrion'),
              ),
              TextField(
                controller: _todoDateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Pick a Date',
                  prefixIcon: InkWell(
                    onTap: () {
                      _selectedTodoDate(context);
                    },
                    child: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              DropdownButtonFormField(
                  value: _selectedValue,
                  items: _categories,
                  hint: Text('Category'),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value;
                    });
                  }),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  var todoObject = Todo();
                  todoObject.title = _todoTitleController.text;
                  todoObject.description = _todoDescriptionController.text;
                  todoObject.isFinished = 0;
                  todoObject.category = _selectedValue.toString();
                  todoObject.todoDate = _todoDateController.text;

                  var _todoService = TodoService();
                  var result = await _todoService.saveTodo(todoObject);

                  if (result > 0) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                    _showSuccessSnackBar(Text('Created'));
                  }

                  print(result);
                },
                child: Text('save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ));
  }
}
