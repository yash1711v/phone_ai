import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/utils/permission_handler.dart';
import '../../../core/utils/logger.dart';

/// Custom text field with multiple variants
/// Supports: email, password, number, speech-to-text, and dropdown
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool isEmail;
  final bool isPassword;
  final bool isNumber;
  final bool enableSpeechToText;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onDropdownSelected;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? initialValue;
  final int? maxLength;
  final String? helperText;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.isEmail = false,
    this.isPassword = false,
    this.isNumber = false,
    this.enableSpeechToText = false,
    this.isDropdown = false,
    this.dropdownItems,
    this.validator,
    this.onChanged,
    this.onDropdownSelected,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.initialValue,
    this.maxLength,
    this.helperText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _selectedDropdownValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.isDropdown && widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty) {
      _selectedDropdownValue = widget.dropdownItems!.first;
    }
  }

  /// Get keyboard type based on field type
  TextInputType _getKeyboardType() {
    if (widget.isEmail) return TextInputType.emailAddress;
    if (widget.isNumber) return TextInputType.number;
    return TextInputType.text;
  }

  /// Get validator based on field type
  String? Function(String?)? _getValidator() {
    if (widget.validator != null) return widget.validator;

    if (widget.isEmail) {
      return (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email';
        }
        return null;
      };
    }

    if (widget.isPassword) {
      return (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Must be at least 6 characters';
        }
        return null;
      };
    }

    if (widget.isNumber) {
      return (value) {
        if (value == null || value.isEmpty) {
          return 'Number is required';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      };
    }

    return null;
  }

  /// Start speech to text
  Future<void> _startListening() async {
    try {
      final hasPermission = await AppPermissionHandler.requestMicrophonePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required')),
          );
        }
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
        onError: (error) {
          LogLevel.error('Speech recognition error', error);
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              widget.controller?.text = result.recognizedWords;
              widget.onChanged?.call(result.recognizedWords);
              setState(() {
                _isListening = false;
              });
            }
          },
        );
      }
    } catch (e) {
      LogLevel.error('Failed to start speech recognition', e);
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  /// Stop speech to text
  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Build prefix icon
  Widget? _buildPrefixIcon() {
    if (widget.enableSpeechToText) {
      return GestureDetector(
        onTap: _isListening ? _stopListening : _startListening,
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening ? Colors.red : Colors.grey,
        ),
      );
    }
    return widget.prefixIcon;
  }

  /// Build suffix icon for password
  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDropdown && widget.dropdownItems != null) {
      return _buildDropdown();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: _getKeyboardType(),
          validator: _getValidator(),
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          initialValue: widget.initialValue,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(),
            helperText: widget.helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Build searchable dropdown field
  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        _SearchableDropdown(
          items: widget.dropdownItems!,
          selectedValue: _selectedDropdownValue,
          hint: widget.hint ?? 'Select an option',
          prefixIcon: widget.prefixIcon,
          enabled: widget.enabled,
          onChanged: (value) {
            setState(() {
              _selectedDropdownValue = value ?? '';
            });
            widget.onDropdownSelected?.call(value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

/// Searchable dropdown widget
class _SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final String? hint;
  final Widget? prefixIcon;
  final bool enabled;
  final ValueChanged<String?>? onChanged;

  const _SearchableDropdown({
    required this.items,
    this.selectedValue,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<_SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<_SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) =>
                item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.enabled
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _filteredItems = widget.items;
                    }
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.selectedValue ?? widget.hint ?? 'Select an option',
                    style: TextStyle(
                      color: widget.selectedValue != null
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && widget.enabled) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item == widget.selectedValue;
                      return InkWell(
                        onTap: () {
                          widget.onChanged?.call(item);
                          setState(() {
                            _isExpanded = false;
                            _searchController.clear();
                            _filteredItems = widget.items;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
