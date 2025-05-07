class SensorEvent {
  final String direction;
  final DateTime timestamp;

  SensorEvent({required this.direction, required this.timestamp});

  factory SensorEvent.fromJson(Map<String, dynamic> json) {
    return SensorEvent(
      direction: json['direction'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
