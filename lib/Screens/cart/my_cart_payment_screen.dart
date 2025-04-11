import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Screens/cart/payment_web_view.dart';
import 'package:elite_tiers/Screens/cart/tabby_manager.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:flutter/material.dart';
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
  //final conditionController = TextEditingController();
  final zipPostalController = TextEditingController();
  final neighborhoodController = TextEditingController();
  //copy controllers
  final copyNameController = TextEditingController();
  final copyEmailController = TextEditingController();
  final copyContactController = TextEditingController();
  final copyStreetController = TextEditingController();
  //final copyConditionController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    TabbyManager().initialize();
  }

  Future<void> processTabbyPayment() async {
    try {
      final tabbySDK = TabbyManager().tabbySDK;
      final payload = TabbyCheckoutPayload(
        merchantCode: '3techsau',
        lang: Lang.en,
        payment: Payment(
          amount: widget.subTotal.toString(),
          currency: Currency.sar,
          buyer: Buyer(
            email: emailController.text,
            phone: contactController.text,
            name: nameController.text,
          ),
          buyerHistory: BuyerHistory(registeredSince: '', loyaltyLevel: 100),
          shippingAddress: ShippingAddress(
            city: selectedShippingCity!,
            address: copyStreetController.text,
            zip: copyZipPostalController.text,
          ),
          order: Order(
            referenceId: '',
            items: [
              OrderItem(
                title: 'Jersey',
                description: 'Jersey',
                quantity: 1,
                unitPrice: '10.00',
                referenceId: 'uuid',
                productUrl: 'http://example.com',
                category: 'clothes',
              )
            ],
          ),
          orderHistory: [
            OrderHistoryItem(
              purchasedAt: '2019-08-24T14:15:22Z',
              amount: '10.00',
              paymentMethod: OrderHistoryItemPaymentMethod.card,
              status: OrderHistoryItemStatus.newOne,
            )
          ],
        ),
      );

      final session = await tabbySDK.createSession(payload);

      if (session.availableProducts.installments != null) {
        final url = session.availableProducts.installments!.webUrl;

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentWebView(url: url)),
        );

        setSnackbar(
          'Payment completed. Please verify on your server.',
          context,
        );
      } else {
        setSnackbar('No installment options available.', context);
      }
    } catch (e) {
      setSnackbar('Error: ${e.toString()}', context);
    }
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
                            getTranslated(context, 'cards')!,
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image:
                                AssetImage('assets/images/paymentMethods.png'))
                      ],
                    ),
                    value: 'paymentMethods',
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
                          getTranslated(context, 'mada')!,
                          style: TextStyle(color: textColor, fontSize: 14),
                        ),
                        const Image(
                            width: 60,
                            height: 45,
                            image: AssetImage('assets/images/mada.png'))
                      ],
                    ),
                    value: 'mada',
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                        } else {
                          setSnackbar(
                              getTranslated(context, 'fill_fields')!, context);
                        }
                        // if (_selectedPaymentRadio == 'tabby') {
                        //   await processTabbyPayment();
                        // } else {
                        //   setSnackbar('Please Select Tabby Payment', context);
                        // }
                      },
                      child: Text(
                        getTranslated(context, 'place_order')!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
