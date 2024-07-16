import 'package:get/get.dart';
import 'package:sixam_mart_store/features/business/domain/models/business_plan_body.dart';
import 'package:sixam_mart_store/features/business/domain/models/package_model.dart';
import 'package:sixam_mart_store/features/business/domain/services/business_service_interface.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';

class BusinessController extends GetxController implements GetxService {
  final BusinessServiceInterface businessServiceInterface;
  BusinessController({required this.businessServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _businessIndex = 0;
  int get businessIndex => _businessIndex;

  int _activeSubscriptionIndex = 0;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  PackageModel? _packageModel;
  PackageModel? get packageModel => _packageModel;

  bool _freeTrialExpand = false;
  bool get freeTrialExpand => _freeTrialExpand;

  void changeFirstTimeStatus() {
    _isFirstTime = !_isFirstTime;
  }

  void resetBusiness(){
    _businessIndex = (Get.find<SplashController>().configModel!.commissionBusinessModel == 0) ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    _isFirstTime = true;
    _paymentIndex = Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus! ? 0 : 1;
  }

  Future<void> getPackageList() async {
    _packageModel = await businessServiceInterface.getPackageList();
    Future.delayed(const Duration(milliseconds: 500), () {
      update();
    });
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}){
    _digitalPaymentName = name;
    if(canUpdate) {
      update();
    }
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status){
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }

  Future<void> submitBusinessPlan({required int storeId})async {
    _isLoading = true;
    update();
    if(businessIndex == 0){
      String businessPlan = 'commission';
      await businessServiceInterface.setUpBusinessPlan(BusinessPlanBody(businessPlan: businessPlan, storeId: storeId.toString()), _digitalPaymentName, businessPlanStatus, storeId);
    }else{
      _businessPlanStatus = 'payment';
      if(!_isFirstTime) {
        _businessPlanStatus = await businessServiceInterface.processesBusinessPlan(_businessPlanStatus, _paymentIndex, storeId, _packageModel, _digitalPaymentName, _activeSubscriptionIndex);
      }else{
        _isFirstTime = false;
      }
    }

    _isLoading = false;
    update();
  }

  Future<void> changeFreeTrialExpandStatus() async {
    _freeTrialExpand = !_freeTrialExpand;
    update();
  }

}