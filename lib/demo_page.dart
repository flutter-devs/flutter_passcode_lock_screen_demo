import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_passcode_lock_screen/constant.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

class DemoPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  bool isAuthenticated = false;

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Passcode Lock Screen Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You are ${isAuthenticated ? '' : 'not'}'
                ' authenticated',style: TextStyle(fontSize: 16),),
            SizedBox(height: 10,),
            _lockScreenButton(context),
          ],
        ),
      ),
    );
  }

  _lockScreenButton(BuildContext context) => MaterialButton(
    padding: EdgeInsets.only(left: 50,right: 50),
    color: Theme.of(context).primaryColor,
    child: Text('Lock Screen',style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold,fontSize: 17),),
    onPressed: () {
      _showLockScreen(
        context,
        opaque: false,
        cancelButton: Text(
          'Cancel',
          style: const TextStyle(fontSize: 16, color: Colors.white,),
          semanticsLabel: 'Cancel',
        ),
      );
    },
  );


  _showLockScreen(BuildContext context,
      {bool opaque,
        CircleUIConfig circleUIConfig,
        KeyboardUIConfig keyboardUIConfig,
        Widget cancelButton,
        List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
            title: Text(
              'Enter Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _passcodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _passcodeCancelled,
            digits: digits,
            passwordDigits: 6,
            bottomWidget: _passcodeRestoreButton(),
          ),
        ));
  }

  _passcodeEntered(String enteredPasscode) {
    bool isValid = storedPasscode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
    }
  }

  _passcodeCancelled() {
    Navigator.maybePop(context);
  }

  _passcodeRestoreButton() => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
      child: FlatButton(
        child: Text(
          "Reset passcode",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w300),
        ),
        splashColor: Colors.white.withOpacity(0.4),
        highlightColor: Colors.white.withOpacity(0.2),
        onPressed: _resetApplicationPassword,
      ),
    ),
  );

  _resetApplicationPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _restoreDialog(() {
        Navigator.maybePop(context);
      });
    });
  }

  _restoreDialog(VoidCallback onAccepted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[50],
          title: Text(
            "Reset passcode",
            style: const TextStyle(color: Colors.black87),
          ),
          content: Text(
            "Passcode reset is a non-secure operation!\nAre you sure want to reset?",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "Cancel",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
            FlatButton(
              child: Text(
                "I proceed",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: onAccepted,
            ),
          ],
        );
      },
    );
  }

}