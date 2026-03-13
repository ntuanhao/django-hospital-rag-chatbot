// lib/providers/global_search_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/global_search_result.dart';
import 'package:hospital_app/services/global_search_service.dart';

// 1. Provider cho Service
final globalSearchServiceProvider = Provider.autoDispose((ref) => GlobalSearchService());

// 2. Provider chính để fetch dữ liệu tìm kiếm
final globalSearchProvider = 
  FutureProvider.autoDispose.family<GlobalSearchResult, String>((ref, query) {
    // Không thực hiện tìm kiếm nếu query rỗng để tiết kiệm tài nguyên
    if (query.trim().isEmpty) {
      return GlobalSearchResult(doctors: [], services: [], specialties: []);
    }
    // Gọi đến service để thực hiện tìm kiếm
    return ref.watch(globalSearchServiceProvider).search(query);
});