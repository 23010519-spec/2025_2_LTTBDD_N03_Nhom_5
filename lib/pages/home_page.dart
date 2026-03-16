import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart' show Hive;
import 'package:todoapp/data/database.dart';
import 'package:todoapp/pages/about_page.dart';
import 'package:todoapp/until/dialog_box.dart';
import 'package:todoapp/until/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('box_v3');
  ToDoDaTaBase db = ToDoDaTaBase();

  bool isVietnamese = true;

  String translate(String text) {
    if (isVietnamese) return text;

    switch (text) {
      case 'Việc Cần Làm':
        return 'To-Do List';
      case 'Ngày':
        return 'Daily';
      case 'Tuần':
        return 'Weekly';
      case 'Tháng':
        return 'Monthly';
      case 'Năm':
        return 'Yearly';
      case 'Bỏ xem lịch sử':
        return 'Clear Date Filter';
      case 'Xem lịch sử theo ngày':
        return 'Select Date';
      case 'Đang xem công việc của ngày:':
        return 'Viewing tasks for date:';
      case 'Thêm Công Việc':
        return 'Add Task';
      case 'Phân Loại:':
        return 'Category:';
      case 'Lưu':
        return 'Save';
      case 'Hủy':
        return 'Cancel';
      case 'Cài đặt':
        return 'Settings';
      case 'Giới thiệu':
        return 'About Us';
      case 'Thông tin nhóm':
        return 'Group Information';
      case 'Tên nhóm:':
        return 'Group Name:';
      case 'Thành viên:':
        return 'Members:';
      default:
        return text;
    }
  }

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  final _controller = TextEditingController();
  String _selectedCategory = 'Ngày';
  String _currentFilter = 'Ngày';
  String? _selectedDateFilter;

  bool _isSameWeek(String date1, String date2) {
    try {
      List<String> p1 = date1.split('/');
      List<String> p2 = date2.split('/');
      DateTime d1 = DateTime(
        int.parse(p1[2]),
        int.parse(p1[1]),
        int.parse(p1[0]),
      );
      DateTime d2 = DateTime(
        int.parse(p2[2]),
        int.parse(p2[1]),
        int.parse(p2[0]),
      );

      DateTime monday1 = DateTime(d1.year, d1.month, d1.day - (d1.weekday - 1));
      DateTime monday2 = DateTime(d2.year, d2.month, d2.day - (d2.weekday - 1));

      return monday1 == monday2;
    } catch (e) {
      return false;
    }
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateData();
  }

  void saveNewTask() {
    String today = db.getToday();
    setState(() {
      db.toDoList.add([_controller.text, false, _selectedCategory, today]);
      _controller.clear();
      _selectedCategory = 'Ngày';
    });
    Navigator.of(context).pop();
    db.updateData();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DialogBox(
              controller: _controller,
              onSave: saveNewTask,
              onCancel: () {
                Navigator.of(context).pop();
                _controller.clear();
              },
              selectedCategory: _selectedCategory,
              onCategoryChanged: (String? newValue) {
                setStateDialog(() {
                  _selectedCategory = newValue!;
                });
              },
              translate: translate,
            );
          },
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: Text(translate('Việc Cần Làm')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.yellow,
        actions: [
          if (_selectedDateFilter != null)
            IconButton(
              icon: const Icon(Icons.event_busy, color: Colors.red),
              tooltip: translate('Bỏ xem lịch sử'),
              onPressed: () {
                setState(() {
                  _selectedDateFilter = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            tooltip: translate('Xem lịch sử theo ngày'),
            onPressed: () => _selectDate(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              dropdownColor: Colors.yellow[300],
              icon: const Icon(Icons.filter_list, color: Colors.black),
              value: _currentFilter,
              items: <String>['Ngày', 'Tuần', 'Tháng', 'Năm'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    translate(value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _currentFilter = newValue!;
                });
              },
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.black),
            tooltip: translate('Cài đặt'),
            color: Colors.yellow[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'language') {
                setState(() {
                  isVietnamese = !isVietnamese;
                });
              } else if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(translate: translate),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'language',
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        isVietnamese
                            ? 'Ngôn ngữ: 🇻🇳 VN'
                            : 'Language: 🇬🇧 EN',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'about',
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        translate('Giới thiệu'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_selectedDateFilter != null)
            Container(
              width: double.infinity,
              color: Colors.yellow[700],
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${translate('Đang xem công việc của ngày:')} $_selectedDateFilter",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: db.toDoList.length,
              itemBuilder: (context, index) {
                String taskName = db.toDoList[index][0];
                bool taskCompleted = db.toDoList[index][1];
                String taskCategory = db.toDoList[index][2];
                String taskDate = db.toDoList[index][3];

                bool isMatchCategory = taskCategory == _currentFilter;

                bool isMatchDate = true;
                if (_selectedDateFilter != null) {
                  if (taskCategory == 'Năm') {
                    isMatchDate =
                        taskDate.substring(6) ==
                        _selectedDateFilter!.substring(6);
                  } else if (taskCategory == 'Tháng') {
                    isMatchDate =
                        taskDate.substring(3) ==
                        _selectedDateFilter!.substring(3);
                  } else if (taskCategory == 'Tuần') {
                    isMatchDate = _isSameWeek(taskDate, _selectedDateFilter!);
                  } else {
                    isMatchDate = taskDate == _selectedDateFilter;
                  }
                }

                if (!isMatchCategory || !isMatchDate) {
                  return const SizedBox.shrink();
                }

                return ToDoTile(
                  taskName: taskName,
                  taskCompleted: taskCompleted,
                  taskCategory: translate(taskCategory),
                  taskDate: taskDate,
                  onChanged: (value) => checkBoxChanged(value, index),
                  deleteFunction: (context) => deleteTask(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
