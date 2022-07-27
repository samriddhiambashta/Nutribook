import 'package:calorie_check/home_screen.dart';
import 'package:calorie_check/user_preferences_track/user_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

_UserPrefState userState = _UserPrefState();

class UserPref extends StatefulWidget {
  const UserPref({Key? key}) : super(key: key);

  @override
  _UserPrefState createState() {
    userState = _UserPrefState();
    return userState;
  }
}

class _UserPrefState extends State<UserPref> {
  String targetCal = '';
  String targetPro = '';
  String targetSteps = '';
  late DatabaseHandlers handler;
  TextEditingController _textFieldController1 = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();
  TextEditingController _textFieldController3 = TextEditingController();
  targetCalorie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('targetcal', int.parse(targetCal));
  }

  targetProtein() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('targetpro', int.parse(targetPro));
  }

  targetStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('targetstep', int.parse(targetSteps));
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        homeScreenState.setState(() {});
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()))
            .then((value) {
          setState(() {});
          dispose();
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xff186070),
        appBar: AppBar(
          title: const Text('Nutribook'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              homeScreenState.setState(() {});

              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomeScreen()))
                  .then((value) {
                setState(() {});
              });
            },
          ),
          backgroundColor: Color(0xff186070),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    child: SizedBox(
                        width: 350,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              const Text(
                                'Target calories:           ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Container(
                                color: Colors.grey,
                                width: 70,
                                child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: _textFieldController1,
                                    onChanged: (value) {
                                      setState(() {
                                        targetCal = value;
                                        homeScreenState.setState(() {});
                                      });
                                    }),
                              )
                            ],
                          ),
                        ))),
                const SizedBox(
                  height: 40.0,
                ),
                Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    child: SizedBox(
                        width: 350,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              const Text(
                                'Target proteins:            ',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                color: Colors.grey,
                                width: 70,
                                child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _textFieldController2,
                                    // validator: (text) {
                                    //   if (text == null || text.isEmpty) {
                                    //     return 'Empty';
                                    //   }
                                    //   return null;
                                    // },
                                    onChanged: (value) {
                                      //setState(() {
                                      setState(() {
                                        targetPro = value;
                                        homeScreenState.setState(() {});
                                      });
                                      // });
                                    }),
                              )
                            ],
                          ),
                        ))),
                const SizedBox(
                  height: 40.0,
                ),
                Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    child: SizedBox(
                        width: 350,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              const Text(
                                'Target steps:                 ',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                color: Colors.grey,
                                width: 70,
                                child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _textFieldController3,
                                    // validator: (text) {
                                    //   if (text == null || text.isEmpty) {
                                    //     return 'Empty';
                                    //   }
                                    //   return null;
                                    // },
                                    onChanged: (value) {
                                      //setState(() {
                                      setState(() {
                                        targetSteps = value;
                                        homeScreenState.setState(() {});
                                      });
                                      // });
                                    }),
                              )
                            ],
                          ),
                        ))),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _textFieldController1.clear();
                        _textFieldController2.clear();
                        _textFieldController3.clear();
                        targetStep();
                        targetCalorie();
                        targetProtein();
                        setState(() {
                          homeScreenState.setState(() {});
                          // HomeCards().calCard(cal, targetCal)
                        });
                      });
                    },
                    child: const Text('OK'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
