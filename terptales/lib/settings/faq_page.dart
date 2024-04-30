// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:terptales/settings/icon_widget.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
    title:  'FAQ',
    subtitle: 'frequently asked questions',
    leading: IconWidget(icon: Icons.question_mark, color: Colors.black),
    child: SettingsScreen(
      title: 'Frequently Asked Questions',
      children: <RichText>[
        RichText(text: TextSpan(
          text: 'What books are available to me?\n',
          style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold, fontSize: 20.0),
          // ignore: prefer_const_literals_to_create_immutables
          children: <TextSpan>[
          TextSpan(
            text: 'Using the search engine you can browse through our catalog.\n\n\n',
            style: TextStyle(color: Colors.white, fontSize: 15.0),
          ),
          ],
        ), 
        ),
        RichText(text: TextSpan(
          text: 'What format are my books?\n',
          style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold, fontSize: 20.0),
          children: <TextSpan>[
            TextSpan(
              text: 'All books are in pdf format.\n\n\n',
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          ],
        ),
        ),
         RichText(text: TextSpan(
          text: 'How do I save a section in the text?\n',
          style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold, fontSize: 20.0),
          children: <TextSpan>[
            TextSpan(
              text: 'You can highlight pieces of text within a pdf.\n\n\n',
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          ],
        ),
        ),
        RichText(text: TextSpan(
          text: 'How can I save the page I am on in a book?\n',
          style: TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize: 20.0), 
          children: <TextSpan>[
            TextSpan(
            text: 'You can bookmark a page and find it in our bookmark tab.\n\n\n',
            style: TextStyle(color: Colors.white, fontSize: 15.0),),
          ],
        ))
      ],
    )
  );
}