import 'package:flutter/material.dart';
import 'package:trip_planner/base_card.dart';
import 'package:trip_planner/constant.dart';
import 'package:trip_planner/day_class.dart';
import 'package:trip_planner/sql_db.dart';

class LocPage extends StatelessWidget {
  LocPage({required this.carryOver});

  final Day carryOver;
  int latestId = 1;

  var nameController = TextEditingController();
  var startController = TextEditingController();
  var finishController = TextEditingController();

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
                              hintStyle: TextStyle(
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
                                hintStyle: TextStyle(
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
                                hintStyle: TextStyle(
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
        title: Text(
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
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                backgroundColor: planCardColor,
                child: Icon(Icons.save, size: 40),
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
                  print(updated.toString());
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Container(
                height: 70,
                width: 70,
                child: FloatingActionButton(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.delete_forever, size: 40),
                  onPressed: () async {
                    SQLDB.instance.deleteLoc(carryOver.locId);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
