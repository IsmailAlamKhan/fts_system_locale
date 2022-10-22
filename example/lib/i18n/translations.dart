// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "bn.dart";
import "en.dart";

//ignore: avoid_classes_with_only_static_members
abstract class Translations {
  static Map<String, Map<String, String>> byKeys = getByKeys();
  static Map<String, Map<String, String>> getByKeys() => {
        "bn": LocaleBn.data,
        "en": LocaleEn.data,
      };

  static Map<String, Map<String, String>>? _byText;
  static Map<String, Map<String, String>> get byText {
    _byText ??= getByText();
    return _byText!;
  }

  static Map<String, Map<String, String>> getByText() {
    final source = getByKeys();
    final output = <String, Map<String, String>>{};
    final master = source[AppLocales.available.first.key]!;
    for (final localeKey in source.keys) {
      output[localeKey] = mapLocaleKeysToMasterText(
        source[localeKey]!,
        masterMap: master,
      );
    }
    return output;
  }

  static Map<String, String> mapLocaleKeysToMasterText(
    Map<String, String> localeMap, {
    Map<String, String>? masterMap,
  }) {
    final output = <String, String>{};
    final inputMap =
        masterMap ?? Translations.byKeys[AppLocales.available.first.key];
    if (inputMap == null) {
      throw Exception(
          "No master map found for locale: ${AppLocales.available.first.key}");
    }
    for (var k in localeMap.keys) {
      output[inputMap[k]!] = localeMap[k]!;
    }
    return output;
  }
}

//ignore: avoid_classes_with_only_static_members
abstract class AppLocales {
  static const en = LangVo("English", "English", "en", Locale("en"), "🇬🇧");
  static const bn = LangVo("বাংলা", "Bengali", "bn", Locale("bn"), "🇧🇩");
  static const available = <LangVo>[en, bn];
  static List<Locale> get supportedLocales => [en.locale, bn.locale];
  static Locale get systemLocale => window.locale;
  static List<Locale> get systemLocales => window.locales;
  static LangVo? of(Locale locale, [bool fullMatch = false]) {
    for (final langVo in AppLocales.available) {
      if ((!fullMatch && langVo.locale.languageCode == locale.languageCode) ||
          langVo.locale == locale) {
        return langVo;
      }
    }
    return null;
  }
}

class LangVo {
  final String nativeName, englishName, key, flagChar;
  final Locale locale;
  const LangVo(this.nativeName, this.englishName, this.key, this.locale,
      [this.flagChar = '']);
  @override
  String toString() =>
      'LangVo {nativeName: "$nativeName", englishName: "$englishName", locale: $locale, emoji: this.flagChar}';
}

/// demo widgets

/// Dropdown menu with available locales. (Material style)
/// Useful to test changing Locales.
class LangPickerMaterial extends StatelessWidget {
  final Locale? selected;
  final Function(Locale) onSelected;
  const LangPickerMaterial({
    super.key,
    this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) {
    final selectedValue = selected ?? AppLocales.supportedLocales.first;
    return Material(
      type: MaterialType.transparency,
      child: PopupMenuButton<Locale>(
        tooltip: 'Select language',
        initialValue: selectedValue,
        onSelected: onSelected,
        itemBuilder: (_) {
          return AppLocales.available
              .map(
                (e) => PopupMenuItem<Locale>(
                  value: e.locale,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              e.englishName,
                              style: const TextStyle(
                                fontSize: 14,
                                letterSpacing: -0.2,
                                fontWeight: FontWeight.w300,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.nativeName,
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: .15,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.key.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.translate,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(AppLocales.of(selectedValue)?.englishName ?? '-')
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple language picker (Cupertino style).
typedef SimpleLangPicker = LangPickerCupertino;

class LangPickerCupertino extends StatefulWidget {
  final Locale selected;
  final ValueChanged<Locale> onSelected;
  final bool changeOnScroll, showFlag, showNativeName, showLocaleCode, looping;

  const LangPickerCupertino({
    super.key,
    required this.selected,
    required this.onSelected,
    this.looping = false,
    this.changeOnScroll = false,
    this.showFlag = false,
    this.showNativeName = true,
    this.showLocaleCode = true,
  });

  @override
  createState() => _LangPickerCupertinoState();
}

class _LangPickerCupertinoState extends State<LangPickerCupertino> {
  @override
  void didUpdateWidget(covariant LangPickerCupertino oldWidget) {
    if (oldWidget.selected != widget.selected ||
        oldWidget.looping != widget.looping ||
        oldWidget.changeOnScroll != widget.changeOnScroll ||
        oldWidget.showFlag != widget.showFlag ||
        oldWidget.showNativeName != widget.showNativeName ||
        oldWidget.showLocaleCode != widget.showLocaleCode) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  late FixedExtentScrollController scrollController;

  LangVo? get selected => AppLocales.of(widget.selected);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: openPicker,
      child: Text(selected?.englishName ?? 'Choose language'),
    );
  }

  Future<void> openPicker() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        scrollController = FixedExtentScrollController(
          initialItem:
              selected == null ? 0 : AppLocales.available.indexOf(selected!),
        );
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: _buildPicker(),
          ),
        );
      },
    );
    if (!widget.changeOnScroll) {
      var index = scrollController.selectedItem;
      index %= AppLocales.available.length;
      widget.onSelected(AppLocales.available[index].locale);
    }
  }

  Widget _buildPicker() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CupertinoPicker(
        magnification: 1.22,
        squeeze: 1.2,
        useMagnifier: false,
        itemExtent: 40,
        scrollController: scrollController,
        onSelectedItemChanged: (index) {
          if (widget.changeOnScroll) {
            widget.onSelected(AppLocales.available[index].locale);
          }
        },
        looping: widget.looping,
        children: List<Widget>.generate(
          AppLocales.available.length,
          (index) {
            final vo = AppLocales.available[index];
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showNativeName)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        vo.nativeName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  if (widget.showFlag)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(vo.flagChar),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(vo.englishName),
                  ),
                  if (widget.showLocaleCode)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        vo.locale.toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
