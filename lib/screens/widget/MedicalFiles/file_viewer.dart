// lib/screens/widget/MedicalFiles/file_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:open_file/open_file.dart';

class FileViewerPage extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerPage({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  _FileViewerPageState createState() => _FileViewerPageState();
}

class _FileViewerPageState extends State<FileViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      final bytes = response.bodyBytes;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.fileName}');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Error downloading file: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String extension = widget.fileName.split('.').last.toLowerCase();

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (localPath == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: const Center(child: Text('Failed to load file.')),
      );
    }

    if (['pdf'].contains(extension)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: PDFView(
          filePath: localPath!,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
        ),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      // Open DOC/DOCX with external application
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await OpenFile.open(localPath);
            },
            child: const Text('Open Document'),
          ),
        ),
      );
    } else if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Image.file(File(localPath!)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: const Center(child: Text('Cannot view this file type.')),
      );
    }
  }
}
