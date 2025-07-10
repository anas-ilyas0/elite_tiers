import 'dart:async';
import 'package:elite_tiers/App/routes.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Helpers/forgot_password.dart';
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

class SendOtp extends StatefulWidget {
  final String? title;
  static route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SendOtp(
          title: arguments?['title'],
        );
      },
    );
  }

  const SendOtp({super.key, this.title});

  @override
  SendOtpState createState() => SendOtpState();
}

class SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final emailController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool acceptTnC = true;

  validateAndSubmit() async {
    if (validateAndSave()) {
      if (widget.title != getTranslated(context, 'SEND_OTP_TITLE')) {
        _playAnimation();
        checkNetwork();
      } else {
        if (acceptTnC) {
          _playAnimation();
          checkNetwork();
        } else {
          setSnackbar(getTranslated(context, 'TnCNOTACCEPTED')!, context);
        }
      }
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (emailController.text.trim().isEmpty) {
        setSnackbar(getTranslated(context, 'MOB_REQUIRED')!, context);
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: kToolbarHeight),
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
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => super.widget));
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

  Future<void> getVerifyUser() async {
    try {
      var data = {
        MOBILE: mobile,
        "is_forgot_password":
            (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')
                    ? 1
                    : 0)
                .toString()
      };

      apiBaseHelper.postAPICall(getVerifyUserApi, data).then((getdata) async {
        bool? error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();

        // SettingProvider settingsProvider =
        //     Provider.of<SettingProvider>(context, listen: false);

        if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
          if (!error!) {
            setSnackbar(msg!, context);

            Future.delayed(const Duration(seconds: 1)).then((_) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => VerifyOtp(
                            mobileNumber: mobile!,
                            countryCode: countrycode,
                            title: getTranslated(context, 'SEND_OTP_TITLE'),
                          )));
            });
          } else {
            setSnackbar(msg!, context);
          }
        }
        if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
          if (!error!) {
            Future.delayed(const Duration(seconds: 1)).then((_) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => VerifyOtp(
                            mobileNumber: mobile!,
                            countryCode: countrycode,
                            title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                          )));
            });
          } else {
            setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG')!, context);
          }
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      await buttonController!.reverse();
    }

    return;
  }

  createAccTxt() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.title == getTranslated(context, 'SEND_OTP_TITLE')
                ? getTranslated(context, 'CREATE_ACC_LBL')!
                : getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Widget verifyCodeTxt() {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              getTranslated(context, 'SEND_VERIFY_CODE_LBL')!,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                  ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ),
        ));
  }

  setCodeWithEmail() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        controller: emailController,
        decoration: InputDecoration(
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .fontColor
                  .withValues(alpha: 0.6),
              fontWeight: FontWeight.normal),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          fillColor: Theme.of(context).colorScheme.white,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
      ),
    );
  }

  bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Basic email regex
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Widget verifyBtn() {
    return AppBtn(
      title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
          ? getTranslated(context, 'SEND_OTP')!.toUpperCase()
          : getTranslated(context, 'CONTINUE')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        if (emailController.text.isEmpty ||
            !isValidEmail(emailController.text)) {
          validateAndSubmit();
          return;
        }
        await buttonController!.forward();
        try {
          var response = await sendForgetPasswordRequest(emailController.text);
          if (response['status'] == 'success') {
            await buttonController!.reverse();
            setSnackbar(
                getTranslated(
                    context, 'PASSWORD_RESET_LINK_SENT_SUCCESSFULLY')!,
                context);
          } else {
            await buttonController!.reverse();
            setSnackbar(
                getTranslated(context, 'SELECTED_EMAIL_INVALID')!, context);
          }
        } catch (e) {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'SOMETHING_WENT_WRONG')!, context);
        }
      },
    );
  }

  getSignUpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 20.0),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(getTranslated(context, 'ALREADY_HAVE_AN_ACC')!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold)),
            InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routers.loginScreen,
                      arguments: {"isPop": false},
                      (route) => false);
                },
                child: Text(
                  getTranslated(context, 'SIGNIN_LBL')!,
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

  Widget termAndPolicyTxt() {
    return widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        ? Padding(
            padding: const EdgeInsets.only(
              top: 250,
              bottom: 0.0,
              left: 40.0,
              right: 40.0,
            ),
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
                              text:
                                  getTranslated(context, 'CONTINUE_AGREE_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 5.0),
                            ),
                            TextSpan(
                              text: getTranslated(context, 'AND_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            WidgetSpan(
                              child: SizedBox(width: 5.0),
                            ),
                            WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   CupertinoPageRoute(
                                  //     builder: (context) => PrivacyPolicy(
                                  //       title:
                                  //           getTranslated(context, 'PRIVACY'),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
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
          )
        : const SizedBox.shrink();
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
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                ],
              )
            : noInternet(context));
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.title == getTranslated(context, 'SEND_OTP_TITLE')
                            ? getTranslated(context, 'SIGN_UP_LBL')!
                            : getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  verifyCodeTxt(),
                  setCodeWithEmail(),
                  const SizedBox(
                    height: 10,
                  ),
                  verifyBtn(),
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

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - (150 / 2),
      top: (MediaQuery.of(context).size.height * 0.11) - 40,
      child: SizedBox(
        width: 150,
        height: 150,
        child: SvgPicture.asset(
          "assets/images/logo.png",
        ),
      ),
    );
  }
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ${getToken()}',
    };
