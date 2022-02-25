
// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_2/archived_task_screen/archived_tasks.dart';
import 'package:todo_app_2/cubit/states.dart';
import 'package:todo_app_2/done_task_screen/done_tasks.dart';
import 'package:todo_app_2/new_task_screen/new_tasks.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());


  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List titles = const[
    'New tasks',
    'Done tasks',
    'Archived tasks',
  ];

  List screen = const[
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  IconData fabIcon = Icons.edit;
  bool isBottomNavBarShow = false;

  void changeFabIcon({
    required IconData icon,
    required bool isShow
}){
    emit(AppChangeFabIconState());
    fabIcon = icon;
    isBottomNavBarShow = isShow;
  }



  void changeBottomNavBar(index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;

  Future createDataBase() async{
     openDatabase(
       'todo.db',
       version: 1,
       onCreate: (database, version){
         database.execute(
           'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)',
         ).then((value) {
           print('Database Created');
         }).catchError((error){
           print('Error When Create Database ==> ${error.toString()}');
         });
       },
       onOpen: (database){
         getDataFromDataBase(database);
         print('Database Opened');
     }
     ).then((value) {
       database = value;
       emit(AppCreateDataBaseState());

     });
  }

  Future insertDataToDataBase({
  required String title,
  required String date,
  required String time,
}) async{
    await database!.transaction((txn) async{
      txn.rawInsert(
        'INSERT INTO tasks (title, date, time, status) VALUES ("$title", "$date", "$time", "new")',
      ).then((value) {
        emit(AppInsertDataBaseState());
        print('$value Inserted Successfully');
        getDataFromDataBase(database!);
      }).catchError((error){
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }


  void getDataFromDataBase(database){
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    database!.rawQuery('SELECT * FROM tasks').then((value) {
      print(newTasks);
      emit(AppGetDataBaseState());
      for (var element in value) {
        if(element['status'] == 'new'){
          newTasks.add(element);
        }
        else if(element['status'] == 'done'){
          doneTasks.add(element);
        }
        else{
          archivedTasks.add(element);
        }
      }
    });
  }


  void updateDataBase({
    required String status,
    required int id,
}){
    database!.rawUpdate(
      'UPDATE tasks SET status =? WHERE id =?',
      [status, id],
    ).then((value) {
      getDataFromDataBase(database);
      emit(AppUpdateDataBaseState());
    });
  }


  void deleteDataFromDataBase({
    required int id,
}){
    database!.rawDelete(
      'DELETE FROM tasks WHERE id=?',
      [id],
    ).then((value) {
      emit(AppDeleteDataBaseState());
      getDataFromDataBase(database);
    });
  }

  var direction;
  void dismisableItem(dir){
    emit(AppChangeDismisableColorState());
    direction = dir;
  }

}