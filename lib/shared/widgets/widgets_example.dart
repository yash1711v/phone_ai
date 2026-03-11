import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'custom_tab_bar.dart';
import 'custom_button.dart';
import 'custom_chip_selection.dart';
import 'custom_sub_button.dart';


/// Example usage of all custom widgets
class WidgetsExamplePage extends StatefulWidget {
  const WidgetsExamplePage({super.key});

  @override
  State<WidgetsExamplePage> createState() => _WidgetsExamplePageState();
}

class _WidgetsExamplePageState extends State<WidgetsExamplePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _numberController = TextEditingController();
  final _speechController = TextEditingController();
  String? _selectedDropdownValue;
  int _selectedTabIndex = 0;
  String? _selectedChip;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _numberController.dispose();
    _speechController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Widgets Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Text Field - Email
            CustomTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: _emailController,
              isEmail: true,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 20),

            // Custom Text Field - Password
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outlined),
              helperText: 'Must be at least 6 characters',
            ),
            const SizedBox(height: 20),

            // Custom Text Field - Number
            CustomTextField(
              label: 'Number',
              hint: 'Enter a number',
              controller: _numberController,
              isNumber: true,
              prefixIcon: const Icon(Icons.numbers),
            ),
            const SizedBox(height: 20),

            // Custom Text Field - Speech to Text
            CustomTextField(
              label: 'Speech to Text',
              hint: 'Tap microphone to speak',
              controller: _speechController,
              enableSpeechToText: true,
            ),
            const SizedBox(height: 20),

            // Custom Text Field - Dropdown
            CustomTextField(
              label: 'Select Option',
              hint: 'Choose an option',
              isDropdown: true,
              dropdownItems: const [
                'Option 1',
                'Option 2',
                'Option 3',
                'Option 4',
              ],
              onDropdownSelected: (value) {
                setState(() {
                  _selectedDropdownValue = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Custom Tab Bar
            CustomTabBar(
              tabs: const ['Google Business', 'Website'],
              initialIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 20),

            // Custom Button - Enabled
            CustomButton(
              text: 'Enabled Button',
              enabled: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Button pressed')),
                );
              },
            ),
            const SizedBox(height: 12),

            // Custom Button - Disabled
            CustomButton(
              text: 'Disabled Button',
              enabled: false,
            ),
            const SizedBox(height: 20),

            // Custom Chip Selection
            CustomChipSelection(
              items: const ['All', 'Unread', 'Contacts', 'Missed'],
              initialIndex: 0,
              onSelectionChanged: (value) {
                setState(() {
                  _selectedChip = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: $value')),
                );
              },
            ),
            const SizedBox(height: 20),

            // Custom Sub Buttons - Icon
            Row(
              children: [
                CustomSubButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone icon pressed')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                CustomSubButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message icon pressed')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                CustomSubButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('More icon pressed')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Custom Sub Buttons - Text
            Row(
              children: [
                Expanded(
                  child: CustomSubButton(
                    text: const Text('Call'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call button pressed')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomSubButton(
                    text: const Text('Message'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message button pressed')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
