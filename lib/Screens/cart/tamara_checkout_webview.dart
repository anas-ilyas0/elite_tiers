import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TamaraCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final String successUrl;
  final String cancelUrl;
  final String failureUrl;

  const TamaraCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.failureUrl,
  });

  @override
  State<TamaraCheckoutWebView> createState() => _TamaraCheckoutWebViewState();
}

class _TamaraCheckoutWebViewState extends State<TamaraCheckoutWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.successUrl)) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tamara Payment Successful!')),
              );
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(widget.cancelUrl)) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tamara Payment Cancelled!')),
              );
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(widget.failureUrl)) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tamara Payment Failed!')),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Checkout')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
