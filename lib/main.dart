import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Shredding & Recovery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
        ),
      ),
      home: const DataScreen(),
    );
  }
}

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _data = '';
  String? _tempData; // Variable to hold temporarily deleted data
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _data = _prefs!.getString('data') ?? '';
    });
  }

  void _storeData(String newData) async {
    String? existingData = _prefs!.getString('data');
    String combinedData =
        existingData != null ? '$existingData\n$newData' : newData;
    await _prefs!.setString('data', combinedData);
    setState(() {
      _data = combinedData;
    });
  }

  void _deleteTemporarily() async {
    // Store temporarily deleted data before removing it
    _tempData = _data;
    await _prefs!.remove('data');
    setState(() {
      _data = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Data deleted temporarily.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: _recoverData, // Call _recoverData to undo deletion
      ),
    ));
  }

  void _recoverData() {
    if (_tempData != null) {
      _storeData(_tempData!); // Restore temporarily deleted data
      _tempData = null; // Reset tempData after recovery
    }
  }

  void _recoverDataButton() async {
    if (_tempData != null) {
      _storeData(_tempData!); // Restore temporarily deleted data
      _tempData = null; // Reset tempData after recovery
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data recovered successfully.'),
      ));
    } else {
      // Inform the user that permanent deletion cannot be recovered
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permanent deletion cannot be recovered.'),
      ));
    }
  }

  Future<void> _deletePermanentlyConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete data permanently?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deletePermanently();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePermanently() async {
    // Store an empty string to simulate permanent deletion
    await _prefs!.setString('data', '');
    setState(() {
      _data = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data deleted permanently.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Shredding & Recovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Stored Data:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _data.isEmpty ? 'No data stored' : _data,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _storeDataPrompt,
              child: const Text('Store Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteTemporarily,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Delete Temporarily'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recoverDataButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Recover Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deletePermanentlyConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Permanently'),
            ),
          ],
        ),
      ),
    );
  }

  void _storeDataPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newData = ''; // Variable to hold the new data entered
        return AlertDialog(
          title: const Text('Enter Data'),
          content: TextField(
            onChanged: (value) {
              newData = value; // Update newData when text changes
            },
            decoration: const InputDecoration(hintText: 'Enter data to store'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newData.isNotEmpty) {
                  // Check if new data is not empty
                  _storeData(newData); // Store the new data
                  Navigator.of(context).pop();
                } else {
                  // Handle case where no data is entered
                }
              },
              child: const Text('Store'),
            ),
          ],
        );
      },
    );
  }
}
