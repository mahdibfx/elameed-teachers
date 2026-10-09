import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

Future<T?> _sheet<T>(String title, List<Widget> Function(BuildContext) children) => showModalBottomSheet<T>(
  context: StackedService.navigatorKey!.currentContext!,
  isScrollControlled: true,
  backgroundColor: AppColors.backgroundColor,
  builder: (c) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(c).height * .75),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: CustomText.bodyLarge(text: title),
          ),
          ...children(c),
        ],
      ),
    ),
  ),
);

Widget _check(bool on) => on ? const Icon(Icons.check, color: AppColors.primaryColor) : const SizedBox.shrink();

/// Book → unit. `(unit: null)` = "no book unit"; `null` = dismissed.
Future<({BookUnit? unit})?> showUnitPicker(List<Book> books, int? currentId) => _sheet(
  'session.unit'.tr(),
  (c) => [
    ListTile(leading: const Icon(Icons.block), title: Text('session.no_book_unit'.tr()), onTap: () => Navigator.pop(c, (unit: null))),
    for (final b in books)
      ExpansionTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(b.name),
        initiallyExpanded: b.units.any((u) => u.id == currentId),
        children: [
          for (final u in b.units)
            ListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
              title: Text(u.name),
              trailing: _check(u.id == currentId),
              onTap: () => Navigator.pop(c, (unit: u)),
            ),
        ],
      ),
  ],
);

Future<Room?> showRoomPicker(List<Room> rooms, int? currentId) => _sheet(
  'session.change_room'.tr(),
  (c) => [
    for (final r in rooms)
      ListTile(
        leading: const Icon(Icons.meeting_room_outlined),
        title: Text(roomLabel(r)),
        trailing: _check(r.id == currentId),
        onTap: () => Navigator.pop(c, r),
      ),
  ],
);
