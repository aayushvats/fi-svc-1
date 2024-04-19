import 'package:fi_svc_1/services/service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/categoryData.dart';

class Insigts extends StatefulWidget {
  const Insigts({super.key});

  @override
  State<Insigts> createState() => _InsigtsState();
}

class _InsigtsState extends State<Insigts> {

  List<CategoryData>? categoryData = null;

  void fetchData() async {

  //   String jsonString = '''
  //   {
  //     "totalSpendingPerCategory": [
  //       {
  //         "category": "Dining",
  //         "totalSpending": 150.00
  //       },
  //       {
  //         "category": "Shopping",
  //         "totalSpending": 50.00
  //       },
  //       {
  //         "category": "Travel",
  //         "totalSpending": 100.00
  //       },
  //       {
  //         "category": "Gifts",
  //         "totalSpending": 0.00
  //       },
  //       {
  //         "category": "Bills",
  //         "totalSpending": 0.00
  //       },
  //       {
  //         "category": "Entertainment",
  //         "totalSpending": 0.00
  //       }
  //     ]
  //   }
  // ''';

    List<CategoryData>? categoryDataList = await fetchCategoryData();
    if(categoryDataList==null){
      final snackBar = SnackBar(
        content: Text('Some Error Occurred'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 0, bottom: MediaQuery.of(context).size.height-120),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Perform undo operation
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      categoryDataList = [];
    }
    setState(() {
      categoryData = categoryDataList;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Insights',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: categoryData==null?
            Center(
                child: CircularProgressIndicator()
            ):PieChartWidget(data: categoryData!),
          ),
          Flexible(
            flex: 1,
            child: categoryData==null?
            Center(
                child: CircularProgressIndicator()
            ):DataTable(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              columns: <DataColumn>[
                DataColumn(label: Text('Sno.'),),
                DataColumn(label: Text('Category'),),
                DataColumn(label: Text('Amount Spent'),),
              ],
              rows: List<DataRow>.generate(
                categoryData!.length,
                    (index) => DataRow(
                  color: MaterialStateColor.resolveWith((states) {
                    if (index % 2 != 0) {
                      return Colors.transparent;
                    } else {
                      return Colors.red.shade100;
                    }
                  }),
                  cells: <DataCell>[
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(categoryData![index].category)),
                    DataCell(Text(categoryData![index].totalSpending.toString())),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final List<CategoryData> data;

  PieChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    List<Color> shadesOfRed = [
      Colors.red.shade900,
      // Colors.red.shade800,
      Colors.red.shade700,
      Colors.red.shade600,
      // Colors.red.shade500,
      Colors.red.shade400,
      Colors.red.shade300,
      // Colors.red.shade200,
      Colors.red.shade100,
    ];

    List<PieChartSectionData> sections = data.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryData = entry.value;
      final color = shadesOfRed[index % shadesOfRed.length];
      return PieChartSectionData(
        color: color,
        value: categoryData.totalSpending,
        title: categoryData.category,
        radius: 80,
        titleStyle: TextStyle(color: Colors.white),
      );
    }).toList();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 40,
              sectionsSpace: 0,
              pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
            ),
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 30,),
              for (var i = 0; i < data.length; i++)
                LegendItem(
                  color: shadesOfRed[i % shadesOfRed.length],
                  text: data[i].category,
                ),
              SizedBox(width: 30,),
            ],
          ),
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        SizedBox(width: 4),
        Text(text),
        SizedBox(width: 16),
      ],
    );
  }
}