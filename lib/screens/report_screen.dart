import 'package:flutter/material.dart';

import 'package:webapp_components/screens/screen_base.dart';
import 'package:webapp_template/webapp_data.dart';
import 'package:webapp_model/webapp_data_base.dart';

import 'package:webapp_ui_commons/mixin/progress_log.dart';

import 'package:webapp_components/abstract/multi_value_component.dart';
import 'package:webapp_components/components/leaf_selectable_list.dart';
import 'package:webapp_components/components/image_list_component.dart';
import 'package:webapp_ui_commons/mixin/progress_log.dart';
import 'package:webapp_components/action_components/button_component.dart';
import 'package:webapp_model/id_element_table.dart';
import 'package:webapp_model/id_element.dart';



class ReportScreen extends StatefulWidget {
  final WebAppData modelLayer;
  const ReportScreen(this.modelLayer, {super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with ScreenBase, ProgressDialog {
  final List<String> plotStepIds = ["7aa6de32-4e47-4f25-bbca-c297c546247f", "ed6a57dd-34c6-4963-9f13-a3dac9481fc2"];

  @override
  String getScreenId() {
    return "ReportScreen";
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

    var imageSelectComponent = LeafSelectableListComponent("imageSelect", getScreenId(), "Analyses List", ["workflow", "image"], _fetchWorkflows, multi: true);
    addComponent("default", imageSelectComponent);


    var imageListComponent = ImageListComponent("imageList", getScreenId(), "Images",  _fetchWorkflowImages );
    imageListComponent.addParent(imageSelectComponent);
    addComponent("default", imageListComponent);

    // var downloadBtn = ButtonActionComponent(
        // "doDownload", "Download", _doDownload);

    // addActionComponent( downloadBtn);

    initScreen(widget.modelLayer as WebAppDataBase);
  }

  Future<IdElementTable> _fetchWorkflows( List<String> parentKeys, String groupId ) async {
    var workflows = await widget.modelLayer.fetchProjectWorkflows(widget.modelLayer.project.id);

    List<IdElement> workflowCol = [];
    List<IdElement> imageCol = [];

    for( var w in workflows ){
      var plotSteps = w.steps.where((e) => plotStepIds.contains(e.id)).toList();
      for( var ps in plotSteps ){
        workflowCol.add(IdElement(w.id, w.name));
        imageCol.add(IdElement(ps.id, ps.name));
      }
    }
    var tbl = IdElementTable()
      ..addColumn("workflow", data: workflowCol)
      ..addColumn("image", data: imageCol);

    return tbl;
  }

  Future<IdElementTable> _fetchWorkflowImages(List<String> parentKeys, String groupId) async {
    var comp = getComponent("imageSelect") as LeafSelectableListComponent;
    var selectedTable = comp.getValueAsTable();


    return await widget.modelLayer.workflowService.fetchImageData(selectedTable);
  }

  @override
  Widget build(BuildContext context) {
    return buildComponents(context);
  }
}
