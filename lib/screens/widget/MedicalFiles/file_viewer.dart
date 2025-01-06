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
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

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

    // Determine file extension
    String extension = widget.fileName.split('.').last.toLowerCase();

    // Handle DOC / DOCX by opening via OpenFile
    if (['doc', 'docx'].contains(extension)) {
      OpenFile.open(localPath!);
      return const Scaffold(
        body: Center(child: Text('Opening file ...')),
      );
    }

    // Handle PDF (use flutter_pdfview)
    if (extension == 'pdf') {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: PDFView(
          filePath: localPath!,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
        ),
      );
    }

    // Handle images
    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.fileName)),
        body: Image.file(File(localPath!)),
      );
    }

    // Handle TXT files: read the file as text, display in a scrollable text widget
    if (extension == 'txt') {
      return FutureBuilder<String>(
        future: File(localPath!).readAsString(), // read the text
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.fileName)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.fileName)),
              body: Center(
                  child: Text('Error reading text file: ${snapshot.error}')),
            );
          }
          final textContent = snapshot.data ?? "No text found.";
          return Scaffold(
            appBar: AppBar(title: Text(widget.fileName)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(textContent),
            ),
          );
        },
      );
    }

    // If none matched, fallback
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: const Center(child: Text('Cannot view this file type.')),
    );
  }
}
