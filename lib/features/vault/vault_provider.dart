import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Not Modeli
class VaultNote {
  final String id;
  final String title;
  final String content;
  final String tag; // #Fikir, #Kod, #Gizli
  final DateTime createdAt;
  final Color color;

  VaultNote({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.color,
  });
}

// Vault Durumu
class VaultState {
  final List<VaultNote> notes;
  final bool isLocked; // Gizli mod açık mı?

  VaultState({required this.notes, required this.isLocked});

  VaultState copyWith({List<VaultNote>? notes, bool? isLocked}) {
    return VaultState(
      notes: notes ?? this.notes,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class VaultNotifier extends Notifier<VaultState> {
  @override
  VaultState build() {
    return VaultState(
      isLocked: false, // Başlangıçta kilit açık
      notes: [
        VaultNote(
          id: const Uuid().v4(),
          title: "Proje Fikri: X",
          content: "Yapay zeka ile çalışan, kullanıcıyı tanrı moduna sokan bir asistan.",
          tag: "#FIKIR",
          createdAt: DateTime.now(),
          color: const Color(0xFF00E5FF),
        ),
        VaultNote(
          id: const Uuid().v4(),
          title: "Server Şifreleri",
          content: "Root: 123456\nAWS Key: AKIA...",
          tag: "#GIZLI",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          color: const Color(0xFFFF2E93),
        ),
        VaultNote(
          id: const Uuid().v4(),
          title: "Flutter Trick",
          content: "Riverpod kullanırken ref.watch() her zaman build içinde olmalı.",
          tag: "#KOD",
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          color: const Color(0xFF00E676),
        ),
      ],
    );
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }

  void addNote(String title, String content, String tag, Color color) {
    final newNote = VaultNote(
      id: const Uuid().v4(),
      title: title,
      content: content,
      tag: tag,
      createdAt: DateTime.now(),
      color: color,
    );
    state = state.copyWith(notes: [newNote, ...state.notes]);
  }

  void deleteNote(String id) {
    state = state.copyWith(notes: state.notes.where((n) => n.id != id).toList());
  }
}

final vaultProvider = NotifierProvider<VaultNotifier, VaultState>(() => VaultNotifier());