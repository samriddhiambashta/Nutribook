//import 'main.dart';
//import 'dart:html';

import 'package:calorie_check/meal_track/historyInfo.dart';

import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'history_helper.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';
import 'package:calorie_check/home_page.dart';
import 'package:calorie_check/step_track/step_info.dart';
import 'package:calorie_check/step_track/step_helper.dart';
import 'package:calorie_check/health.dart';
import 'package:calorie_check/home_screen.dart';
import 'package:calorie_check/user_preferences_track/user_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  //final List<Calprotein> data;
  // String val1, val2;
  //int val1 = 0, val2 = 0;

  @override
  _HistoryState createState() => _HistoryState();

  //History();

}

class _HistoryState extends State<History> {
  //List<Calprotein> data;
  //int? val1, val2;
  // _HistoryState();
  late DatabaseHandler handler;
  late DatabaseHandlersStep handlersStep;
  late DatabaseHandlers handlers;
  int steps = 0;
  int stepsTemp = 0;
  //int targetSteps = 10000;
  String updatedDt = "";
  String mainText = "TODAY";
  String cal = "";
  String pro = "";
  String meal = "";
  bool next = false;
  int? total1 = 0;
  int? total2 = 0;
  int? temp1 = 0;
  int? temp2 = 0;
  int? glassWater = 0;
  int? s = 0;
  var dt = DateTime.now();
  var newFormat = DateFormat("yy-MM-dd");
  int nofSteps = 10;
  HealthFactory health = HealthFactory();
  AppState _state = AppState.DATA_NOT_FETCHED;
  //HomeScreen homeScreen = HomeScreen();
  Future<List<HistoryInfo>> history = Future.value([]);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void setDate() {
    updatedDt = newFormat.format(dt);
    if (newFormat.format(dt) != newFormat.format(DateTime.now())) {
      next = true;
    } else {
      next = false;
    }
    print(updatedDt);
  }

  late Future<int> _targetStep;
  Future<int?> getTargetStep() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    final int? intValue = prefs.getInt('targetstep');
    _targetStep = intValue as Future<int>;
    return intValue;
  }

  late Future<int> _targetCal;
  Future<int?> getTargetCal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    final int? intValue = prefs.getInt('targetcal');
    _targetCal = intValue as Future<int>;
    return intValue;
  }

  late Future<int> _targetPro;
  Future<int?> getTargetPro() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    final int? intValue = prefs.getInt('targetpro');
    _targetPro = intValue as Future<int>;
    return intValue;
  }

  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');
      //this.handlersStep = DatabaseHandlersStep();
      this.handlersStep = DatabaseHandlersStep();
      this.handlersStep.initializeDB().whenComplete(() async {
        s = (await this.handlersStep.getSteps(DateTime.now()))[0]['steps'];
      });
      print(s);
      setState(() {
        nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  void initState() {
    fetchData();

    super.initState();
    setDate();
    fetchStepData();
    _targetStep = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetstep') ?? 10000;
    });
    _targetCal = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetcal') ?? 1000;
    });

    _targetPro = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetpro') ?? 200;
    });

    this.handlers = DatabaseHandlers();
    this.handlers.initializeDB().whenComplete(() async {
      glassWater = (await this.handlers.glassWater(DateTime.now()))[0]['water'];
      //  targetPro = (await this.handlers.targetPro())[0]['targetPro'];
      // targetSteps = (await this.handlers.targetSteps())[0]['targetSteps'];

      //   print(targetCal);
      setState(() {});
    });
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      //await this.addUsers();

      total1 = (await this.handler.calculateTotalCalorie())[0]['TOTAL'];
      total2 = (await this.handler.calculateTotalProtein())[0]['TOTAL'];
      setState(() {});
      setState(() {
        // calOnTop(DateTime.now());
      });
    });
  }

  void fetchData() async {
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      //print(history);
      history = this.handler.retrieveUsersDate(updatedDt);
      setState(() {});
    });
  }

  void update(int? id, DateTime dt) {
    updatedDt = newFormat.format(dt);

    this.handler = DatabaseHandler();

    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        //history
        HistoryInfo hist = HistoryInfo(
            id: id,
            protein: int.parse(pro),
            calorie: int.parse(cal),
            mealName: meal,
            dateTime: updatedDt);
        //print(history);
        this.handler.updateUser(hist);
      });

      homeScreenState.total1 =
          (await this.handler.calculateTotalCalorie())[0]['TOTAL'];
      homeScreenState.total2 =
          (await this.handler.calculateTotalProtein())[0]['TOTAL'];

      setState(() {
        homeScreenState.setState(() {});
      });
    });
  }

  void delete(int id) async {
    //this.handler.deleteUser(id);
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      //print(history);
      this.handler.deleteData(id);
      setState(() {
        //history.
      });
    });
  }

  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  final TextEditingController _textFieldController3 = TextEditingController();

  _displayDialog(BuildContext context, List<HistoryInfo>? his,
      AsyncSnapshot<List<HistoryInfo>> snapshot, int index, DateTime dt) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Calories and Proteins'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      meal = value;
                    });
                  },
                  controller: _textFieldController3,
                  decoration: const InputDecoration(hintText: "Meal Name"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      cal = value;
                    });
                  },
                  controller: _textFieldController1,
                  decoration: const InputDecoration(hintText: "Calories"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      pro = value;
                    });
                  },
                  controller: _textFieldController2,
                  decoration: const InputDecoration(hintText: "Proteins"),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: Text('OK'),
                onPressed: () async {
                  _textFieldController1.clear();
                  _textFieldController2.clear();
                  this.handler = DatabaseHandler();

                  // this.handler.initializeDB().whenComplete(() async {
                  // print(snapshot
                  //     .data![snapshot.data!.length - 1 - index].calorie);
                  update(
                      snapshot.data![snapshot.data!.length - 1 - index].id, dt);

                  // });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void calOnTop(DateTime date) {
    this.handler = DatabaseHandler();

    this.handler.initializeDB().whenComplete(() async {
      total1 = (await this.handler.calorieDate(date))[0]['TOTAL'];

      // _total1 = total1;
      //total2 = (await this.handler.calculateTotalProtein())[0]
      //  ['TOTAL'];
    });
    setState(() {});
  }

  //@override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff186070),
      appBar: AppBar(
        title: const Text(
          'Nutribook',
        ),
        backgroundColor: Color(0xff186070),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 15.0),
            //   child: Text(
            //     'You added ${total1 != null ? total1.toString() : '0'} calories and ${total2 != null ? total2.toString() : '0'} grams protein.',
            //     style: const TextStyle(fontSize: 18.0),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 70.0,
                child: Center(
                  child: Card(
                      elevation: 50,
                      shadowColor: Colors.black,
                      child: SizedBox(
                        width: 330,
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => HistoryPrev()));

                                  setState(() async {
                                    dt = dt.subtract(const Duration(days: 1));
                                    total1 = (await this
                                        .handler
                                        .calorieDate(dt))[0]['TOTAL'];
                                    total2 = (await this
                                        .handler
                                        .proteinDate(dt))[0]['TOTAL'];

                                    glassWater = (await this
                                                .handlers
                                                .glassWater(dt))[0]['water'] ==
                                            null
                                        ? 0
                                        : (await this
                                            .handlers
                                            .glassWater(dt))[0]['water'];

                                    //setState(() async {
                                    s = (await this
                                                .handlersStep
                                                .getSteps(dt))[0]['steps'] ==
                                            null
                                        ? 0
                                        : (await this
                                            .handlersStep
                                            .getSteps(dt))[0]['steps'];
                                    // });
                                    print(s);

                                    setDate();

                                    //calOnTop(dt);

                                    // _total1 = total1;
                                    //total2 = (await this.handler.calculateTotalProtein())[0]
                                    //  ['TOTAL'];

                                    setState(() {});

                                    if (updatedDt !=
                                        newFormat.format(DateTime.now())) {
                                      mainText = updatedDt;
                                    } else {
                                      mainText = 'TODAY';
                                    }
                                  });
                                },
                                child: const Text(
                                  '<',
                                  style: TextStyle(
                                      fontSize: 25.0, color: Colors.black),
                                )),
                            const SizedBox(
                              width: 40.0,
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                mainText,
                                style: const TextStyle(
                                    fontSize: 25.0, color: Colors.black),
                              ),
                              style: TextButton.styleFrom(
                                elevation: 10,
                                shadowColor: Colors.white10,
                              ),
                            ),
                            const SizedBox(
                              width: 40.0,
                            ),
                            next
                                ? TextButton(
                                    onPressed: () {
                                      setState(() async {
                                        dt = dt.add(const Duration(days: 1));
                                        setDate();

                                        total1 = (await this
                                            .handler
                                            .calorieDate(dt))[0]['TOTAL'];
                                        total2 = (await this
                                            .handler
                                            .proteinDate(dt))[0]['TOTAL'];
                                        glassWater = (await this
                                                        .handlers
                                                        .glassWater(dt))[0]
                                                    ['water'] ==
                                                null
                                            ? 0
                                            : (await this
                                                .handlers
                                                .glassWater(dt))[0]['water'];

                                        s = (await this
                                                        .handlersStep
                                                        .getSteps(dt))[0]
                                                    ['steps'] ==
                                                null
                                            ? 0
                                            : (await this
                                                .handlersStep
                                                .getSteps(dt))[0]['steps'];

                                        // _total1 = total1;
                                        //total2 = (await this.handler.calculateTotalProtein())[0]
                                        //  ['TOTAL'];

                                        setState(() {});

                                        if (updatedDt !=
                                            newFormat.format(DateTime.now())) {
                                          mainText = updatedDt;
                                        } else {
                                          mainText = 'TODAY';
                                        }
                                      });
                                    },
                                    child: const Text(
                                      '>',
                                      style: TextStyle(
                                          fontSize: 25.0, color: Colors.black),
                                    ),
                                    style: TextButton.styleFrom(
                                      elevation: 10,
                                      shadowColor: Colors.white10,
                                    ))
                                : const Text('')
                          ],
                        ),
                      )),
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    child: FutureBuilder<int>(
                        future: _targetCal,
                        builder: (context, AsyncSnapshot snapshot) {
                          //return Text('${snapshot.data} cal');

                          return HomeCards().calCard(
                              total1 != null ? total1.toString() : '0',
                              snapshot.data);
                        }),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => History()),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextButton(
                    child: FutureBuilder<int>(
                        future: _targetPro,
                        builder: (context, AsyncSnapshot snapshot) {
                          //return Text('${snapshot.data} cal');

                          return HomeCards().proCard(
                              total2 != null ? total2.toString() : '0',
                              snapshot.data);
                        }),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => History()),
                      );
                    },
                  ),
                )
              ],
            ),
            Row(
              children: [
                FutureBuilder<dynamic>(
                    future: _targetStep,
                    builder: (context, AsyncSnapshot snapshot) {
                      //return Text('${snapshot.data} cal');

                      return Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: HomeCards().stepCard(s, snapshot.data, _state),
                        ),
                      );
                    }),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: Card(
                        elevation: 50,
                        shadowColor: Colors.black,
                        child: SizedBox(
                            width: 160,
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Container(
                                    height: 75,
                                    child: Image.asset(
                                        'assets/images/glass-of-water.png'),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  glassWater.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ))

                        //child:
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
                //padding: const EdgeInsets.all(10.0),
                future: this.handler.retrieveUsersDate(updatedDt),
                builder: (BuildContext context,
                    AsyncSnapshot<List<HistoryInfo>> snapshot) {
                  List<HistoryInfo>? his = snapshot.data;
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 520,
                          width: 380,
                          child: ListView.builder(
                            // shrinkWrap: true,
                            // scrollDirection: Axis.vertical,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                  elevation: 50,
                                  shadowColor: Colors.black,
                                  child: SizedBox(
                                    height: 170,
                                    //width: 150,
                                    child: ListTile(
                                      title: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 13.0, left: 8),
                                            child: Container(
                                              width: 250,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                  color: Color(0xffA8DCEC)),
                                              child: Center(
                                                child: Text(snapshot
                                                    .data![
                                                        snapshot.data!.length -
                                                            1 -
                                                            index]
                                                    .mealName),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.0),
                                                child: Text('Calories'),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    color: Color(0xffA8DCEC)),
                                                child: Center(
                                                  child: Text((snapshot
                                                          .data![snapshot.data!
                                                                  .length -
                                                              1 -
                                                              index]
                                                          .calorie)
                                                      .toString()),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Text('Proteins'),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    color: Color(0xffA8DCEC)),
                                                child: Center(
                                                  child: Text((snapshot
                                                          .data![snapshot.data!
                                                                  .length -
                                                              1 -
                                                              index]
                                                          .protein)
                                                      .toString()),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 70.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _displayDialog(context, his,
                                                        snapshot, index, dt);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                  size: 20,
                                                )),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                // this.handler.deleteData(index);

                                                this.handler =
                                                    DatabaseHandler();

                                                this
                                                    .handler
                                                    .initializeDB()
                                                    .whenComplete(() async {
                                                  //await this.addUsers();
                                                  this.handler.deleteUser(his![
                                                          snapshot.data!
                                                                  .length -
                                                              1 -
                                                              index]
                                                      .id);
                                                  homeScreenState
                                                      .total1 = (await this
                                                          .handler
                                                          .calculateTotalCalorie())[
                                                      0]['TOTAL'];
                                                  homeScreenState
                                                      .total2 = (await this
                                                          .handler
                                                          .calculateTotalProtein())[
                                                      0]['TOTAL'];
                                                  setState(() {
                                                    homeScreenState
                                                        .setState(() {
                                                      // homeScreenState.total1 = val1;
                                                      // homeScreenState.total2 = val2;
                                                    });
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ],
        ),
      ),
    );
  }

  // Future<int> addUsers() async {
  //   HistoryInfo firstUser =
  //       HistoryInfo(protein: int.parse(val2), calorie: int.parse(val1));
  //   //HistoryInfo secondUser = HistoryInfo(protein: 30, calorie: 40);
  //   List<HistoryInfo> listOfUsers = [firstUser];
  //   return await this.handler.insertUser(listOfUsers);
  // }
}
