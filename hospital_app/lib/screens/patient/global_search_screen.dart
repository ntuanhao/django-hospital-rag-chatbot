// lib/screens/patient/global_search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/global_search_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _query = _searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultAsync = ref.watch(globalSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: searchResultAsync.when(
        loading: () => _query.isEmpty ? const Center(child: Text('Bắt đầu tìm kiếm...')) : const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
        data: (result) {
          if (_query.isEmpty) return const Center(child: Text('Bắt đầu tìm kiếm...'));
          if (result.doctors.isEmpty && result.services.isEmpty && result.specialties.isEmpty) {
            return const Center(child: Text('Không có kết quả nào.'));
          }

          return ListView(
            children: [
              // Hiển thị kết quả cho từng loại
              if (result.doctors.isNotEmpty) ..._buildSection('Bác sĩ', result.doctors.map((d) => ListTile(title: Text(d.fullName), /* TODO: onTap */)).toList()),
              if (result.services.isNotEmpty) ..._buildSection('Dịch vụ', result.services.map((s) => ListTile(title: Text(s.name), /* TODO: onTap */)).toList()),
              if (result.specialties.isNotEmpty) ..._buildSection('Chuyên khoa', result.specialties.map((sp) => ListTile(title: Text(sp.name), /* TODO: onTap */)).toList()),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSection(String title, List<Widget> items) {
    return [
      Padding(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      ...items,
      const Divider(),
    ];
  }
}