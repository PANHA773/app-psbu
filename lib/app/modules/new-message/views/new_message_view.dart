import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_message_controller.dart';

class NewMessageView extends GetView<NewMessageController> {
  const NewMessageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewMessageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NewMessageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
