import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfx/pdfx.dart';
import 'package:charset_converter/charset_converter.dart';

class MenuDay {
  final DateTime date;
  final Map<String, String> meals;
  MenuDay(this.date, this.meals);
}

class MenuService {
  static const String boardUrl = 'http://pvv.co.kr/bbs/index.php?code=bbs_menu01';

  Future<String?> fetchLatestPdfUrl() async {
    final response = await http.get(Uri.parse(boardUrl));
    if (response.statusCode != 200) return null;
    final decoded = await CharsetConverter.decode("euc-kr", response.bodyBytes);
    final doc = html_parser.parse(decoded);
    Element? link = doc.querySelector('a[href\$=".pdf"]');
    if (link == null) return null;
    final href = link.attributes['href'];
    if (href == null) return null;
    return Uri.parse(boardUrl).resolve(href).toString();
  }

  Future<File> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/menu.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<List<MenuDay>> parseMenuFromPdf(File pdfFile) async {
    final pdf = await PdfDocument.openFile(pdfFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final days = <MenuDay>[];
    for (int i = 1; i <= pdf.pagesCount; i++) {
      final page = await pdf.getPage(i);
      final pageImage = await page.render(width: page.width, height: page.height);
      final bytes = pageImage!.bytes;
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(pageImage.width.toDouble(), pageImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: pageImage.width * 4,
        ),
      );
      final text = await textRecognizer.processImage(inputImage);
      for (final line in text.text.split('\n')) {
        final date = _extractDate(line);
        if (date != null) {
          days.add(MenuDay(date, {'raw': line}));
        }
      }
      await page.close();
    }
    await textRecognizer.close();
    return days;
  }

  DateTime? _extractDate(String line) {
    final match = RegExp(r'(\d{1,2})\/(\d{1,2})').firstMatch(line);
    if (match == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
}
