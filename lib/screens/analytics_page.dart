import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../models/mood_entry.dart';
import '../services/analytics_service.dart';
import '../constants/mood_data.dart';
import '../utils/animations.dart';
import '../services/theme_service.dart';

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
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Mood Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: widget.moodEntries.isEmpty 
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransitionAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _buildInsightsCards(insights),
                  ),
                  const SizedBox(height: 24),
                  SlideTransitionAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTimeRangeSelector(),
                  ),
                  const SizedBox(height: 24),
                  SlideTransitionAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: _buildMoodTrendChart(recentEntries),
                  ),
                  const SizedBox(height: 24),
                  SlideTransitionAnimation(
                    delay: const Duration(milliseconds: 800),
                    child: _buildMoodDistributionChart(),
                  ),
                  const SizedBox(height: 24),
                  SlideTransitionAnimation(
                    delay: const Duration(milliseconds: 1000),
                    child: _buildMoodFrequencyList(),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SlideTransitionAnimation(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'No Data Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your moods to see analytics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCards(Map<String, dynamic> insights) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildInsightCard(
            'Most Common Mood',
            insights['mostCommonMood'] ?? 'N/A',
            Icons.mood,
            ThemeService.primaryGradient,
          ),
          _buildInsightCard(
            'Average Mood',
            insights['averageMood'] ?? 'N/A',
            Icons.analytics,
            ThemeService.secondaryGradient,
          ),
          _buildInsightCard(
            'Total Entries',
            '${widget.moodEntries.length}',
            Icons.calendar_today,
            LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Gradient gradient) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: GlowAnimation(
        glowColor: gradient.colors.first.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            color: Colors.white,
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
                  label: Text(
                    '$days days',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedDays = days;
                    });
                  },
                  backgroundColor: Colors.white10,
                  selectedColor: Theme.of(context).primaryColor,
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
                color: Colors.white,
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
                              return const Text('😢', style: TextStyle(fontSize: 16, color: Colors.white));
                            case 2:
                              return const Text('😔', style: TextStyle(fontSize: 16, color: Colors.white));
                            case 3:
                              return const Text('😐', style: TextStyle(fontSize: 16, color: Colors.white));
                            case 4:
                              return const Text('😊', style: TextStyle(fontSize: 16, color: Colors.white));
                            case 5:
                              return const Text('🤩', style: TextStyle(fontSize: 16, color: Colors.white));
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
                color: Colors.white,
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
                color: Colors.white,
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
                    Text(MoodData.getMoodEmoji(entry.key), style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key, style: TextStyle(color: Colors.white))),
                    Text('${entry.value} times', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Text('(${percentage.toStringAsFixed(1)}%)', style: TextStyle(color: Colors.white)),
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
