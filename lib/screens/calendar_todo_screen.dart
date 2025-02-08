import 'package:flutter/material.dart';
import 'package:flutter_todolist_sqflite/models/todo.dart';
import 'package:flutter_todolist_sqflite/services/todo_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarTodoScreen extends StatefulWidget {
  const CalendarTodoScreen({super.key});

  @override
  State<CalendarTodoScreen> createState() => _CalendarTodoScreenState();
}

class _CalendarTodoScreenState extends State<CalendarTodoScreen> {
  var _focusedDay = DateTime.now();
  ValueNotifier<String> whereday = ValueNotifier('first');
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  List<Map<String, dynamic>> listmap = [
    {'id': '0', 'value': 'honda'},
    {'id': '1', 'value': 'suzuki'},
    {'id': '2', 'value': 'toyota'},
  ];
  var _todoService = TodoService();
  var _todoList = List<Todo>.empty(growable: true);
  var _filteredTodoList = List<Todo>.empty(growable: true);
  List<Todo> todos = [];

  @override
  void initState() {
    // TODO: implement initState
    _loadData();
    // print(todos.toString());
  }

  Future<void> _loadData() async {
    var todos = await _todoService!.readTodos();

    setState(() {
      todos.forEach((todo) {
        var model = Todo();
        model.id = todo['id'];
        model.title = todo['title'];
        model.description = todo['description'];
        model.todoDate = todo['todoDate'];
        model.category = todo['category'];
        model.isFinished = todo['isFinished'];
        _todoList.add(model);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('calendar_todo_screen'),
      ),
      body: Column(
        children: [
          TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2025, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              onDaySelected: (DateTime selectedDay, DateTime forcusedDay) {
                setState(() {
                  _focusedDay = selectedDay;
                  whereday.value = outputFormat.format(_focusedDay);
                  _filteredTodoList =_todoList.where((todo)=>todo.todoDate==whereday.value).toList();
                });
              }),
          Divider(),
          ValueListenableBuilder(
              valueListenable: whereday,
              builder: (context, value, child) {
                return Text(value);
              }),
          Divider(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: whereday,
              builder: (context, value, child) {
                return ListView.builder(
                  itemCount: _filteredTodoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredTodoList[index].title ?? ''),
                      subtitle: Text(_filteredTodoList[index].todoDate ?? ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
