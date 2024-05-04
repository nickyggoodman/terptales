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
import 'package:sensors_plus/sensors_plus.dart'; // for flip detection
import 'package:google_fonts/google_fonts.dart';
import 'painter.dart';
// import 'package:terptales/theme_data_style.dart';
import 'package:terptales/theme_provider.dart';
import 'package:provider/provider.dart';



// ADDED BY SHAY
enum FilterOption { Alphabetical, Chronological, DateAdded }


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

Todo: add form to add url to 'pdfUrls' which should then also trigger a
call to loadPdfAssets() which will update 'bookUrls' and 'pdfThumbnailMap'

Todo: save pdfs loaded from web to assets somehow so that it is saved to the  
device. currently, the pdfs can take some time to load (e.g. some are >3MB and
can take considerable time to load on each rebuild)
*/
class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  
  List<String> recentlyAddedUrls = [];
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
          recentlyAddedUrls.add(pdfFile2.path);
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


//ADDED BY JUSTINAH
 @override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Terptales',
    debugShowCheckedModeBanner: false,
    home: Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: themeProvider.themeDataStyle.scaffoldBackgroundColor, 
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFilterDialog(),
          child: const Icon(Icons.filter_list),
        ),
        body: Column(
          children: [
            Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start, //ADDED BY JUSTINAH
    children: [
      
      Text(
        'Book List',
        style: GoogleFonts.taprom(
          textStyle: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 30,
           color: themeProvider.themeDataStyle.textTheme.bodyLarge?.color, //ADDED BY JUSTINAH
        ),
        ),
      ),
    ],
  ),
),
            Expanded(
              child: ListView.builder(
                // scrollDirection: Axis.horizontal,
                itemCount: bookUrls.length,
                itemBuilder: (context, index) => _buildBookTile(bookUrls[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Added',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.taprom( color: themeProvider.themeDataStyle.textTheme.bodyLarge?.color, //ADDED BY JUSTINAH
                      textStyle: const TextStyle(fontStyle: FontStyle.italic,fontSize: 30),
                    ),
                  ),
                  IconButton(
                    icon:  Icon(Icons.add, color: themeProvider.themeDataStyle.textTheme.bodyLarge?.color),
                    onPressed: () {
                      // Future implementation here
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentlyAddedUrls.length,
                itemBuilder: (context, index) => _buildBookTile(recentlyAddedUrls[index]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _applyFilter(FilterOption option) {
  Navigator.pop(context);
  filterPDFs(option);
}

/* Builds a ListTile representing a book with its title set to the base name of the book file
extracted from the provided bookPath. The text color of the title dynamically adapts to the
current theme using the ThemeProvider. The leading widget displays an image thumbnail of
the book obtained from pdfThumbnailMap. Tapping the tile opens the PDF screen for the selected book.
-Justinah Bashua*/
Widget _buildBookTile(String bookPath) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) => ListTile(
      title: Text(
        path.basename(bookPath),
        style: TextStyle(
          color: themeProvider.themeDataStyle.textTheme.bodyLarge?.color,
        ),
      ),
      leading: RawImage(
        image: pdfThumbnailMap[bookPath].imageIfAvailable,
        fit: BoxFit.contain,
      ),
      onTap: () => _openPDFScreen(bookPath),
    ),
  );
}

void _openPDFScreen(String bookPath) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFScreen(
        path: bookPath,
        addBookmark: addBookmark,
        pdfBookmarks: bookmarks,
        removeBookmark: removeBookmark,
        isBookmarked: isBookmarked,
      ),
    ),
  );
}

void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter PDFs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Alphabetical Order'),
            onTap: () => _applyFilter(FilterOption.Alphabetical),
          ),
          ListTile(
            title: const Text('Chronological Order'),
            onTap: () => _applyFilter(FilterOption.Chronological),
          ),
          ListTile(
            title: const Text('Date Added Order'),
            onTap: () => _applyFilter(FilterOption.DateAdded),
          ),
        ],
      ),
    ),
  );
}
}

class PDFScreen extends StatefulWidget {
  final String? path;
  final Function(String, int) addBookmark;
  final List<Bookmark> pdfBookmarks;
  final Function(String, int) removeBookmark;
  final Function(String, int) isBookmarked;

  PDFScreen({
    Key? key,
    this.path,
    required this.addBookmark,
    required this.pdfBookmarks,
    required this.removeBookmark,
    required this.isBookmarked,
  }) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool isAnnotating = false; // Track whether annotating is enabled or not

  // for gyroscope sensor
  late StreamSubscription _gyroSubscription;
  double _gyroX = 0.0; 
  double _gyroY = 0.0; 
  double _gyroZ = 0.0; 

  // for page changes

  // for checking for the last time a page was turned. For the delay in gyroscope
  int _lastPageTurnTime = DateTime.now().millisecondsSinceEpoch;
  

  @override
  void initState() {
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

    /*
    https://pub.dev/packages/sensors_plus
    https://plus.fluttercommunity.dev/docs/sensors_plus/usage/
    gyroscope stream here. - Nicky G.
    */ 
    _gyroSubscription = gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval).listen((event) {
      setState(() {
        _gyroX = event.x;
        _gyroY = event.y;
        _gyroZ = event.z;
        DateTime dateTimeGyro = DateTime.now();
        //print('x: $_gyroX y: $_gyroY, z: $_gyroZ}');
        // allow a page turn only every 2 seconds. If we allow less than then
        // it can turn back a page or forward a page without you wanting it
        // to since the gyro position works relatively.
        if (dateTimeGyro.millisecondsSinceEpoch - _lastPageTurnTime > 2000){
          if (_gyroY > 5){
            currentPage = currentPage! + 1;
            _controller.future.then((value) => value.setPage(currentPage!));
            _lastPageTurnTime = dateTimeGyro.millisecondsSinceEpoch;
          }
          if (_gyroY < -5) {
            currentPage = currentPage! - 1;
            _controller.future.then((value) => value.setPage(currentPage!));
            _lastPageTurnTime = dateTimeGyro.millisecondsSinceEpoch;
          }
        }
      });
    });

  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _gyroSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(path.basename(widget.path ?? 'No File Selected')),
            // Text('x:${_gyroX}'),
            // Text('y:${_gyroY}'), // y will be less than -1 for right page turn (forward a page), greater than 1 for left page flip (back a page)
            // Text('z:${_gyroZ}')
          ]
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (widget.isBookmarked(widget.path!, currentPage!)) {
                widget.removeBookmark(widget.path!, currentPage!);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark Removed')));
              } else {
                widget.addBookmark(widget.path!, currentPage!);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark Added')));
              }
              setState(() {});
            },
            icon: Icon(
              widget.isBookmarked(widget.path!, currentPage!)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
          ),
          // Toggle button for annotating
          IconButton(
            onPressed: () {
              setState(() {
                isAnnotating = !isAnnotating;
              });
            },
            icon: Icon(
              isAnnotating ? Icons.edit : Icons.edit_off,
            ),
          ),
          FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  onPressed: () async {
                    await snapshot.data!.setPage(currentPage! - 1);
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: "Go to ${currentPage! + 1}",
                );
              }

              return Container();
            },
          ),
          FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  onPressed: () async {
                    await snapshot.data!.setPage(currentPage! + 1);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: "Go to ${pages! + 1}",
                );
              }

              return Container();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView( 
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
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
              // controller is alive! -Nicky G.
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
                ),
          // Show drawing room screen only if annotating is enabled
          if (isAnnotating)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: DrawingRoomScreen(),
            ),
        ],
      ),
    );
  }
}


// code taken from: https://github.com/dannndi/flutter_drawing_app/tree/main
class DrawingRoomScreen extends StatefulWidget {
const DrawingRoomScreen({Key? key}) : super(key: key);




@override
State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}




class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
final List<Color> availableColors = [
  Colors.red,
  Colors.amber,
  Colors.blue,
  Colors.green,
  Colors.brown,
  Colors.black, 
];




List<DrawingPoint> historyDrawingPoints = [];
List<DrawingPoint> drawingPoints = [];
Color selectedColor = Colors.black;
double selectedWidth = 2.0;
DrawingPoint? currentDrawingPoint;




@override
Widget build(BuildContext context) {
  return Stack(
    children: <Widget>[
      GestureDetector(
        onPanStart: (details) {
          setState(() {
            currentDrawingPoint = DrawingPoint(
              id: DateTime.now().microsecondsSinceEpoch,
              offsets: [details.localPosition],
              color: selectedColor,
              width: selectedWidth,
            );




            if (currentDrawingPoint == null) return;
            drawingPoints.add(currentDrawingPoint!);
            historyDrawingPoints = List.of(drawingPoints);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (currentDrawingPoint == null) return;




            currentDrawingPoint = currentDrawingPoint?.copyWith(
              offsets: currentDrawingPoint!.offsets..add(details.localPosition),
            );
            drawingPoints.last = currentDrawingPoint!;
            historyDrawingPoints = List.of(drawingPoints);
          });
        },
        onPanEnd: (_) {
          currentDrawingPoint = null;
          // Automatically save the drawing points when the user stops drawing
          saveAnnotations();
        },
        child: CustomPaint(
          painter: DrawingPainter(drawingPoints: drawingPoints),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
      // Undo Button
      Positioned(
        top: 20,
        left: 20,
        child: IconButton(
          onPressed: undo,
          icon: const Icon(Icons.undo),
        ),
      ),
      // Redo Button
      Positioned(
        top: 20,
        left: 60,
        child: IconButton(
          onPressed: redo,
          icon: const Icon(Icons.redo),
        ),
      ),
      // Color Palette
      Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var color in availableColors)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}




void saveAnnotations() {
    // Convert drawing points to JSON
    final jsonData =
        jsonEncode(drawingPoints.map((point) => point.toJson()).toList());

    // Save JSON data to file
    final file = File('annotations.json');
    file.writeAsString(jsonData);
  }

  void undo() {
    if (drawingPoints.isNotEmpty) {
      setState(() {
        historyDrawingPoints.add(drawingPoints.removeLast());
      });
    }
  }

  void redo() {
    if (historyDrawingPoints.isNotEmpty) {
      setState(() {
        drawingPoints.add(historyDrawingPoints.removeLast());
      });
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
