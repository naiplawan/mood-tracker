import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../services/analytics_service.dart';
import '../constants/mood_data.dart';

class AnalyticsPage extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const AnalyticsPage({super.key, required this.moodEntries});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final insights = AnalyticsService.getMoodInsights(widget.moodEntries);
    final recentEntries = AnalyticsService.getEntriesForLastDays(widget.moodEntries, selectedDays);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analytics'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: widget.moodEntries.isEmpty 
        ? _buildEmptyState()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightsCards(insights),
                const SizedBox(height: 24),
                _buildTimeRangeSelector(),
                const SizedBox(height: 16),
                _buildMoodTrendChart(recentEntries),
                const SizedBox(height: 24),
                _buildMoodDistributionChart(),
                const SizedBox(height: 24),
                _buildMoodFrequencyList(),
              ],
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Data to Analyze',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your moods to see analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCards(Map<String, dynamic> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildInsightCard(
              'Total Entries',
              insights['totalEntries'].toString(),
              Icons.edit_note,
              Colors.blue,
            ),
            _buildInsightCard(
              'Average Mood',
              insights['averageMood'],
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightCard(
              'Most Frequent',
              insights['mostFrequentMood'],
              Icons.favorite,
              Colors.red,
            ),
            _buildInsightCard(
              'Current Streak',
              '${insights['streak']} days',
              Icons.local_fire_department,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [7, 14, 30, 90].map((days) {
              final isSelected = selectedDays == days;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('${days} days'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedDays = days;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendChart(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No data for selected time range'),
          ),
        ),
      );
    }

    final trendData = AnalyticsService.getMoodTrendData(entries, selectedDays);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 1:
                              return const Text('😢', style: TextStyle(fontSize: 16));
                            case 2:
                              return const Text('😔', style: TextStyle(fontSize: 16));
                            case 3:
                              return const Text('😐', style: TextStyle(fontSize: 16));
                            case 4:
                              return const Text('😊', style: TextStyle(fontSize: 16));
                            case 5:
                              return const Text('🤩', style: TextStyle(fontSize: 16));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: trendData.length.toDouble() - 1,
                  minY: 1,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: trendData,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart() {
    final chartData = AnalyticsService.getMoodDistributionChart(widget.moodEntries);
    
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: chartData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodFrequencyList() {
    final frequency = AnalyticsService.getMoodFrequency(widget.moodEntries);
    final sortedMoods = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedMoods.map((entry) {
              final percentage = (entry.value / widget.moodEntries.length) * 100;
              final color = MoodData.getMoodColor(entry.key);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(MoodData.getMoodEmoji(entry.key)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value} times'),
                    const SizedBox(width: 8),
                    Text('(${percentage.toStringAsFixed(1)}%)'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
