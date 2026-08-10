import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../models/dashboard_summary.dart';
import 'chart_legend.dart';
import 'empty_chart_placeholder.dart';

/// Biểu đồ thu/chi theo tháng (section 7) — luôn hiển thị 6 tháng gần nhất,
/// không phụ thuộc bộ lọc thời gian của Dashboard (để luôn thấy xu hướng dài hạn).
class MonthlyFlowChart extends StatelessWidget {
  const MonthlyFlowChart({super.key, required this.flows});

  final List<MonthlyFlow> flows;

  @override
  Widget build(BuildContext context) {
    if (flows.isEmpty || flows.every((f) => f.income == 0 && f.expense == 0)) {
      return const EmptyChartPlaceholder(message: 'Chưa có dữ liệu 6 tháng gần đây');
    }

    final maxValue = flows
        .expand((f) => [f.income, f.expense])
        .fold<int>(0, (max, v) => v > max ? v : max);
    final maxY = maxValue == 0 ? 1.0 : maxValue * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final flow = flows[group.x.toInt()];
                    final isIncome = rodIndex == 0;
                    final amount = isIncome ? flow.income : flow.expense;
                    return BarTooltipItem(
                      '${isIncome ? 'Vào' : 'Ra'}: ${CurrencyFormatter.format(amount)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= flows.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          AppDateFormatter.formatMonthLabel(flows[index].month),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < flows.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: flows[i].income.toDouble(),
                        color: AppColors.income,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: flows[i].expense.toDouble(),
                        color: AppColors.expense,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const ChartLegend(),
      ],
    );
  }
}
