import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatelessWidget {
  const PDFViewerPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final pdfURL = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PDFView(
        filePath: pdfURL,
      ),
    );
  }
}
