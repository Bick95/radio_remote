import 'dart:math';

shortenText(String text, {int maxLen = 25}){
  // If text is short enough, return text. Else return cropped text + "..."
  return text.substring(0, min(text.length, maxLen)) + (text.length > maxLen ? "..." : "");
}