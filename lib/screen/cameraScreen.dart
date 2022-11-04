import 'dart:io';

import 'package:custom_camera_app/main.dart';
import 'package:custom_camera_app/screen/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraStarted = false;
  File? imageFile;
  bool showev = false;
  bool showzoom = false;
  double maxzoom = 1.0;
  double minzoom = 1.0;
  double currentZoom = 1.0;
  double minev = 1.0;
  double maxev = 1.0;
  double currentev = 1.0;
  Future<void> onSelectedCamera(CameraDescription cameraDescription) async {
    final previousController = controller;
    final CameraController newControlller = CameraController(
        cameraDescription, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg);
    await previousController?.dispose();
    if (mounted) {
      setState(() {
        controller = newControlller;
      });
    }
    newControlller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    try {
      await newControlller.initialize();
    } on CameraException catch (e) {
      print('cannot open camera');
    }
    newControlller.getMinZoomLevel().then((value) => minzoom = value);
    newControlller.getMaxZoomLevel().then((value) => maxzoom = value);
    newControlller.getMinExposureOffset().then((value) => minev = value);
    newControlller.getMaxExposureOffset().then((value) => maxev = value);
    if (mounted) {
      setState(() {
        isCameraStarted = controller!.value.isInitialized;
      });
    }

    print(minzoom);
    print(maxzoom);
    print('hi');
    print(minev);
    print('hello');
    print('object');
  }

  Future<XFile?> click() async {
    final CameraController? newCameracontroller = controller;
    if (newCameracontroller!.value.isTakingPicture) {
      return null;
    }
    try {
      XFile picture = await newCameracontroller.takePicture();
      print('clicked');
      return picture;
    } on CameraException catch (e) {
      print('can\'t capture picture');
    }
  }

  @override
  void initState() {
    onSelectedCamera(cameras[0]);
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AspectRatio(
  //       aspectRatio: controller!.value.aspectRatio,
  //       child: Stack(fit: StackFit.expand, children: [
  //         CameraPreview(controller!),
  //         cameraOverlay(padding: 50, aspectRatio: 1, color: Color(0x55000000))
  //       ]));
  // }

  // Widget cameraOverlay(
  //     {required double padding,
  //     required double aspectRatio,
  //     required Color color}) {
  //   return LayoutBuilder(builder: (context, constraints) {
  //     double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
  //     double horizontalPadding;
  //     double verticalPadding;

  //     if (parentAspectRatio < aspectRatio) {
  //       horizontalPadding = padding;
  //       verticalPadding = (constraints.maxHeight -
  //               ((constraints.maxWidth - 2 * padding) / aspectRatio)) /
  //           2;
  //     } else {
  //       verticalPadding = padding;
  //       horizontalPadding = (constraints.maxWidth -
  //           ((constraints.maxHeight - (2 * padding) - aspectRatio)) / 2);
  //     }
  //     return Stack(fit: StackFit.expand, children: [
  //       Align(
  //           alignment: Alignment.centerLeft,
  //           child: Container(width: horizontalPadding, color: color)),
  //       Align(
  //           alignment: Alignment.centerRight,
  //           child: Container(width: horizontalPadding, color: color)),
  //       Align(
  //           alignment: Alignment.topCenter,
  //           child: Container(
  //               margin: EdgeInsets.only(
  //                   left: horizontalPadding, right: horizontalPadding),
  //               height: verticalPadding,
  //               color: color)),
  //       Align(
  //           alignment: Alignment.bottomCenter,
  //           child: Container(
  //               margin: EdgeInsets.only(
  //                   left: horizontalPadding, right: horizontalPadding),
  //               height: verticalPadding,
  //               color: color)),
  //       Container(
  //         margin: EdgeInsets.symmetric(
  //             horizontal: horizontalPadding, vertical: verticalPadding),
  //         decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
  //       )
  //     ]);
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCameraStarted
          ? Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / controller!.value.aspectRatio,
                  // child: Stack(fit: StackFit.expand, children: [
                  //   CameraPreview(controller!),
                  //   cameraOverlay(
                  //       padding: 50, aspectRatio: 1, color: Color(0x55000000))
                  // ])
                  child: Stack(fit: StackFit.expand, children: [
                    controller!.buildPreview(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 100),
                      child: CustomWidget(),
                    )
                  ]),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        showzoom
                            ? Slider(
                                value: currentZoom,
                                min: minzoom,
                                max: maxzoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    currentZoom = value;
                                    print(currentZoom);
                                  });
                                  await controller?.setZoomLevel(value);
                                },
                              )
                            : Container(),
                        showev
                            ? Slider(
                                value: currentev,
                                min: minev,
                                max: maxev,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    currentev = value;
                                    print(currentev);
                                  });
                                  await controller?.setExposureOffset(value);
                                },
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    showzoom = !showzoom;
                                    showev = false;
                                  });
                                },
                                child: Text(
                                  'Zoom',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    showev = !showev;
                                    showzoom = false;
                                  });
                                },
                                child: Text(
                                  'EV',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                            ),
                            InkWell(
                                onTap: () async {
                                  XFile? rawImage = await click();
                                  imageFile = File(rawImage!.path);
                                  int currentUnix =
                                      DateTime.now().millisecondsSinceEpoch;
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  String fileFormat =
                                      imageFile!.path.split('.').last;
                                  await imageFile!.copy(
                                    '${directory.path}/$currentUnix.$fileFormat',
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.circle_outlined,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                )),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                // image: DecorationImage(
                                //   image: FileImage(imageFile!),
                                //   fit: BoxFit.cover,
                                // ),
                                image: imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            )
                          ],
                        ),
                      ]),
                )
              ],
            )
          : Container(),
    );
  }
}
// Widget cameraOverlay({double padding, double aspectRatio, Color color}) {
//     return LayoutBuilder(builder: (context, constraints) {
//       double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
//       double horizontalPadding;
//       double verticalPadding;

//       if (parentAspectRatio < aspectRatio) {
//         horizontalPadding = padding;
//         verticalPadding = (constraints.maxHeight -
//                 ((constraints.maxWidth - 2 * padding) / aspectRatio)) /
//             2;
//       } else {
//         verticalPadding = padding;
//         horizontalPadding = (constraints.maxWidth -
//                 ((constraints.maxHeight - 2  )  aspectRatio)) /
//             2;
//       }
//       return Stack(fit: StackFit.expand, children: [
//         Align(
//             alignment: Alignment.centerLeft,
//             child: Container(width: horizontalPadding, color: color)),
//         Align(
//             alignment: Alignment.centerRight,
//             child: Container(width: horizontalPadding, color: color)),
//         Align(
//             alignment: Alignment.topCenter,
//             child: Container(
//                 margin: EdgeInsets.only(
//                     left: horizontalPadding, right: horizontalPadding),
//                 height: verticalPadding,
//                 color: color)),
//         Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//                 margin: EdgeInsets.only(
//                     left: horizontalPadding, right: horizontalPadding),
//                 height: verticalPadding,
//                 color: color)),
//         Container(
//           margin: EdgeInsets.symmetric(
//               horizontal: horizontalPadding, vertical: verticalPadding),
//           decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
//         )
//       ]);
//     });
//   }
