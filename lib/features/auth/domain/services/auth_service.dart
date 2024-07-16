import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:sixam_mart_store/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart_store/features/business/screens/business_plan_screen.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';

class AuthService implements AuthServiceInterface {
  final AuthRepositoryInterface authRepositoryInterface;
  AuthService({required this.authRepositoryInterface});

  @override
  Future<Response> login(String? email, String password, String type) async {
    return await authRepositoryInterface.login(email, password, type);
  }

  @override
  Future<Response> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover) async {
    Response response = await authRepositoryInterface.registerRestaurant(data, logo, cover);
    if(response.statusCode == 200) {
      int? storeId = response.body['store_id'];
      Get.offAllNamed(RouteHelper.getBusinessPlanRoute(storeId));
    }
    return response;
  }

  @override
  Future<Response> updateToken() async {
    return await authRepositoryInterface.updateToken();
  }

  @override
  Future<bool> saveUserToken(String token, String zoneTopic, String type) async {
    return await authRepositoryInterface.saveUserToken(token, zoneTopic, type);
  }

  @override
  String getUserToken() {
    return authRepositoryInterface.getUserToken();
  }

  @override
  bool isLoggedIn() {
    return authRepositoryInterface.isLoggedIn();
  }

  @override
  Future<bool> clearSharedData() async {
    return await authRepositoryInterface.clearSharedData();
  }

  @override
  Future<void> saveUserNumberAndPassword(String number, String password, String type) async {
    return await authRepositoryInterface.saveUserNumberAndPassword(number, password, type);
  }

  @override
  String getUserNumber() {
    return authRepositoryInterface.getUserNumber();
  }

  @override
  String getUserPassword() {
    return authRepositoryInterface.getUserPassword();
  }

  @override
  String getUserType() {
    return authRepositoryInterface.getUserType();
  }

  @override
  bool isNotificationActive() {
    return authRepositoryInterface.isNotificationActive();
  }

  @override
  void setNotificationActive(bool isActive) {
    return authRepositoryInterface.setNotificationActive(isActive);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    return await authRepositoryInterface.clearUserNumberAndPassword();
  }

  @override
  Future<bool> toggleStoreClosedStatus() async {
    return await authRepositoryInterface.toggleStoreClosedStatus();
  }

  @override
  Future<bool> saveIsStoreRegistration(bool status) async {
    return await authRepositoryInterface.saveIsStoreRegistration(status);
  }

  @override
  bool getIsStoreRegistration() {
    return authRepositoryInterface.getIsStoreRegistration();
  }

  @override
  Future<ResponseModel?> manageLogin(Response response, String type) async {
    ResponseModel? responseModel;
    if (response.statusCode == 200) {
      if(response.body['subscribed'] != null){
        int? storeId = response.body['subscribed']['store_id'];
        Get.to(()=> BusinessPlanScreen(storeId: storeId));
        responseModel = ResponseModel(false, 'please_choose_a_business_plan'.tr);
      }else{
        saveUserToken(response.body['token'], response.body['zone_wise_topic'], type);
        await updateToken();
        Get.find<ProfileController>().getProfile();
        responseModel = ResponseModel(true, 'successful');
      }
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

}