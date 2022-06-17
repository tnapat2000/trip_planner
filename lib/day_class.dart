class Day {
  final int day;
  final int locId;
  final String locName;
  final int arriveTime;
  final int exitTime;
  final int completed;

  const Day(
      {required this.day,
      required this.locId,
      required this.locName,
      required this.arriveTime,
      required this.exitTime,
      required this.completed});

  Map<String, dynamic> toMap() {
    return {
      "day": day,
      "loc_id": locId,
      "loc_name": locName,
      "arrive_time": arriveTime,
      "exit_time": exitTime,
      "completed": completed
    };
  }

  @override
  String toString() {
    return "Day{day: $day, loc_id:$locId, loc_name:$locName, arrive_time:$arriveTime, exit_time:$exitTime}, completed:$completed";
  }
}
