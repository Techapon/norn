// ============================================================================
// MODELS
// ============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Enums
enum PeriodType { day, week, month }

enum DataType {
  snoreScore,
  snorePercent,
  loudPercent,
  veryLoudPercent,
  undetected,
  undetectedPercent,
  quiet,
  quietPercent,
  sleepTime
}

// Sleep Session Model
class SleepSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int apnea; // วินาที
  final int loud; // วินาที
  final int veryloud; // วินาที
  final int quiet; // วินาที
  final String? note;

  SleepSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.apnea,
    required this.loud,
    required this.veryloud,
    required this.quiet,
    this.note,
  });

  // Computed properties
  int get sleepTime => loud + veryloud + quiet + apnea;
  int get snoreScore => loud + veryloud;

  double get snorePercent =>
      sleepTime > 0 ? ((snoreScore / sleepTime) * 100) : 0;
  double get loudPercent => sleepTime > 0 ? ((loud / sleepTime) * 100) : 0;
  double get veryLoudPercent =>
      sleepTime > 0 ? ((veryloud / sleepTime) * 100) : 0;
  double get undetectedPercent =>
      sleepTime > 0 ? ((apnea / sleepTime) * 100) : 0;
  double get quietPercent => sleepTime > 0 ? ((quiet / sleepTime) * 100) : 0;

  // แปลงวินาทีเป็นนาที
  double get sleepTimeMinutes => sleepTime / 60;
  double get snoreScoreMinutes => snoreScore / 60;
  double get loudMinutes => loud / 60;
  double get veryloudMinutes => veryloud / 60;
  double get apneaMinutes => apnea / 60;
  double get quietMinutes => quiet / 60;

  factory SleepSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SleepSession(
      id: data['id'].toString(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      apnea: data['apnea'] as int,
      loud: data['lound'] as int, // Note: typo in Firebase field name
      veryloud: data['verylound'] as int,
      quiet: data['quiet'] as int,
      note: data['note'] as String?,
    );
  }
}

// Sleep Metrics for Bar Detail
class SleepMetrics {
  final String dateRange;
  final String dateRange2;
  final String? preroid;
  final int sessionCount;
  final double? changePercent; // null สำหรับแท่งแรก
  final bool isGood;
  final bool hasData; // เพื่อเช็คว่ากดได้หรือไม่

  SleepMetrics({
    required this.dateRange,
    required this.dateRange2,
    this.preroid,
    required this.sessionCount,
    this.changePercent,
    required this.isGood,
    this.hasData = true,
  });
}

// Bar Chart Data with Metrics
class ChartBarData {
  final String bottomTitle;
  final List<BarChartRodData> rodData;
  final SleepMetrics metrics;

  ChartBarData({
    required this.bottomTitle,
    required this.rodData,
    required this.metrics,
  });
}

// ============================================================================
// REPOSITORY LAYER
// ============================================================================

class SleepSessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String email;
  SleepSessionRepository({required this.email});

  Future<List<SleepSession>?> fetchAllSessions() async {
    try {
      // final userEmail = _auth.currentUser?.email;
      final snapshot = await _firestore
          .collection('General user')
          .doc(email)
          .collection('sleepsession')
          .orderBy('startTime', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => SleepSession.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
      return null;
    }
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class GridHelper {
  // Grid lines สำหรับ % charts (0, 25, 50, 75, 100)
  static List<double> getPercentageGridLines() => [25, 50, 75];

  // Grid lines สำหรับ time charts (ทุก 30 นาที)
  static List<double> getTimeGridLines(double maxMinutes) {
    List<double> lines = [];
    int interval = 30; // นาที

    for (int i = interval; i < maxMinutes; i += interval) {
      lines.add(i.toDouble());
    }

    return lines;
  }

  // คำนวณ maxY พร้อมปัดเศษสำหรับ time charts
  static double calculateTimeMaxY(double maxMinutes) {
    // เพิ่ม 60 นาที (1 ชม.)
    int totalMinutes = maxMinutes.toInt() + 60;
    int remainder = totalMinutes % 60;

    if (remainder == 0) {
      return totalMinutes.toDouble();
    } else if (remainder < 30) {
      return (totalMinutes - remainder).toDouble();
    } else {
      return (totalMinutes - remainder + 60).toDouble();
    }
  }
}

class ChartTitleGenerator {
  static String formatDayTitle(DateTime date) {
    final dayFormat = DateFormat('E', 'en_US'); // Mon, Tue, etc.
    final dateFormat = DateFormat('d MMM', 'en_US'); // 2 NOV

    return '${dayFormat.format(date)}. \n${dateFormat.format(date).toUpperCase()}';
  }

  static String formatWeekTitle(DateTime weekStart) {
    DateTime weekEnd = weekStart.add(Duration(days: 6));
    final format = DateFormat('d MMM', 'en_US');

    return '${format.format(weekStart).toUpperCase()}\n- ${format.format(weekEnd).toUpperCase()}';
  }

  static String formatMonthTitle(DateTime date) {
    final format = DateFormat('MMM yyyy', 'en_US');
    return format.format(date).toUpperCase();
  }

  // ---------------

  // หาวันอาทิตย์ของสัปดาห์
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  // Generate daily titles from start to end
  static List<String> generateDailyTitles(DateTime start, DateTime end) {
    List<String> titles = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      titles.add(formatDayTitle(current));
      current = current.add(Duration(days: 1));
    }

    return titles;
  }

  // Generate weekly titles
  static List<String> generateWeeklyTitles(DateTime start, DateTime end) {
    List<String> titles = [];
    DateTime weekStart = getWeekStart(start);
    DateTime endDate = getWeekStart(end);

    while (
        weekStart.isBefore(endDate) || weekStart.isAtSameMomentAs(endDate)) {
      titles.add(formatWeekTitle(weekStart));
      weekStart = weekStart.add(Duration(days: 7));
    }

    return titles;
  }

  // Generate monthly titles
  static List<String> generateMonthlyTitles(DateTime start, DateTime end) {
    List<String> titles = [];
    DateTime current = DateTime(start.year, start.month, 1);
    DateTime endMonth = DateTime(end.year, end.month, 1);

    while (
        current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
      titles.add(formatMonthTitle(current));
      current = DateTime(current.year, current.month + 1, 1);
    }
    return titles;
  }

  // ------------- DETIAL PART ------------------
    // ---------detail
  static List<String> formatDayDetailTitle(DateTime date) {
    final dayFormat = DateFormat('E d', 'en_US'); // Mon, Tue, etc.
    final dateFormat = DateFormat('MMM', 'en_US'); // 2 NOV

    return [
      '${dayFormat.format(date)}.',
      ' ${dateFormat.format(date).toUpperCase()}'
    ];
  }

  static List<String> formatWeekDetailTitle(DateTime weekStart) {
    DateTime weekEnd = weekStart.add(Duration(days: 6));
    final format = DateFormat('d MMM', 'en_US');

    return [
      '${format.format(weekStart).toUpperCase()} ',
      '- ${format.format(weekEnd).toUpperCase()}'
    ];
  }

  static List<String> formatMonthDetailTitle(DateTime date) {
    final monthformat = DateFormat('MMM', 'en_US');
    final yearformat = DateFormat('yyyy', 'en_US');
    return [
      '${monthformat.format(date).toUpperCase()} ',
      '${yearformat.format(date).toUpperCase()}',
    ];
  }

    // Generate daily titles from start to end
  static List<List<String>> generateDailyDetialTitles(DateTime start, DateTime end) {
    List<List<String>> titles = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      titles.add(formatDayDetailTitle(current));
      current = current.add(Duration(days: 1));
    }

    return titles;
  }

  // Generate weekly titles
  static List<List<String>> generateWeeklyDetailTitles(DateTime start, DateTime end) {
    List<List<String>> titles = [];
    DateTime weekStart = getWeekStart(start);
    DateTime endDate = getWeekStart(end);

    while (
        weekStart.isBefore(endDate) || weekStart.isAtSameMomentAs(endDate)) {
      titles.add(formatWeekDetailTitle(weekStart));
      weekStart = weekStart.add(Duration(days: 7));
    }

    return titles;
  }

  static List<List<String>> generateMonthDetailTitles(DateTime start, DateTime end) {
    List<List<String>> titles = [];
    DateTime current = DateTime(start.year, start.month, 1);
    DateTime endMonth = DateTime(end.year, end.month, 1);

    while (
        current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
      titles.add(formatMonthDetailTitle(current));
      current = DateTime(current.year, current.month + 1, 1);
    }
    return titles;
  }
}

class ColorHelper {
  static const Color apnea = Color(0xFF2283D0);
  static const Color quiet = Color(0xFF15B700);
  static const Color loud = Color(0xFF1E07528);
  static const Color veryLoud = Color(0xFFD53739);
}

// ============================================================================
// SERVICE LAYER
// ============================================================================

class SleepAnalysisService {
  // -------------------------------------------------------------------------
  // DAILY ANALYSIS
  // -------------------------------------------------------------------------
  List<ChartBarData> analyzeDailyData(
    List<SleepSession> sessions,
    DataType dataType,
  ) {
    if (sessions.isEmpty) return [];

    final firstDate = sessions.first.startTime;
    final lastDate = sessions.last.startTime;

    final titles = ChartTitleGenerator.generateDailyTitles(firstDate, lastDate);
    final detialtitle = ChartTitleGenerator.generateDailyDetialTitles(firstDate, lastDate);

    // สร้าง Map: date -> session
    Map<String, SleepSession> sessionMap = {};
    for (var session in sessions) {
      final dateKey = _getDateKey(session.startTime);
      sessionMap[dateKey] = session;
    }

    List<ChartBarData> chartData = [];
    DateTime current = DateTime(firstDate.year, firstDate.month, firstDate.day);
    SleepSession? previousSession;

    for (int i = 0; i < titles.length; i++) {
      final dateKey = _getDateKey(current);
      final session = sessionMap[dateKey];

      final hasData = session != null;
      final rodData = hasData
          ? _createRodData(session, dataType)
          : [BarChartRodData(toY: 0, width: 20, color: Colors.grey[300])];

      double? changePercent;
      bool isGood = false;

      if (hasData && previousSession != null) {
        changePercent = _calculateChange(
          previousSession,
          session,
          dataType,
        );
        isGood = _isChangeGood(changePercent, dataType);
      }

      chartData.add(ChartBarData(
        bottomTitle: "${titles[i]}",
        rodData: rodData,
        metrics: SleepMetrics(
          dateRange: detialtitle[i][0],
          dateRange2: detialtitle[i][1],
          preroid: "day",
          sessionCount: hasData ? 1 : 0,
          changePercent: changePercent,
          isGood: isGood,
          hasData: hasData,
        ),
      ));

      if (hasData) previousSession = session;
      current = current.add(Duration(days: 1));
    }

    return chartData;
  }

  // -------------------------------------------------------------------------
  // WEEKLY ANALYSIS
  // -------------------------------------------------------------------------
  List<ChartBarData> analyzeWeeklyData(
    List<SleepSession> sessions,
    DataType dataType,
  ) {
    if (sessions.isEmpty) return [];

    final firstWeekStart =
        ChartTitleGenerator.getWeekStart(sessions.first.startTime);
    final lastWeekStart =
        ChartTitleGenerator.getWeekStart(sessions.last.startTime);

    final titles =
        ChartTitleGenerator.generateWeeklyTitles(firstWeekStart, lastWeekStart);
    final detialtitle = ChartTitleGenerator.generateWeeklyDetailTitles(firstWeekStart, lastWeekStart);

    List<ChartBarData> chartData = [];
    DateTime weekStart = firstWeekStart;
    List<SleepSession>? previousWeekSessions;

    for (int i = 0; i < titles.length; i++) {
      DateTime weekEnd = weekStart.add(Duration(days: 6, hours: 23, minutes: 59));

      // หา sessions ในสัปดาห์นี้
      final weekSessions = sessions.where((s) {
        return s.startTime.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
            s.startTime.isBefore(weekEnd.add(Duration(seconds: 1)));
      }).toList();

      final hasData = weekSessions.isNotEmpty;

      List<BarChartRodData> rodData;
      if (hasData) {
        final avgSession = _calculateAverageSession(weekSessions);
        rodData = _createRodData(avgSession, dataType);
      } else {
        rodData = [BarChartRodData(toY: 0, width: 20, color: Colors.grey[300])];
      }

      double? changePercent;
      bool isGood = false;

      if (hasData && previousWeekSessions != null && previousWeekSessions.isNotEmpty) {
        final prevAvg = _calculateAverageSession(previousWeekSessions);
        final currentAvg = _calculateAverageSession(weekSessions);
        changePercent = _calculateChange(prevAvg, currentAvg, dataType);
        isGood = _isChangeGood(changePercent, dataType);
      }

      chartData.add(ChartBarData(
        bottomTitle: titles[i],
        rodData: rodData,
        metrics: SleepMetrics(
          dateRange: detialtitle[i][0],
          dateRange2: detialtitle[i][1],
          preroid: "week",
          sessionCount: weekSessions.length,
          changePercent: changePercent,
          isGood: isGood,
          hasData: hasData,
        ),
      ));

      if (hasData) previousWeekSessions = weekSessions;
      weekStart = weekStart.add(Duration(days: 7));
    }

    return chartData;
  }

  // -------------------------------------------------------------------------
  // MONTHLY ANALYSIS
  // -------------------------------------------------------------------------
  List<ChartBarData> analyzeMonthlyData(
    List<SleepSession> sessions,
    DataType dataType,
  ) {
    if (sessions.isEmpty) return [];

    final firstDate = sessions.first.startTime;
    final lastDate = sessions.last.startTime;

    final titles = ChartTitleGenerator.generateMonthlyTitles(firstDate, lastDate);
    final detialtitle = ChartTitleGenerator.generateMonthDetailTitles(firstDate, lastDate);

    List<ChartBarData> chartData = [];
    DateTime current = DateTime(firstDate.year, firstDate.month, 1);
    List<SleepSession>? previousMonthSessions;

    for (int i = 0; i < titles.length; i++) {
      DateTime monthStart = current;
      DateTime monthEnd = DateTime(current.year, current.month + 1, 0, 23, 59, 59);

      // หา sessions ในเดือนนี้
      final monthSessions = sessions.where((s) {
        return s.startTime.isAfter(monthStart.subtract(Duration(seconds: 1))) &&
            s.startTime.isBefore(monthEnd.add(Duration(seconds: 1)));
      }).toList();

      final hasData = monthSessions.isNotEmpty;

      List<BarChartRodData> rodData;
      if (hasData) {
        final avgSession = _calculateAverageSession(monthSessions);
        rodData = _createRodData(avgSession, dataType);
      } else {
        rodData = [BarChartRodData(toY: 0, width: 20, color: Colors.grey[300])];
      }

      double? changePercent;
      bool isGood = false;

      if (hasData && previousMonthSessions != null && previousMonthSessions.isNotEmpty) {
        final prevAvg = _calculateAverageSession(previousMonthSessions);
        final currentAvg = _calculateAverageSession(monthSessions);
        changePercent = _calculateChange(prevAvg, currentAvg, dataType);
        isGood = _isChangeGood(changePercent, dataType);
      }

      chartData.add(ChartBarData(
        bottomTitle: titles[i],
        rodData: rodData,
        metrics: SleepMetrics(
          dateRange: detialtitle[i][0],
          dateRange2: detialtitle[i][1],
          preroid: "month",
          sessionCount: monthSessions.length,
          changePercent: changePercent,
          isGood: isGood,
          hasData: hasData,
        ),
      ));

      if (hasData) previousMonthSessions = monthSessions;
      current = DateTime(current.year, current.month + 1, 1);
    }

    return chartData;
  }

  // -------------------------------------------------------------------------
  // HELPER METHODS
  // -------------------------------------------------------------------------

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // คำนวณค่าเฉลี่ยของ sessions หลายตัว
  SleepSession _calculateAverageSession(List<SleepSession> sessions) {
    if (sessions.isEmpty) {
      return SleepSession(
        id: 'avg',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        apnea: 0,
        loud: 0,
        veryloud: 0,
        quiet: 0,
      );
    }

    int totalApnea = 0;
    int totalLoud = 0;
    int totalVeryloud = 0;
    int totalQuiet = 0;

    for (var session in sessions) {
      totalApnea += session.apnea;
      totalLoud += session.loud;
      totalVeryloud += session.veryloud;
      totalQuiet += session.quiet;
    }

    int count = sessions.length;

    return SleepSession(
      id: 'avg',
      startTime: sessions.first.startTime,
      endTime: sessions.last.endTime,
      apnea: (totalApnea / count).round(),
      loud: (totalLoud / count).round(),
      veryloud: (totalVeryloud / count).round(),
      quiet: (totalQuiet / count).round(),
    );
  }

  // สร้าง BarChartRodData ตาม DataType
  List<BarChartRodData> _createRodData(SleepSession session, DataType dataType) {
    switch (dataType) {
      case DataType.snoreScore:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.snoreScoreMinutes,
            width: 20,
            rodStackItems: [
              BarChartRodStackItem(
                0,
                session.loudMinutes,
                ColorHelper.loud,
              ),
              BarChartRodStackItem(
                session.loudMinutes,
                session.snoreScoreMinutes,
                ColorHelper.veryLoud,
              ),
            ],
          ),
        ];

      case DataType.snorePercent:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.snorePercent,
            width: 20,
            rodStackItems: [
              BarChartRodStackItem(
                0,
                session.loudPercent,
                ColorHelper.loud,
                
              ),
              BarChartRodStackItem(
                session.loudPercent,
                session.snorePercent,
                ColorHelper.veryLoud,
              ),
            ],
          ),
        ];

      case DataType.loudPercent:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.loudPercent,
            width: 20,
            color: ColorHelper.loud,
          ),
        ];

      case DataType.veryLoudPercent:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.veryLoudPercent,
            width: 20,
            color: ColorHelper.veryLoud,
          ),
        ];

      case DataType.undetected:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.apneaMinutes,
            width: 20,
            color: ColorHelper.apnea,
          ),
        ];

      case DataType.undetectedPercent:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.undetectedPercent,
            width: 20,
            color: ColorHelper.apnea,
          ),
        ];

      case DataType.quiet:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.quietMinutes,
            width: 20,
            color: ColorHelper.quiet,
          ),
        ];

      case DataType.quietPercent:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.quietPercent,
            width: 20,
            color: ColorHelper.quiet,
          ),
        ];

      case DataType.sleepTime:
        return [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: session.sleepTimeMinutes,
            width: 20,
            color: Colors.blueGrey,
          ),
        ];
    }
  }

  // คำนวณการเปลี่ยนแปลง
  double _calculateChange(
    SleepSession previous,
    SleepSession current,
    DataType dataType,
  ) {
    double prevValue = _getValue(previous, dataType);
    double currentValue = _getValue(current, dataType);

    // สำหรับ % charts ใช้ percentage point difference
    if (_isPercentageType(dataType)) {
      return currentValue - prevValue;
    }

    // สำหรับ time charts ใช้ percentage change
    if (prevValue == 0) return 0;
    return ((currentValue - prevValue) / prevValue) * 100;
  }

  double _getValue(SleepSession session, DataType dataType) {
    switch (dataType) {
      case DataType.snoreScore:
        return session.snoreScoreMinutes;
      case DataType.snorePercent:
        return session.snorePercent;
      case DataType.loudPercent:
        return session.loudPercent;
      case DataType.veryLoudPercent:
        return session.veryLoudPercent;
      case DataType.undetected:
        return session.apneaMinutes;
      case DataType.undetectedPercent:
        return session.undetectedPercent;
      case DataType.quiet:
        return session.quietMinutes;
      case DataType.quietPercent:
        return session.quietPercent;
      case DataType.sleepTime:
        return session.sleepTimeMinutes;
    }
  }

  bool _isPercentageType(DataType dataType) {
    return dataType == DataType.snorePercent ||
        dataType == DataType.loudPercent ||
        dataType == DataType.veryLoudPercent ||
        dataType == DataType.undetectedPercent ||
        dataType == DataType.quietPercent;
  }

  // เช็คว่าการเปลี่ยนแปลงเป็นผลดีหรือไม่
  bool _isChangeGood(double changePercent, DataType dataType) {
    // ประเภทที่ลดลงเป็นผลดี
    final decreaseIsGood = [
      DataType.snoreScore,
      DataType.snorePercent,
      DataType.loudPercent,
      DataType.veryLoudPercent,
      DataType.undetected,
      DataType.undetectedPercent,
    ];

    if (decreaseIsGood.contains(dataType)) {
      return changePercent < 0; // ลดลง = ดี
    } else {
      return changePercent > 0; // เพิ่มขึ้น = ดี (quiet, sleepTime)
    }
  }

  // คำนวณ maxY สำหรับแต่ละ DataType
  double calculateMaxY(List<ChartBarData> data, DataType dataType) {
    if (data.isEmpty) return 100;

    double maxValue = 0;
    for (var bar in data) {
      for (var rod in bar.rodData) {
        if (rod.toY > maxValue) maxValue = rod.toY;
      }
    }

    if (_isPercentageType(dataType)) {
      return 100;
    } else {
      return GridHelper.calculateTimeMaxY(maxValue);
    }
  }
}

// ============================================================================
// CONTROLLER
// ============================================================================

class SleepTrendController extends ChangeNotifier {
  final String email;

  late final SleepSessionRepository _repository;
  final SleepAnalysisService _service = SleepAnalysisService();

  SleepTrendController({required this.email}) {
    _repository = SleepSessionRepository(email: email);
  }

  List<SleepSession>? _allSessions;
  PeriodType _selectedPeriod = PeriodType.day;
  DataType _selectedType = DataType.snoreScore;
  ChartBarData? _selectedBar;

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  PeriodType get selectedPeriod => _selectedPeriod;
  DataType get selectedType => _selectedType;
  SleepMetrics? get selectedMetrics => _selectedBar?.metrics;

  List<ChartBarData> get chartData {
    if (_allSessions == null || _allSessions!.isEmpty) return [];

    switch (_selectedPeriod) {
      case PeriodType.day:
        return _service.analyzeDailyData(_allSessions!, _selectedType);
      case PeriodType.week:
        return _service.analyzeWeeklyData(_allSessions!, _selectedType);
      case PeriodType.month:
        return _service.analyzeMonthlyData(_allSessions!, _selectedType);
    }
  }

  double get maxY {
    return _service.calculateMaxY(chartData, _selectedType);
  }

  // Load data from Firebase
  Future<bool> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _allSessions = await _repository.fetchAllSessions();

    _isLoading = false;

    if (_allSessions == null) {
      _error = 'Failed to load data';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  // Select period
  void selectPeriod(PeriodType period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    _selectedBar = null; // Reset selection
    notifyListeners();
  }

  // Select data type
  void selectDataType(DataType type) {
    if (_selectedType == type) return;
    _selectedType = type;
    _selectedBar = null; // Reset selection
    notifyListeners();
  }

  // Handle bar tap
  void onBarTapped(int barIndex) {
    final data = chartData;
    if (barIndex < 0 || barIndex >= data.length) return;

    final bar = data[barIndex];

    // ตรวจสอบว่ากดได้หรือไม่ (ต้องมีข้อมูล)
    if (!bar.metrics.hasData) return;

    _selectedBar = bar;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedBar = null;
    notifyListeners();
  }
}