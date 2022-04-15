import 'package:flutter/material.dart';

import 'circular_fab_button.dart';

main() {
  runApp(const MaterialApp(home: AnimationExample()));
}

class AnimationExample extends StatefulWidget {
  const AnimationExample({Key? key}) : super(key: key);

  @override
  State<AnimationExample> createState() => _AnimationExampleState();
}

class _AnimationExampleState extends State<AnimationExample>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollableFabButton(
        children: [
          FloatingActionButton(onPressed: () {}),
          FloatingActionButton(onPressed: () {}),
          FloatingActionButton(onPressed: () {}),
          FloatingActionButton(onPressed: () {}),
          FloatingActionButton(onPressed: () {}),
          FloatingActionButton(onPressed: () {}),
        ],
      ),
    );
  }
}
