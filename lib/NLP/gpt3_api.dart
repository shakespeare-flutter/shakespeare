import 'package:dart_openai/openai.dart';
import 'env/env.dart';
import 'dart:convert';

//str에 스트링 넣으면 감정 분석 스트링 리턴
Future<String> getEmotionFromGpt3(String str) async {
  OpenAI.apiKey = Env.apiKey;
  str = str + "\\n\\n###\\n\\n {'emotion':";

  final completion = await OpenAI.instance.completion.create(
      model: "ada:ft-personal-2023-04-05-16-31-41",
      prompt: str,
      //"There was a sad fish in blue sky. It was sunny.\\n\\n###\\n\\n {'emotion':"
      temperature: 0.7,
      maxTokens: 256,
      topP: 1,
      frequencyPenalty: 0,
      presencePenalty: 0,
      stop: "###");

  return "{'emotion':" + completion.choices[0].text;
}

String testtext2 = //테스트용 예시 api 호출시 출력 텍스트
    "{'emotion':{'admiration': 0, 'amusement': 0, 'anger': 0, 'annoyance': 0, 'approval': 0, 'caring': 0, 'confusion': 0, 'curiosity': 0, 'desire': 0, 'disappointment': 0, 'disapproval': 0, 'disgust': 0, 'embarrassment': 0, 'excitement': 0, 'fear': 0, 'gratitude': 0, 'grief': 1, 'joy': 0, 'love': 0, 'nervousness': 0, 'optimism': 0, 'pride': 0, 'realization': 0, 'relief': 0, 'remorse': 0, 'sadness': 1, 'surprise': 0, 'neutral': 0}, 'weather': 'sunny', 'hue': [blue], 'saturation': None, 'value': 'high'}";

Map<String, dynamic> gpt3StrToMap(String str) {
  str = str.replaceAll("'", '"');
  str = str.replaceAll('None', 'null');
  List<String> str_list = str.split(RegExp(r'[\[\]]'));

  String result_str = str_list[0] +
      '["' +
      str_list[1].replaceAll(',', '","') +
      '"]' +
      str_list[2];
  //print("result_str: " + result_str);

  Map<String, dynamic> jsonMap = jsonDecode(result_str);
  return jsonMap;
}
