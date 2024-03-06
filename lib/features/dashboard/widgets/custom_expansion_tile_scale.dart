import 'package:flutter/material.dart';

class CustomExpansionTileScale extends StatefulWidget {
  const CustomExpansionTileScale({
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
  State<CustomExpansionTileScale> createState() =>
      _CustomExpansionTileScaleState();
}

class _CustomExpansionTileScaleState extends State<CustomExpansionTileScale>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hoverAnimationController;
  late Animation<double> _heightFactor;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _heightFactor = _animationController.drive(CurveTween(curve: widget.curve));

    _hoverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation =
        Tween(begin: 1.0, end: 1.035).animate(_hoverAnimationController);

    _hoverAnimationController.addListener(() {
      if (!_isHovering &&
          _hoverAnimationController.value ==
              _hoverAnimationController.upperBound) {
        _hoverAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hoverAnimationController.dispose();
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

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    if (isHovering) {
      _hoverAnimationController.forward();
    } else {
      _hoverAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber[800]!, // Darker color
          Theme.of(context).cardColor, // Lighter color
          Colors.amber[800]!, // Darker color
        ],
      ),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 10),
          blurRadius: 30,
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _heightFactor]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: decoration,
              child: InkWell(
                onTap: _toggleExpansion,
                onHover: _onHover,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        trailing: widget.trailing,
                      ),
                      ClipRect(
                        child: Align(
                          heightFactor: _heightFactor.value,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.children,
        ),
      ),
    );
  }
}
