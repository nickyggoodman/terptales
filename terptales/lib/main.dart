import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMSC436 Group Project',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: MyHomePage(title: 'TerpTales'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Future<File>> pdfFiles;

  var currentPage = 0;

  @override
  void initState() {
    pdfFiles = [
      DownloadService.downloadFile(pdfUrls[0], 'cmdline.pdf'),
      DownloadService.downloadFile(pdfUrls[1], 'cmsc389z.pdf'),
      DownloadService.downloadFile(pdfUrls[2], 'tools.pdf'),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
  widget.title,
  style: GoogleFonts.abrilFatface(
    fontWeight: FontWeight.bold, // Make the text bold
    color: Color.fromARGB(255, 125, 189, 238), // Set text color to white
  ),
),
  elevation: 0,
  backgroundColor: Colors.white, // Change the color of the app bar
  actions: [
    IconButton( // Add IconButton as an action
      icon: const Icon(Icons.search, color: Color.fromARGB(255, 125, 189, 238)), // Search icon
      onPressed: () {
        // Handle search action here
      },
    ),
  ],
),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
            decoration: backgroundGradient(),
            ),
            // CustomBanner(),
      ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          return FutureBuilder<File>(
            future: pdfFiles[index],
            builder: (context, snapshot) {
              if (snapshot.hasData){
                return  Stack(
                  children: [
                    const Positioned(
                      top: 10,
                      left: 0,
                      child: Text(
                        "Book Title",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
              ),
            ),
          ),
          PdfThumbnail.fromFile(
            snapshot.data!.path,
            currentPage: currentPage,
            backgroundColor: Colors.transparent,
            height: 200,
            currentPageWidget: (page, isCurrentPage) {
              return Positioned(
                bottom: 50,
                right: 0,
                child: Container(
                  height: 30,
                  width: 30,
                  color: isCurrentPage ? Colors.green : Colors.pink,
                  alignment: Alignment.center,
                  child: Text(
                    '$page',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            currentPageDecoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.orange,
                  width: 10,
                ),
              ),
            ),
            onPageClicked: (page) {
              setState(() {
                currentPage = page + 1;
              });
              if (kDebugMode) {
                print('Page $page clicked');
              }
            },
          ),
          
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
            },
          
          );
        }
      )

              ],
            )
          ),
           Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(),
          ),
        ]
      )
            );
  }
}


const pdfUrls = [
  'https://www.cs.umd.edu/~mmarsh/books/cmdline.pdf',
  'https://www.cs.umd.edu/~mmarsh/books/cmsc389z.pdf',
  'https://www.cs.umd.edu/~mmarsh/books/tools.pdf',
];

class DownloadService {
  static final _httpClient = HttpClient();

  static Future<File> downloadFile(String url, String filename) async {
    var request = await _httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}










// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf_thumbnail/pdf_thumbnail.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'PDF Thumbnail Demo'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late Future<File> pdfFile;

//   var currentPage = 0;
//   @override
//   void initState() {
//     pdfFile = DownloadService.downloadFile(pdfUrl, 'cmdline.pdf');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         elevation: 0,
//       ),
//       body: FutureBuilder<File>(
//           future: pdfFile,
//           builder: (context, snapshot) {
//             return Center(
//               child: snapshot.hasData
//                   ? PdfThumbnail.fromFile(
//                       snapshot.data!.path,
//                       currentPage: currentPage,
//                       backgroundColor:
//                           Theme.of(context).primaryColor.withOpacity(0.3),
//                       height: 200,

//                       /// You can put widget to display page number.
//                       /// This widget will be in stack.
//                       currentPageWidget: (page, isCurrentPage) {
//                         return Positioned(
//                           bottom: 50,
//                           right: 0,
//                           child: Container(
//                             height: 30,
//                             width: 30,
//                             color: isCurrentPage ? Colors.green : Colors.pink,
//                             alignment: Alignment.center,
//                             child: Text(
//                               '$page',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         );
//                       },

//                       /// Customize decoration so selected page is highlighted
//                       currentPageDecoration: const BoxDecoration(
//                         color: Colors.white,
//                         border: Border(
//                           bottom: BorderSide(
//                             color: Colors.orange,
//                             width: 10,
//                           ),
//                         ),
//                       ),
//                       onPageClicked: (page) {
//                         /// You can update the current page,
//                         /// or animate to the page with
//                         /// most of the pdf viewer packages' controller.
//                         /// like: _controller.setPage(page);
//                         setState(() {
//                           currentPage = page + 1;
//                         });
//                         if (kDebugMode) {
//                           print('Page $page clicked');
//                         }
//                       },
//                     )
//                   : const CircularProgressIndicator(),
//             );
//           }),
//     );
//   }
// }

// const pdfUrl = 'https://www.cs.umd.edu/~mmarsh/books/cmdline.pdf';
// const pdfUrl2 = 'https://www.cs.umd.edu/~mmarsh/books/cmsc389z.pdf';

// class DownloadService {
//   static final _httpClient = HttpClient();

//   static Future<File> downloadFile(String url, String filename) async {
//     var request = await _httpClient.getUrl(Uri.parse(url));
//     var response = await request.close();
//     var bytes = await consolidateHttpClientResponseBytes(response);
//     String dir = (await getApplicationDocumentsDirectory()).path;
//     File file = File('$dir/$filename');
//     await file.writeAsBytes(bytes);
//     return file;
//   }
// }




// import 'dart:async';
// import 'dart:io';
// import 'dart:convert';

// import 'package:path/path.dart' as path;
// //import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:pdfx/pdfx.dart';

// import 'dart:typed_data';

// import 'package:pdf/pdf.dart';
// // ignore: library_prefixes
// import 'package:pdf/pdf.dart' as pdfLib;
// // ignore: library_prefixes
// import 'package:pdf/widgets.dart' as pdfWidgets;



// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// // going off of the example from https://pub.dev/packages/flutter_pdfview/example
// class _MyAppState extends State<MyApp> {
  
//   List<String> bookUrls = [];
//   List<Uint8List> thumbnails = [];
  

//   @override
//   void initState() {
//     super.initState();
//     loadPdfAssets();
//   }

//   // // do what espresso3389 spells.
//   // Future<Uint8List?> generatePdfThumbnail(String pdfAssetPath) async {
//   //   try {
//   //     // Open the PDF document from the asset
//   //     final PdfDocument doc = await PdfDocument.openAsset(pdfAssetPath);

//   //     // Get the number of pages in the PDF file
//   //     final int pageCount = doc.pageCount;

//   //     // The first page is 1
//   //     final PdfPage page = await doc.getPage(1);

//   //     // Render the page as an image
//   //     final PdfPageImage pageImage = await page.render();

//   //     // Generate dart:ui.Image cache for later use by imageIfAvailable
//   //     await pageImage.createImageIfNotAvailable();

//   //     // PDFDocument must be disposed as soon as possible
//   //     doc.dispose();

//   //     // Return the raw RGBA data of the rendered page image
//   //     return pageImage.pixels;
//   //   } catch (e) {
//   //     print('Error generating PDF thumbnail: $e');
//   //     return null;
//   //   }
//   // }


//   Future<void> loadPdfAssets() async {
//     try {
//       // Get list of all assets
//       final assetBundle = DefaultAssetBundle.of(context);
//       final assetList = await assetBundle.load('AssetManifest.json');
//       final manifestMap = json.decode(utf8.decode(assetList.buffer.asUint8List()));
//       final assets = manifestMap.keys.where((String key) => key.contains('.pdf'));

//       // Iterate through each PDF asset and add its path to bookUrls
//       for (var asset in assets) {
//         final pdfFile = await fromAsset(asset);
//         setState(() {
//           bookUrls.add(pdfFile.path);
//         });
//       }
//       // Generate thumbnails for each PDF
//       for (var url in bookUrls) {
//         Uint8List thumbnail = await generatePdfThumbnail(url);
//         setState(() {
//           thumbnails.add(thumbnail);
//         });
//       }
//     } catch (e) {
//       print('Error loading PDF assets: $e');
//     }
//   }

//   Future<File> fromAsset(String asset) async {
//     try {
//       final data = await rootBundle.load(asset);
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File('${dir.path}/${path.basename(asset)}'); // Use path.basename
//       final bytes = data.buffer.asUint8List();
//       await file.writeAsBytes(bytes, flush: true);
//       return file;
//     } catch (e) {
//       throw Exception('Error parsing asset file: $e');
//     }
//   }

//   Future<Map<int, Uint8List>> generatePdfThumbnails(String filePath) async {
//   try {
//     final document = await PdfDocument.openFile(filePath);
//     final Map<int, Uint8List> thumbnails = {};

//     for (var pageNumber = 1; pageNumber <= document.pagesCount; pageNumber++) {
//       final page = await document.getPage(pageNumber);
//       final pageImage = await page.render(
//         width: page.width,
//         height: page.height,
//       );
//       thumbnails[pageNumber] = pageImage.bytes;
//       await page.close();
//     }

//     await document.close();
//     return thumbnails;
//   } catch (e) {
//     print('Error generating PDF thumbnails: $e');
//     return {};
//   }
// }






//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Terptales',
//       // theme: ThemeData(
//       //   textTheme: const TextTheme(
//       //       title: TextStyle(
//       //         fontSize: 24.0,
//       //         color: Colors.white,
//       //         fontWeight: FontWeight.w300,
//       //         letterSpacing: 1,
//       //       ),
//       //       subtitle: TextStyle(
//       //           fontSize: 20,
//       //           color: Colors.white,
//       //           fontWeight: FontWeight.w300,
//       //           letterSpacing: 1)),
//       //   // iconTheme: IconThemeData(color: Colors.white, size: 28),
//       //   fontFamily: 'OpenSansCondensed',
//       // ),
//       // theme: ThemeData(iconTheme: const IconThemeData(color: Colors.white, size: 28), ),
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         // appBar: AppBar(
//         //   title: const Text('Terptales')),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 Container(
//             decoration: backgroundGradient(),
//             ),
//             CustomBanner(),
//             ListView.builder(
//   itemCount: bookUrls.length,
//   itemBuilder: (context, index) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PDFScreen(path: bookUrls[index]),
//           ),
//         );
//       },
//       child: BookCard(file: bookUrls[index]), // Use BookCard instead of ListTile
//     );
//   },
// ),

//         // ListView.builder(
//         // itemCount: bookUrls.length, //THIS IS HARD CODED - FIX LATER
//         // itemBuilder: (context, index) {
//         //   print(bookUrls[index]);
//         //   return ListTile(
//         //     title: Text(path.basename(bookUrls[index]), style: const TextStyle(color: Colors.white, fontSize: 30)), // THIS IS HARD CODED - FIX LATER
//         //     leading: const Icon(Icons.book, color : Colors.white),
//         //     trailing: const Icon(Icons.arrow_forward_ios_sharp, color : Colors.white),

//         //     onTap: () {
//         //       Navigator.push(
//         //         context,
//         //         MaterialPageRoute(
//         //           // FIX - LOOP THROUGH EVERY PATH, NOT JUST cmdlinepath.
//         //           builder: (context) => PDFScreen(path: bookUrls[index]),
//         //         ),
//         //       );
//         //     },
//         //   );
//         // },
//         // ),
//         ],
//       ),
//       ),
//       Align(
//             alignment: Alignment.bottomCenter,
//             child: CustomBottomNav(),
//       ),
//         ],
//       ),
//       ),
//     );
//   }
// }

BoxDecoration backgroundGradient(){
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      tileMode: TileMode.mirror,
      stops: const [0.0,0.4,0.6,1],
      colors: [
        Colors.blueGrey.shade800,
        Colors.blueGrey.shade700,
        Colors.blueGrey.shade700,
        Colors.blueGrey.shade800,
      ]
    )
  );
}


// class BookCard extends StatelessWidget {
//   final String file;

//  const BookCard({required this.file});


//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white, // Set the card background color as needed
//         borderRadius: BorderRadius.circular(8), // Add border radius for rounded corners
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // You can adjust the size of the thumbnail as needed
//           Container(
//             width: double.infinity,
//             height: 120,
//             child: Image.asset(
//               file,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               path.basename(file),
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





class CustomBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(Icons.home),
          Icon(Icons.bookmark),
          Icon(Icons.settings),
        ],
      ),
    );
  }
}


// class CustomBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: LinePainter(),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         height: 90.0,
//         child: Column(
//           children: <Widget>[
//             const SizedBox(
//               height: 40,
//             ),
//             Row(
//               children: <Widget>[
//                 const Text(
//                   'Terptales',
//                   style: TextStyle(
//               fontSize: 24.0,
//               color: Colors.black,
//               fontWeight: FontWeight.w300,
//               letterSpacing: 1,
//             ),
//                 ),
//                 Expanded(
//                   child: Container(),
//                 ),
//                 const Icon(Icons.search),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class LinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 0.2
//       ..style = PaintingStyle.stroke;

//     Path path = Path();
//     path.moveTo(0, size.height + 10);
//     path.lineTo(size.width, size.height + 10);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }


// // this will be our PDF page
// // again, pull this code from https://pub.dev/packages/flutter_pdfview/example
// class PDFScreen extends StatefulWidget {
//   final String? path;

//   PDFScreen({Key? key, this.path}) : super(key: key);

//   _PDFScreenState createState() => _PDFScreenState();
// }

// class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
//   final Completer<PDFViewController> _controller =
//       Completer<PDFViewController>();
//   int? pages = 0;
//   int? currentPage = 0;
//   bool isReady = false;
//   String errorMessage = '';

//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(path.basename(widget.path ?? 'No File Selected')),
//       ),
//       body: Stack(
//         children: <Widget>[
//           PDFView(
//             filePath: widget.path, //gets the path of the book from the widget
//             enableSwipe: true, 
//             swipeHorizontal: true, // like a book
//             autoSpacing: false,
//             pageFling: true,
//             pageSnap: true,
//             defaultPage: currentPage!, //???
//             fitPolicy: FitPolicy.BOTH, //???
//             preventLinkNavigation:
//               false,
//             onRender: (_pages) {
//               setState(() {
//                 pages = _pages;
//                 isReady = true;
//               });
//             },
//             onError: (error) {
//               setState(() {
//                 errorMessage = error.toString();
//               });
//               print(error.toString());
//             },
//             onPageError: (page, error) {
//               setState(() {
//                 errorMessage = '$page: ${error.toString()}';
//               });
//               print('$page: ${error.toString()}');
//             },
//             onViewCreated: (PDFViewController PDFViewController) {
//               _controller.complete(PDFViewController);
//             },
//             onLinkHandler: (String? uri) {
//               print('goto uri: $uri');
//             },
//             onPageChanged: (int? page, int? total) {
//               print('page change: $page/$total');
//               setState(() {
//                 currentPage = page;
//               });
//             },
//           ),
//           errorMessage.isEmpty
//             ? !isReady
//               ? Center(
//                   child: CircularProgressIndicator(),
//               )
//               : Container()
//             : Center(
//               child: Text(errorMessage),
//             )
//         ],
//       ),
//     );
//   }

// }
