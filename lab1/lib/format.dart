String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]}, ${date.hour}:$minute';
}
