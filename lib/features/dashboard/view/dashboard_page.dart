import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_envvar/data/models/env_file.dart';
import 'package:macos_envvar/features/dashboard/dashboard.dart';
import 'package:macos_envvar/features/dashboard/widgets/custom_expansion_tile_scale.dart';
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
  String nameValue = 'name';
  String valueValue = 'value';
  String issues = 'No issues found';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardAppBarTitle), ),
      drawer: const Drawer(
        child: Text('Menu'),
      ),
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
          _buildIssues(),
          
          _buildFilters(),
          const SizedBox(height: 16),
          _buildZshrcContent(),
        ],
      ),
    );
  }

  Widget _buildIssues() {
    return Column(
      children: [
        const Text('Issues'),
        const SizedBox(height: 16),
        Text(issues),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        const Text('Filters'),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Filter by:'),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: nameValue,
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'value', child: Text('Value')),
              ],
              onChanged: (value) => setState(() {
                nameValue = value!;
              }),
            ),
            const SizedBox(width: 16),
            const Text('Order by:'),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: valueValue,
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'value', child: Text('Value')),
              ],
              onChanged: (value) => setState(() {
                valueValue = value!;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZshrcContent() {
    if (zshrcContent?.isEmpty ?? true) {
      return const Text('No .zshrc file found');
    }
    final envModel = ZshrcContent(content: zshrcContent!);

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final key = envModel.content.keys.elementAt(index);
        final value = envModel.content[key];
        final filteredList = value?.entries
            .where((entry) => entry.key.toString().contains(nameValue))
            .toList();
      
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: CustomExpansionTileScale(
            title: Text(key),
            children: [
              ...filteredList!.map(
                (entry) => Text('Order: ${entry.key}, Value: ${entry.value}'),
              ),
              
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
      issues = detectIssuesOrImprovementsInZshrc(fileContent);
      log('Issues found: $issues');

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

  String detectIssuesOrImprovementsInZshrc(String content) {
    final issues = <String>[];
    final lines = content.split('\n');
    final exportRegex = RegExp(r'^export\s+([^=]+)="?(.*?)"?$');

    for (final line in lines) {
      final match = exportRegex.firstMatch(line);
      if (match != null) {
        final key = match.group(1)!.trim();
        final value = match.group(2)!.trim();

        if (key.isEmpty) {
          issues.add('Empty key found');
        }
        if (value.isEmpty) {
          issues.add('Empty value found for key: $key');
        }
      } else if (line.isNotEmpty) {
        issues.add('Invalid line found: $line');
      } else if (line.startsWith('#')) {
        issues.add('Commented line found: $line');
      } else if (line.startsWith('export')) {
        issues.add('Invalid export line found: $line');
      } else if (line.startsWith('alias')) {
        issues.add('Alias line found: $line');
      } else if (line.startsWith('source')) {
        issues.add('Source line found: $line');
      } else if (line.startsWith('export PATH')) {
        issues.add('Path line found: $line');
      } else if (line.startsWith('export ZSH')) {
        issues.add('ZSH line found: $line');
      } else if (line.startsWith('#')) {
        issues.add('Commented line found: $line');
      }
    }

    return issues.join('\n');
  }
}
