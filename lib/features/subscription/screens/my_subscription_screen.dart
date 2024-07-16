import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/subscription/controllers/subscription_controller.dart';
import 'package:sixam_mart_store/features/subscription/widgets/change_subscription_plan_bottom_sheet.dart';
import 'package:sixam_mart_store/features/subscription/widgets/subscription_details_widget.dart';
import 'package:sixam_mart_store/features/subscription/widgets/transaction_widget.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> with TickerProviderStateMixin {

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<SubscriptionController>().getProfile(Get.find<ProfileController>().profileModel);
    } else {
      Get.find<SubscriptionController>().getProfile(Get.find<AuthController>().profileModel);
    }

    Get.find<SubscriptionController>().initSetDate();
    Get.find<SubscriptionController>().setOffset(1);

    Get.find<SubscriptionController>().getSubscriptionTransactionList(
      offset: Get.find<SubscriptionController>().offset.toString(),
      from: Get.find<SubscriptionController>().from, to: Get.find<SubscriptionController>().to,
      searchText: Get.find<SubscriptionController>().searchText,
    );
    _loadTrialWidgetShow();
  }

  Future<void> _loadTrialWidgetShow() async {
    await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.mySubscription);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscriptionController) {

      bool businessIsCommission = subscriptionController.profileModel!.stores![0].storeBusinessModel == 'commission';

      return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          Get.find<ProfileController>().trialWidgetShow(route: '');
        },
        child: Scaffold(
          appBar: CustomAppBarWidget(title: 'my_business_plan'.tr, onTap: () {
            Get.find<ProfileController>().trialWidgetShow(route: '');
            Get.back();
          }),
          body: subscriptionController.profileModel != null ? (businessIsCommission && !subscriptionController.profileModel!.subscriptionTransactions!) ? Column(children: [

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).disabledColor.withOpacity(0.03),
                  ),
                  child: Column(children: [

                    Text(
                      'commission_base_plan'.tr,
                      style: robotoBold.copyWith(color: const Color(0xff006161), fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      '${Get.find<SplashController>().configModel?.adminCommission} %',
                      style: robotoBold.copyWith(color: Colors.teal, fontSize: 24),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.width * 0.15),
                      child: Text(
                        "${'store_will_pay'.tr} ${Get.find<SplashController>().configModel!.adminCommission}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel!.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7), height: 2), textAlign: TextAlign.center,
                      ),
                    )

                  ]),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                buttonText: 'change_business_plan'.tr,
                radius: Dimensions.radiusDefault,
                height: 55,
                onPressed: () {
                  showCustomBottomSheet(
                    child: ChangeSubscriptionPlanBottomSheet(businessIsCommission: businessIsCommission),
                  );
                },
              ),
            ),

          ]) : Column(children: [

            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).disabledColor,
              unselectedLabelStyle: robotoRegular,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
              tabs: [
                Tab(text: businessIsCommission ? 'plan_details'.tr : 'subscription_details'.tr),
                Tab(text: 'transaction'.tr),
              ],
            ),

            Expanded(child: TabBarView(
              controller: _tabController,
              children: [
                SubscriptionDetailsWidget(subscriptionController: subscriptionController),
                const TransactionWidget(),
              ],
            )),

          ]) : const Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }
}
