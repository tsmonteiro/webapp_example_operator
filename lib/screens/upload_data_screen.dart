import 'package:flutter/material.dart';

import 'package:webapp_components/screens/screen_base.dart';
import 'package:webapp_model/id_element.dart';
import 'package:webapp_model/webapp_data_base.dart';
import 'package:webapp_template/webapp_data.dart';
import 'package:webapp_ui_commons/mixin/progress_log.dart';

import 'package:webapp_components/components/upload_multi_file_component.dart';

class UploadDataScreen extends StatefulWidget {
  final WebAppData modelLayer;
  const UploadDataScreen(this.modelLayer, {super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen>
    with ScreenBase, ProgressDialog {
  @override
  String getScreenId() {
    return "UploadDataScreen";
  }

  @override
  void dispose() {
    super.dispose();
    disposeScreen();
  }

  @override
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    var uploadComponent = UploadFileComponent("uploadComp", getScreenId(), "Upload Files", 
          modelLayer.app.projectId, modelLayer.app.teamname);


    addComponent("default", uploadComponent);

    initScreen(widget.modelLayer as WebAppDataBase);
  }

  @override
  Widget build(BuildContext context) {
    return buildComponents(context);
  }
}
