import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webapp_template/tmp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:webapp_components/abstract/multi_value_component.dart';
import 'package:webapp_components/definitions/component.dart';
import 'package:webapp_components/mixins/component_base.dart';
import 'package:webapp_model/id_element.dart';
import 'package:webapp_ui_commons/mixin/progress_log.dart';
import 'package:webapp_ui_commons/styles/styles.dart';
import 'package:webapp_utils/services/file_data_service.dart';

import 'dart:typed_data';
import 'package:sci_tercen_client/sci_client_service_factory.dart' as tercen;
import 'package:sci_tercen_client/sci_client.dart';


class UploadTableComponent extends UploadFileComponent2 {
  UploadTableComponent(super.id, super.groupId, super.componentLabel, super.projectId, super.fileOwner);

  @override
  Future<void> doUpload(BuildContext context) async{
    openDialog(context);
    log("File upload in progress. Please wait.", dialogTitle: "File Uploading");
    
    var fileService = FileDataService();

    for( int i = 0; i < htmlFileList.length; i++ ){
      
      DropzoneFileInterface file = htmlFileList[i];
      

      log("Uploading ${file.name}", dialogTitle: "File Uploading");
      var bytes = await dvController.getFileData(file);
      var fileId = await uploadFile(file.name, projectId, fileOwner, bytes, folderId: folderId);
      uploadedFiles.add(IdElement(fileId, file.name));
    }

    for( int i = 0; i < platformFileList.length; i++ ){
      PlatformFile file = platformFileList[i];
      var bytes = file.bytes!;
      log("Uploading ${file.name}", dialogTitle: "File Uploading");

      var fileId = await uploadFile(file.name, projectId, fileOwner, bytes, folderId: folderId);
      uploadedFiles.add(IdElement(fileId, file.name));
    }


    closeLog();

  }

    Future<String> uploadFile(String filename, String projectId, String owner, Uint8List data, {String folderId = ""} ) async {
    var factory = tercen.ServiceFactory();

    var metadata = CSVFileMetadata()
      ..separator = '\t'
      ..quote = '"'
      ..contentType = 'text/csv'
      ..contentEncoding = utf8.name;


    var docToUpload = FileDocument()
        ..name = filename
        ..projectId = projectId
        ..folderId = folderId
        ..acl.owner = owner
        ..metadata = metadata;



    var file = await factory.fileService.upload(docToUpload, Stream.fromIterable([data]) );


    var parserParams = CSVParserParam()
    ..separator = ","
    ..quote = '"'
    ..hasHeaders = true
    ..encoding = utf8.name;
    

    var csvTask = CSVTask()
    ..fileDocumentId = file.id
    ..projectId = projectId
    ..owner = file.acl.owner
    ..params = parserParams
    ..state = InitState();

    csvTask =
        await factory.taskService.create(csvTask) as CSVTask;


    var stream = taskStream(csvTask.id);


    await for (var _ in stream) {
      // ...
    }


    return file.id;

  }

  Stream<TaskEvent> taskStream(String taskId) async* {
    var factory = tercen.ServiceFactory();
    bool startTask = true;
    var task = await factory.taskService.get(taskId);

    while (!task.state.isFinal) {
      var taskStream = factory.eventService
          .listenTaskChannel(taskId, startTask)
          .asBroadcastStream();

      startTask = false;
      await for (var evt in taskStream) {
        yield evt;
      }
      task = await factory.taskService.get(taskId);

    }

  }

}