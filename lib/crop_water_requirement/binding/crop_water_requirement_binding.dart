import 'package:get/get.dart';
import '../controller/crop_water_requirement_controller.dart';

class CropWaterRequirementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropWaterRequirementController>(
      () => CropWaterRequirementController(),
    );
  }
} 