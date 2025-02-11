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

Todo fromJson(Map<String,dynamic> json){
  Todo todo=Todo();
  todo.id = json['id'];
  todo.title=json['title'];
  todo.description=json['description'];
  todo.category=json['category'];
  todo.todoDate=json['todoDate'];
  todo.isFinished=json['isFinished'];

  return todo;
}