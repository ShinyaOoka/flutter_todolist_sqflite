import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class json_todo_screen extends StatefulWidget {
  const json_todo_screen({super.key});

  @override
  State<json_todo_screen> createState() => _json_todo_screenState();
}

class _json_todo_screenState extends State<json_todo_screen> {
  List<Todo> _todolist = [];

  @override
  void initState() {
    super.initState();
    _loadjson();
  }

  // 初期のjson読み込み
  Future<void> _loadjson() async {
    final String response = await rootBundle.loadString('assets/sample_todo.json');
    final List<dynamic> data = jsonDecode(response);
    List<Todo> _todos = data.map((json) => fromJson(json)).toList();
    setState(() {
      _todolist = _todos;
      print(_todolist.toString());
    });
  }

  // CSV export
  Future<void> _exportCSV() async {
    try {
      List<List<String>> csvData = [
        ["id", "title", "description", "category", "todoDate", "isFinished"]
      ];

      csvData.addAll(_todolist.map((todo) =>
      [
        todo.id.toString(),
        todo.title ?? '',
        todo.description ?? '',
        todo.todoDate ?? '',
        todo.isFinished.toString(),
      ]));
      String csvString = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final path = '/storage/emulated/0/Download/todolist.csv';
      final File file = File(path);
      await file.writeAsString(csvString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Csv saved to $path')),
      );
    } catch (e) {
      print('csv export error $e');
    }
  }

  // CSV import (upload)
  Future<void> _importCSV() async {
    try {
      // ファイルピッカーでCSVファイルを選択
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        String csvString = await file.readAsString();

        // CSVをリストに変換
        List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

        List<Todo> _newTodo = [];

        // CSVからTodoデータを生成
        for (var row in csvTable) {
          if (row.isNotEmpty) {
            var _model = Todo();

            // それぞれのフィールドに適切な型を設定
            _model.id = int.tryParse(row[0].toString()) ?? 0;  // idはint型
            _model.title = row[1] ?? '';  // titleはString型
            _model.description = row[2] ?? '';  // descriptionはString型
            _model.category =  '';  // categoryはString型
            _model.todoDate = row[3] ?? '';  // todoDateはString型

            // isFinishedはint型なので、文字列をintに変換
            _model.isFinished = int.tryParse(row[4].toString()) ?? 0;

            _newTodo.add(_model);
          }
        }

        // 新しいデータをセット
        setState(() {
          _todolist = _newTodo;
        });

        // CSVアップロード成功メッセージ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Csv uploaded successfully')),
        );
      }
    } catch (e) {
      print('Error importing CSV: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('json_todo_screen'),
        actions: [
          IconButton(onPressed: _exportCSV, icon: Icon(Icons.get_app)),
          IconButton(onPressed: _importCSV, icon: Icon(Icons.upload)),
        ],
      ),
      body: ListView.builder(
        itemCount: _todolist.length,
        itemBuilder: (context, index) {
          var todo = _todolist[index];
          return ListTile(
            title: Text(todo.title ?? 'No title'),
            subtitle: Text(todo.description ?? 'No description'),
          );
        },
      ),
    );
  }
}
