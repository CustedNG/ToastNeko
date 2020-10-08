import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class _ActivityTimeline extends StatefulWidget {
  @override
  _ActivityTimelineState createState() => _ActivityTimelineState();
}

class _ActivityTimelineState extends State<_ActivityTimeline> {
  List<Step> _steps;

  @override
  void initState() {
    _steps = _generateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D1E20),
      child: Theme(
        data: Theme.of(context).copyWith(
          accentColor: Colors.white.withOpacity(0.2),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                children: <Widget>[
                  _Header(),
                  Expanded(
                    child: _TimelineActivity(steps: _steps),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Step> _generateData() {
    return <Step>[
      Step(
        type: Type.checkpoint,
        icon: Icons.home,
        message: 'Home',
        duration: 2,
        color: const Color(0xFFF2F2F2),
      ),
      Step(
        type: Type.line,
        hour: '8:38',
        message: 'Walk',
        duration: 9,
        color: const Color(0xFF40C752),
      ),
      Step(
        type: Type.line,
        hour: '8:47',
        message: 'Transport',
        duration: 12,
        color: const Color(0xFF797979),
      ),
      Step(
        type: Type.line,
        hour: '8:59',
        message: 'Run',
        duration: 3,
        color: const Color(0xFFDF54C9),
      ),
      Step(
        type: Type.checkpoint,
        icon: Icons.work,
        hour: '9:02',
        message: 'Work',
        duration: 2,
        color: const Color(0xFFF2F2F2),
      ),
      Step(
        type: Type.line,
        hour: '12:12',
        message: 'Walk',
        duration: 8,
        color: const Color(0xFF40C752),
      ),
      Step(
        type: Type.checkpoint,
        icon: Icons.local_drink,
        hour: '12:20',
        message: 'Coffee shop',
        duration: 2,
        color: const Color(0xFFF2F2F2),
      ),
      Step(
        type: Type.line,
        hour: '01:05',
        message: 'Walk',
        duration: 8,
        color: const Color(0xFF40C752),
      ),
      Step(
        type: Type.checkpoint,
        icon: Icons.work,
        hour: '01:13',
        message: 'Work',
        duration: 2,
        color: const Color(0xFFF2F2F2),
      ),
      Step(
        type: Type.line,
        hour: '05:25',
        message: 'Walk',
        duration: 3,
        color: const Color(0xFF40C752),
      ),
      Step(
        type: Type.line,
        hour: '05:28',
        message: 'Cycle',
        duration: 14,
        color: const Color(0xFF01CBFE),
      ),
      Step(
        type: Type.checkpoint,
        hour: '05:42',
        icon: Icons.home,
        message: 'Home',
        duration: 2,
        color: const Color(0xFFF2F2F2),
      ),
    ];
  }
}

class _TimelineActivity extends StatelessWidget {
  const _TimelineActivity({Key key, this.steps}) : super(key: key);

  final List<Step> steps;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (BuildContext context, int index) {
        final Step step = steps[index];

        final IndicatorStyle indicator = step.isCheckpoint
            ? _indicatorStyleCheckpoint(step)
            : const IndicatorStyle(width: 0);

        final rightChild = _RightChildTimeline(step: step);

        Widget leftChild;
        if (step.hasHour) {
          leftChild = _LeftChildTimeline(step: step);
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          lineXY: 0.25,
          indicatorStyle: indicator,
          startChild: leftChild,
          endChild: rightChild,
          hasIndicator: step.isCheckpoint,
          beforeLineStyle: LineStyle(
            color: step.color,
            thickness: 8,
          ),
        );
      },
    );
  }

  IndicatorStyle _indicatorStyleCheckpoint(Step step) {
    return IndicatorStyle(
      width: 46,
      height: 100,
      indicator: Container(
        decoration: BoxDecoration(
          color: step.color,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Center(
          child: Icon(
            step.icon,
            color: const Color(0xFF1D1E20),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _RightChildTimeline extends StatelessWidget {
  const _RightChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    final double minHeight =
    step.isCheckpoint ? 100 : step.duration.toDouble() * 8;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: step.isCheckpoint ? 20 : 39, top: 8, bottom: 8, right: 8),
            child: RichText(
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: step.message,
                ),
                TextSpan(
                  text: '  ${step.duration} min',
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}

class _LeftChildTimeline extends StatelessWidget {
  const _LeftChildTimeline({Key key, this.step}) : super(key: key);

  final Step step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: step.isCheckpoint ? 10 : 29),
          child: Text(
            step.hour,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Activity Tracker',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

enum Type {
  checkpoint,
  line,
}

class Step {
  Step({
    this.type,
    this.hour,
    this.message,
    this.duration,
    this.color,
    this.icon,
  });

  final Type type;
  final String hour;
  final String message;
  final int duration;
  final Color color;
  final IconData icon;

  bool get isCheckpoint => type == Type.checkpoint;

  bool get hasHour => hour != null && hour.isNotEmpty;
}