import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final String initialUrl;

  WebViewScreen({required this.initialUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Container(  
        padding: EdgeInsets.only(top: 40),
        child: 
        WebView(
          initialUrl: initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      )
    );
  } 
} 
//webview_flutter: ^2.0.13 