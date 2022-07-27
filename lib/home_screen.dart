import 'package:calorie_check/health.dart';
import 'package:calorie_check/meal_track/history.dart';
import 'package:calorie_check/meal_track/historyInfo.dart';
import 'package:calorie_check/meal_track/history_helper.dart';
import 'package:calorie_check/step_track/step_helper.dart';
import 'package:calorie_check/user_preferences_track/user_preferences.dart';
import 'package:calorie_check/weight_track/weight_helper.dart';
import 'package:calorie_check/weight_track/weight_info.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'package:health/health.dart';
import 'user_preferences_track/user_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_preferences_track/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'step_track/step_helper.dart';
import 'step_track/step_info.dart';

_HomeScreenState homeScreenState = _HomeScreenState();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    homeScreenState = _HomeScreenState();
    return homeScreenState;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  final TextEditingController _textFieldController3 = TextEditingController();
  //String codeDialog;
  String valueText1 = "";
  String valueText2 = "";
  String meal = "";
  int id = 0;
  String codeDialog1 = "";
  String codeDialog2 = "";
  int finalCount1 = 0;
  int finalCount2 = 0;
  int? total2 = 0;
  int? total1 = 0;
  int steps = 0;
  int stepsTemp = 0;
  int? glassWater = 0;
  int targetPro = 200;
  double wt = 0;
  double weight = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int targetSteps = 10000;
  double temp = 0;
  String m = "";
  int c = 0;
  int? ca = 0;
  //HistoryHelper _historyHelper = HistoryHelper();
  //final dbhelper = DatabaseHelper.instance;
  late DatabaseHandlers handlers;
  late DatabaseHandler handler;
  late DatabaseHandlersWeight handlersWeight;
  late DatabaseHandlersStep handlersStep;
  int nofSteps = 10;
  HealthFactory health = HealthFactory();
  AppState _state = AppState.DATA_NOT_FETCHED;
  Future<List<UserInfo>> userPref = Future.value([]);
  void fetchData() async {
    this.handlers = DatabaseHandlers();
    this.handlers.initializeDB().whenComplete(() async {
      //print(history);
      userPref = this.handlers.retrieveUsers();
      print(userPref);
      setState(() {});
    });
  }

  final TextEditingController _textFieldController = TextEditingController();
  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Current Weight'),
            content: TextField(
              onChanged: (value) {
                wt = double.parse(value);
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Your weight"),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  if (wt == '') {
                  } else {
                    setState(() {
                      this.handlers = DatabaseHandlers();

                      this.handlersWeight.initializeDB().whenComplete(() async {
                        await this.addWeight();
                        weight =
                            (await this.handlersWeight.weight())[0]['weight'];

                        setState(() {});
                      });
                    });
                  }
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  late Future<double> _counter;

  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final double counter = (prefs.getDouble('counter') ?? 0) + 1;

    setState(() {
      _counter = prefs.setDouble('counter', temp).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _deccrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final double counter = (prefs.getDouble('counter') ?? 0) - 1;

    setState(() {
      _counter = prefs.setDouble('counter', temp).then((bool success) {
        return counter;
      });
    });
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

  late Future<int> _targetStep;
  Future<int?> getTargetStep() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    final int? intValue = prefs.getInt('targetstep');
    _targetStep = intValue as Future<int>;
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
      this.handlersStep = DatabaseHandlersStep();

      this.handlersStep.initializeDB().whenComplete(() async {
        await this.addSteps(steps);

        stepsTemp =
            (await this.handlersStep.getSteps(DateTime.now()))[0]['steps'];
        print('Steps are $stepsTemp');
      });
      setState(() {
        nofSteps = (steps == null) ? 0 : steps;
        _state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    var dt = DateTime.now();
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(dt);
    this.handlers = DatabaseHandlers();
    this.handlers.initializeDB().whenComplete(() async {
      glassWater = (await this.handlers.glassWater(DateTime.now()))[0]['water'];
      //  targetPro = (await this.handlers.targetPro())[0]['targetPro'];
      // targetSteps = (await this.handlers.targetSteps())[0]['targetSteps'];

      //   print(targetCal);
      setState(() {});
    });
    this.handlersStep = DatabaseHandlersStep();

    this.handlersStep.initializeDB().whenComplete(() async {
      await this.addSteps(steps);

      stepsTemp =
          (await this.handlersStep.getSteps(DateTime.now()))[0]['steps'];
      print('Steps are $stepsTemp');
    });

    this.handlersWeight = DatabaseHandlersWeight();
    this.handlersWeight.initializeDB().whenComplete(() async {
      weight = (await this.handlersWeight.weight())[0]['weight'];
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
      // addSteps();
      fetchStepData();
      //fetchData();
      setState(() {});

      //await healthAppState.fetchStepData();
    });
    void dispose() {
      super.dispose();
    }

    _targetCal = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetcal') ?? 1000;
    });

    _targetPro = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetpro') ?? 200;
    });

    _targetStep = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('targetstep') ?? 10000;
    });

    _counter = _prefs.then((SharedPreferences prefs) {
      return prefs.getDouble('counter') ?? 0;
    });
    //setState(() {

    // });

    // this.handler = DatabaseHandler();

    // this.handler.initializeDB().whenComplete(() async {
    //   await this.addUsers();
    //   setState(() {
    //     //calc();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //homeScreenState.setState(() {});
        //Navigator.pop(context);
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xff186070),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Nutribook'),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // this.handler = DatabaseHandler();
                    // this.handler.initializeDB().whenComplete(() async {
                    //   this.handler.del();
                    // });
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    //   this.handler = DatabaseHandler();
                    //   this.handler.initializeDB().whenComplete(() async {
                    //     this.handler.recreate();
                    //   });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            )
          ],
          backgroundColor: Color(0xff186070),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
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
                              MaterialPageRoute(
                                  builder: (context) => History()),
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
                              MaterialPageRoute(
                                  builder: (context) => History()),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // HomeCards().stepCard(nofSteps, targetSteps, _state),
                const SizedBox(
                  height: 10.0,
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
                              child: HomeCards()
                                  .stepCard(nofSteps, snapshot.data, _state),
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
                                    CupertinoSpinBox(
                                      min: 0,
                                      max: 100,
                                      value: glassWater != null
                                          ? glassWater!.toDouble()
                                          : 0,
                                      onChanged: (value) {
                                        temp = value;

                                        setState(() {
                                          this.handlers = DatabaseHandlers();

                                          this
                                              .handlers
                                              .initializeDB()
                                              .whenComplete(() async {
                                            await this.addWater();
                                          });
                                        });
                                      },
                                    )
                                  ],
                                ))

                            //child:
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              displayTextInputDialog(context);
                            });
                          },
                          child: HomeCards().weightCard(weight)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextButton(
                        child: HomeCards().userPreference(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserPref()),
                          );
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                // Text('cal is $m'),
                //Text('total is $ca'),
                Card(
                    elevation: 50,
                    child: SizedBox(
                      height: 120,
                      width: 360,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(children: [
                          Container(
                            width: 280,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Color(0xffA8DCEC)),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Meal Name'),
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                setState(() {
                                  meal = value;
                                });
                              },
                              controller: _textFieldController3,
                              // decoration: InputDecoration(hintText: "Add proteins"),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Color(0xffA8DCEC)),
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Calorie'),
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    setState(() {
                                      valueText1 = value;
                                    });
                                  },
                                  controller: _textFieldController1,
                                  // decoration: InputDecoration(hintText: "Add proteins"),
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  height: 40,
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.grey,

                                    child: const Icon(
                                      Icons.add,
                                    ),
                                    //: Colors.blue,
                                    //textColor: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        SystemChannels.textInput
                                            .invokeMethod('TextInput.hide');
                                        //  _textFieldController1.clear();
                                        // _textFieldController2.clear();
                                        if (!(_textFieldController1.text ==
                                                '' &&
                                            _textFieldController2.text == '')) {
                                          if (_textFieldController1.text ==
                                              '') {
                                            valueText1 = "0";
                                          }
                                          if (_textFieldController2.text ==
                                              '') {
                                            valueText2 = "0";
                                          }
                                          _textFieldController1.clear();
                                          _textFieldController2.clear();
                                          _textFieldController3.clear();

                                          this.handler = DatabaseHandler();

                                          this
                                              .handler
                                              .initializeDB()
                                              .whenComplete(() async {
                                            await this.addUsers();

                                            total1 = (await this
                                                    .handler
                                                    .calculateTotalCalorie())[0]
                                                ['TOTAL'];
                                            ca = total1;
                                            // _total1 = total1;
                                            total2 = (await this
                                                    .handler
                                                    .calculateTotalProtein())[0]
                                                ['TOTAL'];
                                            // _total2 = total2;

                                            setState(() {});
                                          });
                                        }
                                        //Navigator.pop(context);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Color(0xffA8DCEC)),
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Protein'),

                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    setState(() {
                                      valueText2 = value;
                                    });
                                  },
                                  controller: _textFieldController2,
                                  // decoration: InputDecoration(hintText: "Add proteins"),
                                ),
                              )
                            ],
                          ),
                        ]),
                      ),
                    )),

                const SizedBox(
                  height: 40,
                ),

                //icon: Icon(Icons.add))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> addUsers() async {
    var dt = DateTime.now();
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(dt);
    HistoryInfo firstUser = HistoryInfo(
        protein: int.parse(valueText2),
        calorie: int.parse(valueText1),
        mealName: meal,
        dateTime: updatedDt);

    m = meal;
    //HistoryInfo secondUser = HistoryInfo(protein: 30, calorie: 40);
    List<HistoryInfo> listOfUsers = [firstUser];
    return await this.handler.insertUser(listOfUsers);
    // c = int.parse(valueText1);
  }

  Future<int> addWater() async {
    var dt = DateTime.now();
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(dt);
    UserInfo firstUser = UserInfo(water: temp.toInt(), dateTime: updatedDt);
    //HistoryInfo secondUser = HistoryInfo(protein: 30, calorie: 40);
    List<UserInfo> listOfUsers = [firstUser];
    return await this.handlers.insertUser(listOfUsers);
  }

  Future<int> addWeight() async {
    var dt = DateTime.now();
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(dt);
    WeightInfo firstUser = WeightInfo(weight: wt, dateTime: updatedDt);
    //HistoryInfo secondUser = HistoryInfo(protein: 30, calorie: 40);
    List<WeightInfo> listOfUsers = [firstUser];
    return await this.handlersWeight.insertUser(listOfUsers);
  }

  Future<int> addSteps(int? steps) async {
    var dt = DateTime.now();
    var newFormat = DateFormat("yy-MM-dd");
    String updatedDt = newFormat.format(dt);
    StepInfo firstUser = StepInfo(steps: nofSteps, dateTime: updatedDt);
    //HistoryInfo secondUser = HistoryInfo(protein: 30, calorie: 40);
    List<StepInfo> listOfUsers = [firstUser];
    return await this.handlersStep.insertUser(listOfUsers);
  }

  // void _insert() async {
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnProtein: int.parse(valueText2),
  //     DatabaseHelper.columnCalorie: int.parse(valueText1)
  //   };
  //   final id = await dbhelper.insert(row);
  //   print(row);
  // }
}
