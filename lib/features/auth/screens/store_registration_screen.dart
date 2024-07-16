import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/address/controllers/address_controller.dart';
import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/store_body_model.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/helper/validate_check.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/features/auth/widgets/custom_time_picker_widget.dart';
import 'package:sixam_mart_store/features/auth/widgets/pass_view_widget.dart';
import 'package:sixam_mart_store/features/address/widgets/select_location_module_view_widget.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({super.key});

  @override
  State<StoreRegistrationScreen> createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> with TickerProviderStateMixin {

  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];
  final FocusNode _vatFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;

  final ScrollController _scrollController = ScrollController();
  String? _countryDialCode;
  bool firstTime = true;
  TabController? _tabController;
  final List<Tab> _tabs =[];

  GlobalKey<FormState>? _formKeyLogin;
  GlobalKey<FormState>? _formKeySecond;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _languageList!.length, initialIndex: 0, vsync: this);
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    for (var language in _languageList) {
      if (kDebugMode) {
        print(language);
      }
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }
    Get.find<AuthController>().storeStatusChange(0.1, isUpdate: false);
    Get.find<AddressController>().getZoneList();
    Get.find<AuthController>().setDeliveryTimeTypeIndex(Get.find<AuthController>().deliveryTimeTypeList[0], false);
    if(Get.find<AuthController>().showPassView){
      Get.find<AuthController>().showHidePass(isUpdate: false);
    }
    Get.find<AuthController>().pickImageForReg(false, true);

    for (var language in _languageList) {
      _tabs.add(Tab(text: language.value));
    }
    _formKeyLogin = GlobalKey<FormState>();
    _formKeySecond = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return GetBuilder<AddressController>(builder: (addressController) {

        if(addressController.storeAddress != null && _languageList!.isNotEmpty){
          _addressController[0].text = addressController.storeAddress.toString();
        }

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async{
            if(authController.storeStatus != 0.1 && firstTime){
              authController.storeStatusChange(0.1);
              firstTime = false;
            }else {
              await _showBackPressedDialogue('your_registration_not_setup_yet'.tr);
            }
          },
          child: Scaffold(

            appBar: CustomAppBarWidget(title: 'store_registration'.tr, onTap: () {
              if(authController.storeStatus != 0.1 && firstTime){
                authController.storeStatusChange(0.1);
                firstTime = false;
              }else {
                _showBackPressedDialogue('your_registration_not_setup_yet'.tr);
              }
            }),

            body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical:  Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    authController.storeStatus == 0.1 ? 'provide_store_information_to_proceed_next'.tr : 'provide_owner_information_to_confirm'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  LinearProgressIndicator(
                    backgroundColor: Theme.of(context).disabledColor, minHeight: 2,
                    value: authController.storeStatus,
                  ),

                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  child: Column(children: [

                    Visibility(
                      visible: authController.storeStatus == 0.1,
                      child: Form(
                        key: _formKeyLogin,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text('store_info'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [

                              SizedBox(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TabBar(
                                    tabAlignment: TabAlignment.start,
                                    controller: _tabController,
                                    indicatorColor: Theme.of(context).primaryColor,
                                    indicatorWeight: 3,
                                    labelColor: Theme.of(context).primaryColor,
                                    unselectedLabelColor: Theme.of(context).disabledColor,
                                    unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                                    labelPadding: const EdgeInsets.only(right: Dimensions.radiusDefault),
                                    isScrollable: true,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    tabs: _tabs,
                                    onTap: (int ? value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                                child: Divider(height: 0),
                              ),

                              CustomTextFieldWidget(
                                hintText: 'write_store_name'.tr,
                                labelText: 'store_name'.tr,
                                controller: _nameController[_tabController!.index],
                                focusNode: _nameFocus[_tabController!.index],
                                nextFocus: _tabController!.index != _languageList!.length-1 ? _addressFocus[_tabController!.index] : _addressFocus[0],
                                inputType: TextInputType.name,
                                prefixImage: Images.shopIcon,
                                capitalization: TextCapitalization.words,
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "store_name_field_is_required".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              Row(children: [

                                Expanded(flex: 4,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                    Row(children: [
                                      Text('store_logo'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7))),
                                      Text(' (${'1:1'})', style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    Align(alignment: Alignment.center, child: Stack(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          child: authController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                                            authController.pickedLogo!.path, width: 150, height: 120, fit: BoxFit.cover,
                                          ) : Image.file(
                                            File(authController.pickedLogo!.path), width: 150, height: 120, fit: BoxFit.cover,
                                          ) : SizedBox(
                                            width: 150, height: 120,
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                              Icon(CupertinoIcons.photo_camera_solid, size: 30, color: Theme.of(context).disabledColor.withOpacity(0.6)),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                                child: Text(
                                                  'upload_store_logo'.tr,
                                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.center,
                                                ),
                                              ),

                                            ]),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0, right: 0, top: 0, left: 0,
                                        child: InkWell(
                                          onTap: () => authController.pickImageForReg(true, false),
                                          child: DottedBorder(
                                            color: Theme.of(context).primaryColor,
                                            strokeWidth: 1,
                                            strokeCap: StrokeCap.butt,
                                            dashPattern: const [5, 5],
                                            padding: const EdgeInsets.all(0),
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(Dimensions.radiusDefault),
                                            child: Center(
                                              child: Visibility(
                                                visible: authController.pickedLogo != null,
                                                child: Container(
                                                  padding: const EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 2, color: Colors.white),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(CupertinoIcons.photo_camera_solid, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ])),
                                  ]),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault),

                                Expanded(flex: 6,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                    Row(children: [
                                      Text('store_cover'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7))),
                                      Text(' (${'3:1'})', style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

                                    Stack(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          child: authController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                                            authController.pickedCover!.path, width: context.width, height: 120, fit: BoxFit.cover,
                                          ) : Image.file(
                                            File(authController.pickedCover!.path), width: context.width, height: 120, fit: BoxFit.cover,
                                          ) : SizedBox(
                                            width: context.width, height: 120,
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                              Icon(CupertinoIcons.photo_camera_solid, size: 30, color: Theme.of(context).disabledColor.withOpacity(0.6)),

                                              Text(
                                                'upload_store_cover'.tr,
                                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.center,
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                                child: Text(
                                                  'upload_jpg_png_gif_maximum_2_mb'.tr,
                                                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor.withOpacity(0.6), fontSize: Dimensions.fontSizeSmall),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                            ]),
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom: 0, right: 0, top: 0, left: 0,
                                        child: InkWell(
                                          onTap: () => authController.pickImageForReg(false, false),
                                          child: DottedBorder(
                                            color: Theme.of(context).primaryColor,
                                            strokeWidth: 1,
                                            strokeCap: StrokeCap.butt,
                                            dashPattern: const [5, 5],
                                            padding: const EdgeInsets.all(0),
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(Dimensions.radiusDefault),
                                            child: Center(
                                              child: Visibility(
                                                visible: authController.pickedCover != null,
                                                child: Container(
                                                  padding: const EdgeInsets.all(25),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 3, color: Colors.white),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(CupertinoIcons.photo_camera_solid, color: Colors.white, size: 50),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),

                                  ]),
                                ),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Text('location_info'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          addressController.zoneList != null ? SelectLocationAndModuleViewWidget(
                            fromView: true,  addressController: _addressController[0], addressFocus: _addressFocus[0],
                          ) : const Center(child: CircularProgressIndicator()),

                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          Text('store_preference'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                            child: Column(children: [

                              CustomTextFieldWidget(
                                hintText: 'write_vat_tax_amount'.tr,
                                labelText: 'vat_tax'.tr,
                                controller: _vatController,
                                focusNode: _vatFocus,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.number,
                                prefixImage: Images.vatTaxIcon,
                                isAmount: true,
                                suffixChild: CustomToolTip(
                                  message: 'please_provide_vat_tax_amount'.tr,
                                  preferredDirection: AxisDirection.down,
                                  iconColor: Theme.of(context).disabledColor,
                                ),
                                required: true,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "store_vat_tax_field_is_required".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              InkWell(
                                onTap: () {
                                  Get.dialog(const CustomTimePickerWidget());
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.5),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                      child: Row(children: [
                                        Expanded(child: Text(
                                          '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                                          style: robotoMedium,
                                        )),
                                        Icon(Icons.access_time_filled, color: Theme.of(context).primaryColor,)
                                      ]),
                                    ),

                                    Positioned(
                                      left: 10, top: -15,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: Text('select_time'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),

                        ]),
                      ),
                    ),

                    Visibility(
                      visible: authController.storeStatus != 0.1,
                      child: Form(
                        key: _formKeySecond,
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                          Row(children: [
                            Text('owner_info'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            CustomToolTip(
                              message: 'this_info_will_need_for_store_app_and_panel_login'.tr,
                              preferredDirection: AxisDirection.down,
                              iconColor: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.7),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                              CustomTextFieldWidget(
                                hintText: 'write_first_name'.tr,
                                controller: _fNameController,
                                focusNode: _fNameFocus,
                                nextFocus: _lNameFocus,
                                inputType: TextInputType.name,
                                capitalization: TextCapitalization.words,
                                prefixIcon: CupertinoIcons.person_crop_circle_fill,
                                iconSize: 25,
                                required: true,
                                labelText: 'first_name'.tr,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "first_name_field_is_required".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              CustomTextFieldWidget(
                                hintText: 'write_last_name'.tr,
                                controller: _lNameController,
                                focusNode: _lNameFocus,
                                nextFocus: _phoneFocus,
                                prefixIcon: CupertinoIcons.person_crop_circle_fill,
                                iconSize: 25,
                                inputType: TextInputType.name,
                                capitalization: TextCapitalization.words,
                                required: true,
                                labelText: 'last_name'.tr,
                                validator: (value) => ValidateCheck.validateEmptyText(value, "last_name_field_is_required".tr),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              CustomTextFieldWidget(
                                hintText: 'enter_phone_number'.tr,
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                nextFocus: _emailFocus,
                                inputType: TextInputType.phone,
                                isPhone: true,
                                onCountryChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                                    : Get.find<LocalizationController>().locale.countryCode,
                                required: true,
                                labelText: 'phone'.tr,
                                validator: (value) => ValidateCheck.validateEmptyText(value, null),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              CustomTextFieldWidget(
                                hintText: 'write_email'.tr,
                                controller: _emailController,
                                focusNode: _emailFocus,
                                nextFocus: _passwordFocus,
                                inputType: TextInputType.emailAddress,
                                prefixIcon: Icons.email,
                                iconSize: 25,
                                required: true,
                                labelText: 'email'.tr,
                                validator: (value) => ValidateCheck.validateEmail(value),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              GetBuilder<AuthController>(builder: (authController) {
                                return Column(children: [
                                  CustomTextFieldWidget(
                                    hintText: '8+characters'.tr,
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    nextFocus: _confirmPasswordFocus,
                                    inputType: TextInputType.visiblePassword,
                                    prefixIcon: Icons.lock,
                                    iconSize: 25,
                                    isPassword: true,
                                    onChanged: (value){
                                      if(value != null && value.isNotEmpty){
                                        if(!authController.showPassView){
                                          authController.showHidePass();
                                        }
                                        authController.validPassCheck(value);
                                      }else{
                                        if(authController.showPassView){
                                          authController.showHidePass();
                                        }
                                      }
                                    },
                                    required: true,
                                    labelText: 'password'.tr,
                                    validator: (value) => ValidateCheck.validateEmptyText(value, "password_field_is_required".tr),
                                  ),
                                  authController.showPassView ? const PassViewWidget() : const SizedBox(),

                                ]);
                              }),

                              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                              CustomTextFieldWidget(
                                hintText: '8+characters'.tr,
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                inputType: TextInputType.visiblePassword,
                                inputAction: TextInputAction.done,
                                prefixIcon: Icons.lock,
                                iconSize: 25,
                                isPassword: true,
                                required: true,
                                labelText: 'confirm_password'.tr,
                                validator: (value) => ValidateCheck.validateConfirmPassword(value, _passwordController.text),
                              ),
                              // const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                            ]),
                          ),

                        ]),
                      ),
                    ),

                  ]),
                ),
              ),

              !authController.isLoading ? Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: CustomButtonWidget(
                  buttonText: 'submit'.tr,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  onPressed: () {
                    bool defaultNameNull = false;
                    bool defaultAddressNull = false;
                    for(int index=0; index<_languageList.length; index++) {
                      if(_languageList[index].key == 'en') {
                        if (_nameController[index].text.trim().isEmpty) {
                          defaultNameNull = true;
                        }
                        if(_addressController[index].text.trim().isEmpty){
                          defaultAddressNull = true;
                        }
                        break;
                      }
                    }
                    String vat = _vatController.text.trim();
                    String minTime = authController.storeMinTime;
                    String maxTime = authController.storeMaxTime;
                    String fName = _fNameController.text.trim();
                    String lName = _lNameController.text.trim();
                    String phone = _phoneController.text.trim();
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    String confirmPassword = _confirmPasswordController.text.trim();
                    String phoneWithCountryCode = _countryDialCode! + phone;
                    bool valid = false;
                    try {
                      double.parse(maxTime);
                      double.parse(minTime);
                      valid = true;
                    } on FormatException {
                      valid = false;
                    }
                    if(authController.storeStatus == 0.1){
                      if(_formKeyLogin!.currentState!.validate()){
                        if(defaultNameNull) {
                          showCustomSnackBar('enter_store_name'.tr);
                        }else if(authController.pickedLogo == null) {
                          showCustomSnackBar('select_store_logo'.tr);
                        }else if(authController.pickedCover == null) {
                          showCustomSnackBar('select_store_cover_photo'.tr);
                        }else if(addressController.selectedModuleIndex == -1) {
                          showCustomSnackBar('please_select_module_first'.tr);
                        }else if(defaultAddressNull) {
                          showCustomSnackBar('enter_store_address'.tr);
                        }else if(addressController.selectedZoneIndex == -1) {
                          showCustomSnackBar('please_select_zone'.tr);
                        }else if(vat.isEmpty) {
                          showCustomSnackBar('enter_vat_amount'.tr);
                        }else if(minTime.isEmpty) {
                          showCustomSnackBar('enter_minimum_delivery_time'.tr);
                        }else if(maxTime.isEmpty) {
                          showCustomSnackBar('enter_maximum_delivery_time'.tr);
                        }else if(!valid) {
                          showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
                        }else if(valid && double.parse(minTime) > double.parse(maxTime)) {
                          showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                        }else if(addressController.restaurantLocation == null) {
                          showCustomSnackBar('set_store_location'.tr);
                        }else{
                          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                          authController.storeStatusChange(0.6);
                          firstTime = true;
                        }
                      }
                    }else{
                      if(_formKeySecond!.currentState!.validate()){
                        if(fName.isEmpty) {
                          showCustomSnackBar('enter_your_first_name'.tr);
                        }else if(lName.isEmpty) {
                          showCustomSnackBar('enter_your_last_name'.tr);
                        }else if(phone.isEmpty) {
                          showCustomSnackBar('enter_phone_number'.tr);
                        }else if(email.isEmpty) {
                          showCustomSnackBar('enter_email_address'.tr);
                        }else if(!GetUtils.isEmail(email)) {
                          showCustomSnackBar('enter_a_valid_email_address'.tr);
                        }else if(password.isEmpty) {
                          showCustomSnackBar('enter_password'.tr);
                        }else if(password.length < 6) {
                          showCustomSnackBar('password_should_be'.tr);
                        }else if(password != confirmPassword) {
                          showCustomSnackBar('confirm_password_does_not_matched'.tr);
                        }else {
                          List<Translation> translation = [];
                          for(int index=0; index<_languageList.length; index++) {
                            translation.add(Translation(
                              locale: _languageList[index].key, key: 'name',
                              value: _nameController[index].text.trim().isNotEmpty ? _nameController[index].text.trim()
                                  : _nameController[0].text.trim(),
                            ));
                            translation.add(Translation(
                              locale: _languageList[index].key, key: 'address',
                              value: _addressController[index].text.trim().isNotEmpty ? _addressController[index].text.trim()
                                  : _addressController[0].text.trim(),
                            ));
                          }

                          Map<String, String> data = {};

                          data.addAll(StoreBodyModel(
                            translation: jsonEncode(translation), tax: vat, minDeliveryTime: minTime,
                            maxDeliveryTime: maxTime, lat: addressController.restaurantLocation!.latitude.toString(), email: email,
                            lng: addressController.restaurantLocation!.longitude.toString(), fName: fName, lName: lName, phone: phoneWithCountryCode,
                            password: password, zoneId: addressController.zoneList![addressController.selectedZoneIndex!].id.toString(),
                            moduleId: addressController.moduleList![addressController.selectedModuleIndex!].id.toString(),
                            deliveryTimeType: authController.deliveryTimeTypeList[authController.deliveryTimeTypeIndex],
                          ).toJson());

                          authController.registerStore(data);

                        }
                      }
                    }
                  },
                ),
              ) : const Center(child: CircularProgressIndicator()),

            ]),
          ),
        );
      });
    });
  }

  Future<void> _showBackPressedDialogue(String title) async {
    Get.dialog(ConfirmationDialogWidget(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
    ), useSafeArea: false);
  }

}
