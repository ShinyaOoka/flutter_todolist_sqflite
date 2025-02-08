import 'package:flutter/material.dart';
import 'package:flutter_todolist_sqflite/screens/calendar_screen.dart';
import 'package:flutter_todolist_sqflite/screens/categories_screen.dart';
import 'package:flutter_todolist_sqflite/screens/home_screen.dart';
import 'package:flutter_todolist_sqflite/screens/todo_by_category.dart';
import 'package:flutter_todolist_sqflite/services/category_service.dart';
import '';
import '../screens/calendar_todo_screen.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({super.key});

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  List<Widget> _categoryList = List<Widget>.empty(growable: true);
  CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllCategories();
  }

  getAllCategories() async {
    var categories = await _categoryService.readCategories();
    categories.forEach((category) {
      setState(() {
        _categoryList.add(InkWell(
          onTap: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new TodosByCategory(category: category['name'],))),
          child: ListTile(
            title: Text(category['name']),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://www.hyponex.co.jp/websys/wp-content/uploads/2023/07/4-4mini-1.webp'),
            ),
            accountName: Text('Shinya oooka'),
            accountEmail: Text('tesstemail@test.com'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen())),
          ),
          ListTile(
            leading: Icon(Icons.view_list),
            title: Text('Categories'),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CategoriesScreen())),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Calender'),
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CalendarScreen())),
          ),
          ListTile(
            leading: Icon(Icons.calendar_month_outlined),
            title: Text('CalenderTodo'),
            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CalendarTodoScreen())),
          ),
          Divider(),
          Column(
            children: _categoryList,
          )
        ]),
      ),
    );
  }
}
