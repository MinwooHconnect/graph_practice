import 'package:flutter/material.dart';

class BloodPressureChartPage extends StatelessWidget {
  const BloodPressureChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('혈압 기록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(height: 360, child: BloodPressureChart()),
      ),
    );
  }
}

class BloodPressureChart extends StatelessWidget {
  BloodPressureChart({super.key});

  final List<BloodPressureData> data = [
    BloodPressureData(
      date: "24.12.01",
      systolic: 100,
      diastolic: 55,
      heartRate: 18,
      pressureType: PressureType.low,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 120,
      diastolic: 80,
      heartRate: 35,
      pressureType: PressureType.normal,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 100,
      diastolic: 70,
      heartRate: 20,
      pressureType: PressureType.normal,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 110,
      diastolic: 90,
      heartRate: 32,
      pressureType: PressureType.warning,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 100,
      diastolic: 65,
      heartRate: 39,
      pressureType: PressureType.high,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 300),
            painter: BloodPressureChartPainter(data),
          ),
        ),
        const SizedBox(height: 20),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(Colors.blue, "저혈압"),
        _legendItem(Colors.green, "정상"),
        _legendItem(Color(0xFFB8DC44), "주의혈압"),
        _legendItem(Colors.red, "고혈압"),
        _legendItem(Colors.black, "맥박(bpm)"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class BloodPressureChartPainter extends CustomPainter {
  final List<BloodPressureData> data;

  BloodPressureChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double padding = 20;
    final double chartHeight = height - padding * 2;
    final double chartWidth = width - padding * 2;

    // 배경 그리드 라인 그리기
    _drawGridLines(canvas, size, padding, chartHeight);

    // 혈압 값을 표시할 각 포인트 간의 간격
    final double pointSpacing = chartWidth / (data.length - 1);

    // 혈압 값 표시
    _drawPressureValues(canvas, padding, pointSpacing);

    // 맥박 선 그리기
    _drawHeartRateLine(canvas, padding, pointSpacing, chartHeight);

    // 혈압 막대 그리기
    _drawPressureBars(canvas, padding, pointSpacing, chartHeight);

    // 날짜 표시
    _drawDates(canvas, padding, pointSpacing, height);
  }

  void _drawGridLines(
      Canvas canvas, Size size, double padding, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // 수평 그리드 라인
    for (int i = 0; i <= 5; i++) {
      final y = padding + chartHeight / 5 * i;
      canvas.drawLine(
          Offset(padding, y), Offset(size.width - padding, y), paint);
    }
  }

  void _drawPressureValues(Canvas canvas, double padding, double pointSpacing) {
    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * pointSpacing;
      final text = "${data[i].systolic}/${data[i].diastolic}";

      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, padding - 20));
    }
  }

  void _drawHeartRateLine(
      Canvas canvas, double padding, double pointSpacing, double chartHeight) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final textStyle = const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 포인트 위치 계산
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = padding + i * pointSpacing;
      final y = padding + chartHeight / 2; // 중간 위치에 맥박 표시
      points.add(Offset(x, y));
    }

    // 곡선 그리기
    if (points.length > 1) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];

        // 두 점 사이에 곡선 설정
        final controlPointX = (current.dx + next.dx) / 2;
        path.quadraticBezierTo(controlPointX, current.dy, next.dx, next.dy);
      }

      canvas.drawPath(path, linePaint);
    }

    // 맥박 원과 텍스트 그리기
    for (int i = 0; i < data.length; i++) {
      final x = points[i].dx;
      final y = points[i].dy;

      // 맥박 원형 배경
      canvas.drawCircle(Offset(x, y), 24, circlePaint);

      // 맥박 텍스트
      textPainter.text =
          TextSpan(text: "${data[i].heartRate}", style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawPressureBars(
      Canvas canvas, double padding, double pointSpacing, double chartHeight) {
    for (int i = 0; i < data.length; i++) {
      final x = padding + i * pointSpacing;
      final barWidth = 30.0;

      // 혈압 유형에 따른 색상 선택
      final color = _getColorForPressureType(data[i].pressureType);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // 혈압 막대 그리기
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, padding + chartHeight / 2),
          width: barWidth,
          height: 100, // 막대 높이 조정
        ),
        const Radius.circular(15),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  void _drawDates(
      Canvas canvas, double padding, double pointSpacing, double height) {
    final textStyle = TextStyle(color: Colors.grey, fontSize: 12);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * pointSpacing;

      textPainter.text = TextSpan(text: data[i].date, style: textStyle);
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, height - padding));
    }
  }

  Color _getColorForPressureType(PressureType type) {
    switch (type) {
      case PressureType.low:
        return Colors.blue;
      case PressureType.normal:
        return Colors.green;
      case PressureType.warning:
        return Color(0xFFB8DC44); // 연한 녹색
      case PressureType.high:
        return Colors.red;
    }
  }

  @override
  bool shouldRepaint(BloodPressureChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

class BloodPressureData {
  final String date;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final PressureType pressureType;

  BloodPressureData({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.pressureType,
  });
}

enum PressureType {
  low, // 저혈압
  normal, // 정상
  warning, // 주의혈압
  high, // 고혈압
}
