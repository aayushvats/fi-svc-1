import 'package:dio/dio.dart';
import 'package:fi_svc_1/models/transactionData.dart';
import 'package:fi_svc_1/screens/insights.dart';
import 'package:fi_svc_1/services/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;
  double? selectedAmount;
  String? selectedCategory;
  String? description;

  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  onClear() {
    setState(() {
      selectedDate = null;
      selectedAmount = null;
      amountController.clear();
      descriptionController.clear();
      selectedCategory = null;
      description = null;
    });
  }

  onSubmit() async {
    if (selectedDate == null ||
        selectedAmount == null ||
        selectedCategory == null ||
        description == null) {
      final snackBar = SnackBar(
        content: Text('All Fields are Mandatory.'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            top: 0, bottom: MediaQuery.of(context).size.height - 120),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sending Request...'),
                ],
              ),
            ),
          );
        },
      );

      try {
        TransactionData newTransaction = TransactionData(
          date: selectedDate!,
          amount: selectedAmount!,
          category: selectedCategory!,
          description: description!,
        );

        print(await newTransaction.toJSON());
        Response? response =
        await pushTransactionData(newTransaction.toJSON());
        print(response?.statusCode);

        Navigator.pop(context); // Close the dialog

        if (response?.statusCode == 201) {
          final snackBar = SnackBar(
            content: Text('Successfully Saved.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                top: 0, bottom: MediaQuery.of(context).size.height - 120),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                // Perform undo operation
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          onClear();
        } else {
          final snackBar = SnackBar(
            content: Text('Some Error Occurred'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                top: 0, bottom: MediaQuery.of(context).size.height - 120),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                // Perform undo operation
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        print('Error: $e');
        Navigator.pop(context); // Close the dialog on error
        final snackBar = SnackBar(
          content: Text('Error Occurred: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              top: 0, bottom: MediaQuery.of(context).size.height - 120),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () {
              // Perform undo operation
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.white,
        title: Text(
          '\nHome',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Text(
              'Please fill the following details to get accurate Financial Insights :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1987),
                                lastDate: DateTime.now(),
                                initialEntryMode:
                                    DatePickerEntryMode.calendarOnly,
                              );
                              if (pickedDate != null &&
                                  pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range_rounded,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      '   ${selectedDate != null ? DateFormat('dd MMM. yyyy').format(selectedDate!) : 'Date'}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              setState(() {
                                selectedAmount = double.tryParse(val);
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.money),
                              hintText: 'Enter amount',
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Select one Category',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.fastfood_outlined),
                                          title: Text('Dining'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Dining';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              Icon(Icons.shopping_bag_outlined),
                                          title: Text('Shopping'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Shopping';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              Icon(Icons.travel_explore_outlined),
                                          title: Text('Travel'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Travel';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              Icon(Icons.card_giftcard_outlined),
                                          title: Text('Gifts'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Gifts';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              Icon(Icons.account_balance_wallet),
                                          title: Text('Bills'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Bills';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              Icon(Icons.movie_creation_outlined),
                                          title: Text('Entertainment'),
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = 'Entertainment';
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 15),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0), // Border radius
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      '   ${selectedCategory ?? 'Category'}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            onChanged: (val) {
                              setState(() {
                                description = val;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter amount',
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                alignLabelWithHint: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onClear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Container()),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          Insigts(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                      transitionDuration: Duration(milliseconds: 300)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Go to Insights',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
