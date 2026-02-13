import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/task_model.dart';
import 'task_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with TickerProviderStateMixin {
  // --- ARKA PLAN ANİMASYON CONTROLLER ---
  late AnimationController _bgController;
  Alignment _topAlignment = Alignment.topLeft;
  Alignment _bottomAlignment = Alignment.bottomRight;

  DateTime _selectedDate = DateTime.now();
  final DateTime _timelineStartDate = DateTime.now().subtract(const Duration(days: 30));
  late ScrollController _scrollController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  final List<String> _categories = ["Genel", "İş", "Okul", "Spor", "Kişisel", "Sağlık"];
  String _selectedCategory = "Genel"; 
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 30.0 * 72.0);

    // ARKA PLAN ANİMASYONU BAŞLATMA
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Çok yavaş ve sakin bir akış
    )..repeat(reverse: true);

    _bgController.addListener(() {
      setState(() {
        // Renklerin çaprazlama yer değiştirmesi
        _topAlignment = Alignment(
          -1.0 + (_bgController.value * 2.0),
          -1.0 + (_bgController.value * 0.5),
        );
        _bottomAlignment = Alignment(
          1.0 - (_bgController.value * 2.0),
          1.0 - (_bgController.value * 0.5),
        );
      });
    });
  }

  @override
  void dispose() {
    _bgController.dispose(); // Controller'ı temizlemeyi unutma
    _scrollController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String get _greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 6) return "İyi Geceler";
    if (hour < 12) return "Günaydın";
    if (hour < 18) return "Tünaydın";
    return "İyi Akşamlar";
  }

  Future<void> _selectDateFromCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && !_isSameDay(picked, _selectedDate)) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final dailyTasks = allTasks.where((task) => _isSameDay(task.date, _selectedDate)).toList();

    return Scaffold(
      // Arka plan rengini kaldırıyoruz çünkü Stack içinde halledeceğiz
      backgroundColor: Colors.transparent, 
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskModal(context, null),
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),

      body: Stack(
        children: [
          // 1. KATMAN: "ÇAĞ DIŞI MÜKEMMEL" YAŞAYAN ARKA PLAN
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _topAlignment,
                end: _bottomAlignment,
                // Premium Gündoğumu Renk Paleti
                colors: const [
                  Color(0xFFF8BBD0), // Yumuşak Pembe
                  Color(0xFFE1BEE7), // Açık Lavanta
                  Color(0xFFB3E5FC), // Bebek Mavisi
                  Color(0xFFFFE0B2), // Altın Şeftali
                  Colors.white,      // Geçişi yumuşatmak için beyaz
                ],
                stops: const [0.1, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),

          // 2. KATMAN: İçeriklerin okunması için çok hafif bir beyaz tül
          Container(
            color: Colors.white.withOpacity(0.5),
          ),

          // 3. KATMAN: ASIL İÇERİK
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildDateTimeline(),
                const SizedBox(height: 20),
                Expanded(child: _buildTaskList(dailyTasks)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingMessage.toUpperCase(),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isSameDay(_selectedDate, DateTime.now()) ? "Doğu" : DateFormat('d MMMM').format(_selectedDate),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.0),
                  ),
                ],
              ),
            ],
          ),
          
          Material(
            color: Colors.white.withOpacity(0.6), // Biraz daha şeffaf
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.5))
            ),
            child: InkWell(
              onTap: _selectDateFromCalendar,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 26),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateTimeline() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 90, 
        padding: const EdgeInsets.only(left: 20),
        itemBuilder: (context, index) {
          final date = _timelineStartDate.add(Duration(days: index));
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () { setState(() => _selectedDate = date); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              width: 60,
              decoration: BoxDecoration(
                // Arka plan hareketli olduğu için kutuları biraz daha belirgin yapalım
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                border: isToday && !isSelected ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 2) : Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: isSelected 
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))] 
                  : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('d').format(date), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary)),
                  if (isToday && isSelected) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle), child: Icon(Icons.event_note_rounded, size: 60, color: AppColors.primary.withOpacity(0.5))),
              const SizedBox(height: 20),
              const Text("Planlar Boş", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text("Güne başlamak için ekle butonuna bas!", style: TextStyle(color: AppColors.textSecondary)),
            ],
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Görevler (${tasks.length})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) { ref.read(taskProvider.notifier).deleteTask(task.id); },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  child: GestureDetector(
                    onTap: () => _showTaskModal(context, task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // Kartları arka plandan ayırmak için daha opak yapıyoruz
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: task.isDone ? AppColors.success.withOpacity(0.3) : Colors.white),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          if (task.startTime != null)
                            Container(
                              padding: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade100))),
                              child: Column(
                                children: [
                                  Text(task.startTime!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  if (task.endTime != null)
                                    Text(task.endTime!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title, 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: task.isDone ? TextDecoration.lineThrough : null, color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary)
                                ),
                                if (task.description.isNotEmpty)
                                  Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.8))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(task.category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () { ref.read(taskProvider.notifier).toggleTask(task.id); },
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: task.isDone ? AppColors.success : Colors.transparent,
                                border: Border.all(color: task.isDone ? AppColors.success : Colors.grey.shade300, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: task.isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskModal(BuildContext context, Task? taskToEdit) {
    final isEditing = taskToEdit != null;
    if (isEditing) {
      _titleController.text = taskToEdit.title;
      _descController.text = taskToEdit.description;
      setState(() {
        _selectedCategory = taskToEdit.category;
        _startTime = _parseTime(taskToEdit.startTime);
        _endTime = _parseTime(taskToEdit.endTime);
      });
    } else {
      _titleController.clear();
      _descController.clear();
      setState(() { _selectedCategory = "Genel"; _startTime = null; _endTime = null; });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? "Planı Düzenle ✏️" : "Yeni Plan Ekle 🚀", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      if (isEditing)
                         IconButton(
                           icon: const Icon(Icons.delete_outline, color: AppColors.error),
                           onPressed: () { ref.read(taskProvider.notifier).deleteTask(taskToEdit.id); Navigator.pop(context); },
                         )
                      else
                        Text(DateFormat('d MMM').format(_selectedDate), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Kategori", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                            backgroundColor: Colors.grey.shade100,
                            onSelected: (bool selected) { setModalState(() { _selectedCategory = category; }); },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Ne yapacaksın?",
                      filled: true, fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.title, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      hintText: "Detay ekle",
                      filled: true, fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.short_text, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay.now());
                            if (picked != null) setModalState(() => _startTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(_startTime == null ? "Başlangıç" : _startTime!.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());
                            if (picked != null) setModalState(() => _endTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.update, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(_endTime == null ? "Bitiş" : _endTime!.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        if (_titleController.text.isNotEmpty) {
                          if (isEditing) {
                            ref.read(taskProvider.notifier).updateTask(id: taskToEdit.id, title: _titleController.text, description: _descController.text, category: _selectedCategory, startTime: _startTime?.format(context), endTime: _endTime?.format(context));
                          } else {
                            ref.read(taskProvider.notifier).addTask(title: _titleController.text, description: _descController.text, category: _selectedCategory, taskDate: _selectedDate, startTime: _startTime?.format(context), endTime: _endTime?.format(context));
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(isEditing ? "Güncelle" : "Listeye Ekle", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}