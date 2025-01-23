import 'package:flutter_todolist_sqflite/repository/repository.dart';

import '../models/category.dart';

class CategoryService {
  Repository? _repository;

  CategoryService() {
    _repository = Repository();
  }

  //create data
  saveCategory(Category category) async {
    return await _repository!.insertData('categories', category.categoryMap());
  }

  readCategories() async {
    return await _repository!.readData('categories');
  }

  readCategoryById(categoryId) async {
    return await _repository!.readDataById('categories', categoryId);
  }

  //Update data from table
  updateCategory(Category category) async {
    return await _repository!.updateData('categories', category.categoryMap());
  }

  //Delete data from table
  deleteCategory(categoryId) async {
    return await _repository!.deleteData('categories', categoryId);
  }
}
