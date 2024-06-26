import 'dart:convert';
import 'package:http/http.dart' as http;

class OPenAIService{
final List<Map<String,String>> messages = [];
final openAIKey =  "sk-proj-ZuRfu5HdA8QvJWStigCYT3BlbkFJJqGBBv6YF5iNnMGmK5LF";
  //checks if the request if for image generation by Dall-E or for ChatGPT
  Future<String> isArtPromptAPI(String prompt) async{
    try{
      final res = await http.post(Uri.parse(
          "https://api.openai.com/v1/chat/completions",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAIKey"
      },
          body: jsonEncode({
            "model": "gpt-4o",
            "messages": [
              {
                "role": "user",
                "content": "Does this message want to generate an AI picture, image, art or anything similar? $prompt. Simply answer with a yes or no."
              },

            ]
          }));

      if(res.statusCode == 200){

        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        //check if prompt is for image generation
        switch(content){
          case "Yes":
          case "yes":
          case "Yes.":
          case "yes.":
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;

        }

      }
//something wrong happened. Check your api key or something related to usage
      return "Error";
    }catch(e){
      return e.toString();
    }
  }

  //handles request to chatGPT
  Future<String> chatGPTAPI(String prompt) async{
    messages.add({
      "role":"user","content":prompt
    });

    try{
      final res = await http.post(Uri.parse(
        "https://api.openai.com/v1/chat/completions",
      ),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $openAIKey"
          },
          body: jsonEncode({
            "model": "gpt-4o",
            "messages": messages
          }));
      if(res.statusCode == 200){
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          "role":"assistant","content":content
        });
        return content;
      }
//something wrong happened. Check your api key or something related to usage
      return "Error";
    }catch(e){
      return e.toString();
    }
  }

  //handles request to dall-E
  Future<String> dallEAPI(String prompt) async{
    messages.add({
      "role":"user","content":prompt
    });

    try{
      final res = await http.post(Uri.parse(
        "https://api.openai.com/v1/images/generations",
      ),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $openAIKey"
          },
          body: jsonEncode({
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
          }));
      if(res.statusCode == 200){
        String imgUrl = jsonDecode(res.body)['data'][0]['url'];
        imgUrl = imgUrl.trim();
        messages.add({
          "role":"assistant","content":imgUrl
        });
        return imgUrl;
      }
//something wrong happened. Check your api key or something related to usage
      return "Error";
    }catch(e){
      return e.toString();
    }
  }

}
