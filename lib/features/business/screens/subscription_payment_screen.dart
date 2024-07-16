import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/features/business/controllers/business_controller.dart';
import 'package:sixam_mart_store/features/business/widgets/payment_cart_widget.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/helper/responsive_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class SubscriptionPaymentScreen extends StatelessWidget {
  final int storeId;
  const SubscriptionPaymentScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (businessController) {
      return Scaffold(
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
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Column(children: [

                    Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus! ? PaymentCartWidget(
                      title: '${'continue_with'.tr} ${Get.find<SplashController>().configModel!.subscriptionFreeTrialDays} '
                          '${Get.find<SplashController>().configModel!.subscriptionFreeTrialType} ${'days_free_trial'.tr}',
                      index: 0,
                      onTap: () {
                        businessController.setPaymentIndex(0);
                      },
                    ) : const SizedBox(),

                    SizedBox(height: Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus! ? Dimensions.paddingSizeExtremeLarge : 0),

                    Row(children: [
                      Text('${'pay_via_online'.tr} ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      Text(
                        'faster_and_secure_way_to_pay_bill'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      ),
                    ]),

                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isTab(context) ? 2 : 1,
                        crossAxisSpacing: Dimensions.paddingSizeLarge,
                        mainAxisSpacing: Dimensions.paddingSizeLarge,
                        mainAxisExtent: 55,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                      itemBuilder: (context, index) {
                        bool isSelected = businessController.paymentIndex == 1 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == businessController.digitalPaymentName;

                        return InkWell(
                          onTap: (){
                            businessController.setPaymentIndex(1);
                            businessController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                            child: Row(children: [
                              Container(
                                height: 20, width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                  border: Border.all(color: Theme.of(context).disabledColor),
                                ),
                                child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              Text(
                                Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                              const Spacer(),

                              CustomImageWidget(
                                height: 40, width: 50, fit: BoxFit.contain,
                                image: '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                              ),

                            ]),
                          ),
                        );
                      },
                    ),

                  ]),
                ),

              ]),
            ),
          ),

          GetBuilder<BusinessController>(builder: (busController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
              child: !busController.isLoading ? CustomButtonWidget(
                height: 50,
                radius: Dimensions.radiusDefault,
                buttonText: 'confirm'.tr,
                onPressed: () {
                  busController.submitBusinessPlan(storeId: storeId);
                },
              ) : const Center(child: CircularProgressIndicator()),
            );
          }),

        ]),
      );
    });
  }
}
