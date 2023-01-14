import 'package:flutter/material.dart';
import 'package:flutter_app_1/db/database_instance.dart';
import 'package:flutter_app_1/models/transaksi_model.dart';
import 'package:flutter_app_1/screens/create_screen.dart';
import 'package:flutter_app_1/screens/update_screen.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kelola Uang",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseInstance? databaseInstance;

  Future _refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    databaseInstance = DatabaseInstance();
    initDatabase();
    super.initState();
  }

  Future initDatabase() async {
    await databaseInstance!.database();
    setState(() {});
  }

  showAlertDialog(BuildContext context, int idTransaksi) {
    Widget okButton = TextButton(
      child: Text("Yakin"),
      onPressed: () {
        databaseInstance!.hapus(idTransaksi);
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {});
      },
    );
    AlertDialog alertDialog = AlertDialog(
      title: Text("Peringatan !"),
      content: Text("Anda Yakin akan menghapus?"),
      actions: [okButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelola Uangku"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                        MaterialPageRoute(builder: (context) => CreateScreen()))
                    .then((value) {
                  setState(() {});
                });
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: _refresh,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: databaseInstance!.totalPemasukan(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("-");
                    } else {
                      if (snapshot.hasData) {
                        return Text(
                            "Total Pemasukan: Rp. ${snapshot.data.toString()}");
                      } else {
                        return Text("");
                      }
                    }
                  })),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: databaseInstance!.totalPengeluaran(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("-");
                    } else {
                      if (snapshot.hasData) {
                        return Text(
                            "Total Pengeluaran: Rp. ${snapshot.data.toString()}");
                      } else {
                        return Text("");
                      }
                    }
                  })),
              FutureBuilder<List<TransaksiModel>>(
                  future: databaseInstance!.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    } else {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    title: Text(snapshot.data![index].name!),
                                    subtitle: Text(snapshot.data![index].total!
                                        .toString()),
                                    leading: snapshot.data![index].type == 1
                                        ? Icon(
                                            Icons.download,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            Icons.upload,
                                            color: Colors.red,
                                          ),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateScreen(
                                                            transaksiMmodel:
                                                                snapshot.data![
                                                                    index],
                                                          )))
                                                  .then((value) {
                                                setState(() {});
                                              });
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.grey,
                                            )),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              showAlertDialog(context,
                                                  snapshot.data![index].id!);
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red))
                                      ],
                                    ));
                              }),
                        );
                      } else {
                        return Text("Tidak ada data");
                      }
                    }
                  })
            ],
          )),
    );
  }
}
