import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationManager {
  static final ValueNotifier<String> currentLanguage = ValueNotifier('en');

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'my_warehouse': 'MY WAREHOUSE',
      'dashboard': 'Dashboard',
      'my_inventory': 'My Inventory',
      'ledger_statement': 'Ledger Statement',
      'my_bookings': 'My Bookings',
      'settings': 'Settings',
      'logout': 'Logout',
      'verified_client': 'Verified Client',
      'welcome': 'Welcome,',
      'total_bags': 'TOTAL BAGS',
      'total_lots': 'TOTAL LOTS',
      'outstanding_balance': 'OUTSTANDING BALANCE',
      'main_services': 'MAIN SERVICES',
      'my_stock': 'My Stock',
      'ledger': 'Ledger',
      'bookings': 'Bookings',
      'profile': 'Profile',
      'recent_activity': 'RECENT ACTIVITY',
      'see_all': 'See All',
      'no_recent_activity': 'No recent activity',
      'select_language': 'Select Language',
      'english': 'English',
      'hindi': 'हिंदी (Hindi)',
      'app_language': 'App Language',
      'language_desc': 'Choose your preferred language for the app',
      'save': 'SAVE',
      'lang_saved': 'Language updated successfully!',
      'delete_account': 'Delete Account',
      'delete_account_desc': 'Permanently delete your account and registered mobile number from this profile.',
      'delete_account_confirm': 'Are you sure you want to delete your account? This action will permanently remove your login access and unregistered phone number. This cannot be undone.',
      'delete': 'DELETE',
      'cancel': 'CANCEL',
      'deleting': 'Deleting...',
      'account_deleted': 'Account deleted successfully!',
    },
    'hi': {
      'my_warehouse': 'मेरा गोदाम',
      'dashboard': 'डैशबोर्ड',
      'my_inventory': 'मेरा स्टॉक',
      'ledger_statement': 'खाता विवरण',
      'my_bookings': 'मेरी बुकिंग',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'verified_client': 'सत्यापित ग्राहक',
      'welcome': 'स्वागत है,',
      'total_bags': 'कुल बोरियां',
      'total_lots': 'कुल लॉट्स',
      'outstanding_balance': 'बकाया राशि',
      'main_services': 'मुख्य सेवाएं',
      'my_stock': 'मेरा स्टॉक',
      'ledger': 'खाता',
      'bookings': 'बुकिंग्स',
      'profile': 'प्रोफाइल',
      'recent_activity': 'हाल की गतिविधि',
      'see_all': 'सभी देखें',
      'no_recent_activity': 'कोई गतिविधि नहीं',
      'select_language': 'भाषा चुनें',
      'english': 'English',
      'hindi': 'हिंदी (Hindi)',
      'app_language': 'ऐप की भाषा',
      'language_desc': 'ऐप के लिए अपनी पसंदीदा भाषा चुनें',
      'save': 'सुरक्षित करें',
      'lang_saved': 'भाषा सफलतापूर्वक बदल दी गई है!',
      'delete_account': 'खाता हटाएं',
      'delete_account_desc': 'अपने लॉगिन खाते और पंजीकृत मोबाइल नंबर को इस प्रोफ़ाइल से स्थायी रूप से हटाएं।',
      'delete_account_confirm': 'क्या आप वाकई अपना खाता हटाना चाहते हैं? यह क्रिया आपके लॉगिन एक्सेस और पंजीकृत फोन नंबर को स्थायी रूप से हटा देगी। इसे वापस नहीं लिया जा सकता।',
      'delete': 'हटाएं',
      'cancel': 'रद्द करें',
      'deleting': 'हटाया जा रहा है...',
      'account_deleted': 'खाता सफलतापूर्वक हटा दिया गया है!',
    }
  };

  static String translate(String key) {
    return _localizedValues[currentLanguage.value]?[key] ?? key;
  }

  static Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_lang') ?? 'en';
    currentLanguage.value = lang;
  }

  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', langCode);
    currentLanguage.value = langCode;
  }
}
