import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/CollageType.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_collage_widget/utils/CameraType.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'src/screens/collage_sample.dart';
import 'src/tranistions/fade_route_transition.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(my365()),
    blocObserver: AppBlocObserver(),
  );
}

// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }
}

class my365 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My 365',
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //late final CollageType collageType;
  String? type;

  var color = Colors.white;
  late final bool readOnly;
  bool _startLoading = false;
  final GlobalKey _screenshotKey = GlobalKey();
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  CollageSample? _CollageSample;

  @override
  void initState() {
    super.initState();
  }

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Center(
              child: Text('My365'),
            )),
        backgroundColor: Colors.blueGrey[200],
        body: SingleChildScrollView(
            child: Stack(children: [
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(35, 100, 35, 100),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    //shape: BoxShape.circle,
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(47, 141, 255, 1),
                    image: DecorationImage(
                        image: AssetImage('asset/image/app_icon_image.png'),
                        fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(height: 20.0),
                Column(children: [
                  TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          hintText: 'Supporting Image',
                          enabled: true,
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.camera_alt_rounded),
                              onPressed: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Column(children: <Widget>[
                                              RadioListTile(
                                                title: const Text("1 image"),
                                                value: "1image",
                                                groupValue: type,
                                                onChanged: (value) {
                                                  setState(() {
                                                    pushImageWidget(CollageType
                                                        .SingleSquare);
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text("2 images"),
                                                value: "2images",
                                                groupValue: type,
                                                onChanged: (value) {
                                                  setState(() {
                                                    pushImageWidget(
                                                        CollageType.VSplit);
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text("3 images"),
                                                value: "3images",
                                                groupValue: type,
                                                onChanged: (value) {
                                                  setState(() {
                                                    pushImageWidget(CollageType
                                                        .ThreeVertical);
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text("4 images"),
                                                value: "4images",
                                                groupValue: type,
                                                onChanged: (value) {
                                                  setState(() {
                                                    pushImageWidget(
                                                        CollageType.FourSquare);
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: const Text("6 images"),
                                                value: "6images",
                                                groupValue: type,
                                                onChanged: (value) {
                                                  setState(() {
                                                    pushImageWidget(
                                                        CollageType.SixSquare);
                                                  });
                                                },
                                              ),
                                            ]);
                                          },
                                        ),
                                      );
                                    });
                              })))
                ])
              ]))
        ])));
  }

  ///On click of perticular type of button show that type of widget
  pushImageWidget(CollageType type) async {
    await Navigator.of(context).push(
      FadeRouteTransition(page: CollageSample(type)),
    );
  }

  ///Used for capture screenshot
  void onSave() async {
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }

    if (isGranted) {
      String directory = (await getExternalStorageDirectory())!.path;
      String fileName = "${DateTime.now().microsecondsSinceEpoch}.png";
      _screenshotController.captureAndSave(directory, fileName: fileName);
    }
  }
}
