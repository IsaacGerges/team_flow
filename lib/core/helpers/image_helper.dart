import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Helper to render images that could be either a URL or a base64 string.
class ImageHelper {
  /// Returns an [ImageProvider] for a given [photoUrl].
  ///
  /// Automatically detects if [photoUrl] is a base64 string or a network URL.
  static ImageProvider? getProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    if (photoUrl.startsWith('http')) {
      return NetworkImage(photoUrl);
    }

    try {
      final String base64Content = photoUrl.contains(',')
          ? photoUrl.split(',').last
          : photoUrl;
      final Uint8List bytes = base64Decode(base64Content);
      return MemoryImage(bytes);
    } catch (e) {
      // Fallback if parsing fails
      return null;
    }
  }
}
