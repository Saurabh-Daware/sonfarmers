import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/controller/auth_controller.dart';
import 'package:sixvalley_delivery_boy/helper/email_checker.dart';
import 'package:sixvalley_delivery_boy/utill/color_resources.dart';
import 'package:sixvalley_delivery_boy/utill/dimensions.dart';
import 'package:sixvalley_delivery_boy/utill/images.dart';
import 'package:sixvalley_delivery_boy/view/base/custom_button.dart';
import 'package:sixvalley_delivery_boy/view/base/custom_snackbar.dart';
import 'package:sixvalley_delivery_boy/view/base/custom_text_field.dart';
import 'package:sixvalley_delivery_boy/view/screens/dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController _emailController;
  TextEditingController _passwordController;
  GlobalKey<FormState> _formKeyLogin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _emailController.text = Get.find<AuthController>().getUserEmail();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Form(
          key: _formKeyLogin,
          child: GetBuilder<AuthController>(
            builder: (authController) {
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      Images.login,
                      height: MediaQuery.of(context).size.height / 4.5,
                      fit: BoxFit.scaleDown,
                      matchTextDirection: true,
                    ),
                  ),
                  //SizedBox(height: 20),
                  Center(
                      child: Text(
                    'login'.tr,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        fontSize: 24, color: Theme.of(context).hintColor),
                  )),
                  const SizedBox(height: 35),
                  Text(
                    'email_address'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(color: Theme.of(context).highlightColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextField(
                    hintText: 'demo_gmail'.tr,
                    isShowBorder: true,
                    focusNode: _emailFocus,
                    nextFocus: _passwordFocus,
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    'password'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(color: Theme.of(context).highlightColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CustomTextField(
                    hintText: 'password_hint'.tr,
                    isShowBorder: true,
                    isPassword: true,
                    isShowSuffixIcon: true,
                    focusNode: _passwordFocus,
                    controller: _passwordController,
                    inputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 22),

                  // for remember me section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          authController.toggleRememberMe();
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  color: authController.isActiveRememberMe
                                      ? Theme.of(context).primaryColor
                                      : ColorResources.colorWhite,
                                  border: Border.all(
                                      color: authController.isActiveRememberMe
                                          ? Colors.transparent
                                          : Theme.of(context).highlightColor),
                                  borderRadius: BorderRadius.circular(3)),
                              child: authController.isActiveRememberMe
                                  ? const Icon(Icons.done,
                                      color: ColorResources.colorWhite,
                                      size: 17)
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              'remember_me'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2
                                  .copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).highlightColor),
                            )
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      authController.loginErrorMessage.isNotEmpty
                          ? const CircleAvatar(
                              backgroundColor: Colors.red, radius: 5)
                          : const SizedBox.shrink(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authController.loginErrorMessage ?? "",
                          style: Theme.of(context).textTheme.headline2.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.red,
                              ),
                        ),
                      )
                    ],
                  ),

                  // for login button
                  const SizedBox(height: 10),
                  !authController.isLoading
                      ? CustomButton(
                          btnTxt: 'login'.tr,
                          onTap: () async {
                            String _email = _emailController.text.trim();
                            String _password = _passwordController.text.trim();
                            if (_email.isEmpty) {
                              showCustomSnackBar('enter_email_address'.tr);
                            } else if (EmailChecker.isNotValid(_email)) {
                              showCustomSnackBar('enter_valid_email'.tr);
                            } else if (_password.isEmpty) {
                              showCustomSnackBar('enter_password'.tr);
                            } else if (_password.length < 6) {
                              showCustomSnackBar('password_should_be'.tr);
                            } else {
                              authController
                                  .login(_email, _password)
                                  .then((status) async {
                                if (status.isSuccess) {
                                  if (authController.isActiveRememberMe) {
                                    authController.saveUserNumberAndPassword(
                                        _email, _password);
                                  } else {
                                    authController.clearUserEmailAndPassword();
                                  }
                                  await Get.find<AuthController>().getProfile();
                                  // ignore: prefer_const_constructors
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (_) => DashboardScreen(
                                                pageIndex: 0,
                                              )));
                                } else {
                                  showCustomSnackBar(status.message);
                                }
                              });
                            }
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
