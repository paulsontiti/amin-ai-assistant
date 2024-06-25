import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String titleText;
  final String descriptionText;
  const FeatureBox({super.key, required this.color, required this.titleText, required this.descriptionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
      decoration:  BoxDecoration(
        color: color,
        borderRadius:  BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleText,
          style: const TextStyle(
            fontFamily: "Cera Pro",
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          ),
          const SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(descriptionText,
              style: const TextStyle(
                  fontFamily: "Cera Pro",

              ),
            ),
          ),
        ],
      ),
    );
  }
}
