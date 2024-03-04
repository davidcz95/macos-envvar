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
  Map<String, dynamic>? zshrcContent;

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
      itemBuilder: (context, index) {
        final key = zshrcContent!.keys.elementAt(index);
        final value = zshrcContent![key];
        return ListTile(
          title: Text(key),
          subtitle: Text(value.toString()),
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

  Map<String, String> parseZshrcContent(String content) {
    final envVars = <String, String>{};
    final lines = content.split('\n');
    final exportRegex = RegExp(r'^export\s+([^=]+)="?(.*?)"?$');

    for (final line in lines) {
      final match = exportRegex.firstMatch(line);
      if (match != null) {
        final key = match.group(1)!.trim();
        final value = match.group(2)!.trim();
        envVars[key] = value;
      }
    }

    return envVars;
  }
}
