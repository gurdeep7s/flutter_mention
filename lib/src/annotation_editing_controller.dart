 part of flutter_mentions;

/// A custom implementation of [TextEditingController] to support @ mention or other
/// trigger based mentions.
class AnnotationEditingController extends TextEditingController {
  Map<String, Annotation> _mapping;
  String? _pattern;

  // Generate the Regex pattern for matching all the suggestions in one.
  AnnotationEditingController(this._mapping)
      : _pattern = _mapping.values.isNotEmpty
    ? "(${_mapping.values.map((e) => RegExp.escape(e.display ?? '')).join('|')})"
    : null;


  /// Can be used to get the markup from the controller directly.
  String get markupText {
    final someVal = _mapping.isEmpty
        ? text
        : text.splitMapJoin(
            RegExp('$_pattern'),
         onMatch: (Match match) {
  final matchedText = match[0]!;

  final mention = _mapping.values.firstWhere(
    (element) => element.display == matchedText,
    orElse: () => Annotation(trigger: '@'),
  );

  if (!mention.disableMarkup && mention.id != null && mention.display != null) {
    return mention.markupBuilder != null
        ? mention.markupBuilder!(
            mention.trigger, mention.id!, mention.display!)
        : '${mention.trigger}[__${mention.id}__](__${mention.display}__)';
  } else {
    return matchedText;
  }
},
            onNonMatch: (String text) {
              return text;
            },
          );

    return someVal;
  }

  Map<String, Annotation> get mapping {
    return _mapping;
  }

  set mapping(Map<String, Annotation> mapping) {
  _mapping = mapping;

  final mentionDisplays = mapping.values
      .map((annotation) => RegExp.escape(annotation.display ?? ''))
      .where((display) => display.isNotEmpty)
      .toList();

  _pattern = '(${mentionDisplays.join('|')})';
}


  @override
TextSpan buildTextSpan({BuildContext? context, TextStyle? style, bool? withComposing}) {
  var children = <InlineSpan>[];

  if (_pattern == null || _pattern == '()') {
    children.add(TextSpan(text: text, style: style));
  } else {
    text.splitMapJoin(
      RegExp('$_pattern'),
      onMatch: (Match match) {
        final matchedText = match[0]!;

        final mention = _mapping.values.firstWhere(
          (element) => element.display == matchedText,
          orElse: () => Annotation(trigger: '@'),
        );

        children.add(
          TextSpan(
            text: matchedText,
            style: style!.merge(mention.style),
          ),
        );

        return '';
      },
      onNonMatch: (String nonMatchText) {
        children.add(TextSpan(text: nonMatchText, style: style));
        return '';
      },
    );
  }

  return TextSpan(style: style, children: children);
}

}



// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';

// class AnnotationEditingController extends TextEditingController {
//   late String _pattern;
//   Map<String, Annotation> _mapping = {};

//   void setMapping(Map<String, Annotation> mapping) {
//     _mapping = mapping;

//     _pattern = _mapping.values.isNotEmpty
//         ? '(${_mapping.values.map((a) => RegExp.escape(a.display ?? '')).join('|')})'
//         : '';
//   }

//   @override
//   InlineSpan buildTextSpan({
//     required TextStyle style,
//     required bool withComposing,
//   }) {
//     if (_pattern.isEmpty) {
//       return TextSpan(style: style, text: text);
//     }

//     final spans = <TextSpan>[];
//     final matches = RegExp(_pattern).allMatches(text);

//     int lastMatchEnd = 0;

//     for (final match in matches) {
//       if (match.start > lastMatchEnd) {
//         spans.add(TextSpan(
//           text: text.substring(lastMatchEnd, match.start),
//           style: style,
//         ));
//       }

//       final mentionText = match[0]!;
//       final annotation = _mapping.values.firstWhere(
//         (m) => m.display == mentionText,
//         orElse: () => Annotation(trigger: '@', display: mentionText),
//       );

//       spans.add(TextSpan(
//         text: annotation.display,
//         style: annotation.style ?? TextStyle(color: Colors.blue),
//         recognizer: TapGestureRecognizer()
//           ..onTap = () {
//             // Optional: handle tap on mention
//           },
//       ));

//       lastMatchEnd = match.end;
//     }

//     if (lastMatchEnd < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(lastMatchEnd),
//         style: style,
//       ));
//     }

//     return TextSpan(children: spans);
//   }

//   /// Returns the marked-up text using [markupBuilder] or default HTML span
//   String markupText() {
//     if (_pattern.isEmpty) return text;

//     return text.replaceAllMapped(RegExp(_pattern), (match) {
//       final mentionText = match[0]!;
//       final mention = _mapping.values.firstWhere(
//         (m) => m.display == mentionText,
//         orElse: () => Annotation(trigger: '@', display: mentionText),
//       );

//       if (mention.disableMarkup) return mentionText;

//       if (mention.markupBuilder != null) {
//         return mention.markupBuilder!(
//           mention.trigger,
//           mentionText,
//           mention.id ?? '',
//         );
//       }

//       // Default markup (e.g., HTML span)
//       return '''<span data-value="${mention.display}" data-id="${mention.id}" data-denotation-char="${mention.trigger}" class="mention"><span>${mention.display}</span></span>''';
//     });
//   }
// }

