import 'package:flutter/material.dart';

void main() {
  runApp(const GardenClickerApp());
}

//stateful since active
class GardenClickerApp extends StatefulWidget {
  const GardenClickerApp({super.key});

  @override
  State<GardenClickerApp> createState() => _GardenClickerAppState();
}

class _GardenClickerAppState extends State<GardenClickerApp> {

  bool _darkMode = false; // dark mode state
  double _volume = 0.5;   // volume

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // removes debug banner
      title: 'Garden Clicker',

      // Theme changes depending on dark mode
      theme: ThemeData(
          brightness: _darkMode ? Brightness.dark : Brightness.light
      ),

      // Main screen of the app
      home: MainMenuScreen(
        darkMode: _darkMode,
        volume: _volume,

        // Function to toggle dark mode
        onToggleDarkMode: (val) =>
            setState(() =>
            _darkMode = val),

        // Function to change volume
        onChangeVolume: (val) =>
            setState(() =>
            _volume = val),
      ),
    );
  }
}

// Main Menu Screen(Stateless because data comes from parent)
class MainMenuScreen extends StatelessWidget {

  final bool darkMode; // current dark mode
  final double volume; // current volume

  // Functions passed from parent
  final Function(bool) onToggleDarkMode;
  final Function(double) onChangeVolume;

  const MainMenuScreen({
    super.key,
    required this.darkMode,
    required this.volume,
    required this.onToggleDarkMode,
    required this.onChangeVolume,
  });

  @override
  Widget build(BuildContext context) {
    // Change background depending on dark mode
    final backgroundColors = darkMode ? Colors.black : Colors.greenAccent;
    // Change text color depending on dark mode
    final textColor = darkMode ? Colors.greenAccent : Colors.green;
    return Scaffold(
      backgroundColor: backgroundColors,
      // Stack for button and menu
      body: Stack(
        children: [
          // settings button (top right)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.settings, color: textColor, size: 32),
              onPressed: () {
                // Opens popup
                showDialog(
                  context: context,
                  builder: (_) => SettingsPopup(
                    isDarkMode: darkMode,
                    volume: volume,
                    // Pass functions to popup
                    onDarkModeChanged: onToggleDarkMode,
                    onVolumeChanged: onChangeVolume,
                    // Reset game action
                    onResetGame: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Game reset!")),
                      );
                    },

                    // Rebirth action
                    onRebirth: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Rebirth screen opening...")),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // main menu
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // title
                  Text(
                    "Garden Clicker",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // play button
                  _menuButton(
                    context: context,
                    label: "Play",
                    color: darkMode ? Colors.greenAccent : Colors.black,
                    textColor: darkMode ? Colors.black : Colors.white,
                    onTap: () => debugPrint("Play pressed"),
                  ),

                  const SizedBox(height: 15),

                  //login button
                  _menuButton(
                    context: context,
                    label: "Login",
                    color: Colors.white,
                    textColor: Colors.black,
                    onTap: () => debugPrint("Login pressed"),
                  ),

                  const SizedBox(height: 15),

                  // quit button
                  _menuButton(
                    context: context,
                    label: "Quit",
                    color: Colors.redAccent,
                    textColor: Colors.black,
                    onTap: () => debugPrint("Quit pressed"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // reusable functions
  Widget _menuButton({
    required BuildContext context,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      //button styel
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 20),
      ),
    );
  }
}

// setings
class SettingsPopup extends StatefulWidget {
  final bool isDarkMode;
  final double volume;
  final Function(bool) onDarkModeChanged;
  final Function(double) onVolumeChanged;
  final VoidCallback onResetGame;
  final VoidCallback onRebirth;

  const SettingsPopup({ //call them since already done
    super.key,
    required this.isDarkMode,
    required this.volume,
    required this.onDarkModeChanged,
    required this.onVolumeChanged,
    required this.onResetGame,
    required this.onRebirth,
  });

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  late bool _darkMode; // dark mode
  late double _volume; //volume
  @override
  void initState() {
    super.initState();
    // Initialize values from parent
    _darkMode = widget.isDarkMode;
    _volume = widget.volume;
  }

  @override
  Widget build(BuildContext context) {
    // Title color depends on dark mode
    final titleColor = _darkMode ? Colors.greenAccent : Colors.green;
    return Dialog(
      backgroundColor: Colors.transparent, // transparent background
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _darkMode ? Colors.black : Colors.brown,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),

            const SizedBox(height: 20),

            // audio
            _buildSection(
              title: "Audio",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Volume"),
                  // slider to control volume
                  Slider(
                    value: _volume,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() => _volume = val); // update UI
                      widget.onVolumeChanged(val);   // send to parent
                    },
                  ),
                ],
              ),
            ),

            // dark mode
            _buildSection(
              title: "Appearance",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Dark Mode"),
                  // switch toggle
                  Switch(
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      widget.onDarkModeChanged(val);
                    },
                  ),
                ],
              ),
            ),

            // resent button
            _buildSection(
              title: "Game Data",
              child: ElevatedButton(
                onPressed: _confirmReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 40),
                ),

                child: const Text("Reset Game"),
              ),
            ),

            // rebirth button
            _buildSection(
              title: "Rebirth",
              child: ElevatedButton(
                onPressed: widget.onRebirth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40),
                ),

                child: const Text("Go to Rebirth Screen"),
              ),
            ),

            const SizedBox(height: 15),

            //close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: titleColor, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // reusable
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _darkMode ? Colors.grey : Colors.lightGreen,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),

          const SizedBox(height: 8),
          child, // content inside section
        ],
      ),
    );
  }

  // confirmation of reset
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Reset"),
        content: const Text(
            "Are you sure you want to reset your progress? This can't be undone."),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // resent button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onResetGame();
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}