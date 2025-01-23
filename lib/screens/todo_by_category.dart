import 'package:flutter/material.dart';
import 'package:flutter_todolist_sqflite/models/todo.dart';
import 'package:flutter_todolist_sqflite/services/todo_service.dart';

class TodosByCategory extends StatefulWidget {
  final String? category;

  TodosByCategory({this.category});

  @override
  State<TodosByCategory> createState() => _TodosByCategoryState();
}

class _TodosByCategoryState extends State<TodosByCategory> {
  List<Todo> _todoList = List<Todo>.empty(growable: true);
  TodoService _todoService = TodoService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTodoByCategories();
  }

  getTodoByCategories() async {
    var todos = await _todoService.readTodosByCategory(this.widget.category);
    todos.forEach((todo) {
      setState(() {
        var model = Todo();
        model.title = todo['title'];
        model.description = todo['description'];
        model.todoDate = todo['todoDate'];

        _todoList.add(model);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos by Category'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(top:8.0,left:8.0,right:8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)
                        ),
                        elevation: 8,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_todoList[index].title ?? 'No title')
                            ],
                          ),
                          subtitle:
                              Text(_todoList[index].description ?? 'No description'),
                          trailing: Text(_todoList[index].todoDate ?? 'No Date'),
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
