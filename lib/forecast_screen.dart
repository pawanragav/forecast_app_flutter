import "dart:convert";
import "dart:ui";

import "package:flutter/material.dart";
import "package:forecast_app/additional_info.dart";
import "package:forecast_app/appid.dart";
import "package:forecast_app/hourly_forecast.dart";
import 'package:http/http.dart' as http;
import "package:intl/intl.dart";

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey'),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An error occured';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getWeather();
                });
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.hasError.toString());
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSkyIcon = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Text(
                            '$currentTemp K',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Icon(
                            currentSkyIcon == 'Clouds' ||
                                    currentSkyIcon == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentSkyIcon,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
              //Hourly forecast
              const SizedBox(height: 20),
              const Text(
                'Hourly Forecast',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 15),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for (int i = 0; i < 5; i++)
              //         HourlyForecast(
              //           icon: data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Clouds' ||
              //                   data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Rain'
              //               ? Icons.cloud
              //               : Icons.sunny,
              //           value1: data['list'][i + 1]['dt'].toString(),
              //           value2: data['list'][i + 1]['main']['temp'].toString(),
              //         ),
              //     ],
              //   ),
              // ),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5 ,
                  itemBuilder: ((context, index) {
                    final hourlyForecastIcon =
                        data['list'][index + 1]['weather'][0]['main'];
                    final hourlyForecastCurrent = data['list'][index + 1];
                    final time = DateTime.parse(
                        hourlyForecastCurrent['dt_txt'].toString());
                    return HourlyForecast(
                        icon: hourlyForecastIcon == 'Clouds' ||
                                hourlyForecastIcon == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        value1: DateFormat.j().format(time),
                        value2:
                            hourlyForecastCurrent['main']['temp'].toString());
                  }),
                ),
              ),
              //additional info
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfo(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfo(
                    icon: Icons.air,
                    label: 'Wind speed',
                    value: currentWindSpeed.toString(),
                  ),
                  AdditionalInfo(
                    icon: Icons.gas_meter_outlined,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }
}
