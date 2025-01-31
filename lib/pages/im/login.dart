import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fumeo/controllers/im.dart';

class LoginView extends GetView<IMController> {
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _userSigController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIDController,
              decoration: InputDecoration(labelText: '用户ID'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _userSigController,
              decoration: InputDecoration(labelText: 'UserSig'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.login(
                _userIDController.text,
                _userSigController.text,
              ),
              child: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}
