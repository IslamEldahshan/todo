import 'package:flutter/material.dart';
import 'package:todo_app_2/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required validate,
  required String label,
  required IconData prefix,
  bool isPassword = false,
  required Function onTap,

}) => TextFormField(
  validator: validate,
  onTap: () {
    onTap();
  },
  controller: controller,
  keyboardType: type,
  obscureText: isPassword,
  decoration:  InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    prefixIcon: Icon(
      prefix,
    ),

  ),
);


Widget buildTaskItem(List<Map> tasks) => tasks.isEmpty ? Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(
        Icons.menu,
        size: 120.0,
        color: Colors.grey,
      ),
      Text(
        'Tasks is empty. add some tasks',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
) : ListView.separated(
  itemBuilder: (BuildContext context, int index) {
    AppCubit cubit = AppCubit.get(context);
    return Dismissible(
      key: Key(tasks[index]['id'].toString()),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: BorderRadius.circular(20.0,),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Icon(
          Icons.delete,
          color: Colors.grey.shade200,
          size: 80.0,
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade300,
          borderRadius: BorderRadius.circular(20.0,),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Icon(
          Icons.arrow_back,
          color: Colors.grey.shade200,
          size: 80.0,
        ),
      ),
      onDismissed: (direction){
        if(direction == DismissDirection.startToEnd){
          cubit.deleteDataFromDataBase(id: tasks[index]['id']);
        }
        else{
          if(tasks != cubit.newTasks){
            cubit.updateDataBase(status: 'new', id: tasks[index]['id']);
            tasks.remove(tasks[index]);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 43.0,
              backgroundColor: Colors.blue,
              child: Text(
                tasks[index]['time'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks[index]['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    tasks[index]['date'],
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: (){
                AppCubit.get(context).updateDataBase(
                  status: 'done',
                  id: tasks[index]['id'],
                );
              },
              icon: const Icon(
                Icons.check_box,
              ),
              color: Colors.green,
            ),
            IconButton(
              onPressed: (){
                AppCubit.get(context).updateDataBase(
                  status: 'archived',
                  id: tasks[index]['id'],
                );
              },
              icon: const Icon(
                Icons.archive,
              ),
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  },
  separatorBuilder: (BuildContext context, int index) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
    ),
    child: Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    ),
  ),
  itemCount: tasks.length,
);