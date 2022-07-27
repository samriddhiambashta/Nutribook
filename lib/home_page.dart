import 'package:calorie_check/user_preferences_track/user_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'health.dart';
import 'user_preferences_track/user_info.dart';
import 'user_preferences_track/user_helper.dart';
import 'package:flutter_spinbox/cupertino.dart';

//double temp = 0;

class HomeCards {
  double temp = 0;
  int wt = 0;
  late DatabaseHandlers handlers;
  Future<List<UserInfo>> userPref = Future.value([]);
  void fetchData() async {
    this.handlers = DatabaseHandlers();
    this.handlers.initializeDB().whenComplete(() async {
      //print(history);
      userPref = this.handlers.retrieveUsers();
      print(userPref);
      //setState(() {});
    });
  }

  //int targetCal = 1000;
  Widget calCard(String cal, int targetCal) {
    // fetchData();
    print(targetCal);

    double calPercent = (int.parse(cal) * 100 / targetCal);
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      child: SizedBox(
        width: 160,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(
                '$cal/$targetCal calories',
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10.0,
              ),
              CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                //animationDuration: 1200,
                lineWidth: 4,
                percent: int.parse(cal) / targetCal <= 1.0
                    ? int.parse(cal) / targetCal
                    : 1.0,
                center: Text(
                  "${calPercent.toStringAsFixed(2)}%",
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.lightGreenAccent,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget proCard(String pro, int targetPro) {
    double proPercent = int.parse(pro) * 100 / targetPro;
    return Card(
      elevation: 50,
      child: SizedBox(
        width: 160,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text(
                '$pro/$targetPro gms protein',
                style: const TextStyle(
                    fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 10.0,
              ),
              CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                //animationDuration: 1200,
                lineWidth: 4,
                percent: int.parse(pro) / targetPro <= 1.0
                    ? int.parse(pro) / targetPro
                    : 1.0,
                center: Text(
                  "${proPercent.toStringAsFixed(2)}%",
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.lightBlueAccent,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget stepCard(int? steps, int targetSteps, AppState state) {
    //healthAppState.fetchStepData();
    if (state == AppState.NO_DATA) {
      steps = 0;
    }
    if (state == AppState.STEPS_READY || state == AppState.NO_DATA) {
      double stepPercent = steps! * 100 / targetSteps;
      return Card(
          elevation: 50,
          shadowColor: Colors.black,
          child: SizedBox(
            width: 160,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$steps/$targetSteps steps',
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  CircularPercentIndicator(
                      radius: 50.0,
                      animation: true,
                      //animationDuration: 1200,
                      lineWidth: 4,
                      percent: steps! / targetSteps <= 1.0
                          ? steps! / targetSteps
                          : 1.0,
                      center: Text(
                        "${stepPercent.toStringAsFixed(2)}%",
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.pinkAccent[100])
                ],
              ),
            ),
          )

          //child:
          );
      // } else if (state == AppState.NO_DATA) {
      //   return const Card(
      //       elevation: 50,
      //       shadowColor: Colors.black,
      //       child: SizedBox(
      //         width: 160,
      //         height: 170,
      //         child: Center(child: Text('No data')),
      //       )

      //       //child:
      //       );
    } else {
      return const Card(
          elevation: 50,
          shadowColor: Colors.black,
          child: SizedBox(
            width: 160,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          )

          //child:
          );
    }
  }

  Widget userPreference() {
    return Card(
        elevation: 50,
        shadowColor: Colors.black,
        child: SizedBox(
            width: 160,
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.person,
                    size: 80.0,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  // Text('User preferences')
                ],
              ),
            ))

        //child:
        );
  }

  Widget water(double glassWater) {
    // double temp = 0;
    return Card(
        elevation: 50,
        shadowColor: Colors.black,
        child: SizedBox(
            width: 160,
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water),
                  CupertinoSpinBox(
                    min: 0,
                    max: 100,
                    value: glassWater,
                    onChanged: (value) {
                      temp = value;
                      print(temp);
                    },
                  )
                ],
              ),
            ))

        //child:
        );
  }

  Widget weightCard(double wt) {
    return Card(
        elevation: 50,
        shadowColor: Colors.black,
        child: SizedBox(
            width: 160,
            height: 150,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 14.0),
                  child: Text(
                    'Current weight',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  '${wt.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 50, fontWeight: FontWeight.w400),
                ),
              ],
            ))

        //child:
        );
  }

  Widget mealCards(String mealName) {
    return Card(
        elevation: 50,
        shadowColor: Colors.black,
        child: SizedBox(
            width: 350,
            height: 180,
            child: Column(
              children: [
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Color(0xffA8DCEC)),
                  child: Text(mealName),
                )
              ],
            )));
  }
}
