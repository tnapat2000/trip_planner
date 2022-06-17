import 'package:flutter/material.dart';
import 'package:trip_planner/constant.dart';
import 'package:trip_planner/day_class.dart';
import 'package:trip_planner/loc_page.dart';
import 'sql_db.dart';
import 'dart:math';

import 'base_card.dart';

// use statefulwidget because I need setState()
class DayPage extends StatefulWidget {
  DayPage({required this.carryOverDayNum});

  // day number that got carried from previous page
  final int carryOverDayNum;
  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  late List<Day> allLocs = [];
  late List<int> allLocIds = [];
  late int latestId = 2;

  // refresh information and latest index
  Future refreshDays(int dayNum) async {
    allLocs = await SQLDB.instance.allSpecificDay(dayNum);
    allLocIds = await SQLDB.instance.getAllLocIds(dayNum);
    latestId = (allLocIds.isEmpty ? latestId : allLocIds.reduce(max) + 1);
  }

  // create basecard from day
  Widget getBaseCardFromData(Day day, Key? key) {
    return BaseCard(
        key: key,
        // push into location page
        cardOnTapFunc: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => LocPage(carryOver: day)));
          setState(() {
            refreshDays(widget.carryOverDayNum);
          });
        },
        cardColor: day.completed == 1 ? dayDark : dayBright,
        cardChild: Row(
          children: [
            // check if visited
            Expanded(
                flex: 2,
                child: BaseCard(
                  cardOnTapFunc: () {
                    Day updated = Day(
                        day: day.day,
                        locId: day.locId,
                        locName: day.locName,
                        arriveTime: day.arriveTime,
                        exitTime: day.exitTime,
                        completed: day.completed == 0 ? 1 : 0);
                    SQLDB.instance.updateDay(updated);
                    setState(() {
                      refreshDays(widget.carryOverDayNum);
                    });
                  },
                  cardColor: planHeadColor,
                  cardChild: const SizedBox(
                      height: 80,
                      width: 10,
                      child: Icon(
                        Icons.check,
                        size: 40,
                      )),
                )),
            // location information
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  // location name
                  Row(
                    children: [
                      Expanded(
                        child: BaseCard(
                            cardColor: dayCardColor,
                            cardChild: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(day.locName),
                            )),
                      )
                    ],
                  ),
                  // arrive & exit time
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: BaseCard(
                              cardColor: dayHeadColor,
                              cardChild: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(day.arriveTime.toString())),
                              ))),
                      Expanded(
                          flex: 2,
                          child: BaseCard(
                              cardColor: dayHeadColor,
                              cardChild: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(day.exitTime.toString())),
                              ))),
                    ],
                  )
                ],
              ),
            ),
            // Fake button to let user know that they can reorder the location
            Expanded(
                flex: 2,
                child: BaseCard(
                  cardColor: dayDark,
                  cardChild: const SizedBox(
                      height: 80,
                      width: 10,
                      child: Icon(
                        Icons.unfold_more,
                        size: 40,
                      )),
                ))
          ],
        ));
  }

  // turn all location into basecard widget
  late List<Widget> widgetList = allLocs
      .map((day) => getBaseCardFromData(day, Key(day.locId.toString())))
      .toList();

  @override
  Widget build(BuildContext context) {
    refreshDays(widget.carryOverDayNum);
    int carryOverDayNum = widget.carryOverDayNum;
    return Scaffold(
      backgroundColor: dayBg,
      appBar: AppBar(
        backgroundColor: dayHeadColor,
        title: Text(
          "Day $carryOverDayNum",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: dayTextColor),
        ),
      ),
      body: Center(
        // generate list of widget
        child: FutureBuilder<List<Day>>(
            future: SQLDB.instance.allSpecificDay(carryOverDayNum),
            builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text(
                        "no where to go...",
                        style: TextStyle(fontSize: 30, color: dayDark),
                      ),
                    )
                  // reorderable list view
                  : ReorderableListView(
                      children: List.generate(snapshot.data!.length, (index) {
                        return getBaseCardFromData(snapshot.data![index],
                            Key(snapshot.data![index].locId.toString()));
                      }).toList(),
                      // swap data from one location to another when user swaps the card
                      onReorder: (int oldIndex, int newIndex) {
                        if (newIndex > allLocs.length) {
                          newIndex = allLocs.length;
                        }
                        if (oldIndex < newIndex) newIndex -= 1;

                        setState(() {
                          final Day oldItem = allLocs[oldIndex];
                          final Day newItem = allLocs[newIndex];

                          Day updatedOldItem = Day(
                              day: newItem.day,
                              locId: newItem.locId,
                              locName: oldItem.locName,
                              arriveTime: oldItem.arriveTime,
                              exitTime: oldItem.exitTime,
                              completed: oldItem.completed);

                          Day updatedNewItem = Day(
                              day: oldItem.day,
                              locId: oldItem.locId,
                              locName: newItem.locName,
                              arriveTime: newItem.arriveTime,
                              exitTime: newItem.exitTime,
                              completed: newItem.completed);

                          SQLDB.instance.updateDay(updatedOldItem);
                          SQLDB.instance.updateDay(updatedNewItem);

                          // update basecard ordering
                          allLocs.removeAt(oldIndex);
                          allLocs.insert(newIndex, oldItem);
                          allLocs.insert(oldIndex, updatedNewItem);
                        });
                      });
            }),
      ),
      // add new location
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                heroTag: "add",
                backgroundColor: dayHeadColor,
                child: const Icon(Icons.add, size: 40),
                onPressed: () async {
                  Day newDay = Day(
                      day: carryOverDayNum,
                      locId: latestId,
                      locName: "New Location " + latestId.toString(),
                      arriveTime: 0,
                      exitTime: 0,
                      completed: 0);
                  SQLDB.instance.insertDay(newDay);
                  setState(() {
                    refreshDays(carryOverDayNum);
                  });
                  // latestId += 1;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
