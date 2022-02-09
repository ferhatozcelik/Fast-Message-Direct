import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:messagedirect/widget/text_input.dart';
import 'package:country_picker/country_picker.dart';
import 'package:messagedirect/widget/custom_button.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    List<String> events = [];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        hintColor: Colors.grey,
      ),
      home: SafeArea(
        child: Scaffold(
          body: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'TR +90';
  String initialCountryCode = "+90";
  String shortcut = 'no action set';
  String clipboardData = "";

  void _getClipboard() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() {
      clipboardData = data.text;
    });
  }
  bool isNumeric(String str) {
    try{
      var value = double.parse(str);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      _getClipboard();
    });
    WidgetsBinding.instance?.addObserver(this);
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      setState(() {
        if (shortcutType != null) {
          shortcut = shortcutType;
          if (shortcut == 'action_copy_text_open') {
            _getClipboard();
            _launchWhatsappURL(initialCountryCode + clipboardData);
            print('action_copy_text_open');
          }
        }
      });
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_copy_text_open',
        localizedTitle: 'Send to Number Clipboard',
        icon: 'ic_fast_icon',
      ),

    ]).then((void _) {
      setState(() {
        if (shortcut == 'no action set') {
          shortcut = 'actions ready';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 50.0,
          ),
          const Text(
            "Fast Message Send",
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 40,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          SvgPicture.asset("assets/images/messages.svg",
              width: 200, height: 200, semanticsLabel: 'Fast Message Direct'),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: CustomButton(
                        icon: Icons.public,
                        padding: EdgeInsets.all(10.0),
                        text: initialCountry,
                        onPressed: () {
                          showCountryPicker(
                              showPhoneCode: true,
                              context: context,
                              searchAutofocus: true,
                              countryListTheme: const CountryListThemeData(
                                flagSize: 25,
                                backgroundColor: Colors.white,
                                textStyle: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                ),
                                //Optional. Styles the search field.
                                inputDecoration: InputDecoration(
                                  prefixIconColor: Colors.red,
                                  labelText: 'Search',
                                  hintText: 'Start typing to search...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              onSelect: (Country country) {
                                setState(() {
                                  print(
                                      'Select country: ${country.displayName}');
                                  initialCountry = country.countryCode +
                                      ' +' +
                                      country.phoneCode;
                                  initialCountryCode = ' +' + country.phoneCode;
                                });
                              });
                        },
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: CustomTextInput(
                    textEditController: controller,
                    hintTextString: 'Phone number',
                    inputType: InputType.Number,
                    maxLength: 10,
                    enableBorder: true,
                    themeColor: Colors.red,
                    cornerRadius: 20.0,
                    prefixIcon: const Icon(Icons.phone, color: Colors.red),
                    textColor: Colors.black,
                    errorMessage: 'Phone Number cannot be empty',
                    labelText: 'Phone number',
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomButton(
              icon: Icons.send,
              padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 14.0),
              text: "Send Message",
              onPressed: () {
                String number = initialCountryCode + controller.text;
                _launchWhatsappURL(number);
                print('Send Url: ' + number);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchWhatsappURL(String _url) async {
    print(_url.length);
    if(isNumeric(_url) &&  _url.length == 13){
      await launch('https://api.whatsapp.com/send?phone=' + _url);
    }else{
      Fluttertoast.showToast(
          msg: "Please Enter Number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }


  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
