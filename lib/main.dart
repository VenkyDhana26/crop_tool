import 'package:crop_wat/crop_water_requirement/controller/crop_water_requirement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'climate/controller/climate_controller.dart';
import 'soil/controller/soil_controller.dart';
import 'crop/controller/crop_controller.dart';
import 'climate/view/climate_view.dart';
import 'soil/view/soil_view.dart';
import 'crop/view/crop_view.dart';
import 'schedule/view/schedule_view.dart';
import 'crop_water_requirement/view/crop_water_requirement_view.dart';

void main() {
  Get.lazyPut(() => ClimateController());
  Get.lazyPut(() => SoilController());
  Get.lazyPut(() => CropController());
  Get.lazyPut(() => CropWaterRequirementController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Tool',
      theme: ThemeData(
        
        
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StepperHomePage(),
    );
  }
}

class StepperHomePage extends StatefulWidget {
  const StepperHomePage({super.key});

  @override
  State<StepperHomePage> createState() => _StepperHomePageState();
}

// ...existing code...

class _StepperHomePageState extends State<StepperHomePage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    ClimateView(),
    SoilView(),
    CropView(),
    CropWaterRequirementView(),
    ScheduleView(),
  ];

  void _onStepContinue() {
    if (_currentStep < _pages.length - 1) {
      setState(() {
        _currentStep++;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Crop Wat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            EasyStepper(
              activeStep: _currentStep,
              stepShape: StepShape.circle,
              stepBorderRadius: 15,
              borderThickness: 2,
              showLoadingAnimation: false,
              lineStyle: const LineStyle(
                lineLength: 150,
                lineType: LineType.normal,
                lineThickness: 2,
                lineSpace: 1,
                lineWidth: 10,
                unreachedLineType: LineType.dashed,
              ),
              steps: [
                EasyStep(icon: Icon(Icons.sunny), title: 'Climate'),
                EasyStep(icon: Icon(Icons.water_drop), title: 'Soil'),
                EasyStep(icon: Icon(Icons.grass), title: 'Crop'),
                EasyStep(icon: Icon(Icons.opacity), title: 'Crop Water Requirement'),
                EasyStep(icon: Icon(Icons.calendar_month), title: 'Schedule'),
              ],
              onStepReached: (index) {
                setState(() {
                  _currentStep = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                });
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onStepCancel,
                  child: const Text('Previous'),
                ),
                TextButton(
                  onPressed: _onStepContinue,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ...existing code...
