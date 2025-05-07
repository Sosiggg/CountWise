import 'package:flutter/material.dart';
import 'models/event.dart';
import 'services/sensor_service.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(PeopleCounterApp());
}

class PeopleCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People Counter Dashboard',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.tealAccent,
        ),
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int peopleCount = 0;
  List<SensorEvent> log = [];

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  Future<void> _loadSensorData() async {
    try {
      final events = await SensorService.fetchEvents();
      final reversed = events.reversed.toList();
      setState(() {
        log = reversed;
        peopleCount = _calculatePeopleCount(reversed);
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  int _calculatePeopleCount(List<SensorEvent> events) {
    int count = 0;
    for (var e in events) {
      if (e.direction == 'IN') count++;
      if (e.direction == 'OUT' && count > 0) count--;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👥 People Counter Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadSensorData,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Dashboard Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(
                  title: 'Current Count',
                  value: '$peopleCount',
                  icon: Icons.people,
                  color: Colors.teal,
                ),
                DashboardCard(
                  title: 'Total Entries',
                  value: '${log.where((e) => e.direction == 'IN').length}',
                  icon: Icons.login,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Total Exits',
                  value: '${log.where((e) => e.direction == 'OUT').length}',
                  icon: Icons.logout,
                  color: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '📋 Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1),
            Expanded(
              child: log.isEmpty
                  ? Center(child: Text('No activity yet.'))
                  : ListView.builder(
                      itemCount: log.length,
                      itemBuilder: (context, index) {
                        final event = log[index];
                        final formattedTime = DateFormat('hh:mm:ss a').format(event.timestamp);
                        return Card(
                          color: Colors.grey[850],
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              event.direction == 'IN' ? Icons.login : Icons.logout,
                              color: event.direction == 'IN' ? Colors.green : Colors.red,
                            ),
                            title: Text('Direction: ${event.direction}'),
                            subtitle: Text('Time: $formattedTime'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
