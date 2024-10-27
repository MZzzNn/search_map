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

class SearchMap extends StatefulWidget {
  final String apiKey;
  final FocusNode focusNode;
  final Function(PlaceDetails) onClickAddress;

  const SearchMap({
    Key? key,
    required this.apiKey,
    required this.focusNode,
    required this.onClickAddress,
  }) : super(key: key);

  @override
  State<SearchMap> createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {
  final GlobalKey _textFieldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  late final ApiService _apiService;

  List<PlaceDetails> _predictions = [];
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(widget.apiKey);

    _searchController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_showOverlay) _debounceSearch(_searchController.text);
    if (_searchController.text.isEmpty) _clearPredictions();
  }

  void _debounceSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String query) async {
    final result = await _apiService.getAutocompletePredictions(query);
    result.fold(
      (error) => log('Error: $error'),
      (predictions) {
        setState(() {
          _predictions = predictions;
        });
        _showPredictionOverlay();
      },
    );
  }

  void _onPredictionSelected(PlaceDetails prediction) async {
    _showOverlay = false;
    final result = await _apiService.getPlaceDetails(prediction.placeId!);
    result.fold(
      (error) => log('Error: $error'),
      (details) {
        widget.onClickAddress(details);
        setState(() {
          _searchController.text = prediction.description ?? '';
          _clearPredictions();
        });
        _hideOverlay();
        _resetOverlayVisibility();
      },
    );
  }

  void _showPredictionOverlay() {
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _resetOverlayVisibility() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _showOverlay = true;
    });
  }

  void _clearPredictions() {
    setState(() {
      _predictions.clear();
    });
    _hideOverlay();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: ListView.builder(
            itemCount: _predictions.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final prediction = _predictions[index];
              return ListTile(
                title: Text(prediction.description ?? ''),
                onTap: () => _onPredictionSelected(prediction),
              );
            },
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: _textFieldKey,
              controller: _searchController,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                labelText: tr('search_address'),
                hintText: tr('search_address'),
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
                      _searchController.clear();
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
