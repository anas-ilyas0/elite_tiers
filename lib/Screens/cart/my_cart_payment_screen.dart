import 'dart:convert';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Screens/cart/tamara_checkout_webview.dart';
import 'package:http/http.dart' as http;
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:flutter/material.dart';
//import 'package:myfatoorah_flutter/MFModels.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

final _formKey = GlobalKey<FormState>();

class MyCartPaymentScreen extends StatefulWidget {
  final int subTotal;
  const MyCartPaymentScreen({super.key, required this.subTotal});

  @override
  State<MyCartPaymentScreen> createState() => _MyCartPaymentScreenState();
}

class _MyCartPaymentScreenState extends State<MyCartPaymentScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final streetController = TextEditingController();
  final zipPostalController = TextEditingController();
  final neighborhoodController = TextEditingController();
  //copy controllers
  final copyNameController = TextEditingController();
  final copyEmailController = TextEditingController();
  final copyContactController = TextEditingController();
  final copyStreetController = TextEditingController();
  final copyZipPostalController = TextEditingController();
  String selectedBillingCountry = 'Saudi Arabia';
  String selectedShippingCountry = 'Saudi Arabia';
  String? selectedBillingCity;
  String? selectedShippingCity;
  List<String> cities = [
    'Riyadh',
    'Jeddah',
    'Mecca (Makkah)',
    'Medina (Madinah)',
    'Dammam',
    'Khobar (Al Khobar)',
    'Dhahran',
    'Taif',
    'Tabuk',
    'Hail',
    'Buraidah',
    'Unaizah',
    'Jubail',
    'Al Ahsa (Hofuf)',
    'Yanbu',
    'Abha',
    'Khamis Mushait',
    'Najran',
    'Jazan (Jizan)',
    'Al Khafji',
    'Arar',
    'Sakakah',
    'Rafha',
    'Qatif',
    'Al Qunfudhah',
    'Al Bahah',
    'Al Majma\'ah',
    'Al Ula',
    'Al Wajh',
    'Duba',
    'Turaif',
    'Sharurah',
    'Al Lith',
    'Rabigh',
    'Al Qurayyat',
    'Badr',
    'Khaybar',
    'Zulfi',
    'Shaqra',
    'Dawadmi',
    'Wadi ad-Dawasir',
    'Afif',
    'Sarat Abidah',
    'Mahayel Asir',
    'Bisha',
    'Sabya',
    'Abu Arish',
    'Samtah',
    'Farasan',
    'Baljurashi',
    'Al Makhwah',
    'Dumat Al-Jandal',
    'Al Bukayriyah',
    'Al-Rass',
    'Haql',
    'Umluj',
    'Baqqa',
    'Al Shinan',
    'Abqaiq',
    'Ras Tanura'
  ];

  _launchUrl(String url) async {
    final Uri aboutUrl = Uri.parse(isDemoApp
        ? setSnackbar(getTranslated(context, 'SIGNIN_DETAILS')!, context)
        : url);

    if (await canLaunchUrl(aboutUrl)) {
      await launchUrl(aboutUrl, mode: LaunchMode.inAppBrowserView);
    } else {
      throw 'Could not launch $aboutUrl';
    }
  }

  List<String> countries = [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahrain",
    "Bangladesh",
    "China",
    "Egypt",
    "Iran",
    "India",
    "Kuwait",
    "Morocco",
    "Nepal",
    "Saudi Arabia",
    "Pakistan",
    "Qatar",
    "United States",
    "United Arab Emirates",
    "United Kingdom",
    "Yemen",
  ];
  String _selectedShippingRadio = '';
  void _handleShippingRadioValueChange(String? value) {
    if (value != null) {
      setState(() {
        _selectedShippingRadio = value;
      });
    }
  }

  String _selectedPaymentRadio = '';
  void _handlePaymentRadioValueChange(String? value) {
    if (value != null) {
      setState(() {
        _selectedPaymentRadio = value;
      });
    }
  }

  Future<void> startTabbyPayment(
      BuildContext context,
      int amount,
      String phone,
      String email,
      String name,
      String address,
      String zip,
      String city,
      List<Map<String, dynamic>> orderItems) async {
    // Tabby ka API payload
    Map<String, dynamic> payload = {
      "payment": {
        "amount": amount.toString(),
        "currency": "SAR",
        "description": "Order from Elite Tiers",
        "buyer": {"phone": phone, "email": email, "name": name, "dob": ""},
        "shipping_address": {
          "city": city,
          "address": address,
          "zip": zip,
        },
        "order": {
          "tax_amount": "0.00",
          "shipping_amount": "0.00",
          "discount_amount": "0.00",
          "updated_at": DateTime.now().toIso8601String(),
          "reference_id": "ORDER-${DateTime.now().millisecondsSinceEpoch}",
          "items": orderItems,
        },
        "buyer_history": {
          "registered_since":
              DateTime.now().subtract(Duration(days: 365)).toIso8601String(),
          "loyalty_level": 1,
          "wishlist_count": 0,
          "is_social_networks_connected": true,
          "is_phone_number_verified": true,
          "is_email_verified": true,
        },
        "order_history": [],
      },
      "lang": "ar",
      "merchant_code": "3techsa",
      "merchant_urls": {
        "success": "https://your-store/success",
        "cancel": "https://your-store/cancel",
        "failure": "https://your-store/failure"
      }
    };

    final response = await http.post(
      Uri.parse('https://api.tabby.ai/api/v2/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer sk_test_019010e7-f08e-9fe1-1b56-f48b3129dab9', // apni Tabby secret key lagao
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String? webUrl;
      if (data.containsKey('api_url') && data['api_url'] != null) {
        webUrl = data['api_url'];
      } else if (data.containsKey('installments') &&
          data['installments'] != null &&
          data['installments'].containsKey('web_url')) {
        webUrl = data['installments']['web_url'];
      }

      if (webUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TabbyWebView(
              webUrl: webUrl!,
              onResult: (result) {
                if (result == WebViewResult.authorized) {
                  setSnackbar('Tabby Payment Successful!', context);
                } else if (result == WebViewResult.rejected) {
                  setSnackbar('Tabby Payment Rejected!', context);
                } else if (result == WebViewResult.expired) {
                  setSnackbar('Tabby Payment Expired!', context);
                } else if (result == WebViewResult.close) {
                  setSnackbar('Tabby Payment Closed!', context);
                }
              },
            ),
          ),
        );
      } else {
        setSnackbar('Tabby Web URL not found!', context);
      }
    } else {
      setSnackbar('Tabby API error: ${response.body}', context);
    }
  }

  Future<void> startTamaraPayment({
    required BuildContext context,
    required double totalAmount,
    required double shippingAmount,
    required double taxAmount,
    required String orderReferenceId,
    required String orderNumber,
    required Map<String, dynamic> discount,
    required String countryCode,
    required String description,
    required Map<String, String> merchantUrl,
    required String paymentType,
    int? instalments,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> shippingAddress,
    required String platform,
    bool isMobile = true,
    String locale = 'ar_SA',
    Map<String, dynamic>? riskAssessment,
    Map<String, dynamic>? additionalData,
  }) async {
    final cartProvider = Provider.of<MyCartProvider>(context, listen: false);

    List<Map<String, dynamic>> tamaraItems =
        cartProvider.getOrderItemsForTamara();

    Map<String, dynamic> tamaraPayload = {
      "total_amount": {
        "amount": totalAmount,
        "currency": "SAR",
      },
      "shipping_amount": {
        "amount": shippingAmount,
        "currency": "SAR",
      },
      "tax_amount": {
        "amount": taxAmount,
        "currency": "SAR",
      },
      "order_reference_id": orderReferenceId,
      "order_number": orderNumber,
      "discount": discount,
      "items": tamaraItems,
      "consumer": {
        // **Yahan apni app se customer info pass karo (hardcode na karo prod me)**
        "email": emailController.text,
        "first_name": nameController.text,
        "last_name": "",
        "phone_number": contactController.text,
      },
      "country_code": countryCode,
      "description": description,
      "merchant_url": merchantUrl,
      "payment_type": paymentType,
      if (instalments != null) "instalments": instalments,
      "billing_address": billingAddress,
      "shipping_address": shippingAddress,
      "platform": platform,
      "is_mobile": isMobile,
      "locale": locale,
      if (riskAssessment != null) "risk_assessment": riskAssessment,
      if (additionalData != null) "additional_data": additionalData,
    };

    // Clean up nulls (if any)
    tamaraPayload.removeWhere((key, value) => value == null);

    // --- HTTP POST to Tamara API ---
    final response = await http.post(
      Uri.parse('https://api.tamara.co/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tamaraToken',
      },
      body: jsonEncode(tamaraPayload),
    );

    print('Tamara response: ${response.statusCode} | ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String? checkoutUrl = data['checkout_url'] ?? data['redirect_url'];
      if (checkoutUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TamaraCheckoutWebView(
              checkoutUrl: checkoutUrl,
              successUrl: "https://yourstore.com/success",
              cancelUrl: "https://yourstore.com/cancel",
              failureUrl: "https://yourstore.com/fail",
            ),
          ),
        );
        // Show WebView using TamaraCheckout widget
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TamaraCheckout(
        //       checkoutUrl,
        //       merchantUrl['success']!,
        //       merchantUrl['failure']!,
        //       merchantUrl['cancel']!,
        //       onPaymentSuccess: () {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(content: Text('Tamara Payment Successful!')),
        //         );
        //       },
        //       onPaymentFailed: () {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(content: Text('Tamara Payment Failed!')),
        //         );
        //       },
        //       onPaymentCanceled: () {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           SnackBar(content: Text('Tamara Payment Cancelled!')),
        //         );
        //       },
        //     ),
        //   ),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tamara Checkout URL not found!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tamara API Error: ${response.body}')),
      );
    }
  }


  Future<void> startMyFatoorahPayment(BuildContext context, int amount) async {
    // Step 1: Initiate Payment
    MFInitiatePaymentRequest request = MFInitiatePaymentRequest(
      invoiceAmount: amount.toDouble(),
      currencyIso: "SAR",
    );

    try {
      // Get available payment methods
      MFInitiatePaymentResponse response =
          await MFSDK.initiatePayment(request, "en");

      // Choose first payment method for simplicity (can show user options)
      MFPaymentMethod paymentMethod = response.paymentMethods!.first;

      // Step 2: Execute Payment
      MFExecutePaymentRequest executeRequest = MFExecutePaymentRequest(
        paymentMethodId: paymentMethod.paymentMethodId,
        customerName: nameController.text,
        displayCurrencyIso: "SAR",
        mobileCountryCode: "+966",
        customerMobile: contactController.text,
        customerEmail: emailController.text,
        invoiceValue: amount.toDouble(),
        language: "en",
        customerReference:
            "EliteTiers-${DateTime.now().millisecondsSinceEpoch}",
        customerAddress: MFCustomerAddres(
          street: streetController.text,
          block: "",
          houseBuildingNo: "",
          addressInstructions: "",
        ),
        invoiceItems: Provider.of<MyCartProvider>(context, listen: false)
            .cartItems
            .map((item) {
          return MFInvoiceItem(
            itemName: item.title,
            quantity: item.quantity,
            unitPrice: (item.discountedPrice != 0
                ? item.discountedPrice
                : item.actualPrice),
          );
        }).toList(),
      );

      // Execute payment (user will be redirected to MyFatoorah payment page)
      MFGetPaymentStatusResponse status = await MFSDK.executePayment(
        executeRequest,
        "en",
        (invoiceId) {
          // Optional: Payment started callback
        },
      );

      // Handle the response (success/fail)
      if (status.invoiceStatus == "Paid" ||
          status.invoiceStatus == "InProgress") {
        setSnackbar(
            "Payment Successful! Invoice: ${status.invoiceId}", context);
      } else {
        setSnackbar(
            "Payment not completed! Status: ${status.invoiceStatus}", context);
      }
    } catch (e) {
      setSnackbar("MyFatoorah Error: $e", context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final totalCost = widget.subTotal;
    Color textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);
    textFormField(
        String hintText, TextEditingController controller, String validatorText,
        {TextInputType? textInputType}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: controller,
                  cursorColor: textColor,
                  keyboardType: textInputType,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 12),
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslated(context, validatorText)!;
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? colors.darkColor
            : Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: textColor,
            )),
        title: Text(
          getTranslated(context, 'payment')!,
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, 'billing_address')!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    textFormField(getTranslated(context, 'name')!,
                        nameController, 'name_required'),
                    const SizedBox(width: 5),
                    textFormField(getTranslated(context, 'email')!,
                        emailController, 'email_required',
                        textInputType: TextInputType.emailAddress),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    textFormField(getTranslated(context, 'contact_no')!,
                        contactController, 'contact_required',
                        textInputType: TextInputType.phone),
                    const SizedBox(width: 5),
                    textFormField(getTranslated(context, 'str_add')!,
                        streetController, 'street_add_required'),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: textFormField(
                          getTranslated(context, 'zip_postal')!,
                          zipPostalController,
                          'zip_postal_required',
                          textInputType: TextInputType.number),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: textFormField(
                          getTranslated(context, 'neighborhood')!,
                          neighborhoodController,
                          'neighborhood_required'),
                    ),
                    // Expanded(
                    //   child: Container(
                    //     height: 50,
                    //     decoration: BoxDecoration(
                    //         border: Border.all(
                    //             color: Colors.grey.withValues(alpha: 0.7)),
                    //         borderRadius: BorderRadius.circular(4)),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: DropdownButton<String>(
                    //         isExpanded: true,
                    //         underline: Container(),
                    //         hint: Text(
                    //           getTranslated(context, 'CITYSELECT_LBL')!,
                    //           style: const TextStyle(
                    //               color: Colors.grey, fontSize: 12),
                    //         ),
                    //         value: selectedBillingCity,
                    //         items: cities
                    //             .map<DropdownMenuItem<String>>((String value) {
                    //           return DropdownMenuItem<String>(
                    //             value: value,
                    //             child: Text(
                    //               value,
                    //               style: TextStyle(color: textColor),
                    //             ),
                    //           );
                    //         }).toList(),
                    //         onChanged: (String? newValue) {
                    //           setState(() {
                    //             selectedBillingCity = newValue!;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.7)),
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(),
                      hint: Text(
                        getTranslated(context, 'CITYSELECT_LBL')!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      value: selectedBillingCity,
                      items:
                          cities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBillingCity = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.withValues(alpha: 0.7)
                                  : Colors.grey.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AbsorbPointer(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        hint: Text(
                          getTranslated(context, 'sel_country')!,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        value: selectedBillingCountry,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBillingCountry = newValue!;
                          });
                        },
                        items: countries
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // const SizedBox(height: 10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //       child: Text(
                //         getTranslated(context, 'ship_add')!,
                //         style: const TextStyle(
                //             fontWeight: FontWeight.bold, fontSize: 16),
                //       ),
                //     ),
                //     ElevatedButton(
                //         onPressed: () {
                //           copyNameController.text = nameController.text;
                //           copyEmailController.text = emailController.text;
                //           copyContactController.text = contactController.text;
                //           copyStreetController.text = streetController.text;
                //           copyZipPostalController.text =
                //               zipPostalController.text;
                //           selectedShippingCity = selectedBillingCity;
                //           selectedShippingCountry = selectedBillingCountry;
                //         },
                //         child: Text(
                //           getTranslated(context, 'copy_bill_add')!,
                //           style: const TextStyle(fontSize: 10),
                //         ))
                //   ],
                // ),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     textFormField(getTranslated(context, 'name')!,
                //         copyNameController, 'name_required'),
                //     const SizedBox(width: 5),
                //     textFormField(getTranslated(context, 'email')!,
                //         copyEmailController, 'email_required',
                //         textInputType: TextInputType.emailAddress),
                //   ],
                // ),
                // const SizedBox(height: 5),
                // Row(
                //   children: [
                //     textFormField(getTranslated(context, 'contact_no')!,
                //         copyContactController, 'contact_required',
                //         textInputType: TextInputType.phone),
                //     const SizedBox(width: 5),
                //     textFormField(getTranslated(context, 'str_add')!,
                //         copyStreetController, 'street_add_required'),
                //   ],
                // ),
                // const SizedBox(height: 5),
                // Row(
                //   children: [
                //     Expanded(
                //       child: textFormField(
                //           getTranslated(context, 'zip_postal')!,
                //           copyZipPostalController,
                //           'zip_postal_required',
                //           textInputType: TextInputType.number),
                //     ),
                //     const SizedBox(width: 5),
                //     Expanded(
                //       child: Container(
                //         height: 50,
                //         decoration: BoxDecoration(
                //             border: Border.all(
                //                 color: Theme.of(context).brightness ==
                //                         Brightness.light
                //                     ? Colors.grey.withValues(alpha: 0.7)
                //                     : Colors.grey.withValues(alpha: 0.5)),
                //             borderRadius: BorderRadius.circular(4)),
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: DropdownButton<String>(
                //             isExpanded: true,
                //             underline: Container(),
                //             hint: Text(
                //               getTranslated(context, 'CITYSELECT_LBL')!,
                //               style: const TextStyle(
                //                   color: Colors.grey, fontSize: 12),
                //             ),
                //             value: selectedShippingCity,
                //             items: cities
                //                 .map<DropdownMenuItem<String>>((String value) {
                //               return DropdownMenuItem<String>(
                //                 value: value,
                //                 child: Text(
                //                   value,
                //                   style: TextStyle(color: textColor),
                //                 ),
                //               );
                //             }).toList(),
                //             onChanged: (String? newValue) {
                //               setState(() {
                //                 selectedShippingCity = newValue!;
                //               });
                //             },
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 5),
                // Container(
                //   height: 50,
                //   decoration: BoxDecoration(
                //       border: Border.all(
                //           color:
                //               Theme.of(context).brightness == Brightness.light
                //                   ? Colors.grey.withValues(alpha: 0.7)
                //                   : Colors.grey.withValues(alpha: 0.5)),
                //       borderRadius: BorderRadius.circular(4)),
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: AbsorbPointer(
                //       child: DropdownButton<String>(
                //         isExpanded: true,
                //         underline: Container(),
                //         hint: Text(
                //           getTranslated(context, 'sel_country')!,
                //           style:
                //               const TextStyle(color: Colors.grey, fontSize: 12),
                //         ),
                //         value: selectedShippingCountry,
                //         onChanged: (String? newValue) {
                //           setState(() {
                //             selectedShippingCountry = newValue!;
                //           });
                //         },
                //         items: countries
                //             .map<DropdownMenuItem<String>>((String value) {
                //           return DropdownMenuItem<String>(
                //             value: value,
                //             child: Text(
                //               value,
                //               style: TextStyle(color: textColor),
                //             ),
                //           );
                //         }).toList(),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    getTranslated(context, 'invoice')!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.withValues(alpha: 0.7)
                            : Colors.grey.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'sub_total')!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              locale.languageCode == 'ar'
                                  ? '${widget.subTotal.toStringAsFixed(0)} ر.س'
                                  : 'SAR ${widget.subTotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'ship_cost')!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              getTranslated(context, 'sar_0')!,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'vat_tax')!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              getTranslated(context, 'sar_0')!,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'total_cost')!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locale.languageCode == 'ar'
                                  ? '$totalCost ر.س'
                                  : 'SAR $totalCost',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    getTranslated(context, 'ship_methods')!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4))),
                  child: RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'aramax')!,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image: AssetImage('assets/images/aramax.png'))
                      ],
                    ),
                    value: 'aramax',
                    groupValue: _selectedShippingRadio,
                    onChanged: _handleShippingRadioValueChange,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4))),
                  child: RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'samsa')!,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image: AssetImage('assets/images/samsa.png'))
                      ],
                    ),
                    value: 'samsa',
                    groupValue: _selectedShippingRadio,
                    onChanged: _handleShippingRadioValueChange,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    getTranslated(context, 'pay_methods')!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4))),
                  child: RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'tabby')!,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image: AssetImage('assets/images/tabby.png'))
                      ],
                    ),
                    value: 'tabby',
                    groupValue: _selectedPaymentRadio,
                    onChanged: _handlePaymentRadioValueChange,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4))),
                  child: RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'tamara')!,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image: AssetImage('assets/images/tamara.png'))
                      ],
                    ),
                    value: 'tamara',
                    groupValue: _selectedPaymentRadio,
                    onChanged: _handlePaymentRadioValueChange,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4))),
                  child: RadioListTile<String>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            getTranslated(context, 'myfatoorah')!,
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                        ),
                        Row(
                          children: [
                            const Image(
                                width: 60,
                                height: 45,
                                image: AssetImage(
                                    'assets/images/paymentMethods.png')),
                            const SizedBox(width: 7),
                            const Image(
                                width: 30,
                                height: 45,
                                image:
                                    AssetImage('assets/images/applePay.png')),
                          ],
                        )
                      ],
                    ),
                    value: 'myfatoorah',
                    groupValue: _selectedPaymentRadio,
                    onChanged: _handlePaymentRadioValueChange,
                  ),
                ),
                FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          getTranslated(context, 'agree_btn')!,
                          style: const TextStyle(fontSize: 11),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            _launchUrl(
                                'https://elitetiers.3chats.com/terms/conditions');
                          },
                          child: Text(
                            getTranslated(context, 'terms_cond')!,
                            style: const TextStyle(
                                color: Color(0xff22A4BE),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Consumer<MyCartProvider>(builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String phone = contactController.text.trim();
                          String email = emailController.text.trim();
                          String name = nameController.text.trim();
                          String address = streetController.text.trim();
                          String zip = zipPostalController.text.trim();
                          String city = selectedBillingCity ?? '';
                          int amount = widget.subTotal;

                          // if (!(phone.startsWith('+966') &&
                          //     phone.length == 13)) {
                          //   setSnackbar(
                          //       getTranslated(context, 'valid_saudi_no')!,
                          //       context);
                          //   return;
                          // }
                          //else
                          if (selectedBillingCity == null ||
                              selectedBillingCity!.isEmpty) {
                            setSnackbar(
                                getTranslated(context, 'sel_city')!, context);
                            return;
                          }

                          final cartProvider = Provider.of<MyCartProvider>(
                              context,
                              listen: false);

                          // --- TABBY ---
                          if (_selectedPaymentRadio == 'tabby') {
                            List<Map<String, dynamic>> orderItems =
                                cartProvider.cartItems.map((item) {
                              return {
                                "title": item.title,
                                "description": "",
                                "quantity": item.quantity,
                                "unit_price": (item.discountedPrice != 0
                                        ? item.discountedPrice
                                        : item.actualPrice)
                                    .toString(),
                                "discount_amount": 0.00,
                                "reference_id": item.id.toString(),
                                "image_url": item.image,
                                "product_url": "",
                                "gender": "",
                                "category": "",
                                "color": "",
                                "product_material": "",
                                "size_type": "",
                                "size": "",
                                "brand": "",
                                "is_refundable": true,
                              };
                            }).toList();

                            await startTabbyPayment(
                              context,
                              amount,
                              phone,
                              email,
                              name,
                              address,
                              zip,
                              city,
                              orderItems,
                            );
                            return;
                          }

                          // --- TAMARA ---
                          if (_selectedPaymentRadio == 'tamara') {
                            await startTamaraPayment(
                              context: context,
                              totalAmount: amount.toDouble(),
                              shippingAmount: 0,
                              taxAmount: 0,
                              orderReferenceId:
                                  "ORDER-${DateTime.now().millisecondsSinceEpoch}",
                              orderNumber:
                                  "INV-${DateTime.now().millisecondsSinceEpoch}",
                              discount: {
                                "name": "",
                                "amount": {"amount": 0, "currency": "SAR"}
                              },
                              countryCode: "SA",
                              description: "EliteTiers Order",
                              merchantUrl: {
                                "cancel": "https://your-store/cancel",
                                "failure": "https://your-store/failure",
                                "success": "https://your-store/success",
                                "notification": "https://your-store/notify"
                              },
                              paymentType: "PAY_BY_INSTALMENTS", // ya PAY_LATER
                              instalments: 3,
                              billingAddress: {
                                "city": city,
                                "country_code": "SA",
                                "first_name": name,
                                "last_name": "",
                                "line1": address,
                                "line2": "",
                                "phone_number": phone,
                                "region": ""
                              },
                              shippingAddress: {
                                "city": city,
                                "country_code": "SA",
                                "first_name": name,
                                "last_name": "",
                                "line1": address,
                                "line2": "",
                                "phone_number": phone,
                                "region": ""
                              },
                              platform: "elite_tiers_flutter_app",
                              isMobile: true,
                              locale: "ar_SA",
                            );
                            return;
                          }

                          if (_selectedPaymentRadio == 'myfatoorah') {
                            await startMyFatoorahPayment(context, amount);
                            return;
                          }

                          // Agar koi payment method select nahi hua
                          setSnackbar(
                              'Please select a payment method', context);
                        } else {
                          setSnackbar(
                              getTranslated(context, 'fill_fields')!, context);
                        }
                      },
                      child: Text(
                        getTranslated(context, 'place_order')!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  // Future<void> startMyFatoorahPayment(BuildContext context, int amount) async {
  //   MFInitiatePaymentRequest request = MFInitiatePaymentRequest(
  //     invoiceAmount: amount,
  //     currencyIso: "SAR",
  //   );

  //   try {
  //     MFInitiatePaymentResponse response =
  //         await MFSDK.initiatePayment(request, "en");

  //     // Ye line "payment selection" ke liye dialog/modal app ke andar hi khol deta hai!
  //     MFPaymentMethod paymentMethod = await showModalBottomSheet(
  //       context: context,
  //       builder: (ctx) {
  //         return ListView(
  //           children: response.paymentMethods!.map((pm) {
  //             return ListTile(
  //               leading: Image.network(pm.imageUrl ?? ''),
  //               title: Text(pm.paymentMethodEn ?? ''),
  //               onTap: () {
  //                 Navigator.pop(ctx, pm);
  //               },
  //             );
  //           }).toList(),
  //         );
  //       },
  //     );

  //     MFExecutePaymentRequest executeRequest = MFExecutePaymentRequest(
  //       paymentMethodId: paymentMethod.paymentMethodId,
  //       customerName: "Ali",
  //       displayCurrencyIso: "SAR",
  //       mobileCountryCode: "+966",
  //       customerMobile: "500000000",
  //       customerEmail: "test@email.com",
  //       invoiceValue: amount,
  //       language: "en",
  //       customerReference:
  //           "EliteTiers-${DateTime.now().millisecondsSinceEpoch}",
  //       customerAddress: MFCustomerAddres(
  //         street: "Some Street",
  //         block: "",
  //         houseBuildingNo: "",
  //         addressInstructions: "",
  //       ),
  //       invoiceItems: [
  //         MFInvoiceItem(
  //           itemName: "Sample Item",
  //           quantity: 1,
  //           unitPrice: amount,
  //         ),
  //       ],
  //     );

  //     // Ye call MyFatoorah ka UI show karta hai app ke andar
  //     MFGetPaymentStatusResponse status = await MFSDK.executePayment(
  //       executeRequest,
  //       "en",
  //       (invoiceId) {
  //         // Payment started
  //       },
  //     );

  //     // Payment Result yahan mil jayega
  //     print("Status: ${status.invoiceStatus}");
  //   } catch (e) {
  //     print("Payment Error: $e");
  //   }
  // }
