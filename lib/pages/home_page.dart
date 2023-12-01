import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas/models/database.dart';
import 'package:uas/models/transaction_with_category.dart';
import 'package:uas/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = AppDatabase();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //ddashboad income expanse
          Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              child: Icon(
                                Icons.download,
                                color: Colors.green,
                                size: 34,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8))),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Income",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 12),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              FutureBuilder<int>(
                                future: database.getSumAmountByCategoryType(
                                    1), // Ganti 2 dengan nilai type yang sesuai
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Atau widget lain untuk menunjukkan loading
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else {
                                    final totalAmount = snapshot.data ?? 0;
                                    return Text(
                                      "Rp. ${totalAmount.toStringAsFixed(2)}",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 14),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              child: Icon(
                                Icons.upload,
                                color: Colors.red,
                                size: 34,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8))),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Income",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 12),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              FutureBuilder<int>(
                                  future: database.getSumAmountByCategoryType(
                                      2), // Ganti 2 dengan nilai type yang sesuai
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasData) {
                                      final totalAmount = snapshot.data ?? 0;
                                      return Text(
                                        "Rp. ${totalAmount.toStringAsFixed(2)}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Error");
                                    } else {
                                      // Kondisi ketika snapshot.data == 0 atau snapshot.data == null
                                      return Text(
                                        "Rp. 0",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      );
                                    }
                                  }),
                            ],
                          )
                        ],
                      )
                    ]),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16)),
              )),

          //text Transaction
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Transaction",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 10,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await database.deleteTransactionRepo(
                                              snapshot
                                                  .data![index].transaction.id);
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionPage(
                                                    transactionWithCategory:
                                                        snapshot.data![index]),
                                          ));
                                          setState(() {});
                                        },
                                      )
                                    ],
                                  ),
                                  title: Text("Rp. " +
                                      snapshot.data![index].transaction.amount
                                          .toString()),
                                  subtitle: Text(snapshot
                                          .data![index].category.name +
                                      " (" +
                                      snapshot.data![index].transaction.name +
                                      ") "),
                                  leading: Container(
                                    child: (snapshot
                                                .data![index].category.type ==
                                            2)
                                        ? Icon(Icons.upload, color: Colors.red)
                                        : Icon(Icons.download,
                                            color: Colors.green),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: Text("Data Transaksi Masih Kosong"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("Tidak Ada Data"),
                    );
                  }
                }
              }),
        ],
      )),
    );
  }
}
