class InputValidator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    if (value.length > 100) {
      return 'Email is too long';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (value.length > 128) {
      return 'Password is too long';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name is too long';
    }
    
    // Only letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name contains invalid characters';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Zambian phone numbers: +260 or 0 followed by 9 digits
    final phoneRegex = RegExp(r'^(\+260|0)[0-9]{9}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid Zambian phone number';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value.replaceAll(',', ''));
    
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    if (price > 10000000) {
      return 'Price is too high';
    }
    
    return null;
  }

  // Year validation
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Year is required';
    }
    
    final year = int.tryParse(value);
    
    if (year == null) {
      return 'Please enter a valid year';
    }
    
    final currentYear = DateTime.now().year;
    
    if (year < 1900) {
      return 'Year is too old';
    }
    
    if (year > currentYear + 1) {
      return 'Year cannot be in the future';
    }
    
    return null;
  }

  // Mileage validation
  static String? validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mileage is required';
    }
    
    final mileage = int.tryParse(value.replaceAll(',', ''));
    
    if (mileage == null) {
      return 'Please enter a valid mileage';
    }
    
    if (mileage < 0) {
      return 'Mileage cannot be negative';
    }
    
    if (mileage > 1000000) {
      return 'Mileage is too high';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (value.length > 2000) {
      return 'Description is too long (max 2000 characters)';
    }
    
    return null;
  }

  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.length > 1000) {
      return 'Message is too long (max 1000 characters)';
    }
    
    return null;
  }

  // Report reason validation
  static String? validateReportReason(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reason is required';
    }
    
    if (value.length < 5) {
      return 'Reason must be at least 5 characters';
    }
    
    if (value.length > 500) {
      return 'Reason is too long (max 500 characters)';
    }
    
    return null;
  }

  // Generic text validation
  static String? validateText(
    String? value, {
    required String fieldName,
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$fieldName is too long (max $maxLength characters)';
    }
    
    return null;
  }

  // Sanitize input (remove potentially harmful characters)
  static String sanitize(String input) {
    // Remove HTML tags
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove script tags and content
    sanitized = sanitized.replaceAll(
      RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', 
        caseSensitive: false),
      '',
    );
    
    // Trim whitespace
    sanitized = sanitized.trim();
    
    return sanitized;
  }

  // Check for profanity (basic implementation)
  static bool containsProfanity(String text) {
    final profanityList = [
      // Add common profanity words here
      // This is a basic implementation
      'badword1',
      'badword2',
      // Add more as needed
    ];
    
    final lowerText = text.toLowerCase();
    
    for (final word in profanityList) {
      if (lowerText.contains(word)) {
        return true;
      }
    }
    
    return false;
  }

  // Validate image count
  static String? validateImageCount(int count) {
    if (count < 3) {
      return 'Please upload at least 3 images';
    }
    
    if (count > 20) {
      return 'Maximum 20 images allowed';
    }
    
    return null;
  }

  // Validate URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
