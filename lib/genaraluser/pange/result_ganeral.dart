import 'package:flutter/material.dart';
import 'package:nornsabai/Myfunction/generalfunc/mainfunc/graph/dailygraph.dart';

class ResultGaneral extends StatefulWidget {
  const ResultGaneral({Key? key}) : super(key: key);

  @override
  State<ResultGaneral> createState() => ResultGaneralState();
}

class ResultGaneralState extends State<ResultGaneral> {
  final controller = SleepController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await controller.loadLatestSession();
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ Refresh function สำหรับ RefreshIndicator
  Future<void> _onRefresh() async {
    try {
      // บังคับให้โหลดข้อมูลใหม่
      controller.clearCache();
      await controller.loadLatestSession();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error refreshing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ถ้ากำลังโหลดครั้งแรก → แสดง loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ ถ้า error → แสดง error message
    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            child: Center(child: Text(_errorMessage!)),
          ),
        ),
      );
    }

    // ✅ ถ้าไม่มีข้อมูล → แสดง no data
    if (!controller.isLoaded || controller.allDots.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            child: const Center(child: Text('No data available')),
          ),
        ),
      );
    }

    // ✅ แสดงกราฟ + RefreshIndicator
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: buildGraphWidget(
                context: context,
                dots: controller.allDots,
                sessionData: controller.sessionData ?? {},
              ),
            ),
            // เพิ่มเนื้อหาอื่นๆ ถ้ามี
          ],
        ),
      ),
    );
  }
}