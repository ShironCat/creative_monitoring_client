class Sensor {
  final String name;
  final bool status;
  final List<Stack> value;

  const Sensor({
    required this.name,
    required this.status,
    required this.value,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        name: json['name'] as String,
        status: json['status'] as bool,
        value: parseStacks(json['value']));
  }
}

List<Stack> parseStacks(List<dynamic> jsonList) {
  return jsonList.map((value) => Stack.fromJson(value)).toList();
}

class Stack {
  final String name;
  final int count;

  const Stack({
    required this.name,
    required this.count,
  });

  factory Stack.fromJson(Map<String, dynamic> json) {
    return Stack(name: json['name'] as String, count: json['count'] as int);
  }
}
