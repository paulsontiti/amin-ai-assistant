
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feaure_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _result = '';

  String? generatedContent;
  String? generatedImageUrl;

  OPenAIService _oPenAIService = OPenAIService();

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initFlutterTts();
  }

  Future<void> _initFlutterTts() async{
    await flutterTts.setSharedInstance(true);
    setState(() {

    });
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _speechToText.stop();
    flutterTts.stop();
  }


  Future<void> systemSpeak(String speech) async{
    await flutterTts.speak(speech);
  }
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Amin Voice Assistant"),
          centerTitle: true,
          leading: const Icon(Icons.menu),
        ),
        body:  SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8,),
              //virtual assistant picture
                   Container(
                        height: 125,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage('assets/images/virtual_assistant.jpeg'))
                        ),
                      ),
              const SizedBox(height: 16,),
              //ChatGPT response container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
                ),
                decoration:  BoxDecoration(
                  border: Border.all(
                    color: Pallete.borderColor
                  ),
                  borderRadius:  BorderRadius.circular(20)
                      .copyWith(topLeft: Radius.zero)
                ),
                child: const Text("Hello Amin, how can I help you?",
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontFamily: "Cera Pro",
                    fontSize: 25
                  ) ,),
              ),
              Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    // If listening is active show the recognized words
                    _speechToText.isListening
                        ? _lastWords
                    // If listening isn't active but could be tell the user
                    // how to start it, otherwise indicate that speech
                    // recognition is not yet ready or not supported on
                    // the target device
                        : _speechEnabled
                        ? 'Tap the microphone to start listening...'
                        : 'Speech not available',
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(generatedContent ?? ""),
              ),
              if(generatedImageUrl != null) Image.network(generatedImageUrl!),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
                alignment: Alignment.centerLeft,
                //margin: const EdgeInsets.all(20),
                child: const Text(
                  "Here are few things I can do for you",
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontFamily: "Cera Pro",
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              //list of features
              const FeatureBox(color: Pallete.firstSuggestionBoxColor,
                  titleText: "ChatGPT",
                  descriptionText: "I will help you get anything from ChatGPT. Just click on the mike icon and speak"),
          const FeatureBox(color: Pallete.secondSuggestionBoxColor,
            titleText: "Image generation",
            descriptionText: "I will help you generate any image. "
                "Just tap the mike icon and speak"),
              const FeatureBox(color: Pallete.thirdSuggestionBoxColor,
                  titleText: "Smart Voice Assistance",
                  descriptionText: "Speak and I will do whatever you say."
                      "Just tap the mike icon and speak"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:() async{
            // If has permision and not yet listening for speech start, otherwise stop
            if(await _speechToText.hasPermission && _speechToText.isNotListening){
              _startListening();
            }else if(_speechToText.isListening){
              final result = await _oPenAIService.isArtPromptAPI(_lastWords);
              if(result.contains("http")){
                generatedImageUrl = result;
                generatedContent = null;
              }else{
                generatedImageUrl = null;
                generatedContent = result;
                await systemSpeak(result);
              }
              setState(() {});

              _stopListening();
            }else{
              _initSpeech();
            }
          },
          tooltip: 'Listen',
          child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}
