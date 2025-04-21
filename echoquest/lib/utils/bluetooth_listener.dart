import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'chatbot_launcher.dart';

class BluetoothListener {
  BluetoothConnection? _connection;
  bool isConnected = false;
  bool isConnecting = false;

  static final BluetoothListener _instance = BluetoothListener._internal();
  factory BluetoothListener() => _instance;
  BluetoothListener._internal();

  void start(BuildContext context) async {
    if (isConnected || isConnecting) return;

    isConnecting = true;
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    BluetoothDevice device = devices.firstWhere(
      (d) => d.name == 'HC-05',
      orElse: () => throw Exception('HC-05 not found'),
    );

    _connection = await BluetoothConnection.toAddress(device.address);
    isConnected = true;
    isConnecting = false;

    _connection!.input!.listen((Uint8List data) {
      String message = ascii.decode(data).trim();
      if (message == 'CHATBOT') {
        launchChatbot();
      }
    }).onDone(() {
      isConnected = false;
    });
  }
}
