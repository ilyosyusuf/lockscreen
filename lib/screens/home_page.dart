import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lockscreenpro/base/base_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BaseViewLock(viewModel: HomePage, onPageBuilder: (context, widget){
        return Center(child: Text("HomePage"));
      }));
      
  }
}