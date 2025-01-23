import 'package:flutter_todolist_sqflite/models/todo.dart';
import 'package:flutter_todolist_sqflite/repository/repository.dart';

class TodoService {
  final Repository _repository;

  TodoService() : _repository = Repository();

  saveTodo(Todo todo) async {
    return await _repository.insertData('todos', todo.todoMap());
  }

  readTodos() async {
    return _repository.readData('todos');
  }

  readTodoBytodoId(todoId)async {
    return await _repository.readDataById('todos', todoId);
  }

  readTodosByCategory(category) async {
    return await _repository.readDataByColumnName('todos', 'category', category);
  }


  deleteTodos(todoId) async {
    return await _repository.deleteData('todos', todoId);
  }

  updateTodos(Todo todo) async {
    return await _repository.updateData('todos', todo.todoMap());
  }

}