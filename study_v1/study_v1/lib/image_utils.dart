import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:http/http.dart' as http;

class ReciptUpload extends StatefulWidget {
  const ReciptUpload({Key? key}) : super(key: key);
  static String routeName = "/recipt_upload";
  @override
  _ReciptUpload createState() => _ReciptUpload();
}

class _ReciptUpload extends State<ReciptUpload> {
  File? _image;
  final picker = ImagePicker();
  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      _image = File(image!.path);
    });
  }

  Widget showImage() {
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Center(
            child: _image == null
                ? Text('No Image Selected')
                : Image.file(File(_image!.path))));
  }

  Future<http.Response> UploadImage() async {
    var imageApiUrl = Uri.parse("https://2999-211-219-61-185.ngrok.io/upload");
    var request = http.MultipartRequest("POST", imageApiUrl);
    print(_image!.path
        .split('/')
        .last); // print the selected image name for debugging
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile(
      'image',
      _image!.readAsBytes().asStream(),
      _image!.lengthSync(),
      filename: _image!.path.split('/').last,
    ));
    request.headers.addAll(headers);
    print("request: " + request.toString());
    // await를 하기 위햐서는 async keywork를 함수에 적용해서 asynchronous함을 밝혀야 한다.
    var res = await request.send();
    print(res.statusCode);
    http.Response response = await http.Response.fromStream(res);
    return response;
  }

  openImageScanner(BuildContext context) async {
    var image = await DocumentScannerFlutter.launch(context, labelsConfig: {
      ScannerLabelsConfig.ANDROID_NEXT_BUTTON_LABEL: "Next Step",
      ScannerLabelsConfig.ANDROID_OK_LABEL: " OK"
    });
    if (image != null) {
      _image = image;
      // Upload(_scannedImage!); // since the imageFile must not be null, we should allow
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 새로 고침
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.blueGrey,
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // center box에 이미지를 보여줄수 있게
              SizedBox(height: 25.0),
              showImage(),
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // 카메라 촬영 버튼
                  FloatingActionButton(
                      child: Icon(Icons.add_a_photo),
                      tooltip: "Take a picture",
                      onPressed: () {
                        openImageScanner(context);
                      }),
                  // 서버로 이미지 전송하는 버튼
                  FloatingActionButton(
                      child: Icon(Icons.send),
                      tooltip: "Confirm This Image",
                      onPressed: () {
                        UploadImage();
                      }),

                  // 갤러리에서 이미지를 가져오는 버튼
                  FloatingActionButton(
                    child: Icon(Icons.wallpaper),
                    tooltip: "Pick Image",
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                  )
                ],
              )
            ])));
  }
}
