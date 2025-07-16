import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../models/mood_entry.dart';
import '../services/analytics_service.dart';
import '../constants/mood_data.dart';
import '../utils/animations.dart';
import '../services/theme_service.dart';
import '../viewmodels/view_models.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int selectedDays = 7;

  @override
  void initState() {
    super.initState();
    
    // Initialize analytics view model when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moodViewModel = context.read<MoodViewModel>();
      final analyticsViewModel = context.read<AnalyticsViewModel>();
      analyticsViewModel.initialize(moodViewModel.moodEntries);
    });
  }

  @override
  Widget build(BuildContext context) {
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
        body: Consumer2<AnalyticsViewModel, MoodViewModel>(
          builder: (context, analyticsViewModel, moodViewModel, child) {
            // Update analytics view model when mood entries change
            analyticsViewModel.updateMoodEntries(moodViewModel.moodEntries);
            
            final moodEntries = moodViewModel.moodEntries;
            
            if (moodEntries.isEmpty) {
              return _buildEmptyState();
            }
            
            final insights = AnalyticsService.getMoodInsights(moodEntries);
            final recentEntries = AnalyticsService.getEntriesForLastDays(moodEntries, selectedDays);
            
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInsightsCards(insights, moodEntries),
                  const SizedBox(height: 24),
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 24),
                  _buildMoodTrendChart(recentEntries),
                  const SizedBox(height: 24),
                  _buildMoodDistributionChart(moodEntries),
                  const SizedBox(height: 24),
                  _buildMoodFrequencyList(moodEntries),
                ],
              ),
            );
          },
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
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
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
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Data Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some mood entries to see your analytics',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCards(Map<String, dynamic> insights, List<MoodEntry> moodEntries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Total Entries',
                '${moodEntries.length}',
                Icons.bar_chart,
                ThemeService.primaryGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                'Most Frequent',
                insights['mostFrequentMood'] ?? 'N/A',
                Icons.favorite,
                LinearGradient(
                  colors: [Colors.pink.shade400, Colors.pink.shade600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                'Current Streak',
                '${insights['currentStreak'] ?? 0} days',
                Icons.local_fire_department,
                LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                'Average/Day',
                '${(insights['averagePerDay'] ?? 0.0).toStringAsFixed(1)}',
                Icons.timeline,
                LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Gradient gradient) {
    return SlideTransitionAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
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
    );
  }

  Widget _buildTimeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [7, 14, 30].map((days) {
            final isSelected = selectedDays == days;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => selectedDays = days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? ThemeService.primaryGradient
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      '${days}D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodTrendChart(List<MoodEntry> entries) {
    return SlideTransitionAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'No data for selected period',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateSpots(entries),
                            isCurved: true,
                            gradient: ThemeService.primaryGradient,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
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

  List<FlSpot> _generateSpots(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];
    
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length && i < 10; i++) {
      final entry = entries[i];
      final moodValue = _getMoodValue(entry.mood);
      spots.add(FlSpot(i.toDouble(), moodValue));
    }
    return spots;
  }

  double _getMoodValue(String mood) {
    const moodValues = {
      'Terrible': 1,
      'Bad': 2,
      'Okay': 3,
      'Good': 4,
      'Great': 5,
    };
    return moodValues[mood]?.toDouble() ?? 3.0;
  }

  Widget _buildMoodDistributionChart(List<MoodEntry> moodEntries) {
    final chartData = AnalyticsService.getMoodDistributionChart(moodEntries);
    
    return SlideTransitionAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        'No mood data available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: chartData.map<PieChartSectionData>((data) {
                          final moodData = data as Map<String, dynamic>;
                          return PieChartSectionData(
                            color: MoodData.getMoodColor(moodData['mood']),
                            value: moodData['value'].toDouble(),
                            title: '${moodData['value']}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodFrequencyList(List<MoodEntry> moodEntries) {
    final frequency = AnalyticsService.getMoodFrequency(moodEntries);
    
    return SlideTransitionAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Frequency',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...frequency.entries.map((entry) {
              final percentage = (entry.value / moodEntries.length) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MoodData.getMoodColor(entry.key).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        MoodData.getMoodEmoji(entry.key),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              MoodData.getMoodColor(entry.key),
                            ),
                          ),
                        ],
                      ),
                    ),
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
