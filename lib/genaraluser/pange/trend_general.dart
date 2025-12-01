import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nornsabai/Myfunction/globalFunc/trendgraph.dart';

// from general widget
import 'package:nornsabai/Myfunction/globalFunc/getsessiondt/geneWd/g_trend/g_typepop.dart';
import 'package:nornsabai/Myfunction/globalFunc/getsessiondt/geneWd/g_trend/g_detail.dart';
import 'package:nornsabai/Myfunction/globalFunc/getsessiondt/geneWd/g_trend/g_period.dart';

import 'package:provider/provider.dart';


// ============================================================================
// ALTERNATIVE: Simpler Widget (without Provider)
// ============================================================================

class TrendGaneral extends StatefulWidget {
  final String userDocId;

  TrendGaneral({required this.userDocId});
   
  @override
  _TrendGaneralState createState() => _TrendGaneralState();
}

class _TrendGaneralState extends State<TrendGaneral> {
  late SleepTrendController _controller;

  @override
  void initState() {
    super.initState();
    _controller =  SleepTrendController(userDocId: widget.userDocId);
    _controller.addListener(_onControllerUpdate);
    _loadData();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  Future<void> _loadData() async {
    final success = await _controller.loadData();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sleep data')),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Same UI as above...
    return SafeArea(child: SleepTrendPage(userDocId: widget.userDocId,)); // Reuse the widget structure
  }
}

// WIDGET & FUNCTION

class SleepTrendPage extends StatefulWidget {
  final String userDocId;

  SleepTrendPage({required this.userDocId});

  @override
  _SleepTrendPageState createState() => _SleepTrendPageState();
}

class _SleepTrendPageState extends State<SleepTrendPage> {
  late SleepTrendController _controller;
  bool _hasAutoSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = SleepTrendController(userDocId: widget.userDocId);
    _controller.addListener(_onControllerUpdate);
    _loadData();
  }

  void _onControllerUpdate() {
    // Auto-select แท่งล่าสุดเมื่อโหลดข้อมูลเสร็จครั้งแรก
    if (!_hasAutoSelected && 
        _controller.chartData.isNotEmpty && 
        !_controller.isLoading) {
      
      // หาแท่งล่าสุดที่มีข้อมูล
      final lastBarWithData = _controller.chartData
          .lastIndexWhere((bar) => bar.metrics.hasData);
      
      if (lastBarWithData != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.onBarTapped(lastBarWithData);
            _hasAutoSelected = true;
          }
        });
      }
    }
  }


  Future<void> _loadData() async {
    final success = await _controller.loadData();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sleep data')),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }


  // UX/UI
  @override
  Widget build(BuildContext context) {

    List<Color> headColor =[Colors.black,Color(0xFF3373A6)];

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<SleepTrendController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(controller.error!),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Main widget
            return Padding(
              padding: EdgeInsetsGeometry.only(
                left: 30,
                right: 30,
                top: 5
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Padding(
                          padding: EdgeInsetsGeometry.symmetric(vertical: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sleep",
                                style: GoogleFonts.itim(fontSize: 45,color: headColor[0]),
                              ),
                              SizedBox(width: 5,),
                              Text(
                                "Trend",
                                style: GoogleFonts.itim(fontSize: 45,color: headColor[1]),
                              ),
                              // SizedBox(width: 5,),
                              Icon(Icons.bar_chart,color: Colors.black,size: 50,)
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Sleep datatype widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SleepdataSelector(controller: controller),
                      ],
                    ),
                
                    // SizedBox(height: 17.5,),
                
                    // Chart
                    Padding(
                      padding: EdgeInsets.only(top: 20,bottom: 13),
                      child: _buildChart(controller),
                    ),
                
                    PreriodSelector(controller: controller,),
                
                    SizedBox(height: 15,),
                    // Selected Bar Details
                    _buildBarDetailsWrapper(controller),
                      // _buildBarDetails(controller.selectedMetrics!),
                
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );

          },
        ),
    );
  }

  // --------------------

  Widget _buildBarDetailsWrapper(SleepTrendController controller) {
    // ถ้ามี selectedMetrics ให้แสดง
    if (controller.selectedMetrics != null) {
      return buildBarDetails(
        controller: controller,
        metrics: controller.selectedMetrics!,
        isPercentageType: isPercentageType,
      );
    }
    
    // ถ้ายังไม่มี ให้หาแท่งล่าสุดที่มีข้อมูล
    if (controller.chartData.isNotEmpty) {
      final lastBarWithData = controller.chartData
          .lastWhere((bar) => bar.metrics.hasData, 
                     orElse: () => controller.chartData.last);
      
      return buildBarDetails(
        controller: controller,
        metrics: lastBarWithData.metrics,
        isPercentageType: isPercentageType,
      );
    }
    
    // ถ้าไม่มีข้อมูลเลย
    return SizedBox();
  }

  // -------------------------------------------------------------------------
  // CHART
  // -------------------------------------------------------------------------
  Widget _buildChart(SleepTrendController controller) {
    final chartData = controller.chartData;

    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final barCount = chartData.length;

    final minWidthPerBar = 100.0;
    final totalMinWidth = barCount * minWidthPerBar;

    final needScroll = totalMinWidth > screenWidth;

    final chartWidget =  BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: controller.maxY,
        minY: 0,
        barGroups: _createBarGroups(chartData),
        titlesData: _createTitlesData(chartData, controller),
        gridData: _createGridData(controller),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
            top: BorderSide.none,
            right: BorderSide.none,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent && barTouchResponse != null) {
              if (barTouchResponse.spot != null) {
                controller.onBarTapped(
                  barTouchResponse.spot!.touchedBarGroupIndex,
                );
              }
            }
          },
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey[700],
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _formatTooltipValue(rod.toY, controller.selectedType),
                GoogleFonts.itim(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );

    if (needScroll) {
      return SingleChildScrollView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: 450,
          width:  totalMinWidth,
          child: chartWidget,
        ),
      );
    }

    return SizedBox(
      height: 450,
      child: chartWidget,
    );
  }

  List<BarChartGroupData> _createBarGroups(List<ChartBarData> chartData) {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      return BarChartGroupData(
        x: index,
        barRods: data.rodData,
      );
    });
  }

  FlTitlesData _createTitlesData(
    List<ChartBarData> chartData,
    SleepTrendController controller,
  ) {
    final isPercentage = isPercentageType(controller.selectedType);

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= chartData.length) return SizedBox();
            return Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                chartData[index].bottomTitle,
                style: GoogleFonts.itim(fontSize: 17.5),
                textAlign: TextAlign.center,
              ),
            );
          },
          reservedSize: 60,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 65,
          interval: 25,
          getTitlesWidget: (value, meta) {
            if (isPercentage) {
              // แสดง 0, 25, 50, 75, 100
              if (value == 0 || value == 25 || value == 50 || 
                  value == 75 || value == 100) {
                return Padding(
                  padding:EdgeInsetsGeometry.only(right:10),
                  child: Text('${value.toInt()}%', style: GoogleFonts.itim(fontSize: 17.5),textAlign: TextAlign.end,),
                );
              }
            } else {
              // แสดงทุกชั่วโมง (0:00, 1:00, 2:00...)
              if (value % 60 == 0) {
                int hours = (value / 60).toInt();
                return Padding(
                  padding:EdgeInsetsGeometry.only(right:8),
                  child: Text('$hours:00 h', style: GoogleFonts.itim(fontSize: 17.5) ,textAlign: TextAlign.end,),
                );
              }
            }
            return SizedBox();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _createGridData(SleepTrendController controller) {
    final isPercentage = isPercentageType(controller.selectedType);

    if (isPercentage) {
      return FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          // ไม่แสดงเส้นที่ 0 และ 100
          if (value == 0 || value == 100) {
            return FlLine(color: Colors.transparent);
          }
          return FlLine(
            color: Colors.black.withOpacity(0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      );
    } else {
      return FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 30,
        getDrawingHorizontalLine: (value) {
          // ไม่แสดงเส้นที่ 0 และ maxY
          if (value == 0 || value == controller.maxY) {
            return FlLine(color: Colors.transparent);
          }
          return FlLine(
            color: Colors.black.withOpacity(0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      );
    }
  }

  String _formatTooltipValue(double value, DataType type) {
    if (isPercentageType(type)) {
      return '${value.toStringAsFixed(1)}%';
    } else {
      int hours = (value / 60).floor();
      int minutes = (value % 60).round();
      return '$hours:${minutes.toString().padLeft(2, '0')} h';
    }
  }

  // function
  bool isPercentageType(DataType type) {
    return type == DataType.snorePercent ||
        type == DataType.loudPercent ||
        type == DataType.veryLoudPercent ||
        type == DataType.undetectedPercent ||
        type == DataType.quietPercent;
  }
}



