import 'package:flutter/material.dart';

import 'models.dart';
import 'format.dart';

class FormScreen extends StatefulWidget {
  final Event? event;
  const FormScreen({super.key, this.event});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final key = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController place;
  late final TextEditingController limit;
  late final TextEditingController description;
  late final TextEditingController dateText;
  late final TextEditingController timeText;
  late final FocusNode titleFocus;
  late final FocusNode placeFocus;
  late final FocusNode limitFocus;
  late final FocusNode descriptionFocus;
  late EventCategory category;
  late DateTime date;
  late bool online;
  bool saving = false;
  bool saved = false;
  bool dirty = false;
  @override
  void initState() {
    super.initState();
    final e = widget.event ?? Event.empty();
    title = TextEditingController(text: e.title);
    place = TextEditingController(text: e.place);
    limit = TextEditingController(text: e.limit.toString());
    description = TextEditingController(text: e.description ?? '');
    dateText = TextEditingController();
    timeText = TextEditingController();
    titleFocus = FocusNode();
    placeFocus = FocusNode();
    limitFocus = FocusNode();
    descriptionFocus = FocusNode();
    category = e.category;
    date = e.date;
    online = e.isOnline;
    updateDateText();
    for (final c in [title, place, limit, description]) {
      c.addListener(markDirty);
    }
  }

  void markDirty() {
    if (!dirty && !saved) setState(() => dirty = true);
  }

  void updateDateText() {
    dateText.text = '${date.day}/${date.month}/${date.year}';
    timeText.text =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final c in [title, place, limit, description, dateText, timeText]) {
      c.dispose();
    }
    for (final f in [titleFocus, placeFocus, limitFocus, descriptionFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> chooseDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || value == null) return;
    setState(() {
      date = DateTime(
        value.year,
        value.month,
        value.day,
        date.hour,
        date.minute,
      );
      dirty = true;
      updateDateText();
    });
  }

  Future<void> chooseTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (!mounted || value == null) return;
    setState(() {
      date = DateTime(
        date.year,
        date.month,
        date.day,
        value.hour,
        value.minute,
      );
      dirty = true;
      updateDateText();
    });
  }

  Future<void> save() async {
    if (!(key.currentState?.validate() ?? false)) return;
    if (widget.event == null && !date.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a future date')));
      return;
    }
    setState(() => saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final old = widget.event;
    final result = Event(
      title: title.text.trim(),
      category: category,
      date: date,
      place: place.text.trim(),
      limit: int.parse(limit.text),
      attendees: old?.attendees ?? [],
      isOnline: online,
      description: description.text.trim().isEmpty
          ? null
          : description.text.trim(),
      isFavorite: old?.isFavorite ?? false,
    );
    saved = true;
    Navigator.pop(context, result);
  }

  Future<void> askDiscard() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted || yes != true) return;
    setState(() {
      dirty = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !dirty || saved,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && !saving) askDiscard();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'New Event' : 'Edit Event'),
      ),
      body: Form(
        key: key,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: title,
              focusNode: titleFocus,
              maxLength: 60,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v?.trim().length ?? 0) < 3 ? '3–60 characters' : null,
            ),
            DropdownButtonFormField<EventCategory>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in EventCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (v) {
                if (v != null)
                  setState(() {
                    category = v;
                    dirty = true;
                  });
              },
            ),
            SwitchListTile(
              title: const Text('Online'),
              value: online,
              onChanged: (v) => setState(() {
                online = v;
                dirty = true;
              }),
            ),
            TextFormField(
              controller: place,
              focusNode: placeFocus,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: online ? 'Meeting link' : 'Location',
              ),
              validator: (v) {
                if ((v?.trim().isEmpty ?? true)) return 'Required';
                if (online && !(v?.contains('://') ?? false))
                  return 'Include :// in link';
                return null;
              },
            ),
            TextFormField(
              controller: limit,
              focusNode: limitFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Capacity'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1 || n > 500) return 'Enter 1–500';
                if (n < (widget.event?.count ?? 0))
                  return 'Below current participants';
                return null;
              },
            ),
            TextFormField(
              controller: dateText,
              readOnly: true,
              onTap: chooseDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (_) => date.year < 2020 ? 'Select date' : null,
            ),
            TextFormField(
              controller: timeText,
              readOnly: true,
              onTap: chooseTime,
              decoration: const InputDecoration(
                labelText: 'Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              validator: (_) => null,
            ),
            TextFormField(
              controller: description,
              focusNode: descriptionFocus,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: saving ? null : save,
              child: saving
                  ? const CircularProgressIndicator()
                  : const Text('Save Event'),
            ),
            Text('Selected: ${formatDate(date)}'),
          ],
        ),
      ),
    ),
  );
}
