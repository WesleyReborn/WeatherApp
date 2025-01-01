import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/theme/app_colors.dart';
import 'package:weather_app/widgets/graddientText.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  List<dynamic>? time;
  List<dynamic>? temperature;
  List<dynamic>? humidity;
  String? timezone;
  String? greeting;
  String? formattedDate;
  String? formattedTime;
  late Timer timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      updateTime();
      timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
      fetchData();
    });
  }

  void updateTime() {
    setState(() {
      DateTime now = DateTime.now();
      formattedTime = DateFormat('HH:mm:ss').format(now);
      formattedDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final Uri url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=-22.9025&longitude=-43.1049&hourly=temperature_2m,relative_humidity_2m&timezone=America%2FSao_Paulo");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        setState(() {
          data = jsonData;
          time = data?["hourly"]["time"];
          temperature = data?["hourly"]["temperature_2m"];
          humidity = data?["hourly"]["relative_humidity_2m"];
          timezone = data?["timezone"] ?? "GMT";

          DateTime now = DateTime.now();
          int hour = now.hour;

          if (hour >= 5 && hour <= 12) {
            greeting = "Bom dia";
          } else if (hour >= 13 && hour <= 18) {
            greeting = "Boa tarde";
          } else {
            greeting = "Boa noite";
          }

          formattedDate = DateFormat("EEEE, d 'de' MMMM", "pt_BR").format(now);
          formattedTime = DateFormat('h:mm a').format(now);

          isLoading = false;
        });
      } else {
        throw Exception("Erro ao buscar dados da API: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            )
          : data == null
              ? const Center(
                  child: Text(
                    "Erro ao carregar dados. Tente novamente mais tarde.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.lightBlue,
                        AppColors.lightGray,
                        AppColors.darkGray,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 60.0, left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.openSans(height: 1.1),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "$timezone \n",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w100,
                                      color: AppColors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "$greeting",
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                border: Border.all(
                                    width: 0.4, color: AppColors.white),
                              ),
                              child: const Icon(
                                Icons.more_vert_outlined,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            height: 300.0,
                            width: 300.0,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/cloudy.png"),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.openSans(height: 1.1),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${temperature.toString().substring(1, 3)}°C \n",
                                  style: const TextStyle(
                                    fontSize: 75.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: "Umidade: ${humidity![0]}% \n",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: "$formattedDate $formattedTime",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              graddientText(
                                  "Previsão do tempo", 20.0, FontWeight.bold),
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: AppColors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0.0),
                            itemCount: time?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 0.4, color: AppColors.white),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat("HH:mm").format(
                                        DateTime.parse(time![index]),
                                      ),
                                      style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      "${humidity![index].toString()}%",
                                      style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      "${temperature![index].toInt()}C°",
                                      style: GoogleFonts.openSans(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
