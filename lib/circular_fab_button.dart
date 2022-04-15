import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/radial_drag_gesture_detector.dart';

export 'package:untitled/radial_drag_gesture_detector.dart';

class ScrollableFabButton extends StatefulWidget {
  final double? innerRadius;
  final double? outerRadius;
  final double childrenPadding;
  final double initialAngle;
  final Offset? origin;
  final List<Widget> children;
  final Function? childrentwo;
  final RotateMode? rotateMode;
  final bool showInitialAnimation;
  final bool onClickShowAnimation;
  final AnimationSetting? animationSetting;
  final DragAngleRange? dragAngleRange;
  final BoxShape? shape;
  // final  int? itemCount ;
  const ScrollableFabButton({
    Key? key,
    this.innerRadius = 40,
    this.outerRadius = 150,
    this.childrenPadding = 5,
    this.initialAngle = 0,
    this.origin,
    required this.children,
    this.showInitialAnimation = false,
    this.animationSetting,
    this.rotateMode,
    this.dragAngleRange,
    this.onClickShowAnimation = true,
    this.shape,
    this.childrentwo,
  }) : super(key: key);

  @override
  _ScrollableFabButtonState createState() => _ScrollableFabButtonState();
}

class _ScrollableFabButtonState extends State<ScrollableFabButton>
    with TickerProviderStateMixin {
  _DragModel dragModel = _DragModel();
  AnimationController? _controller;
  late Animation<double> _animationRotate;
  bool isAnimationStop = true;
  bool showButtons = false;
  bool position = false;
  bool showAnimation = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final outCircleDiameter = min(size.width, size.height);
    final double outerRadius = widget.outerRadius ?? outCircleDiameter / 2;
    final double innerRadius = widget.innerRadius ?? outerRadius / 2;
    final double betweenRadius = (outerRadius + innerRadius) / 2;
    final dragAngleRange = widget.dragAngleRange;
    final Offset origin = widget.origin ?? Offset(0, -outerRadius);
    var rotateMode = widget.rotateMode ?? RotateMode.onlyChildrenRotate;
    Color listBackgroundColor = Colors.blueGrey;
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: -100,
                  bottom: -100,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: showAnimation ? Colors.blueGrey: Colors.transparent
                    ),

                    width: outerRadius * 2,
                    height: outerRadius * 2,
                    child: RadialDragGestureDetector(
                      stopRotate: rotateMode == RotateMode.stopRotate,
                      onRadialDragUpdate: (PolarCoord updateCoord) {
                        setState(() {
                          dragModel.getAngleDiff(updateCoord, dragAngleRange);
                        });
                      },
                      onRadialDragStart: (PolarCoord startCoord) {
                        setState(() {
                          dragModel.start = startCoord;
                        });
                      },
                      child: Transform.rotate(
                        angle: isAnimationStop
                            ? (dragModel.angleDiff + widget.initialAngle)
                            : (-_animationRotate.value * pi +
                                widget.initialAngle),
                        child: Stack(
                          children:
                              List.generate(widget.children.length, (index) {
                            final double childrenDiameter =
                                2 * pi * betweenRadius / widget.children.length -
                                    widget.childrenPadding;
                            Offset childPoint = getChildPoint(
                              index,
                              widget.children.length,
                              betweenRadius,
                              childrenDiameter,
                            );
                            return AnimatedPositioned(
                              curve: Curves.fastOutSlowIn,
                              left: showAnimation
                                  ? outerRadius + childPoint.dx
                                  : 100,
                              top: showAnimation
                                  ? outerRadius + childPoint.dy
                                  : 100,
                              duration: const Duration(milliseconds: 400),
                              child: Transform.rotate(
                                angle:
                                    ((dragModel.angleDiff) + widget.initialAngle),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: childrenDiameter,
                                  height: childrenDiameter,
                                  decoration: BoxDecoration(
                                    shape: widget.shape ?? BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: widget.children[index],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    width: innerRadius * 2,
                    height: innerRadius * 2,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          if (showAnimation == false) {
                            showAnimation = true;
                          } else {
                            rotateMode == RotateMode.stopRotate;
                            showAnimation = false;
                          }
                        });
                      },
                      child: const Text('Float'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Offset getChildPoint(
      int index, int length, double betweenRadius, double childrenDiameter) {
    double angel = 2 * pi * (index / length);
    double x = cos(angel) * betweenRadius - childrenDiameter / 2;
    double y = sin(angel) * betweenRadius - childrenDiameter / 2;
    return Offset(x, y);
  }
}

class _DragModel {
  PolarCoord? start;
  PolarCoord? end;
  double angleDiff = 0.0;

  double getAngleDiff(PolarCoord updatePolar, DragAngleRange? dragAngleRange) {
    if (start != null) {
      angleDiff = updatePolar.angle - start!.angle;
      if (end != null) {
        angleDiff += end!.angle;
      }
    }
    angleDiff = limitAngle(angleDiff, dragAngleRange);
    return angleDiff;
  }

  double limitAngle(double angleDiff, DragAngleRange? dragAngleRange) {
    if (dragAngleRange == null) return angleDiff;
    if (angleDiff > dragAngleRange.end) angleDiff = dragAngleRange.end;
    if (angleDiff < dragAngleRange.start) angleDiff = dragAngleRange.start;
    return angleDiff;
  }
}

class AnimationSetting {
  final Duration? duration;
  final Curve? curve;

  AnimationSetting({this.duration, this.curve});
}

//
// final double childrenDiameter = 2 *
//     pi *
//     betweenRadius /
//     widget.children.length -
//     widget.childrenPadding;
// Offset childPoint = getChildPoint(
//   index,
//   widget.children.length,
//   betweenRadius,
//   childrenDiameter,
// );
//
// return Positioned(
// left: outerRadius + childPoint.dx,
// top: outerRadius + childPoint.dy,
// child: Transform.rotate(
// angle: ((dragModel.angleDiff) +
// widget.initialAngle),
// child: Container(
// width: childrenDiameter,
// height: childrenDiameter,
// alignment: Alignment.center,
// child: widget.children[index],
// ),
// ),
// );
