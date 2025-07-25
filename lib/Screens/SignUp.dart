import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:elite_tiers/App/routes.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/home_screen.dart';
import 'package:elite_tiers/UI/widgets/cropped_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import '../ui/widgets/AppBtn.dart';
import '../ui/widgets/BehaviorWidget.dart';
import '../utils/blured_router.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  static route(RouteSettings settings) {
    //Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return const SignUp();
      },
    );
  }

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = false;
  bool visible = false;
  bool isPhoneSignup = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  int count = 1;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode,
      loginType;
  FocusNode? nameFocus,
      emailFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
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
      signUpProcess();
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
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    ccodeController.dispose();
    passwordController.dispose();
    referController.dispose();
    buttonController!.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(getTranslated(context, 'USER_REGISTER_DETAILS')!,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.primarytheme,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
      ),
    );
  }

  setUserName() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) =>
            validateField(val!, getTranslated(context, 'name_required')),
        onSaved: (String? value) {
          name = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'NAMEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primarytheme),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget setMobile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        controller: mobileController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone_android,
              size: 17, color: Theme.of(context).colorScheme.fontColor),
          hintText: getTranslated(context, 'MOBILEHINT_LBL')!,
          hintStyle: Theme.of(context).textTheme.titleSmall,
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primarytheme),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
          ),
        ),
        validator: (val) =>
            validateField(val!, getTranslated(context, 'MOBILEHINT_LBL')),
        onSaved: (value) => mobile = value,
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, passFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.alternate_email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primarytheme),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Map<String, String> getData() {
    return isPhoneSignup
        ? {
            "name": nameController.text,
            "phone": mobileController.text,
          }
        : {
            "name": nameController.text,
            "email": emailController.text,
          };
  }

  Future<void> signUpProcess() async {
    Map<String, dynamic> data = getData();
    try {
      var res = await apiBaseHelper.postDioCall(
          isPhoneSignup
              ? userCreateToPhoneApi.toString()
              : userCreateByEmailApi.toString(),
          data);
      await buttonController!.reverse();

      if (!mounted) return;

      if (res['status'] == 'success') {
        String userId = res['user_id'].toString();
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!, context);
        Navigator.pop(context);
      } else {
        setSnackbar(getTranslated(context, 'USER_REGISTER_FAIL')!, context);
      }
    } catch (error) {
      print('error signup $error');
      setSnackbar(getTranslated(context, 'user_exist')!, context);
      await buttonController!.reverse();
      if (!mounted) return;
      setSnackbar('${getTranslated(context, 'error')!}: $error', context);
    }
  }

  setRefer() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        onSaved: (String? value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, maxHeight: 25),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primarytheme),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Padding(
        padding:
            const EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !_showPassword!,
          focusNode: passFocus,
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          textInputAction: TextInputAction.next,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: passwordController,
          validator: (val) => validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PASSWORD_VALIDATION')),
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
            errorMaxLines: 4,
            prefixIcon: SvgPicture.asset(
              "assets/images/password.svg",
              height: 17,
              width: 17,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.fontColor, BlendMode.srcIn),
            ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, maxHeight: 25),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primarytheme),
              borderRadius: BorderRadius.circular(7.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  showPass() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: Theme.of(context).colorScheme.fontColor,
              activeColor: Theme.of(context).colorScheme.lightWhite,
              onChanged: (bool? value) {
                if (mounted) {
                  setState(() {
                    _showPassword = value;
                  });
                }
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'SAVE_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        validateAndSubmit();
      },
    );
  }

  loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Text(getTranslated(context, 'ALREADY_HAVE_AN_ACC')!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold)),
          InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routers.loginScreen,
                    arguments: {"isPop": false});
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primarytheme,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS
        ? Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: shadow(),
                  child: Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Theme.of(context).colorScheme.primarytheme,
                        ),
                      ),
                    ),
                  ),
                )),
          )
        : const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    //getUserDetails();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  backBtn(),
                  Image.asset(
                    'assets/images/doodle.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    color: Theme.of(context).colorScheme.primarytheme,
                  ),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };
      apiBaseHelper.postAPICall(validateReferalApi, data).then((getdata) {
        bool error = getdata["error"];

        if (!error) {
          referCode = refer;
          REFER_CODE = refer;
          if (mounted) setState(() {});
        } else {
          if (count < 5) generateReferral();
          count++;
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on TimeoutException catch (_) {}
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.2,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      registerTxt(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated(context, 'sign_up_using')!),
                            Row(
                              children: [
                                Switch(
                                  value: isPhoneSignup,
                                  onChanged: (val) {
                                    setState(() {
                                      isPhoneSignup = val;
                                    });
                                  },
                                ),
                                Text(getTranslated(context,
                                    isPhoneSignup ? 'phone' : 'email')!)
                              ],
                            ),
                          ],
                        ),
                      ),
                      setUserName(),
                      if (isPhoneSignup) setMobile() else setEmail(),
                      // setPass(),
                      // setRefer(),
                      verifyBtn(),
                      loginTxt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 50,
      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          getThemeColor(context),
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primarytheme, BlendMode.color),
        ),
      ),
    );
  }
}
