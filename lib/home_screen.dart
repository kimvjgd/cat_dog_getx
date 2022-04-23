import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 1,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output!;
      _loading = false;
    });
  }

  captureImagePhoneCamera() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image);
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text('Cats & Dogs Detector Application GetX'),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: _loading
                  ? Container(
                      width: 350,
                      child: Column(
                        children: [
                          Image.asset('assets/background.png'),
                          SizedBox(
                            height: 47.0,
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 280,
                            child: Image.file(_image),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                          _output != null
                              ? Text(
                                  '${_output[0]['label']}',
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                )
                              : Container(),
                          SizedBox(
                            height: 22,
                          )
                        ],
                      ),
                    ),
            ),
            Container(
              width: Get.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      captureImagePhoneCamera();
                    },
                    child: Container(
                      width: Get.width - 250,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      pickGalleryImage();
                    },
                    child: Container(
                      width: Get.width - 250,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
