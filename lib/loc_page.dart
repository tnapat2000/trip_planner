import 'package:flutter/material.dart';
import 'package:trip_planner/base_card.dart';
import 'package:trip_planner/constant.dart';
import 'package:trip_planner/day_class.dart';
import 'package:trip_planner/sql_db.dart';

class LocPage extends StatelessWidget {
  LocPage({required this.carryOver});

  // Day got carried over from previous page
  final Day carryOver;
  int latestId = 1;

  // receive user's input
  var nameController = TextEditingController();
  var startController = TextEditingController();
  var finishController = TextEditingController();

  // build a basecard
  Widget getBaseCardFromData(Day day) {
    return BaseCard(
        cardColor: locCardColor,
        cardChild: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: BaseCard(
                      cardColor: locDark,
                      cardChild: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onSubmitted: (text) {
                            Day updated = Day(
                                completed: carryOver.completed,
                                day: carryOver.day,
                                locId: carryOver.locId,
                                locName:
                                    text.isEmpty ? carryOver.locName : text,
                                arriveTime:
                                    int.parse(carryOver.arriveTime.toString()),
                                exitTime:
                                    int.parse(carryOver.exitTime.toString()));
                            SQLDB.instance.updateDay(updated);
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                              hintText: carryOver.locName,
                              hintStyle: const TextStyle(
                                  color: locTextColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: BaseCard(
                        cardColor: locDark,
                        cardChild: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            onSubmitted: (text) {
                              Day updated = Day(
                                  completed: carryOver.completed,
                                  day: carryOver.day,
                                  locId: carryOver.locId,
                                  locName: carryOver.locName,
                                  arriveTime: text.isEmpty
                                      ? carryOver.arriveTime
                                      : int.parse(text),
                                  exitTime: carryOver.exitTime);
                              SQLDB.instance.updateDay(updated);
                            },
                            controller: startController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                // labelText: "Start Time",
                                hintText: carryOver.arriveTime.toString(),
                                hintStyle: const TextStyle(
                                    color: locTextColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))),
                Expanded(
                    flex: 1,
                    child: BaseCard(
                        cardColor: locDark,
                        cardChild: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            onSubmitted: (text) {
                              Day updated = Day(
                                  day: carryOver.day,
                                  completed: carryOver.completed,
                                  locId: carryOver.locId,
                                  locName: carryOver.locName,
                                  arriveTime: carryOver.arriveTime,
                                  exitTime: text.isEmpty
                                      ? carryOver.exitTime
                                      : int.parse(text));
                              SQLDB.instance.updateDay(updated);
                            },
                            controller: finishController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: carryOver.exitTime.toString(),
                                hintStyle: const TextStyle(
                                    color: locTextColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))),
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: locBg,
      appBar: AppBar(
        actions: [
          // delete location button
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.redAccent,
                child: IconButton(
                  onPressed: () async {
                    SQLDB.instance.deleteLoc(carryOver.locId);
                    // go back to previous page after deleting
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    size: 25,
                  ),
                ),
              )),
        ],
        title: const Text(
          "Edit Information",
          style: TextStyle(fontWeight: FontWeight.bold, color: locTextColor),
        ),
        backgroundColor: locHeadColor,
      ),
      body: Column(
        children: [
          getBaseCardFromData(carryOver),
        ],
      ),
      // save after editing information
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                backgroundColor: planCardColor,
                child: const Icon(Icons.save, size: 40),
                onPressed: () async {
                  Day updated = Day(
                      day: carryOver.day,
                      completed: carryOver.completed,
                      locId: carryOver.locId,
                      locName: nameController.text.isEmpty
                          ? carryOver.locName
                          : nameController.text,
                      arriveTime: startController.text.isEmpty
                          ? carryOver.arriveTime
                          : int.parse(startController.text),
                      exitTime: finishController.text.isEmpty
                          ? carryOver.exitTime
                          : int.parse(finishController.text));
                  SQLDB.instance.updateDay(updated);
                  // go back to previous page after editing
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
