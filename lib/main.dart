import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  String result = 'Translated text...';
  late OnDeviceTranslator onDeviceTranslator;
  final TranslateLanguage sourceLanguage = TranslateLanguage.english;
  final TranslateLanguage targetLanguage = TranslateLanguage.urdu;
  late ModelManager modelManager;
  late LanguageIdentifier languageIdentifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    modelManager = OnDeviceTranslatorModelManager();
    languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    checkAndDownloadModel();
  }

  bool isEnglishDownloaded = false;
  bool isUrduDownloaded = false;
  checkAndDownloadModel() async {
    print("check model start");

    //TODO if models are loaded then create translator
    isEnglishDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    isUrduDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.urdu.bcpCode);

    //TODO download models if not downloaded
    if (!isEnglishDownloaded) {
      isEnglishDownloaded =
          await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    if (!isUrduDownloaded) {
      isUrduDownloaded =
          await modelManager.downloadModel(TranslateLanguage.urdu.bcpCode);
    }

    //TODO if models are loaded then create translator
    if(isEnglishDownloaded && isUrduDownloaded){
      onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
    }
    print("check model end");
  }

  //TODO translate text
  translateText(String text) async {
    result = "";
    if(isEnglishDownloaded && isUrduDownloaded) {
      String res = await onDeviceTranslator.translateText(text);
      setState(() {
        result = res;
      });
    }
    identifyLanguages(text);
  }

  //TODO identify text
  identifyLanguages(String text) async {
    final String input = await languageIdentifier.identifyLanguage(text);
    print(input);
    textEditingController.text = "($input) ${textEditingController.text}";

    final String output = await languageIdentifier.identifyLanguage(result);
    result = "($output) $result";
    print(output);
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: Container(
            color: Colors.black12,
            child:  Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    height: 50,
                    child: Card(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'English',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 48,
                            width: 1,
                            color: Colors.white,
                          ),
                          const Text(
                            'Urdu',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 2, right: 2),
                    width: double.infinity,
                    height: 250,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                              fillColor: Colors.white,
                              hintText: 'Type text here...',
                              filled: true,
                              border: InputBorder.none),
                          style: const TextStyle(color: Colors.black),
                          maxLines: 100,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 13, right: 13),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(color: Colors.white),
                          primary: Colors.green),
                      child: const Text('Translate'),
                      onPressed: () {
                        translateText(textEditingController.text);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
                    width: double.infinity,
                    height: 250,
                    child: Card(
                      color: Colors.white,
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            result,
                            style: const TextStyle(fontSize: 18),
                          )),
                    ),
                  ),
                ],
              ),
            
          ))),
    );
  }
}
