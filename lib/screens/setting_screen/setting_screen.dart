import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Setting Screen'),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import '../../l10n/app_localization.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = FlutterLocalization.instance;

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () => t.translate(AppLocale.VIETNAMESE),
//             child: Text(t.getString('selectLanguage') + ": Tiếng Việt"),
//           ),
//           ElevatedButton(
//             onPressed: () => t.translate(AppLocale.ENGLISH),
//             child: Text(t.getString('selectLanguage') + ": English"),
//           ),
//         ],
//       ),
//     );
//   }
// }
