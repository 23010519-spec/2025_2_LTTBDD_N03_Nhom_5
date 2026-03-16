import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String selectedCategory;
  final Function(String?) onCategoryChanged;
  final String Function(String) translate;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.translate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[300],
      content: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: translate('Thêm Công Việc'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translate('Phân Loại:'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: <String>['Ngày', 'Tuần', 'Tháng', 'Năm'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(translate(value)),
                    );
                  }).toList(),
                  onChanged: onCategoryChanged,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: onSave,
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                  child: Text(translate('Lưu')),
                ),
                const SizedBox(width: 8),
                MaterialButton(
                  onPressed: onCancel,
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                  child: Text(translate('Hủy')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
