import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Container(
            child: _image == null ? null : new DragImage(Offset(0.0, 0.0), _image),
          ),
          new Positioned(
            bottom: 15.0,
            left: 15.0,
            child: new FloatingActionButton(
              onPressed: _initGallery,
              child: new Icon(Icons.collections),
            ),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _initCamera,
        child: new Icon(Icons.camera_alt),
      ),
    );
  }

  void _initCamera() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void _initGallery() async {
    File gallery = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (gallery != null) {
      setState(() {
        _image = gallery;
      });
    }
  }
}

class DragImage extends StatefulWidget {
  final Offset position;
  final File image;

  DragImage(this.position, this.image);

  @override
  DragImageState createState() => DragImageState();
}

class DragImageState extends State<DragImage> {
  double _zoom;
  double _previousZoom;
  Offset _previousOffset;
  Offset _offset;
  Offset _position;
  File _image;

  @override
  void initState() {
    _zoom = 1.0;
    _previousZoom = null;
    _offset = Offset.zero;
    _position = widget.position;
    _image = widget.image;
    super.initState();
  }

  @override
    void didUpdateWidget(DragImage oldWidget) {
      setState(() {
              _image = widget.image;
            });
      super.didUpdateWidget(oldWidget);
    }

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        child: new Container(
          padding: const EdgeInsets.all(10.0),
          width: 350.0,
          height: 450.0,
          child: new GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            onDoubleTap: _handleScaleReset,
            child: new Transform(
              transform: new Matrix4.diagonal3(
                  new vector.Vector3(_zoom, _zoom, _zoom)),
              alignment: FractionalOffset.center,
              child: new Image.file(_image),
            ),
          ),
        ),
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            _position = offset;
          });
        },
        feedback: Container(
          width: 100.0,
          height: 100.0,
          child: new Image.file(_image),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails start) {
    setState(() {
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails update) {
    setState(() {
      _zoom = _previousZoom * update.scale;
    });
  }

  void _handleScaleReset() {
    setState(() {
      _zoom = 1.0;
      _offset = Offset.zero;
      _position = Offset.zero;
    });
  }

  void _handleScaleEnd(ScaleEndDetails end) {
    _previousZoom = null;
  }
}
