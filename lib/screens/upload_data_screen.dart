import 'package:flutter/material.dart';

import 'package:webapp_components/screens/screen_base.dart';
import 'package:webapp_components/action_components/button_component.dart';
import 'package:webapp_template/tmp2.dart';
import 'package:webapp_template/webapp_data.dart';
import 'package:webapp_model/webapp_data_base.dart';

import 'package:webapp_ui_commons/mixin/progress_log.dart';
import 'package:webapp_components/abstract/multi_value_component.dart';
import 'package:webapp_workflow/runners/workflow_runner.dart';



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

    var uploadComponent = UploadTableComponent("uploadComp", getScreenId(), "Upload Files", 
          widget.modelLayer.app.projectId, widget.modelLayer.app.teamname);


    addComponent("default", uploadComponent);

    var runWorkflowBtn = ButtonActionComponent(
        "runWorkflow", "Run Analysis", _runUmap);

    addActionComponent( runWorkflowBtn);

    initScreen(widget.modelLayer as WebAppDataBase);
  }

  Future<void> _runUmap() async {
    openDialog(context);
    log("Running Workflow, please wait.");
    var filesComponent = getComponent("uploadComp", groupId: getScreenId()) as MultiValueComponent;

    var uploadedFiles = filesComponent.getValue();

    for( var uploadedFile in uploadedFiles ){
      WorkflowRunner runner = WorkflowRunner(
        widget.modelLayer.project.id,
        widget.modelLayer.teamname.id,
        widget.modelLayer.getWorkflow("umap_workflow"));

      //TODO
      //Will likely need a function to better interact with tables
      runner.addTableDocument("f4d5e14a-6d75-4d44-ad77-7ae106bd9fb0", uploadedFile.id);

      runner.addPostRun( widget.modelLayer.reloadProjectFiles );
      await runner.doRun(context);

    }
    closeLog();

  }

  @override
  Widget build(BuildContext context) {
    return buildComponents(context);
  }
}
