library image_collage_widget;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/collage_bloc.dart';
import 'blocs/collage_event.dart';
import 'blocs/collage_state.dart';
import 'utils/CollageType.dart';
import 'utils/permission_type.dart';
import 'widgets/row_widget.dart';

/// A ImageCollageWidget.
class ImageCollageWidget extends StatefulWidget {
  final String? filePath;
  final CollageType collageType;
  final bool withImage;

  const ImageCollageWidget({
    this.filePath,
    required this.collageType,
    required this.withImage,
  });

  @override
  State<StatefulWidget> createState() {
    return _ImageCollageWidget(filePath ?? '', collageType);
  }
}

class _ImageCollageWidget extends State<ImageCollageWidget>
    with WidgetsBindingObserver {
  late String _filePath;
  late CollageType _collageType;
  var _withImage = false;
  late CollageBloc _imageListBloc;

  _ImageCollageWidget(this._filePath, this._collageType);

  @override
  void initState() {
    super.initState();

    _withImage = widget.withImage;

    WidgetsBinding.instance.addObserver(this);
    _imageListBloc = CollageBloc(
        context: context, path: _filePath, collageType: _collageType);
    _imageListBloc.add(ImageListEvent(_imageListBloc.blankList()));
    _imageListBloc.add(ImageListEvent(_imageListBloc.blankList()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _imageListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _imageListBloc,
      child: BlocBuilder(
        bloc: _imageListBloc,
        builder: (context, CollageState state) {
          if (state is PermissionDeniedState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                      "To show images you have to allow storage permission."),
                  TextButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)))),
                    child: const Text("Allow"),
                    onPressed: () => _handlePermission(),
                  ),
                ],
              ),
            );
          }
          if (state is LoadImageState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is ImageListState) {
            return _gridView();
          }
          return Container(
            color: Colors.lightBlueAccent,
          );
        },
      ),
    );
  }

  void _handlePermission() {
    _imageListBloc.add(CheckPermissionEvent(true, PermissionType.Storage, 0));
  }

  Widget _gridView() {
    return AspectRatio(
      aspectRatio: 1.0 / 1.0,
      child: GridCollageWidget(_collageType, _imageListBloc, context),
    );
  }
}
