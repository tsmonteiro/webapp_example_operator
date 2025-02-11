## WebApp Creation Tutorial

WebApp are bespoke user interfaces built on top of Tercen's flexible server capabilities. These UI's provide a way to group or grant easy access to common use cases, increasing productivity and reducing user training time.

This tutorial will guide in the creation of your first WebApp: the **UMAP report app**. We will start by covering the use case, briefly how this is achieved typically in Tercen and how the WebApp can change the way the user interacts with Tercen.

### 1. UMAP Report App

Our tutorial use case has four steps:

1. Upload some data
2. Perform cluster analysis using UMAP
3. Check the output 
4. Download a PDF with images of interest

You can download the sample data used in the tutorial from this repository [github.com/data].

##### 1.1. Sample Data Description

TODO

### 2. The Standard Method

If you already know how to do all steps in Tercen, you can skip straight to section 3 [REF], otherwise let's see how to do this. You can also refer to the Developer's Guide [REF] for a detailed view on how to take advantage of Tercen's full functionality.

##### 2.1. Project Setup

[TODO]
DESCRIBE ACTUALLY IMPORTING THE WORKFLOW!
_Importing the Workflow_

A detailed overview on how to import <code>Workflow</code> GitHub repositories is described here [REF]. In this tutorial, we will need to import [the example UMAP workflow](https://github.com/tercen/webapp_tutorial_workflow) into our library.

This workflow has 4 steps:

1. The table step to which we will link our sample data
2. The UMAP step, which runs the UMAP operator on the data
3. & 4. Are visualizations of the resulting UMAP. We will use them to inspect and download images of interest.

[IMG_01 - Workflow]

##### 2.2. Running the Workflow

Now we select the TABLE Step and press run. A prompt appears asking us to select a file. We choose the file we uplaoded earlier and press Next. Although not mandatory, it is better to save our workflow now, in case we accidentally reload the page.

Next, we double click on the UMAP step to build our projection. We will set a standard projection with two channels. You may got to [REF] to check how projections are defined in Tercen. Here is how your projection should look.

[DESCRIBE PROJECTION]

Once we finish setting up our projection we can run the UMAP actually calculation by pressing on the run button. After a few moments, the screen will update and show us a table with the calculated UMAP projections.

DESCRIBE PLOTS

##### 2.3. Saving the Images

TODO

##### 2.3. Scaling

If we want to keep every workflow executed -- and the generated images -- we would need to execute these steps for every new dataset we want to analyze. That is fine if we don't do that very often. In a scenario of multiple runs per day, or multiple users, the overhead can become noticeable.

One solution to this overhead is to do as much as possible inside the operator (see HERE about developing your own operators). Fore more complex analyses, this can make workflows harder to understand and audit in the long run.

A second solution is to develop an UI handles a lot of functionality "behid the scenes", leaving the users free to focus on the analyses and results. That is exactly what WebApps do.


### 3. Developing a WebApp

This is the main section in our tutorial. Here, we will learn how to code a custom UI to run the steps described in section 2.

**NOTE:** This tutorial assumes that the Flutter SDK is correctly installed.

**NOTE 2:** We use VS Code as the development environment in this tutorial. 

##### 3.1. Repository Setup

The first step is to create a Github repository that will contain our WebApp code. Tercen provides a template for that. Select the <code>tercen/webapp_template</code> template, set the new repository to public and click on <code>Create repository</code>.
<p>
<img src="imgs/003_RepoCreateA.png" alt="drawing" width="500" title="Somethin"/></br>
<em>Repository creation. Select <code>tercen/webapp_template</code> as the template (1). Although private repositories are supported, for the sake of simplicity, we will create a public one for this tutorial (2).</em>
</p>

Next, clone the project and in its root project run <code>flutter pub get</code> to ensure that all dependencies are satisfied.

###### 3.1.1. Overview of the WebApp project files

The project comes with a number of folders and files that we will become familiar as the tutorial goes on. For now, it suffices to know that we will create our screens under the <code>lib/screens</code> folder and register them in the <code>main.dart</code> file. 

<p>
<img src="imgs/004_Files.png" alt="drawing" width="300" title="Somethin"/></br>
<em>File structure of a recently created WebApp project.</em>
</p>

###### 3.1.2. Tercen Components

Tercen provides a [webapp development library](https://github.com/tercen/webapp_lib). It contains a number of functions to interact with Workflows, Projects and Users. It also wraps commonly used Widget in what we call **Components**.

**Components** have two main roles:
1. Provide reusable code so it becomes easy to add Widgets like text input or tables to your screens.

2. Integrates these Widgets with the overall WebApp architecture, automatically handling layout placement, state saving and providing a framework for interaction with the data layer.


##### 3.2. Running the WebApp

Before developing our code, let's first see how do we run our WebApp. 

###### 3.2.1 Running from the Library

The standard method of running a WebApp is by pressing the **Run** button after installing the WebApp in the library. Before doing that, however, we need to build the project.

In the root folder of the project, run the <code>flutter build web</code> command. One this is done, go into the **build/web** folder and open the <code>index.html</code>. Remove the <code>\<base href="/"\></code> line. This line interferes with how Tercen serves up WebApp pages, so if it is not removed, your WebApp will not be displayed.

<p>
<img src="imgs/006_indexA.png" alt="drawing" width="450" title="Somethin"/></br>
<em>Line to be removed before commiting the build to Github.</em>
</p>

Push the build changes to Github and install the WebApp as you would install any operator (REF To dev guide).


###### 3.2.2 Running from the VS-Code

TODO


##### 3.3. The Upload Data Screen

_The Upload Screen Screen_

The first functionality we want to add to our Web App is the ability to upload tables into our project using a Tercen component. Let's create a file called <code>lib/screens/upload_data_screen.dart</code> containing the code from <code>base_screen_snippet.dart</code>. 

```dart
// [...] Imports


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

    // ....

    // Component code goes here

    // ...
    initScreen(widget.modelLayer as WebAppDataBase);
  }

  @override
  Widget build(BuildContext context) {
    return buildComponents(context);
  }
}

```

Then, we insert the components we want to see on our screen. In this case, we simply need the <code>UploadTableComponent</code>.

```dart
    var uploadComponent = UploadTableComponent("uploadComp", getScreenId(), "Upload Files", 
          widget.modelLayer.app.projectId, widget.modelLayer.app.teamname);


    addComponent("default", uploadComponent);
```

That's all we need for the screen. Now, we just need to have a navigation entry to reach it. To do that, we simply point to our screen near the end of the function.


_Navigation Menu Entry_

We add the navigation in the <code>initState</code> function of <code>main.dart</code> file. 


```dart
    //The project screen
    app.addNavigationPage(
          "Project", ProjectScreen(appData, key: app.getKey("Project")));
    
    // Our new Upload Data Screen goes here!
    app.addNavigationPage(
          "Data Upload", UploadDataScreen(appData, key: app.getKey("UploadData")));
```

And that's it. We are ready to see our screen in action. We can now rebuild the project and check how it looks in action. Don't forget to remove the **base** tag from the <code>index.html</code> file before committing the changes.

###### 3.3.1. Linking a WebApp to a Workflow Template

We are going to add a different type of component to our screen: an <code>ActionComponent</code>. The <code>ActionComponent</code> adds a button that can invoke asynchronous computations. In our case, we want to run the <code>Workflow</code> we imported in section 2.1 [REF].

_Configuring the Workflow in the WebApp_

The WebApp needs a to know how it can access workflow templates from the library. Create a new file called <code>repos.json</code> under the <code>assets</code> folder and copy the following into it:

[TODO] This workflow will be different
```JSON
{
    "repos":[
        {
            "iid":"train_model",
            "name":"Kumo train model",
            "url":"https://github.com/tercen/kumo_train_model_workflow",
            "version":"0.10.2"
        }
    ]
}
```
Next, we tell the WebApp to load this information. First, we add this file to Flutter's pubspec file so it is loaded.

```YAML
flutter:
  uses-material-design: true

  assets:
    - assets/img/logo.png
    - assets/img/wait.webp
    - assets/repos.json
```

Finally, we read this information into the WebApp during initialization in the <code>main.dart</code> file. In the <code>initSession</code> function, we update the <code>appData.init</code> function call from

```dart
await appData.init(app.projectId, app.projectName, app.username);
```
to

```dart
await appData.init(app.projectId, app.projectName, app.username, 
    reposJsonPath:"assets/repos.json");
```

_Adding the ActionComponent_

We are ready to add a button in our screen that will run this <code>Workflow</code>.

###### 3.3.2. Adding the ActionComponent

Adding an <code>ActionComponent</code> to a screen is similar to a adding a standard <code>Component</code>. We create a <code>ButtonActionComponent</code> in the <code>init</code> function of our upload screen and add it to the action component list handled by the <code>ScreenBase</code>.

```dart
var runWorkflowBtn = ButtonActionComponent(
    "runWorkflow", "Run Analysis", _runUmap);

addActionComponent( runWorkflowBtn);

initScreen(widget.modelLayer as WebAppDataBase);
```

The <code>ButtonActionComponent</code> requires an ID, a label and the asynchronous function that will be called when the button is clicked. 

```dart
Future<void> _runUmap() async {
    
}
```

###### 3.3.3. The WorkflowRunner

The <code>Workflow</code> system in Tercen is powerful and highly flexible. The <code>WorkflowRunner</code> is a utility layer which handles the most common interactions a WebApp has with <code>Workflows</code>. Let's see step-by-step what we need to run our UMAP <code>Workflow</code>.

_Getting the Input Data_

We start by grabbing the data we uploaded from the <code>UploadTableComponent</code>. The <code>ScreenBase</code> provides a <code>getComponent</code> method that retrieves a <code>Component</code> based on its ID. Since we can upload multiple files at once, our component is a <code>MultiValueComponent</code>.

```dart
var filesComponent = getComponent("uploadComp", groupId: getScreenId()) as MultiValueComponent;

var uploadedFiles = filesComponent.getValue();

for( var uploadedFile in uploadedFiles ){
    // Setup and run the workflow
    
    // ...
}
```

The <code>getValue</code> function returns a list of <code>IdElement</code> objects, containing the uploaded files' id and name.

_Configuring the WorkflowRunner_

We create the <code>WorkflowRunner</code> object by passing the project ID, owner Id and the <code>Workflow</code> iid, as described in the <code>repos.json</code> file.

```dart
WorkflowRunner runner = WorkflowRunner(
        widget.modelLayer.project.id,
        widget.modelLayer.teamname.id,
        widget.modelLayer.getWorkflow("umap"));
```

We must link the ID of the files we updated to the <code>TableStep</code> of the <code>Workflow</code>.


##### 3.4. The Report Screen

###### 3.4.1. Mapping Workflow Steps






