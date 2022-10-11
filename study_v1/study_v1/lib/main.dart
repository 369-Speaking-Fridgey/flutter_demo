import 'dart:io';
import 'dart:ui';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'image_utils.dart';

void main() {
  runApp(MyApp());
}

// 이렇게 MyApp안에 모든 navigation을 하게 되면 올바르게 수행
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

//------Upload Single Files-------
Future<void> uploadFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    final filePath = result.files.single.path;
    var dio = Dio();
    var formData =
        FormData.fromMap({'file': await MultipartFile.fromFile(filePath!)});
    //(3) Upload
    final response = await dio.post('/upload', data: formData);
  } else {
    print("No File Selected");
  }
}

//-------Upload Multiple Files---------
Future<void> uploadFiles() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true);
  if (result != null) {
    final filePaths = result.paths;
    var dio = Dio();
    var formData = FormData.fromMap({
      'files': List.generate(filePaths.length,
          (index) => MultipartFile.fromFileSync(filePaths[index]!))
    });

    final response = await dio.post('/upload', data: formData);
  } else {
    print("No File Selected");
  }
}

class _HomePageState extends State<HomePage> {
  File? FilePickerResults;
  File? _scannedImage; // save the scanned recipt as an image
  openImageScan(BuildContext context) async {
    var image = await DocumentScannerFlutter.launch(context, labelsConfig: {
      ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Step",
      ScannerLabelsConfig.ANDROID_OK_LABEL: " OK"
    });
    if (image != null) {
      _scannedImage = image;
      // Upload(_scannedImage!); // since the imageFile must not be null, we should allow
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: const Text('Speaking Fridgey Recipt Scanning Demo')),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_scannedImage != null) ...[
                    Image.file(_scannedImage!,
                        width: 300, height: 600, fit: BoxFit.contain),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_scannedImage?.path ?? ''),
                    ),
                  ],
                  Center(
                    child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReciptUpload()));
                          },
                          child: const Text("Another Way to upload...")),
                      ElevatedButton(
                          onPressed: () => openImageScan(context),
                          child: Text("Recipt Scan")),
                      ElevatedButton(
                          onPressed: () => uploadFile(),
                          child: Text("Upload a Single File")),
                      ElevatedButton(
                          onPressed: () => uploadFiles(),
                          child: Text("Upload Multiple Files"))
                    ]),
                  )
                ])));
  }

  // <Recipt Scan> 이라고 적힌 버튼을 누르면 스캔하는 화면으로 이동하게 된다.
}

final routes = {ReciptUpload.routeName: (context) => ReciptUpload()};
