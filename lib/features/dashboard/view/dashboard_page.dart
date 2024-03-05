import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_envvar/features/dashboard/dashboard.dart';
import 'package:macos_envvar/l10n/l10n.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, Map<int, dynamic>>? zshrcContent;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardAppBarTitle)),
      body: _buildContent(),
      floatingActionButton: _buildActionButton(context, l10n),
    );
  }

  Widget _buildActionButton(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton(
      onPressed: _readZshrc,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to the Envs Dashboard'),
          const SizedBox(height: 16),
          _buildZshrcContent(),
        ],
      ),
    );
  }

  Widget _buildZshrcContent() {
    if (zshrcContent?.isEmpty ?? true) {
      return const Text('No .zshrc file found');
    }
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final key = zshrcContent!.keys.elementAt(index);
        final value = zshrcContent![key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: CustomExpansionTileScale(
            title: Text(key),
            // subtitle: Text('Value: ${value!.values.first}'),
            children: [
              ...value?.entries
                      .map(
                        (entry) =>
                            Text('Order: ${entry.key}, Value: ${entry.value}'),
                      )
                      .toList() ??
                  [],
            ],
          ),
        );
      },
      itemCount: zshrcContent!.length,
    );
  }

  Future<void> _readZshrc() async {
    final file = File('/Users/david/.zshrc');
    if (file.existsSync()) {
      final fileContent = await file.readAsString();
      zshrcContent = parseZshrcContent(fileContent);

      setState(() {});
    } else {
      log('No .zshrc file found');
    }
  }

  Map<String, Map<int, String>> parseZshrcContent(String content) {
    final envVars = <String, Map<int, String>>{};
    final lines = content.split('\n');
    final exportRegex = RegExp(r'^export\s+([^=]+)="?(.*?)"?$');

    // Tracking the occurrence order of each variable
    final occurrenceTracker = <String, int>{};

    for (final line in lines) {
      final match = exportRegex.firstMatch(line);
      if (match != null) {
        final key = match.group(1)!.trim();
        final value = match.group(2)!.trim();

        // Initialize or update the occurrence count
        occurrenceTracker[key] = (occurrenceTracker[key] ?? 0) + 1;
        final order = occurrenceTracker[key]!;

        // Initialize the map for this key if it's the first occurrence
        envVars[key] = envVars[key] ?? {};
        // Store the value with its order
        envVars[key]![order] = value;
      }
    }

    return envVars;
  }
}

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
