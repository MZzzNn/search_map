library search_map;

import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:http/http.dart' as http;

part 'src/api/api_service.dart';

part 'src/models/prediction.dart';

class SearchMapTextField extends StatefulWidget {
  final String apiKey;
  final FocusNode focusNode;
  final Function(PlaceDetails prediction) onClickAddress;

  SearchMapTextField({
    super.key,
    required this.apiKey,
    required this.focusNode,
    required this.onClickAddress,
  }) : assert(apiKey.isNotEmpty);

  @override
  State<SearchMapTextField> createState() => _SearchMapTextFieldState();
}

class _SearchMapTextFieldState extends State<SearchMapTextField> {
  final GlobalKey _textFieldKey = GlobalKey();
  late TextEditingController _searchController;
  late ApiService _apiService;

  List<PlaceDetails> _predictions = [];
  OverlayEntry? _overlayEntry;
  bool _overlayShouldShow = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _apiService = ApiService(widget.apiKey);

    _searchController.addListener(() {
      if (_overlayShouldShow) {
        _onChangedDebounced(_searchController.text);
      }
      if (_searchController.text.isEmpty) {
        _predictions.clear();
        _removeOverlay();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _onChanged(value);
    });
  }

  void _onChanged(String value) async {
    if (value.isNotEmpty) {
      final result = await _apiService.getAutocompletePredictions(value);
      result.fold(
        (exception) {
          log('Error: $exception');
        },
        (predictions) {
          setState(() {
            _predictions = predictions;
          });
          _showOverlay();
        },
      );
    } else {
      setState(() {
        _predictions.clear();
      });
      _removeOverlay();
    }
  }

  void _onPredictionSelected(PlaceDetails prediction) async {
    _overlayShouldShow = false;
    final result = await _apiService.getPlaceDetails(prediction.placeId!);
    result.fold(
      (exception) {
        log('Error: $exception');
      },
      (PlaceDetails placeDetails) {
        placeDetails = placeDetails.copyWith(
          description: prediction.description,
          placeId: prediction.placeId,
        );
        widget.onClickAddress.call(placeDetails);
        setState(() {
          _searchController.text = prediction.description ?? '';
          _predictions.clear();
          widget.focusNode.unfocus();
        });
        _removeOverlay();

        Future.delayed(Duration(milliseconds: 300), () {
          _overlayShouldShow = true;
        });
      },
    );
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction.description ?? ''),
                  onTap: () {
                    _onPredictionSelected(prediction);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA3A3A3).withOpacity(0.25),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 20,
            color: Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: _textFieldKey,
              controller: _searchController,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                fillColor: Colors.white,
                focusColor: Colors.white,
                hoverColor: Colors.white,
                contentPadding: EdgeInsets.only(bottom: 13),
                filled: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                labelText: "search_address".tr(),
                hintText: "search_address".tr(),
                labelStyle: const TextStyle(color: Colors.black),
                hintStyle: const TextStyle(color: Color(0xFFA3A3A3)),
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                suffixIcon: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstChild: IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.xmark,
                      size: 20,
                      color: Color(0xFFA3A3A3),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      widget.focusNode.unfocus();
                      _onChanged('');
                    },
                  ),
                  secondChild: const SizedBox(),
                  crossFadeState: _searchController.text.isNotEmpty
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
                isCollapsed: false,
                isDense: false,
              ),
              textAlign: TextAlign.start,
              keyboardType: TextInputType.streetAddress,
              maxLines: 1,
              textInputAction: TextInputAction.search,
              onTap: () {
                widget.focusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
