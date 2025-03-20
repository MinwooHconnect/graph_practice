import 'package:flutter/material.dart';

class BloodPressureChartPage extends StatelessWidget {
  const BloodPressureChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(child: BloodPressureChart()),
      ),
    );
  }
}

class BloodPressureChart extends StatelessWidget {
  BloodPressureChart({super.key});

  final List<BloodPressureData> data = [
    BloodPressureData(
      date: "24.12.01",
      systolic: 140,
      diastolic: 91,
      heartRate: 100,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 100,
      diastolic: 70,
      heartRate: 72,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 140,
      diastolic: 90,
      heartRate: 115,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 120,
      diastolic: 100,
      heartRate: 110,
    ),
    BloodPressureData(
      date: "24.12.01",
      systolic: 140,
      diastolic: 100,
      heartRate: 130,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 300),
            painter: BloodPressureChartPainter(data, showGridValues: false),
          ),
        ),
        const SizedBox(height: 80),
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
        _legendItem(Colors.orange, "주의혈압"),
        _legendItem(Colors.red, "고혈압"),
        _legendItem(Colors.black, "맥박(bpm)"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 24,
            height: 24,
            color: color,
          ),
        ),
        const SizedBox(width: 9),
        Text(label, style: TextStyle(fontSize: 30)),
      ],
    );
  }
}

class BloodPressureChartPainter extends CustomPainter {
  final List<BloodPressureData> data;
  final bool showGridValues;
  final double spacingFactor;

  BloodPressureChartPainter(
    this.data, {
    this.showGridValues = false,
    this.spacingFactor = 0.85,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double padding = 0;
    final double chartHeight = height;
    final double chartWidth = width;

    // 배경 그리드 라인 그리기
    _drawGridLines(canvas, size, chartHeight);

    // 혈압 값을 표시할 각 포인트 간의 간격 (간격을 spacingFactor로 조절)
    final double pointSpacing = chartWidth / (data.length - 1) * spacingFactor;

    // 차트의 중앙에 배치하기 위한 시작 X 좌표 계산
    final startX = (width - (pointSpacing * (data.length - 1))) / 2;

    // 혈압 막대 그리기 (먼저 그리기)
    _drawPressureBars(canvas, pointSpacing, chartHeight, startX);

    // 맥박 선 그리기 (나중에 그리기)
    _drawHeartRateLine(canvas, pointSpacing, chartHeight, startX);

    // 혈압 값 표시
    _drawPressureValues(canvas, size, pointSpacing, startX);

    // 날짜 표시
    _drawDates(canvas, pointSpacing, height, startX);
  }

  void _drawGridLines(Canvas canvas, Size size, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // 최대 혈압 값 계산 (10의 배수로 올림)
    const defaultMaxPressure = 160;
    final maxSystolic =
        data.map((d) => d.systolic).reduce((a, b) => a > b ? a : b);
    final maxPressure = maxSystolic > defaultMaxPressure
        ? ((maxSystolic * 1.2).round() + 9) ~/ 10 * 10 // 10의 배수로 올림
        : defaultMaxPressure;
    const minPressure = 60;
    final pressureRange = maxPressure - minPressure;

    // 텍스트 스타일 설정
    final textStyle = TextStyle(color: Colors.grey, fontSize: 12);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 6개의 그리드 라인 그리기
    const numLines = 6;
    final step = pressureRange / (numLines - 1); // 간격 계산

    for (int i = 0; i < numLines; i++) {
      final pressureValue = maxPressure - (i * step);
      final y = i * chartHeight / (numLines - 1);

      // 그리드 라인 그리기
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      // 그리드 값 표시 옵션이 true일 때만 값 표시
      if (showGridValues) {
        final text = "${pressureValue.round()}";
        textPainter.text = TextSpan(text: text, style: textStyle);
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(-textPainter.width - 5, y - textPainter.height / 2));
      }
    }
  }

  void _drawPressureValues(
      Canvas canvas, Size size, double pointSpacing, double startX) {
    final textStyle = TextStyle(color: Colors.black, fontSize: 30);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 최대 혈압 값 계산
    const defaultMaxPressure = 160;
    final maxSystolic =
        data.map((d) => d.systolic).reduce((a, b) => a > b ? a : b);
    final maxPressure = maxSystolic > defaultMaxPressure
        ? (maxSystolic * 1.2).round()
        : defaultMaxPressure;
    const minPressure = 60;
    final pressureRange = maxPressure - minPressure;

    for (int i = 0; i < data.length; i++) {
      final x = startX + i * pointSpacing;
      final text = "${data[i].systolic}/${data[i].diastolic}";

      // 수축기 값을 정규화하여 막대 상단 위치 계산
      final normalizedSystolic =
          (data[i].systolic - minPressure) / pressureRange;
      final barTopY = (1 - normalizedSystolic) * size.height;

      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, barTopY - textPainter.height - 5));
    }
  }

  void _drawHeartRateLine(
      Canvas canvas, double pointSpacing, double chartHeight, double startX) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final textStyle = const TextStyle(
        color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 최대 혈압 값 계산
    const defaultMaxPressure = 160;
    final maxSystolic =
        data.map((d) => d.systolic).reduce((a, b) => a > b ? a : b);
    final maxPressure = maxSystolic > defaultMaxPressure
        ? (maxSystolic * 1.2).round()
        : defaultMaxPressure;
    const minPressure = 60;
    final pressureRange = maxPressure - minPressure;

    // 포인트 위치 계산
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = startX + i * pointSpacing;
      // 맥박 값을 혈압 범위에 맞게 변환
      final normalizedValue = (data[i].heartRate - minPressure) / pressureRange;
      final y = (1 - normalizedValue) * chartHeight;
      points.add(Offset(x, y));
    }

    // 직선 그리기
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        canvas.drawLine(current, next, linePaint);
      }
    }

    // 맥박 타원과 텍스트 그리기
    for (int i = 0; i < data.length; i++) {
      final x = points[i].dx;
      final y = points[i].dy;

      // 작은 원 그리기 (점)
      canvas.drawCircle(Offset(x, y), 9, circlePaint);

      // 둥근 직사각형 그리기 (점 아래에 배치)
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y + 32),
          width: 72,
          height: 38,
        ),
        const Radius.circular(24),
      );
      canvas.drawRRect(rect, circlePaint);

      // 맥박 텍스트
      textPainter.text =
          TextSpan(text: "${data[i].heartRate}", style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, y + 30 - textPainter.height / 2));
    }
  }

  void _drawPressureBars(
      Canvas canvas, double pointSpacing, double chartHeight, double startX) {
    // 최대 혈압 값 계산
    const defaultMaxPressure = 160;
    final maxSystolic =
        data.map((d) => d.systolic).reduce((a, b) => a > b ? a : b);
    final maxPressure = maxSystolic > defaultMaxPressure
        ? (maxSystolic * 1.2).round()
        : defaultMaxPressure;
    const minPressure = 60;
    final pressureRange = maxPressure - minPressure;

    for (int i = 0; i < data.length; i++) {
      final x = startX + i * pointSpacing;
      final barWidth = 48.0;

      // 혈압 유형에 따른 색상 선택
      final color = _getColorForPressureType(data[i].pressureType);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // 이완기와 수축기 값을 정규화
      final normalizedDiastolic =
          (data[i].diastolic - minPressure) / pressureRange;
      final normalizedSystolic =
          (data[i].systolic - minPressure) / pressureRange;

      // 막대의 시작 높이(이완기)와 전체 높이 계산
      final startY = chartHeight - (normalizedDiastolic * chartHeight);
      final barHeight =
          (normalizedSystolic - normalizedDiastolic) * chartHeight;

      // 혈압 막대 그리기 (이완기부터 수축기까지)
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - barWidth / 2,
          startY - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(24),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  void _drawDates(
      Canvas canvas, double pointSpacing, double height, double startX) {
    final textStyle = TextStyle(color: Colors.grey, fontSize: 30);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = startX + i * pointSpacing;

      textPainter.text = TextSpan(text: data[i].date, style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, height - 13));
    }
  }

  Color _getColorForPressureType(PressureType type) {
    switch (type) {
      case PressureType.low:
        return Colors.blue;
      case PressureType.normal:
        return Colors.green;
      case PressureType.warning:
        return Colors.orange;
      case PressureType.high:
        return Colors.red;
    }
  }

  @override
  bool shouldRepaint(BloodPressureChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.showGridValues != showGridValues ||
        oldDelegate.spacingFactor != spacingFactor;
  }
}

class BloodPressureData {
  final String date;
  final int systolic;
  final int diastolic;
  final int heartRate;
  late final PressureType pressureType;

  BloodPressureData({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    PressureType? pressureType,
  }) {
    // 혈압 유형 자동 계산
    this.pressureType = _calculatePressureType(systolic, diastolic);
  }

  PressureType _calculatePressureType(int systolic, int diastolic) {
    if (systolic < 90 && diastolic > 60) {
      return PressureType.low;
    } else if (systolic < 120 && diastolic > 80) {
      return PressureType.normal;
    } else if (systolic >= 120 && systolic < 140 && diastolic > 80) {
      return PressureType.warning;
    } else if (systolic >= 140 && diastolic > 90) {
      return PressureType.high;
    } else {
      // 기본값으로 정상 반환
      return PressureType.normal;
    }
  }
}

enum PressureType {
  low, // 저혈압: 수축기 90 미만, 이완기 60초과
  normal, // 정상: 수축기 120 미만, 이완기 80초과
  warning, // 주의혈압: 수축기 120~139, 이완기 80초과
  high, // 고혈압: 수축기 140 초과, 이완기 90초과
}
