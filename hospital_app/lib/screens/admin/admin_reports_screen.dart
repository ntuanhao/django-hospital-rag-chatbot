// lib/screens/admin/admin_reports_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Providers & models
import 'package:hospital_app/providers/admin_reports_provider.dart'
    show
        appointmentsReportProvider,
        appointmentStatusReportProvider,
        stockSummaryReportProvider,
        reportTimeRangeProvider,
        stockOverTimeReportProvider,

        ReportTimeRange;

import 'package:hospital_app/models/report_data_point.dart';

// ================== SCREEN: 3 TABS ==================
class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Báo cáo & Thống kê'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lịch hẹn', icon: Icon(Icons.trending_up)),
              Tab(text: 'Kho thuốc', icon: Icon(Icons.inventory_2)),
              Tab(text: 'Trạng thái', icon: Icon(Icons.pie_chart)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AppointmentsTab(),
            _StockTab(),
            _StatusTab(),
          ],
        ),
      ),
    );
  }
}

// ============== TAB 1: Lịch hẹn (Line chart) ==============
class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(reportTimeRangeProvider);
    final reportDataAsync = ref.watch(appointmentsReportProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Phân tích Lịch hẹn',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Chọn 7 ngày / 30 ngày
        SegmentedButton<ReportTimeRange>(
          style: SegmentedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          segments: const [
            ButtonSegment(
              value: ReportTimeRange.week,
              label: Text('7 ngày'),
              icon: Icon(Icons.calendar_view_week),
            ),
            ButtonSegment(
              value: ReportTimeRange.month,
              label: Text('30 ngày'),
              icon: Icon(Icons.calendar_month),
            ),
          ],
          selected: {selectedRange},
          onSelectionChanged: (sel) =>
              ref.read(reportTimeRangeProvider.notifier).setTimeRange(sel.first),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 300,
          child: reportDataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Không thể tải dữ liệu: $e')),
            data: (points) => points.isEmpty
                ? const Center(child: Text('Không có dữ liệu.'))
                : _AppointmentsLineChart(data: points),
          ),
        ),
      ],
    );
  }
}

// ============== TAB 2: Kho thuốc (Line chart 3 màu theo ngày) ==============
class _StockTab extends ConsumerWidget {
  const _StockTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockOverTimeReportProvider); // ✅ dùng provider mới

    return Padding(
      padding: const EdgeInsets.all(16),
      child: stockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (points) => points.isEmpty
            ? const Center(child: Text('Không có dữ liệu.'))
            : _StockTimeSeriesLineChart(data: points),
      ),
    );
  }
}


class _StockTimeSeriesLineChart extends StatelessWidget {
  final List<StockReportPoint> data;
  const _StockTimeSeriesLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final inSpots = <FlSpot>[];
    final outManualSpots = <FlSpot>[];
    final outPrescriptionSpots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < data.length; i++) {
      final p = data[i];
      inSpots.add(FlSpot(i.toDouble(), p.stockIn.toDouble()));
      outManualSpots.add(FlSpot(i.toDouble(), p.stockOutManual.toDouble()));
      outPrescriptionSpots.add(FlSpot(i.toDouble(), p.stockOutPrescription.toDouble()));
      maxY = [
        maxY,
        p.stockIn.toDouble(),
        p.stockOutManual.toDouble(),
        p.stockOutPrescription.toDouble()
      ].reduce((a, b) => a > b ? a : b);
    }

    double xStep() {
      if (data.length <= 7) return 1;
      if (data.length <= 14) return 2;
      if (data.length <= 21) return 3;
      return (data.length / 6).ceilToDouble();
    }

    double yStep() {
      if (maxY <= 5) return 1;
      if (maxY <= 10) return 2;
      if (maxY <= 20) return 5;
      return (maxY / 4).ceilToDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // chừa thêm đáy để không cắt chữ "Ngày" hoặc tick labels
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minX: -0.5,
                maxX: (data.length - 1).toDouble() + 0.5,
                minY: 0,
                maxY: maxY + (maxY * 0.2),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.black12, strokeWidth: .6),
                  getDrawingVerticalLine: (_) =>
                      const FlLine(color: Colors.black12, strokeWidth: .6),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black26),
                    bottom: BorderSide(color: Colors.black26),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: inSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.green,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: outManualSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.orange,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: outPrescriptionSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.red,
                    dotData: const FlDotData(show: true),
                  ),
                ],

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Ngày',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    // tăng kích thước vùng tên trục để tránh bị cắt
                    axisNameSize: 32,
                    sideTitles: SideTitles(
                      showTitles: true,
                      // tăng reserve để không cắt tick labels dưới
                      reservedSize: 44,
                      interval: xStep(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final label = DateFormat('dd/MM').format(data[idx].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label, style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    axisNameSize: 26,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      interval: yStep(),
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      final i = s.x.toInt();
                      String label;
                      if (s.bar.color == Colors.green) {
                        label = 'Nhập kho';
                      } else if (s.bar.color == Colors.orange) {
                        label = 'Xuất TC';
                      } else {
                        label = 'Kê đơn';
                      }
                      final count = s.y.toInt();
                      return LineTooltipItem(
                        '${DateFormat('dd/MM').format(data[i].date)}\n$label: $count',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: const [
            _LegendDot(color: Colors.green, label: 'Nhập kho'),
            _LegendDot(color: Colors.orange, label: 'Xuất TC'),
            _LegendDot(color: Colors.red, label: 'Kê đơn'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}



// ============== TAB 3: Trạng thái lịch hẹn (Pie chart) ==============
class _StatusTab extends ConsumerWidget {
  const _StatusTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(appointmentStatusReportProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Không có dữ liệu.'))
            : _AppointmentStatusPieChart(data: items),
      ),
    );
  }
}

// ================== REUSABLE CHARTS ==================

// ---- Line Chart: Lịch hẹn ----
class _AppointmentsLineChart extends StatelessWidget {
  final List<ReportDataPoint> data;
  const _AppointmentsLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxCount =
        data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    final spots = <FlSpot>[
      for (int i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].count.toDouble()),
    ];

    double xStep() {
      if (data.length <= 7) return 1;
      if (data.length <= 14) return 2;
      if (data.length <= 21) return 3;
      return (data.length / 6).ceilToDouble();
    }

    double yStep() {
      if (maxCount <= 5) return 1;
      if (maxCount <= 10) return 2;
      if (maxCount <= 20) return 5;
      return (maxCount / 4).ceilToDouble();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24), // chừa thêm đáy cho nhãn/axis name
      child: LineChart(
        LineChartData(
          minX: -0.5,
          maxX: (data.length - 1).toDouble() + 0.5,
          minY: 0,
          maxY: maxCount + (maxCount * 0.2),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Colors.black12, strokeWidth: .6),
            getDrawingVerticalLine: (_) =>
                const FlLine(color: Colors.black12, strokeWidth: .6),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black26),
              bottom: BorderSide(color: Colors.black26),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: true),
            ),
          ],

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Ngày', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              axisNameSize: 32, // tăng để không cắt chữ
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44, // tăng chỗ cho tick labels
                interval: xStep(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('dd/MM').format(data[idx].date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text('Số lịch hẹn',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              axisNameSize: 26,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: yStep(),
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 10)),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}


// ---- Line Chart: Kho thuốc (3 đường) ----
class _StockSummaryLineChart extends StatelessWidget {
  final StockSummaryReport data;
  const _StockSummaryLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.green, Colors.orange, Colors.red];
    final labels = ['Nhập kho', 'Xuất TC', 'Kê đơn'];
    final values = [
      data.stockIn.toDouble(),
      data.stockOutManual.toDouble(),
      data.stockOutPrescription.toDouble()
    ];

    final spotsList = List.generate(3, (i) => [FlSpot(i.toDouble(), values[i])]);
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.3;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: -0.2,
              maxX: 2.2,
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black26),
                  bottom: BorderSide(color: Colors.black26),
                ),
              ),
              lineBarsData: List.generate(3, (i) {
                return LineChartBarData(
                  spots: spotsList[i],
                  color: colors[i],
                  barWidth: 4,
                  isCurved: false,
                  dotData: const FlDotData(show: true),
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Hoạt động', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, m) {
                      final i = v.toInt();
                      if (i >= 0 && i < labels.length) {
                        return Text(labels[i],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child:
                        Text('Số lượng', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, m) =>
                        Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: List.generate(3, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, color: colors[i]),
                const SizedBox(width: 6),
                Text(labels[i], style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ---- Pie Chart: Trạng thái ----
class _AppointmentStatusPieChart extends StatefulWidget {
  final List<AppointmentStatusReport> data;
  const _AppointmentStatusPieChart({required this.data});

  @override
  State<StatefulWidget> createState() => _AppointmentStatusPieChartState();
}

class _AppointmentStatusPieChartState extends State<_AppointmentStatusPieChart> {
  int touchedIndex = -1;

  Color _getColorForStatus(String statusDisplay) {
    switch (statusDisplay) {
      case 'Đã hoàn thành khám':
        return Colors.green;
      case 'Đã xác nhận':
        return Colors.blue;
      case 'Chờ Lễ tân xác nhận':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.grey;
      case 'Đã check-in':
        return Colors.teal;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, res) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        res == null ||
                        res.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = res.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _showSections(),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.data.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: _getColorForStatus(item.statusDisplay)),
                  const SizedBox(width: 8),
                  Text('${item.statusDisplay} (${item.count})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showSections() {
    return widget.data.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final isTouched = i == touchedIndex;
      return PieChartSectionData(
        color: _getColorForStatus(item.statusDisplay),
        value: item.count.toDouble(),
        title: isTouched ? '${item.count}' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}
