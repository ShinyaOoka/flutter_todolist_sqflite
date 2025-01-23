import 'package:flutter/material.dart';
import 'package:flutter_todolist_sqflite/helpers/drawer_navigation.dart';
import 'package:flutter_todolist_sqflite/models/todo.dart';
import 'package:flutter_todolist_sqflite/screens/todo_screen.dart';
import 'package:flutter_todolist_sqflite/services/category_service.dart';
import 'package:flutter_todolist_sqflite/services/todo_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //変数宣言
  TodoService? _todoService;
  List<Todo> _todoList = List<Todo>.empty(growable: true);
  var readId;
  var _editTodoTitleController = TextEditingController();
  var _editTodoDescriptionController = TextEditingController();
  var _editTodoDateController = TextEditingController();
  var _editTodoCategoryController = TextEditingController();
  var todo;
  DateTime _dateTime = DateTime.now();
  var _categories = List<DropdownMenuItem>.empty(growable: true);
  var _selectedValue;
  double _setSlidervalueQ1 = 0.0;
  double _setSlidervalueQ2 = 0.0;
  double _setSlidervalueQ3 = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTodos();
    _loadCategories();
  }

  getAllTodos() async {
    _todoService = TodoService();
    _todoList = List<Todo>.empty(growable: true);

    var todos = await _todoService!.readTodos();

    List<Map> todoslist = todos;
    var filteredlist = todoslist.where((list) {
      return list.containsValue('2025-01-19');
    }).toList();
    print(filteredlist);

    todos.forEach((todo) {
      setState(() {
        var model = Todo();
        model.id = todo['id'];
        model.title = todo['title'];
        model.description = todo['description'];
        model.category = todo['category'];
        model.todoDate = todo['todoDate'];
        model.isFinished = todo['isFinished'];
        _todoList.add(model);
      });
    });
  }

  _selectedTodoDate(BuildContext context) async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100));
    if (_pickedDate != null) {
      setState(() {
        _dateTime = _pickedDate;
        _editTodoDateController.text =
            DateFormat('yyyy-MM-dd').format(_pickedDate);
      });
    }
  }

  _loadCategories() async {
    var _categoryService = CategoryService();
    var categories = await _categoryService.readCategories();
    categories.forEach(
      (category) {
        _categories.add(DropdownMenuItem(
          value: category['name'],
          child: Text(category['name']),
        ));
      },
    );
  }

  _showSuccessSnackBar(message) {
    var _snackBar = SnackBar(content: message);
    //_globalKey.currentState!.(_snackBar);
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }

  _editTodo(BuildContext context, todoId) async {
    todo = await _todoService!.readTodoBytodoId(todoId);
    setState(() {
      readId = todo[0]['id'] ?? 0;
      _editTodoTitleController.text = todo[0]['title'] ?? 'No title';
      _editTodoDescriptionController.text =
          todo[0]['description'] ?? 'No description';
      _editTodoDateController.text = todo[0]['todoDate'] ?? '';
      _editTodoCategoryController.text = todo[0]['category'] ?? '';
    });
    return _editFormDialog(context);
  }

  _editFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('calcel')),
              ElevatedButton(
                  onPressed: () async {
                    var _todo = Todo();
                    _todo.id = readId;
                    _todo.title = _editTodoTitleController.text;
                    _todo.description = _editTodoDescriptionController.text;
                    _todo.todoDate = _editTodoDateController.text;
                    _todo.category = _selectedValue.toString();
                    var result = await _todoService!.updateTodos(_todo);
                    if (result > 0) {
                      Navigator.pop(context);
                      _showSuccessSnackBar(Text('Updated'));
                      getAllTodos();
                    }
                  },
                  child: Text('update')),
            ],
            title: Text('Edit todo'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _editTodoTitleController,
                    decoration: InputDecoration(
                        labelText: 'title', hintText: 'write a title'),
                  ),
                  TextField(
                    controller: _editTodoDescriptionController,
                    decoration: InputDecoration(
                        labelText: 'description',
                        hintText: 'write a description'),
                  ),
                  TextField(
                    controller: _editTodoDateController,
                    decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: 'write a Date',
                        prefixIcon: InkWell(
                          onTap: () {
                            _selectedTodoDate(context);
                          },
                          child: Icon(Icons.calendar_today),
                        )),
                  ),
                  DropdownButtonFormField(
                      value: _editTodoCategoryController.text,
                      hint: Text('category'),
                      items: _categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                        });
                      })
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todolist sqflite'),
      ),
      drawer: DrawerNavigation(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      child: ListTile(
                        //Delete
                        onLongPress: () async {
                          var result = await _todoService!
                              .deleteTodos(_todoList[index].id);
                          if (result > 0) {
                            setState(() {
                              getAllTodos();
                              _showSuccessSnackBar(Text('Deleted'));
                            });
                          }
                        },
                        //Edit
                        onTap: () async {
                          _editTodo(context, _todoList[index].id);
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(_todoList[index].title ?? 'No title')
                          ],
                        ),
                        subtitle:
                            Text(_todoList[index].category ?? 'No category'),
                        trailing: Text(_todoList[index].todoDate ?? 'No Date'),
                      ),
                    ),
                  );
                }),
          ),
          // ListViewとSliderの間のスペースを調整
          SizedBox(height: 16.0), // ここで間隔を調整
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 500,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => Text('$index')),
                    )),
                    SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 500,
                      child: Text('便秘がちである'),
                    ),
                    Expanded(
                        child: Slider(
                            value: _setSlidervalueQ1,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: '${_setSlidervalueQ1.round()}',
                            onChanged: (value) {
                              setState(() {
                                _setSlidervalueQ1 = value;
                              });
                            })),
                    SizedBox(
                      width: 16,
                    )
                  ],
                ),
              ],
            ),
          ), //Slider
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 500,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => Text('$index')),
                    )),
                    SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 500,
                      child: Text('朝早く起きることができない'),
                    ),
                    Expanded(
                        child: Slider(
                            value: _setSlidervalueQ2,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: '${_setSlidervalueQ2.round()}',
                            onChanged: (value) {
                              setState(() {
                                _setSlidervalueQ2 = value;
                              });
                            })),
                    SizedBox(
                      width: 16,
                    )
                  ],
                ),
              ],
            ),
          ), //Slider
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 500,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => Text('$index')),
                    )),
                    SizedBox(
                      width: 16.0,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 500,
                      child: Text('体が以前と比べて冷えやすくなった'),
                    ),
                    Expanded(
                        child: Slider(
                            value: _setSlidervalueQ3,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: '${_setSlidervalueQ3.round()}',
                            onChanged: (value) {
                              setState(() {
                                _setSlidervalueQ3 = value;
                              });
                            })),
                    SizedBox(
                      width: 16,
                    )
                  ],
                ),
              ],
            ),
          ), //Slider
          SizedBox(
            height: 16,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TodoScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}
