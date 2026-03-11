# Custom Widgets Documentation

This directory contains reusable custom widgets for the application.

## CustomTextField

A versatile text field widget that supports multiple input types and features.

### Features
- Email validation
- Password field with visibility toggle
- Number input
- Speech-to-text with microphone icon
- Searchable dropdown

### Usage Examples

#### Email Field
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  isEmail: true,
  prefixIcon: Icon(Icons.email_outlined),
)
```

#### Password Field
```dart
CustomTextField(
  label: 'Password',
  hint: 'Enter your password',
  controller: passwordController,
  isPassword: true,
  prefixIcon: Icon(Icons.lock_outlined),
  helperText: 'Must be at least 6 characters',
)
```

#### Number Field
```dart
CustomTextField(
  label: 'Number',
  hint: 'Enter a number',
  controller: numberController,
  isNumber: true,
)
```

#### Speech-to-Text Field
```dart
CustomTextField(
  label: 'Speech to Text',
  hint: 'Tap microphone to speak',
  controller: speechController,
  enableSpeechToText: true,
)
```

#### Searchable Dropdown
```dart
CustomTextField(
  label: 'Select Option',
  hint: 'Choose an option',
  isDropdown: true,
  dropdownItems: ['Option 1', 'Option 2', 'Option 3'],
  onDropdownSelected: (value) {
    print('Selected: $value');
  },
)
```

### Parameters
- `label`: Field label text
- `hint`: Placeholder text
- `controller`: Text editing controller
- `isEmail`: Enable email validation
- `isPassword`: Enable password field with visibility toggle
- `isNumber`: Enable number input
- `enableSpeechToText`: Enable speech-to-text with microphone
- `isDropdown`: Enable searchable dropdown
- `dropdownItems`: List of items for dropdown
- `onDropdownSelected`: Callback when dropdown item is selected
- `validator`: Custom validator function
- `onChanged`: Callback when text changes
- `prefixIcon`: Icon to display before text
- `suffixIcon`: Icon to display after text
- `enabled`: Enable/disable the field
- `maxLength`: Maximum character length
- `helperText`: Helper text below field

---

## CustomTabBar

A custom tab bar with smooth animations matching the design pattern.

### Usage
```dart
CustomTabBar(
  tabs: ['Google Business', 'Website'],
  initialIndex: 0,
  onTabChanged: (index) {
    print('Selected tab: $index');
  },
)
```

### Parameters
- `tabs`: List of tab labels
- `initialIndex`: Initial selected tab index
- `onTabChanged`: Callback when tab changes
- `selectedColor`: Color for selected tab text
- `unselectedColor`: Color for unselected tab background
- `backgroundColor`: Background color of tab bar

---

## CustomButton

A button with enabled/disabled states. Enabled state is dark black, disabled is gray and not clickable.

### Usage
```dart
// Enabled button
CustomButton(
  text: 'Continue',
  enabled: true,
  onPressed: () {
    print('Button pressed');
  },
)

// Disabled button
CustomButton(
  text: 'Continue',
  enabled: false,
)
```

### Parameters
- `text`: Button text
- `enabled`: Enable/disable button
- `onPressed`: Callback when button is pressed
- `isLoading`: Show loading indicator
- `width`: Button width
- `height`: Button height
- `padding`: Button padding
- `enabledColor`: Color when enabled (default: black)
- `disabledColor`: Color when disabled (default: gray)
- `textColor`: Text color (default: white)
- `borderRadius`: Border radius

---

## CustomChipSelection

A horizontal row of selectable chips. Returns only the selected item.

### Usage
```dart
CustomChipSelection(
  items: ['All', 'Unread', 'Contacts', 'Missed'],
  initialIndex: 0,
  onSelectionChanged: (selectedItem) {
    print('Selected: $selectedItem');
  },
)
```

### Parameters
- `items`: List of chip labels
- `initialIndex`: Initially selected chip index
- `onSelectionChanged`: Callback with selected item string
- `selectedColor`: Background color when selected (default: black)
- `unselectedColor`: Background color when unselected (default: white)
- `selectedTextColor`: Text color when selected (default: white)
- `unselectedTextColor`: Text color when unselected (default: gray)

---

## CustomSubButton

An outline-style button that can display either an icon (SVG or Icon widget) or text.

### Usage

#### With Icon Widget
```dart
CustomSubButton(
  icon: Icon(Icons.phone),
  onPressed: () {
    print('Phone pressed');
  },
)
```

#### With SVG Icon
```dart
CustomSubButton(
  svgIconPath: 'assets/icons/phone.svg',
  onPressed: () {
    print('Phone pressed');
  },
)
```

#### With Text
```dart
CustomSubButton(
  text: Text('Call'),
  onPressed: () {
    print('Call pressed');
  },
)
```

### Parameters
- `icon`: Icon widget to display
- `svgIconPath`: Path to SVG icon asset
- `text`: Text widget to display
- `onPressed`: Callback when button is pressed
- `enabled`: Enable/disable button
- `borderColor`: Border color
- `iconColor`: Icon color
- `width`: Button width
- `height`: Button height
- `padding`: Button padding
- `borderRadius`: Border radius
- `tooltip`: Tooltip text

**Note**: Either `icon`, `svgIconPath`, or `text` must be provided, but not both `icon` and `svgIconPath` together.

---

## Example Page

See `widgets_example.dart` for a complete example page demonstrating all widgets.
