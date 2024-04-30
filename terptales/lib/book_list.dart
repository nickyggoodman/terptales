import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

// ADDED BY SHAY
enum FilterOption { Alphabetical, Chronological, DateAdded }

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}


class Bookmark {
  final String pdfPath;
  final int pageNum;

  Bookmark({required this.pdfPath, required this.pageNum});
}

// going off of the example from https://pub.dev/packages/flutter_pdfview/example
class _BookListState extends State<BookList> {

  late PdfPageImage mythumbnail;
  
  List<String> bookUrls = [];
  List<PdfPageImage> thumbnails = [];
  List<Bookmark> bookmarks = []; // ADDED BY SHAY
  // using library of congress collection: https://www.loc.gov/collections/open-access-books/about-this-collection/rights-and-access/
  List<String> pdfUrls = [
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/64/80/2020716480/2020716480.pdf",
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/97/07/2020719707/2020719707.pdf",
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/99/65/2020719965/2020719965.pdf",
  ];

  @override
  void initState() {
    super.initState();
    loadPdfAssets();
    generatePdfThumbnail('assets/cmdline.pdf');
  }


  // LOADS THUMBNAILS  
  // do what espresso3389 spells.
  // SEE: https://pub.dev/documentation/pdf_render/latest/ "PDF rendering APIs"
  // perhaps use the suggestion here: https://stackoverflow.com/questions/65837703/getting-futureimage-cant-be-assigned-to-a-variable-of-type-image-in-this
  Future<void> generatePdfThumbnail(String pdfAssetPath) async {
    
    // Get list of all assets
    final assetBundle = DefaultAssetBundle.of(context);
    final assetList = await assetBundle.load('AssetManifest.json');
    final manifestMap = json.decode(utf8.decode(assetList.buffer.asUint8List()));
    final assets = manifestMap.keys.where((String key) => key.contains('.pdf'));

    // FOR FILES IN ./assets
    for (var asset in assets) {
      try {

        // Open the PDF document from the asset
        final PdfDocument doc = await PdfDocument.openAsset(asset);

        // The first page is 1
        final PdfPage page = await doc.getPage(1);

        // Render the page as an image
        final PdfPageImage pageImage = await page.render();

        // Generate dart:ui.Image cache for later use by imageIfAvailable
        await pageImage.createImageIfNotAvailable();

        setState(() {
          thumbnails.add(pageImage);
        });

        doc.dispose();

        // PDFDocument must be disposed as soon as possible
        // 

        // // Return the raw RGBA data of the rendered page image
        // // https://pub.dev/documentation/pdf_render/latest/pdf_render/PdfPageImage-class.html
        // // use raw image? https://api.flutter.dev/flutter/widgets/RawImage-class.html
        // return pageImage.pixels;

      } catch (e) {
        print('Error generating PDF thumbnail: $e');
        // return null;
      }
    }

    // FOR PDFS LOADED FROM THE WEB
    for (var url in pdfUrls) {
      try {

        //
        final pdfFile2 = await createFileOfPdfUrl(url);

        // Open the PDF document from the File
        final PdfDocument doc = await PdfDocument.openFile(pdfFile2.path);

        // The first page is 1
        final PdfPage page = await doc.getPage(1);

        // Render the page as an image
        final PdfPageImage pageImage = await page.render();

        // Generate dart:ui.Image cache for later use by imageIfAvailable
        await pageImage.createImageIfNotAvailable();

        setState(() {
          thumbnails.add(pageImage);
        });

        doc.dispose();

      } catch (e) {
        print('Error generating PDF thumbnail: $e');
        // return null;
      }
    }
  }



  // NEW
  Future<File> createFileOfPdfUrl(String pdfurl) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = pdfurl;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }



  // adds the current location of the pdf file from assets in the device
  // adds them all to bookUrls
  Future<void> loadPdfAssets() async {
    try {
      // Get list of all assets
      final assetBundle = DefaultAssetBundle.of(context);
      final assetList = await assetBundle.load('AssetManifest.json');
      final manifestMap = json.decode(utf8.decode(assetList.buffer.asUint8List()));
      final assets = manifestMap.keys.where((String key) => key.contains('.pdf'));

      // Iterate through each PDF asset and add its path to bookUrls
      for (var asset in assets) {
        final pdfFile = await fromAsset(asset);
        setState(() {
          bookUrls.add(pdfFile.path);
        });
      }
      for (var url in pdfUrls) {
        final pdfFile2 = await createFileOfPdfUrl(url);
        setState(() {
            bookUrls.add(pdfFile2.path);
        });
      }
    
    } catch (e) {
      print('Error loading PDF assets: $e');
    }
  }




  // ADDED BY SHAY: Method to filter PDFs based on the selected option
  List<String> filterPDFs(FilterOption option) {
    switch (option) {
      case FilterOption.Alphabetical:
        // Sort PDFs alphabetically
        bookUrls.sort((a, b) => path.basename(a).compareTo(path.basename(b)));
        setState(() {});
        break;
      case FilterOption.Chronological:
        // Sort PDFs chronologically (based on their names or other metadata)
        // Implement your sorting logic here
        break;
      case FilterOption.DateAdded:
        // Sort PDFs based on date added
        // Implement your sorting logic here
        break;
    }
    return bookUrls;
  }




  // This returns the file of the pdf.
  Future<File> fromAsset(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${path.basename(asset)}'); // Use path.basename
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      throw Exception('Error parsing asset file: $e');
    }
  }



  // ADDED BY SHAY
  void addBookmark(String path, int num){
    setState(() {
      bookmarks.add(Bookmark(pdfPath: path, pageNum: num));
    });
  }
  // ADDED BY SHAY
  void removeBookmark(String path, int num){
    setState(() {
      bookmarks.removeWhere((bookmark) => bookmark.pdfPath == path && bookmark.pageNum == num);
    });
  }
  // ADDED BY SHAY
  bool isBookmarked(String path, int num){
    return bookmarks.any((bookmark) => bookmark.pdfPath == path && bookmark.pageNum == num);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Terptales',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text ('Book List')),
        // ADDED BY SHAY
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show filter options dialog
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Filter PDFs'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: const Text('Alphabetical Order'),
                        onTap: () {
                          Navigator.pop(context, FilterOption.Alphabetical);
                          filterPDFs(FilterOption.Alphabetical);
                        },
                      ),
                      ListTile(
                        title: const Text('Chronological Order'),
                        onTap: () {
                          Navigator.pop(context, FilterOption.Chronological);
                        },
                      ),
                      ListTile(
                        title: const Text('Date Added Order'),
                        onTap: () {
                          Navigator.pop(context, FilterOption.DateAdded);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.filter_list),
        ),
        body: ListView.builder(
        itemCount: bookUrls.length, //THIS IS HARD CODED - FIX LATER
        itemBuilder: (context, index) {
          print(bookUrls[index]);
          return ListTile(
            title: Text(path.basename(bookUrls[index])), // THIS IS HARD CODED - FIX LATER
            //instead of icon, use future builder https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
            leading: RawImage(image: thumbnails[index].imageIfAvailable, fit: BoxFit.contain,),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // FIX - LOOP THROUGH EVERY PATH, NOT JUST cmdlinepath.
                  //builder: (context) => PDFScreen(path: bookUrls[index]),
                  // ADDED BY SHAY
                  builder: (context) => PDFScreen(path: bookUrls[index], addBookmark: addBookmark, pdfBookmarks: bookmarks, removeBookmark: removeBookmark, isBookmarked: isBookmarked,),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}




// this will be our PDF page
// again, pull this code from https://pub.dev/packages/flutter_pdfview/example
class PDFScreen extends StatefulWidget {
  final String? path;
  final Function(String, int) addBookmark; // ADDED BY SHAY
  List<Bookmark>pdfBookmarks = [];
  // UPDATED FOR SECOND PART BY SHAY
  final Function(String, int) removeBookmark;
  final Function(String, int) isBookmarked;

  //PDFScreen({Key? key, this.path}) : super(key: key);
  PDFScreen({Key? key, this.path, required this.addBookmark, required this.pdfBookmarks, required this.removeBookmark, required this.isBookmarked}) : super(key: key);  // ADDED BY SHAY

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  // ADDED BY SHAY
  @override
  void initState(){
    super.initState();
    // Check if there is a bookmark for the current pdf path
    final bookmark = widget.pdfBookmarks.lastWhere(
      (bookmark) => bookmark.pdfPath == widget.path,
      orElse: () => Bookmark(pdfPath: '', pageNum: 0), // ADDED BY SHAY
    );
    
    // If there is a bookmark go to it
    if (bookmark.pdfPath != '') {
      setState(() {
        currentPage = bookmark.pageNum;
      });
    }

  }

  @override
  Widget build(BuildContext context){
    // Define the bookmark icon based on the bookmark status ADDED BY SHAY
    late IconData bookmarkIcon;
    if (widget.isBookmarked(widget.path!, currentPage!)) {
      bookmarkIcon = Icons.bookmark;
    } else {
      bookmarkIcon = Icons.bookmark_border;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(widget.path ?? 'No File Selected')),
        // ADDED BY SHAY
        actions: [IconButton(onPressed: () {
          // Remove the bookmark if it is already in the map
          if(widget.isBookmarked(widget.path!, currentPage!)){
            widget.removeBookmark(widget.path!, currentPage!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Removed')),);
          }
          else{
            // Add the bookmark
            widget.addBookmark(widget.path!, currentPage!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Added')),);
          }
          setState(() {
            // Rebuild the widget
          });
          //widget.addBookmark(widget.path!, currentPage!);
        //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Added')),);
        },
        // Change the bookmarked icon
        //Icons.bookmark
        icon: Icon(bookmarkIcon),),],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path, //gets the path of the book from the widget
            enableSwipe: true, 
            swipeHorizontal: true, // like a book
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!, //???
            fitPolicy: FitPolicy.BOTH, //???
            preventLinkNavigation:
              false,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController PDFViewController) {
              _controller.complete(PDFViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
            ? !isReady
              ? const Center(
                  child: CircularProgressIndicator(),
              )
              : Container()
            : Center(
              child: Text(errorMessage),
            )
        ],
      ),
    );
  }

}
