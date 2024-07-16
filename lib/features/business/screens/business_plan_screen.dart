import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/features/business/controllers/business_controller.dart';
import 'package:sixam_mart_store/features/business/domain/models/package_model.dart';
import 'package:sixam_mart_store/features/business/widgets/base_card_widget.dart';
import 'package:sixam_mart_store/features/business/widgets/package_card_widget.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class BusinessPlanScreen extends StatefulWidget {
  final int? storeId;
  final String? paymentId;
  const BusinessPlanScreen({super.key, required this.storeId, this.paymentId});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {

  final bool _canBack = false;

  @override
  void initState() {
    super.initState();
    Get.find<BusinessController>().resetBusiness();
    Get.find<BusinessController>().getPackageList();
    Get.find<BusinessController>().changeDigitalPaymentName(null, canUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (businessController) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async{
          if(_canBack) {
            return;
          }else {
            _showBackPressedDialogue('your_business_plan_not_setup_yet'.tr);
          }
        },
        child: Scaffold(
          body: Column(children: [

            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical:  Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  'store_registration'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                Text(
                  'you_are_one_step_away_choose_your_business_plan'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).disabledColor, minHeight: 2,
                  value: 0.75,
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [

                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeExtremeLarge),
                    child: Center(child: Text('choose_your_business_plan'.tr, style: robotoBold)),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Row(children: [

                      Get.find<SplashController>().configModel!.commissionBusinessModel != 0 ? Expanded(
                        child: BaseCardWidget(businessController: businessController, title: 'commission_base'.tr,
                          index: 0, onTap: ()=> businessController.setBusiness(0),
                        ),
                      ) : const SizedBox(),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      Get.find<SplashController>().configModel!.subscriptionBusinessModel != 0 ? Expanded(
                        child: BaseCardWidget(businessController: businessController, title: 'subscription_base'.tr,
                          index: 1, onTap: ()=> businessController.setBusiness(1),
                        ),
                      ) : const SizedBox(),

                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  businessController.businessIndex == 0 ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Text(
                      "${'store_will_pay'.tr} ${Get.find<SplashController>().configModel!.adminCommission}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel!.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                    ),
                  ) : Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text(
                        'run_store_by_purchasing_subscription_packages'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    SizedBox(
                      height: 420,
                      child: businessController.packageModel != null ? businessController.packageModel!.packages!.isNotEmpty ? Swiper(
                        itemCount: businessController.packageModel!.packages!.length,
                        viewportFraction: 0.60,
                        itemBuilder: (context, index) {

                          Packages package = businessController.packageModel!.packages![index];

                          return PackageCardWidget(
                            currentIndex: businessController.activeSubscriptionIndex == index ? index : null,
                            package: package,
                          );
                        },
                        onIndexChanged: (index) {
                          businessController.selectSubscriptionCard(index);
                        },

                      ) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('no_package_available'.tr, style: robotoMedium),
                          ]),
                      ) : const Center(child: CircularProgressIndicator()),
                    ),

                  ]),

                ]),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                height: 50,
                radius: Dimensions.radiusDefault,
                buttonText: businessController.businessIndex == 0 ? 'complete'.tr : 'next'.tr,
                onPressed: () {
                  if(businessController.businessIndex == 0) {
                    businessController.submitBusinessPlan(storeId: widget.storeId!);
                  } else {
                     Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(widget.storeId));
                  }
                },
              ),
            ),

          ]),
        ),
      );
    });
  }

  void _showBackPressedDialogue(String title){
    Get.dialog(ConfirmationDialogWidget(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
    ), useSafeArea: false);
  }

}
