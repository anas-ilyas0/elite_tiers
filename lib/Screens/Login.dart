import 'dart:async';
import 'dart:io';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/SignUp.dart';
import 'package:elite_tiers/Screens/Verify_Otp.dart';
import 'package:elite_tiers/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import '../ui/widgets/AppBtn.dart';
import '../ui/widgets/BehaviorWidget.dart';
import '../utils/blured_router.dart';

class LoginScreen extends StatefulWidget {
  final Widget? classType;
  final bool isPop;
  final bool? isRefresh;
  static route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return LoginScreen(
          isPop: arguments?['isPop'],
          isRefresh: arguments?['isRefresh'],
          classType: arguments?['classType'],
        );
      },
    );
  }

  const LoginScreen({
    super.key,
    this.classType,
    this.isRefresh,
    required this.isPop,
  });

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode? emailFocus, passFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      countryName,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image,
      loginType;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  AnimationController? _animationController;
  bool acceptTnC = true;
  bool socialLoginLoading = false;
  bool? googleLogin, appleLogin;
  bool isShowPass = true;
  bool isPhoneLogin = false;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    buttonController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void onTapSignIn() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    print('Network Available: $_isNetworkAvail');

    if (_isNetworkAvail) {
      // If network is available, proceed with sign-in process
      signInProcess();
    } else {
      // If network is not available, show "No Internet" widget
      await buttonController!.reverse();
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();

              if (_isNetworkAvail) {
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget));
                }
              } else {
                await buttonController!.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  Widget loginToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => isPhoneLogin = false),
            child: Text(
              getTranslated(context, 'email')!,
              style: TextStyle(
                color: isPhoneLogin
                    ? Theme.of(context).colorScheme.primarytheme
                    : Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                decoration: isPhoneLogin
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => setState(() => isPhoneLogin = true),
            child: Text(
              getTranslated(context, 'phone')!,
              style: TextStyle(
                color: !isPhoneLogin
                    ? Theme.of(context).colorScheme.primarytheme
                    : Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                decoration: !isPhoneLogin
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> getData() {
    return isPhoneLogin
        ? {
            "mobile_no": emailController.text.trim(),
          }
        : {"email": emailController.text.trim()};
  }

  Future<void> signInProcess() async {
    Map<String, dynamic> data = getData();
    try {
      var res = await apiBaseHelper.postDioCall(
          isPhoneLogin
              ? sendOtpToPhoneApi.toString()
              : sendOtpToEmailApi.toString(),
          data);
      await buttonController!.reverse();

      if (!mounted) return;

      if (res['status'] == 'success') {
        String userId = res['user_id'].toString();
        setSnackbar(getTranslated(context, 'otp_sent_success')!, context);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtp(
                userId: userId,
                email: isPhoneLogin ? emailController.text : null,
                mobile: !isPhoneLogin ? emailController.text : null,
              ),
            ),
          );
        }
      } else {
        setSnackbar(getTranslated(context, 'user_doesn`t_exist')!, context);
      }
    } catch (error) {
      print('no otp $error');
      await buttonController!.reverse();
      if (!mounted) return;
      setSnackbar('${getTranslated(context, 'error')!}: $error', context);
    }
  }

  signInTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            getTranslated(context, 'SIGNIN_LBL')!,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  setEmail() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          //FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        enabled: true,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.fontColor,
            size: 20,
          ),
          counter: const SizedBox(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 5,
          ),
          hintText: getTranslated(context, "EMAILHINT_LBL")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.lightBlack2.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  setPhone() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(top: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        controller: emailController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        enabled: true,
        textInputAction: TextInputAction.next,
        validator: (val) => validateMob(
          val!,
          getTranslated(context, 'MOB_REQUIRED'),
          getTranslated(context, 'VALID_MOB'),
        ),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.phone, color: Theme.of(context).colorScheme.fontColor),
          hintText: getTranslated(context, "MOBILEHINT_LBL")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.lightBlack2.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          onTapSignIn();
        },
        keyboardType: TextInputType.text,
        obscureText: isShowPass,
        controller: passwordController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        enabled: true,
        focusNode: passFocus,
        //textInputAction: TextInputAction.next,
        validator: (val) => validatePass(
            val!,
            getTranslated(context, 'PWD_REQUIRED'),
            getTranslated(context, 'PASSWORD_VALIDATION'),
            from: 1),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSaved: (String? value) {
          password = value;
        },
        decoration: InputDecoration(
          errorMaxLines: 2,
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.fontColor, BlendMode.srcIn),
          ),
          suffixIcon: InkWell(
            onTap: () {
              setState(
                () {
                  isShowPass = !isShowPass;
                },
              );
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10.0),
              child: Icon(
                !isShowPass ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context)
                    .colorScheme
                    .fontColor
                    .withValues(alpha: 0.4),
                size: 22,
              ),
            ),
          ),
          hintText: getTranslated(context, "PASSHINT_LBL")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.lightBlack2.withValues(alpha: 0.3),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 20),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 20),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  forgetPass() {
    return Padding(
        padding:
            const EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 13.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.pushNamed(
                //   context,
                //   Routers.sendOTPScreen,
                //   arguments: {
                //     "title": getTranslated(context, 'FORGOT_PASS_TITLE')
                //   },
                // );
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal)),
            ),
          ],
        ));
  }

  getSignUpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 10.0),
      child: FittedBox(
        child: Row(
          children: <Widget>[
            Text(getTranslated(context, 'DONT_HAVE_AN_ACC')!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold)),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => SignUp()));
                },
                child: Text(
                  getTranslated(context, 'SIGN_UP_LBL')!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primarytheme,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, 'SEND_OTP')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        onTapSignIn();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  backBtn(),
                  // Image.asset(
                  //   'assets/images/doodle.png',
                  //   fit: BoxFit.fill,
                  //   width: double.infinity,
                  //   height: double.infinity,
                  //   color: Theme.of(context).colorScheme.primarytheme,
                  // ),
                  getLoginContainer(),
                  // getLogo(),
                  if (socialLoginLoading)
                    Positioned.fill(
                      child: Center(
                          child: showCircularProgress(
                              context,
                              socialLoginLoading,
                              Theme.of(context).colorScheme.primarytheme)),
                    ),
                  // backBtn(),
                ],
              )
            : noInternet(context));
  }

  backBtn() {
    return Positioned(
      top: 34.0,
      // left: 5.0,
      child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: Theme.of(context).colorScheme.fontColor,
                  size: 35,
                ),
              ),
            ),
          )),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      end: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.15,
      textDirection: Directionality.of(context),
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom * 0),
        child: Form(
          key: _formkey,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  setSignInLabel(),
                  setSignInDetail(),
                  loginToggle(),
                  isPhoneLogin ? setPhone() : setEmail(),
                  //setEmail(),
                  //setPass(),
                  //forgetPass(),
                  loginBtn(),
                  loginWith(),
                  const SizedBox(
                    height: 5,
                  ),
                  getSignUpText(),
                  termAndPolicyTxt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginWith() {
    if (googleLogin == true || (Platform.isIOS ? appleLogin == true : false)) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          getTranslated(context, 'OR_LOGIN_WITH_LBL')!,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .fontColor
                  .withValues(alpha: 0.8)),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget termAndPolicyTxt() {
    if (googleLogin == true || (Platform.isIOS ? appleLogin == true : false)) {
      return Padding(
        padding: const EdgeInsets.only(
            bottom: 0.0, left: 40.0, right: 40.0, top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    softWrap: true,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: getTranslated(context, 'CONTINUE_AGREE_LBL')!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 5.0),
                        ),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //     builder: (context) {
                              //       return PrivacyPolicy(
                              //         title: getTranslated(context, 'TERM'),
                              //       );
                              //     },
                              //   ),
                              // );
                            },
                            child: Text(
                              getTranslated(context, 'TERMS_SERVICE_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 5.0),
                        ),
                        TextSpan(
                          text: getTranslated(context, 'AND_LBL')!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 5.0),
                        ),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //     builder: (context) => PrivacyPolicy(
                              //       title: getTranslated(context, 'PRIVACY'),
                              //     ),
                              //   ),
                              // );
                            },
                            child: Text(
                              getTranslated(context, 'PRIVACY')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - (150 / 2),
      top: (MediaQuery.of(context).size.height * 0.11) - 66,
      child: SizedBox(
        width: 150,
        height: 150,
        child: SvgPicture.asset(
          "assets/images/logo.png",
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget setSignInDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_DETAILS')!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
