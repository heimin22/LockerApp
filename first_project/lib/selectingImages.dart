import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:first_project/hiddenImages.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_manager/photo_manager.dart';

class selectingImagesHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(fontFamily: 'ProductSans'),
      home: SelectingImagesScreen(),
    );
  }
}

class SelectingImagesScreen extends StatefulWidget {
  @override
  selectingImages createState() => selectingImages();
}

class selectingImages extends State<SelectingImagesScreen>
    with WidgetsBindingObserver {
  List<AssetEntity> images = [];
  List<AssetPathEntity> albums = [];
  AssetPathEntity? selectedAlbum;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    WidgetsBinding.instance
        .addObserver(this); // Start observing lifecycle changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in background or exited
      SystemNavigator.pop(); // Kills the app
    }
  }

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      await loadAlbums();
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => hiddenImagesHome()));
      Fluttertoast.showToast(
        msg: 'Permissions are required to access and manage files.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white70,
        fontSize: 12.0,
      );
    }
  }

  Future<void> loadAlbums() async {
    setState(() {
      isLoading = true;
    });
    final albumList =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    setState(() {
      albums = albumList;
      selectedAlbum = albums.isNotEmpty ? albums.first : null;
    });
    if (selectedAlbum != null) {
      loadImages(selectedAlbum!);
    }
  }

  Future<void> loadImages(AssetPathEntity album) async {
    setState(() {
      isLoading = true;
    });
    // final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;
    final assetCount = await recentAlbum.assetCountAsync;
    final recentImages =
        await recentAlbum.getAssetListRange(start: 0, end: assetCount);
    setState(() {
      images = recentImages;
      isLoading = false;
    });
  }

  void onAlbumChanged(AssetPathEntity? album) {
    if (album != null) {
      setState(() {
        selectedAlbum = album;
        images.clear();
      });
      loadImages(album);
    }
  }

  void hideSelectedImages(List<AssetEntity> selectedImages) async {
    setState(() {
      images.removeWhere((image) => selectedImages.contains(image));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => hiddenImagesHome()));
          },
        ),
        title: Text('Select Images to Hide'),
        actions: [
          if (albums.isNotEmpty)
            DropdownButton<AssetPathEntity>(
              value: selectedAlbum,
              items: albums.map((album) {
                return DropdownMenuItem(
                  value: album,
                  child: Text(album.name),
                );
              }).toList(),
              onChanged: onAlbumChanged,
            ),
        ],
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: images.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    hideSelectedImages([images[index]]);
                  },
                  child: FutureBuilder<Widget>(
                    future: images[index]
                        .thumbnailDataWithSize(ThumbnailSize(200, 200))
                        .then((data) {
                      return data != null
                          ? Image.memory(data, fit: BoxFit.cover)
                          : Container();
                    }),
                    builder: (context, snapshot) {
                      return snapshot.data ?? Container(color: Colors.grey);
                    },
                  ),
                );
              },
            ),
    );
  }
}
