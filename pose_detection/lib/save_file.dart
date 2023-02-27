// create a dialog box page that asks the user to enter a name for the file and then save the file to the downloads folder

import 'dart:io';
import 'dart:ui';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'mainscreen.dart';

class SaveFile extends StatefulWidget {
  const SaveFile({Key? key}) : super(key: key);

  @override
  _SaveFileState createState() => _SaveFileState();
}

class _SaveFileState extends State<SaveFile> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _fileName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save File'),
      ),
      body: Form(
          key: _formKey,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a file name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a file name';
                    }
                    return null;
                  },
                ),
                Padding(padding: const EdgeInsets.only(top: 10.0)),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _fileName = _controller.text;
                      // create a file with the name entered by the user
                      final String path =
                          await ExternalPath.getExternalStoragePublicDirectory(
                              ExternalPath.DIRECTORY_DOWNLOADS);
                      final String filepath =
                          '$path/' + _controller.text.toString() + '.csv';
                      final file = File(filepath);
                      // save the file to the downloads folder
                      file.writeAsString('Hello World');
                      // show snack bar
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'New file created Internal_Storage/Download/' +
                                  _controller.text.toString() +
                                  '.csv')));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PoseDetectorView(_fileName!)));
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ))),
    );
  }
}
