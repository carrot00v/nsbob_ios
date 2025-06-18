import 'package:flutter/material.dart';
import 'menu_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘 뭐 먹지',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MenuService _service = MenuService();
  List<MenuDay>? _days;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final url = await _service.fetchLatestPdfUrl();
      if (url == null) {
        setState(() => _error = '식단표를 찾을 수 없습니다');
        return;
      }
      final file = await _service.downloadPdf(url);
      final days = await _service.parseMenuFromPdf(file);
      setState(() => _days = days);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('오늘 뭐 먹지')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_days == null) {
      return Center(child: CircularProgressIndicator());
    }
    final today = _days!.isNotEmpty ? _days!.first.meals['raw'] ?? '식단 정보 없음' : '식단 정보 없음';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(today),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => WeeklyMenuPage(days: _days!)));
            },
            child: Text('이번 주 식단 보기'),
          ),
        ],
      ),
    );
  }
}

class WeeklyMenuPage extends StatelessWidget {
  final List<MenuDay> days;

  WeeklyMenuPage({required this.days});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주간 식단')),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          return ListTile(
            title: Text('${day.date.month}/${day.date.day}'),
            subtitle: Text(day.meals['raw'] ?? ''),
          );
        },
      ),
    );
  }
}
