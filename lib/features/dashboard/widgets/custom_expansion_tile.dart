import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    required this.title,
    required this.children,
    super.key,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.fastOutSlowIn,
    this.trailing,
    this.subtitle,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final Duration animationDuration;
  final Curve curve;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _heightFactor = _animationController.drive(CurveTween(curve: widget.curve));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[800]!, // Darker color
              Theme.of(context).cardColor, // Lighter color
              Colors.grey[800]!, // Darker color
            ],
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: widget.trailing,
              ),
              AnimatedBuilder(
                animation: _heightFactor,
                builder: (BuildContext context, Widget? child) {
                  return ClipRect(
                    child: Align(
                      heightFactor: _heightFactor.value,
                      child: child,
                    ),
                  );
                },
                child: Column(children: widget.children),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
