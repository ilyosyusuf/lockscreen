import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get_storage/get_storage.dart';

class BaseViewLock<T> extends StatefulWidget {
  final T? viewModel;
  final Widget Function(BuildContext context, T value)? onPageBuilder;
  final Function(T model)? onModelReady;
  final VoidCallback? onDispose;

  const BaseViewLock({
    Key? key,
    required this.viewModel,
    required this.onPageBuilder,
    this.onModelReady,
    this.onDispose,
  }) : super(key: key);

  @override
  State<BaseViewLock> createState() => _BaseViewLockState();
}

class _BaseViewLockState extends State<BaseViewLock>
    with WidgetsBindingObserver {
  var subscription;
  var internetStatus;

  int _timerCounter = 0;
  Timer? _timer;

  void _incrementTimerCounter(Timer t) {
    print("TimerCounter: $_timerCounter");
    if (_timerCounter >= 30) {
      _timer!.cancel();
      GetStorage().write("isLock", true);
    }
    _timerCounter += 1;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);


    if (state == AppLifecycleState.resumed) {
      _timerCounter = 0;
      debugPrint("Resume!");
    }
    if (state == AppLifecycleState.inactive) {
    }
    if (state == AppLifecycleState.paused) {
      _timerCounter = 0;
    }
    if (state == AppLifecycleState.detached) {
      GetStorage().write("isLock", true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GetStorage().write("isLock", false);
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        internetStatus = result;
      });
    });
    if (widget.onModelReady != null) {
      widget.onModelReady!(widget.viewModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return returnPage();
  }

  Widget returnPage() {
    if (internetStatus == ConnectivityResult.none) {
      return Scaffold(
        body: Center(
          child: Text("No Internet"),
        ),
      );
    } else {
      if (GetStorage().read("isLock") == false) {
        return Scaffold(
            body: GestureDetector(
                onPanDown: (v) {
                  setState(() {
                    debugPrint(v.toString());
                    _timerCounter = 0;
                    GetStorage().write("isLock", false);
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: Text("Homelock"),
                  ),
                )));
      } else {
        return ScreenLock(
            correctString: '1234',
            
            didUnlocked: () {
              setState(() {
                debugPrint("Unlocked");
                _timerCounter = 0;
                GetStorage().write("isLock", false);
                _timer = Timer.periodic(
                    const Duration(milliseconds: 300), _incrementTimerCounter);
              });
            },
            screenLockConfig: const ScreenLockConfig(backgroundColor: Colors.black),
            
      );}
    }
  }

  @override
  void dispose() {
    if (widget.onDispose != null) widget.onDispose!();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
