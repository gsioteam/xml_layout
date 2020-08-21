
import 'package:flutter/material.dart';
import '../xml_layout.dart';

Color _colorGenerator(node) {
  String text = node.text;
  switch (text) {
    case 'transparent': return Colors.transparent;
    case 'black': return Colors.black;
    case 'black87': return Colors.black87;
    case 'black54': return Colors.black54;
    case 'black45': return Colors.black45;
    case 'black38': return Colors.black38;
    case 'black26': return Colors.black26;
    case 'black12': return Colors.black12;
    case 'white': return Colors.white;
    case 'white70': return Colors.white70;
    case 'white60': return Colors.white60;
    case 'white54': return Colors.white54;
    case 'white38': return Colors.white38;
    case 'white30': return Colors.white30;
    case 'white24': return Colors.white24;
    case 'white12': return Colors.white12;
    case 'white10': return Colors.white10;
    case 'red': return Colors.red;
    case 'redAccent': return Colors.redAccent;
    case 'pink': return Colors.pink;
    case 'pinkAccent': return Colors.pinkAccent;
    case 'purple': return Colors.purple;
    case 'purpleAccent': return Colors.purpleAccent;
    case 'deepPurple': return Colors.deepPurple;
    case 'deepPurpleAccent': return Colors.deepPurpleAccent;
    case 'indigo': return Colors.indigo;
    case 'indigoAccent': return Colors.indigoAccent;
    case 'blue': return Colors.blue;
    case 'blueAccent': return Colors.blueAccent;
    case 'lightBlue': return Colors.lightBlue;
    case 'lightBlueAccent': return Colors.lightBlueAccent;
    case 'cyan': return Colors.cyan;
    case 'cyanAccent': return Colors.cyanAccent;
    case 'teal': return Colors.teal;
    case 'tealAccent': return Colors.tealAccent;
    case 'green': return Colors.green;
    case 'greenAccent': return Colors.greenAccent;
    case 'lightGreen': return Colors.lightGreen;
    case 'lightGreenAccent': return Colors.lightGreenAccent;
    case 'lime': return Colors.lime;
    case 'limeAccent': return Colors.limeAccent;
    case 'yellow': return Colors.yellow;
    case 'yellowAccent': return Colors.yellowAccent;
    case 'amber': return Colors.amber;
    case 'amberAccent': return Colors.amberAccent;
    case 'orange': return Colors.orange;
    case 'orangeAccent': return Colors.orangeAccent;
    case 'deepOrange': return Colors.deepOrange;
    case 'deepOrangeAccent': return Colors.deepOrangeAccent;
    case 'brown': return Colors.brown;
    case 'grey': return Colors.grey;
    case 'blueGrey': return Colors.blueGrey;
    default: {
      if (text.startsWith("0x") || text.startsWith("0X")) {
        return Color(int.parse(text.substring(2), radix: 16));
      } if (text.startsWith('#')) {
        return Color(int.parse(text.substring(1), radix: 16));
      } else {
        var matches;
        if ((matches = RegExp(r"(\w+)\[(\d+)\]$").allMatches(text)).length > 0) {
          RegExpMatch match = matches.first;
          Color color = _colorGenerator(match.group(1));
          if (color is MaterialColor) {
            return color[int.parse(match.group(2))];
          }
        } else if ((matches = RegExp(r"^rgb\(([^\)]+)\)$").allMatches(text)).length > 0) {
          RegExpMatch match = matches.first;
          var arr = match.group(1).split(",");
          if (arr.length == 3) {
            return Color.fromRGBO(int.parse(arr[0]), int.parse(arr[1]), int.parse(arr[2]), 1);
          }
        } else if ((matches = RegExp(r"^rgba\(([^\)]+)\)$").allMatches(text)).length > 0) {
          RegExpMatch match = matches.first;
          var arr = match.group(1).split(",");
          if (arr.length == 4) {
            return Color.fromRGBO(int.parse(arr[0]), int.parse(arr[1]), int.parse(arr[2]), double.parse(arr[3]));
          }
        }
      }
      return null;
    }
  }
}

void registerColors() {
  XMLLayout.regType(Color, _colorGenerator);
}