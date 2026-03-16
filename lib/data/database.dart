import 'package:hive_flutter/hive_flutter.dart';

class ToDoDaTaBase {
  List toDoList = [];
  final _myBox = Hive.box('box_v3');

  String getToday() {
    DateTime now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  void createInitialData() {
    toDoList = [
      ["Lập kế hoạch", false, "Ngày", getToday()],
      ["Tập Thể dục", false, "Ngày", getToday()],
    ];
  }

  void loadData() {
    toDoList = _myBox.get("TODOLIST");
    String today = getToday();
    for (int i = 0; i < toDoList.length; i++) {
      if (toDoList[i].length < 3) {
        toDoList[i].add("Ngày");
      }
      if (toDoList[i].length < 4) {
        toDoList[i].add(today);
      }
    }
  }

  void updateData() {
    _myBox.put("TODOLIST", toDoList);
  }
}
