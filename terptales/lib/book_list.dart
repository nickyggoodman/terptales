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
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:pdf_thumbnail/pdf_thumbnail.dart';

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

/*
This class generates the actual list of books. It generates the a list of 
bookfile titles and book thumbnails which can be tapped to navigate to the 
PDFScreen widget, which is where the pdf is displayed. There is functionality 
to sort the PDFs and view recently added. 
- Nicky G.

TODO: add form to add url to 'pdfUrls' which should then also trigger a
call to loadPdfAssets() which will update 'bookUrls' and 'pdfThumbnailMap'

TODO: save pdfs loaded from web to assets somehow so that it is saved to the
device. currently, the pdfs can take some time to load (e.g. some are >3MB and
can take considerable time to load on each rebuild)
*/
class _BookListState extends State<BookList> {
  
  List<String> bookUrls = [];
  // List<PdfPageImage> thumbnails = []; deprecated -Nicky G.
  List<Bookmark> bookmarks = []; // ADDED BY SHAY
  var pdfThumbnailMap = Map();
  // using library of congress collection: https://www.loc.gov/collections/open-access-books/about-this-collection/rights-and-access/
  List<String> pdfUrls = [
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/64/80/2020716480/2020716480.pdf",
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/97/07/2020719707/2020719707.pdf",
    "https://tile.loc.gov/storage-services/master/gdc/gdcebookspublic/20/20/71/99/65/2020719965/2020719965.pdf",
    "https://ia803207.us.archive.org/35/items/in.ernet.dli.2015.460385/2015.460385.Bonjour-Tristesse.pdf",
  ];

  @override
  void initState() {
    super.initState();
    loadPdfAssets();
  }


  /*
  Generates a thumbnail for a single pdf from /assets. this is useful for mapping
  the pdf to its thumbnail. An example of this function was pulled from the
  pdf_render package documentation "PDF rendering APIs"
  https://pub.dev/documentation/pdf_render/latest/
  - Nicky G.
  */
  Future<PdfPageImage?> generatePdfAssetThumbnail(String asset) async {
    
    try {
      // Open the PDF document from the asset
      final PdfDocument doc = await PdfDocument.openAsset(asset);

      // The first page is 1
      final PdfPage page = await doc.getPage(1);

      // Render the page as an image
      final PdfPageImage pageImage = await page.render();

      // Generate dart:ui.Image cache for later use by imageIfAvailable
      await pageImage.createImageIfNotAvailable();

      doc.dispose();

      return pageImage;

    } catch (e) {
      print('generatePdfAssetThumbnail Error generating PDF thumbnail FROM ASSET: $e');
      return null;
    }
  }


  /*
  Generates a thumbnail for a single pdf via url. this is useful for mapping
  the pdf to its thumbnail. An example of this function was pulled from the
  pdf_render package documentation "PDF rendering APIs"
  https://pub.dev/documentation/pdf_render/latest/
  - Nicky G.
  */
  Future<PdfPageImage?> generatePdfUrlThumbnail(String url) async {
  
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

      doc.dispose();

      return pageImage;

    } catch (e) {
      print('generatePdfAssetThumbnail Error generating PDF thumbnail FROM URL: $e');
      return null;
    }
  
  }


  /*
  This function adds the current location of the pdf file from assets in the device
  adds them all to 'bookUrls' List<string> while it does this, it also calls the
  function to load the thumbnail for the associated source (asset or url) and adds
  it to the 'pdfThumbnailMap' k: string -> v: PdfPageImage 
  - Nicky G.
  */
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
        final thumbnailOfAsset = await generatePdfAssetThumbnail(asset);
        setState(() {
          bookUrls.add(pdfFile.path);
          pdfThumbnailMap[pdfFile.path] = thumbnailOfAsset;
        });
      }
      for (var url in pdfUrls) {
        final pdfFile2 = await createFileOfPdfUrl(url);
        final thumbnailOfUrl = await generatePdfUrlThumbnail(url); 
        setState(() {
          bookUrls.add(pdfFile2.path);
          pdfThumbnailMap[pdfFile2.path] = thumbnailOfUrl;
        });
      }
    
    } catch (e) {
      print('Error loading PDF assets: $e');
    }
  }


  /*
  This function returns the file that is associated with the pdf that is given 
  in /assets. - Nicky G.
  */
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


  /*
  This function returns the file that is associated with the pdf that is given 
  from a url from the internet. Some examples are given in the hardcoded version
  of the url list. 
  - Nicky G.
  */
  Future<File> createFileOfPdfUrl(String pdfurl) async {
    Completer<File> completer = Completer();
    // print("Start download file from internet!");
    try {

      final url = pdfurl;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      // print("Download files");
      // print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
      
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;

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
        itemCount: bookUrls.length, 
        itemBuilder: (context, index) {
          // print(bookUrls[index]);
          return ListTile(
            title: Text(path.basename(bookUrls[index])),
            // pdfThumbnailMap takes the name of the file (e.g. 'cmdline.pdf') 
            // and maps to the thumbnail that was generated by both of the functions
            // 'generatePdfUrlThumbnail()' and 'generatePdfAssetThumbnail()'
            // which are called in the 'loadPdfAssets()' function. - Nicky G.
            leading: RawImage(image: pdfThumbnailMap[bookUrls[index]].imageIfAvailable, fit: BoxFit.contain,),
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


/*
This class generates the pdf view page, that is, the place where you can flip 
through the pdf, bookmark the pdf, and annotate the pdf. This is accessed by
tapping on the book on the book_list tab. 

Example pulled from:
https://pub.dev/packages/flutter_pdfview/example

- Nicky G.
*/
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
