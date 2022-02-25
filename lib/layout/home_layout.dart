// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_2/components/components.dart';
import 'package:todo_app_2/cubit/cubit.dart';
import 'package:todo_app_2/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({Key? key}) : super(key: key);

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, state) {  },
        builder: (BuildContext context, Object? state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                  cubit.titles[cubit.currentIndex],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                if(cubit.isBottomNavBarShow){
                  if(formKey.currentState!.validate()){
                    cubit.insertDataToDataBase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    ).then((value) {
                      titleController.text = '';
                      timeController.text = '';
                      dateController.text ='';
                      Navigator.pop(context);
                      cubit.changeFabIcon(
                        icon: Icons.edit,
                        isShow: false,
                      );
                    });
                  }
                }
                else{
                  scaffoldKey.currentState!.showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              type: TextInputType.text,
                              validate: (String? value){
                                if(value!.isEmpty){
                                  return 'Title must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Title',
                              prefix: Icons.title,
                              onTap: (){},
                            ),

                            const SizedBox(
                              height: 15.0,
                            ),

                            defaultFormField(
                              controller: timeController,
                              type: TextInputType.datetime,
                              validate: (String? value){
                                if(value!.isEmpty){
                                  return 'Time must not be empty';
                                }
                                return null;
                              },
                              label: 'Task Time',
                              prefix: Icons.watch_later_outlined,
                              onTap: (){
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text = value!.format(context).toString();
                                  print(value.format(context));
                                });
                              },
                            ),

                            const SizedBox(
                              height: 15.0,
                            ),

                            defaultFormField(
                              controller: dateController,
                              type: TextInputType.datetime,
                              validate: (String? value){
                                if(value!.isEmpty){
                                  return 'Date must not be empty';
                                }
                                return null;
                              },
                              label: 'Date Time',
                              prefix: Icons.calendar_today,
                              onTap: (){
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse('2023-01-01'),
                                ).then((value) {
                                  dateController.text = DateFormat.yMMMd().format(value!);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 15.0,
                  ).closed.then((value) {
                    cubit.changeFabIcon(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  },
                  );
                  cubit.changeFabIcon(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeBottomNavBar(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
            body: cubit.screen[cubit.currentIndex],
          );
        },
      ),
    );
  }
}
