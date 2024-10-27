library search_map;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:http/http.dart' as http;

part 'src/api/api_service.dart';
part 'src/models/prediction.dart';

class SearchMap extends StatefulWidget {
  final String apiKey;
  final FocusNode? focusNode;
  final Function(PlaceDetails) onClickAddress;
  final InputDecoration? decoration;

  const SearchMap({
    Key? key,
    required this.apiKey,
    this.focusNode,
    required this.onClickAddress,
    this.decoration,
  }) : super(key: key);

  @override
  State<SearchMap> createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> with SingleTickerProviderStateMixin {
  final GlobalKey _textFieldKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  late final ApiService _apiService;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  List<PlaceDetails> _predictions = [];
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _initializeAnimationController();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  void _initializeApiService() {
    _apiService = ApiService(widget.apiKey);
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  void _disposeResources() {
    _searchController.dispose();
    _debounce?.cancel();
    _animationController.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Update state to show/hide the suffix icon.
    if (_searchController.text.isEmpty) {
      _hideOverlay();
    } else {
      _debounceSearch(_searchController.text);
    }
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
    final result = await _apiService.getPlaceDetails(prediction.placeId!);
    result.fold(
          (error) => log('Error: $error'),
          (details) {
        widget.onClickAddress.call(details);
        _updateSearchField(prediction.description);
        _hideOverlayWithDelay();
      },
    );
  }

  void _updateSearchField(String? text) {
    setState(() {
      _searchController.text = text ?? '';
      _clearPredictions();
    });
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

  void _hideOverlayWithDelay() {
    _animationController.reverse().whenComplete(_hideOverlay);
  }

  void _clearPredictions() {
    setState(() {
      _predictions.clear();
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _animationController.forward();

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 10,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildPredictionList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
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
    );
  }

  void _clearSearchField() {
    if (mounted) {
      setState(() {
        _searchController.clear();
        _clearPredictions();
      });
    }
    widget.focusNode?.unfocus();
    _hideOverlay();
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      isCollapsed: widget.decoration?.isCollapsed ?? true,
      contentPadding: widget.decoration?.contentPadding ??
          const EdgeInsets.symmetric(vertical: 12),
      border: widget.decoration?.border ?? InputBorder.none,
      enabledBorder: widget.decoration?.enabledBorder ?? InputBorder.none,
      focusedBorder: widget.decoration?.focusedBorder ?? InputBorder.none,
      errorBorder: widget.decoration?.errorBorder ?? InputBorder.none,
      disabledBorder: widget.decoration?.disabledBorder ?? InputBorder.none,
      focusedErrorBorder: widget.decoration?.focusedErrorBorder ?? InputBorder.none,
      labelText: widget.decoration?.labelText ?? tr('search_address'),
      hintText: widget.decoration?.hintText ?? tr('search_address'),
      labelStyle: widget.decoration?.labelStyle ?? const TextStyle(color: Colors.black),
      hintStyle: widget.decoration?.hintStyle ?? const TextStyle(color: Color(0xFFA3A3A3)),
      alignLabelWithHint: widget.decoration?.alignLabelWithHint ?? true,
      floatingLabelBehavior: widget.decoration?.floatingLabelBehavior ??
          FloatingLabelBehavior.never,
      suffixIcon: _searchController.text.isNotEmpty ? _buildSuffixIcon() : null,
    );
  }

  Widget _buildSuffixIcon() {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(
        FontAwesomeIcons.xmark,
        size: 20,
        color: Color(0xFFA3A3A3),
      ),
      onPressed: _clearSearchField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              focusNode: widget.focusNode ?? FocusNode(),
              decoration: _buildDecoration(),
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

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.25),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
