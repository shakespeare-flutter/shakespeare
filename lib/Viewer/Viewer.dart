
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:provider/provider.dart';
import 'package:shakespeare/SelectedBooks.dart';
import 'dart:async';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class Viewer extends StatefulWidget {
  const Viewer({Key? key, required this.openBookPath}) : super(key: key);
  final File openBookPath;


  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer>{
  late EpubController _epubReaderController;
  late String openedBook;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document:
      EpubDocument.openFile(widget.openBookPath),
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
    super.initState();
  }
  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubReaderController,
          builder: (chapterValue) =>
              Text(
                chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
                textAlign: TextAlign.start,
              ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_alt),
            color: Colors.white,
            onPressed: () => _showCurrentEpubCfi(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubReaderController),
      ),
      body: EpubView(
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: _epubReaderController,
      ),
    );
  }

    void _showCurrentEpubCfi(context) {
      final cfi = _epubReaderController.generateEpubCfi();

      if (cfi != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cfi),
            action: SnackBarAction(
              label: 'GO',
              onPressed: () {
                _epubReaderController.gotoEpubCfi(cfi);
              },
            ),
          ),
        );
      }
    }
  }


