import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

// Anı Modeli
class Memory {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final File? image; // Yerel resim dosyası
  final String moodEmoji; // O anki his

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.image,
    required this.moodEmoji,
  });
}

class TimelineNotifier extends Notifier<List<Memory>> {
  @override
  List<Memory> build() {
    // Başlangıç için 1-2 örnek (Demo)
    return [
      Memory(
        id: const Uuid().v4(),
        title: "NewDay Başlangıcı",
        description: "Hayatımı değiştirecek o sistemi kodlamaya başladım.",
        date: DateTime.now(),
        moodEmoji: "🚀",
        image: null,
      ),
    ];
  }

  // Fotoğraf Seçip Ekleme
  Future<void> addMemory(String title, String description, String emoji) async {
    final ImagePicker picker = ImagePicker();
    // Simülatörde kamera çalışmaz, o yüzden galeri açıyoruz
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);

    final newMemory = Memory(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: DateTime.now(),
      moodEmoji: emoji,
      image: imageFile != null ? File(imageFile.path) : null,
    );

    state = [newMemory, ...state];
  }

  void deleteMemory(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}

final timelineProvider = NotifierProvider<TimelineNotifier, List<Memory>>(() => TimelineNotifier());