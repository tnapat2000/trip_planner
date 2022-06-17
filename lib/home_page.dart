import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trip_planner/day_class.dart';
import 'package:trip_planner/day_page.dart';
import 'package:trip_planner/sql_db.dart';
import 'constant.dart';

import 'base_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // int latestDay = 1;
  late List<Day> allDays = [];
  late List<int> allDayNum = [];
  late int latestDay = 1;

  Future refreshDays() async {
    allDays = await SQLDB.instance.allDays();
    allDayNum = (await SQLDB.instance.getAllDayNum()).toSet().toList();
    // print(allDayNum.toSet().toList());
    latestDay = allDayNum.reduce(max) + 1;
  }

  Widget getBaseCardFromData(int dayNum) {
    return Column(
      children: [
        SizedBox(
          width: 10,
          height: 5,
        ),
        Container(
          width: 300,
          child: BaseCard(
            cardColor: Colors.lightGreen,
            cardChild: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Day " + dayNum.toString(),
                    style: TextStyle(fontSize: 35, color: planTextColor),
                  ),
                ),
                // SizedBox(width: 20,),
                const Icon(
                  Icons.arrow_right_alt,
                  size: 40,
                  color: planTextColor,
                )
              ],
            ),
            cardOnTapFunc: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DayPage(carryOverDayNum: dayNum)));
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    refreshDays();
    return Scaffold(
      backgroundColor: planBg,
      appBar: AppBar(
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.redAccent,
                child: IconButton(
                  onPressed: () async {
                    SQLDB.instance.emptyTable();
                    setState(() {
                      refreshDays();
                      latestDay = 1;
                    });
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    size: 25,
                  ),
                ),
              )),
        ],
        backgroundColor: planDark,
        title: Text(
          "TRIP PLANNER",
          style: TextStyle(fontWeight: FontWeight.bold, color: planTextColor),
        ),
      ),
      body: Center(
        child: FutureBuilder<List<int>>(
            future: SQLDB.instance.getAllDayNum(),
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text(
                        "no plan...",
                        style: TextStyle(fontSize: 30, color: planDark),
                      ),
                    )
                  : ListView(
                      children: snapshot.data!.map((day) {
                        return getBaseCardFromData(
                          day,
                        );
                      }).toList(),
                    );
            }),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                heroTag: "add",
                backgroundColor: planHeadColor,
                child: Icon(Icons.add, size: 40),
                onPressed: () async {
                  Day newDay = Day(
                      day: latestDay,
                      locId: 1,
                      locName: "New Location 1",
                      arriveTime: 0,
                      exitTime: 0,
                      completed: 0);
                  SQLDB.instance.insertDay(newDay);
                  print(await SQLDB.instance.allDays());
                  setState(() {
                    refreshDays();
                  });
                  latestDay += 1;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
