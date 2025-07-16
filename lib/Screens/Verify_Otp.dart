import 'dart:async';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/UI/widgets/BehaviorWidget.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/widgets/AppBtn.dart';

class VerifyOtp extends StatefulWidget {
  final String? email, userId;
  const VerifyOtp({super.key, required this.email, required this.userId});

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;
  bool _isNetworkAvail = true;
  bool _isClickable = false;
  bool isCodeSent = false;

  @override
  void initState() {
    super.initState();
    initAnimations();
    triggerOtpSent();
    startClickableTimer();
  }

  void initAnimations() {
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController,
      curve: const Interval(0.0, 0.150),
    ));
  }

  void triggerOtpSent() {
    setState(() {
      isCodeSent = true;
    });
  }

  void startClickableTimer() {
    Future.delayed(const Duration(seconds: 60), () {
      _isClickable = true;
    });
  }

  @override
  void dispose() {
    buttonController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Widget verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'VERIFY_AND_PROCEED')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        FocusScope.of(context).unfocus();
        _onFormSubmitted();
      },
    );
  }

  void _onFormSubmitted() async {
    if (_formKey.currentState!.validate()) {
      await _playAnimation();
      await checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await otpProcess();
    } else {
      await buttonController.reverse();
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> otpProcess() async {
    Map<String, String> data = {
      "email": widget.email ?? '',
      "otp": otpController.text,
      "user_id": widget.userId ?? '',
    };
    print(data);
    try {
      await apiBaseHelper.postAPICall(verifyOtpFromEmailApi, data);
      await buttonController.reverse();
      if (!mounted) return;
      isDemoApp = false;
      setSnackbar(
          '${getTranslated(context, 'OTPMSG')} & ${getTranslated(context, 'logged_in_success')}',
          context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Dashboard()));
    } catch (error) {
      await buttonController.reverse();
      if (!mounted) return;
      setSnackbar('Error $error', context);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
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
                getLoginContainer(),
              ],
            )
          : noInternet(context),
    );
  }

  Widget backBtn() => Positioned(
        top: 34.0,
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
          ),
        ),
      );

  Widget getLoginContainer() => Positioned.directional(
        start: MediaQuery.of(context).size.width * 0.025,
        end: MediaQuery.of(context).size.width * 0.025,
        top: MediaQuery.of(context).size.height * 0.15,
        textDirection: Directionality.of(context),
        child: Form(
          key: _formKey,
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
                        getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 15.0, bottom: 5.0, start: 12),
                    child: Text(
                      '${getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!}: ${widget.email}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  otpInputField(),
                  const SizedBox(height: 10),
                  verifyBtn(),
                  resendText(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget otpInputField() => Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.only(top: 15.0),
        child: TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
          ),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return getTranslated(context, 'ENTEROTP');
            } else if (val.length != 6) {
              return getTranslated(context, 'OTPERROR');
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock,
                color: Theme.of(context).colorScheme.fontColor, size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            hintText: getTranslated(context, "ENTEROTP"),
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.lightBlack2.withAlpha(30),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );

  Widget resendText() => Padding(
        padding: const EdgeInsetsDirectional.only(
            top: 10, bottom: 30, start: 25.0, end: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getTranslated(context, 'DIDNT_GET_THE_CODE')!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            InkWell(
              onTap: () async {
                if (_isClickable) {
                  triggerOtpSent();
                  setSnackbar("OTP resent.", context);
                  _isClickable = false;
                  startClickableTimer();
                } else {
                  setSnackbar("Please wait before resending OTP.", context);
                }
              },
              child: Text(
                getTranslated(context, 'RESEND_OTP')!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primarytheme,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      );

  Widget noInternet(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                await _playAnimation();
                await Future.delayed(const Duration(seconds: 2));
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => widget),
                    );
                  }
                } else {
                  await buttonController.reverse();
                  setState(() {});
                }
              },
            ),
          ],
        ),
      );
}
