import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/UI/widgets/SimpleAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetails extends StatelessWidget {
  final String name, tag, image, date, title, shortDesc, longDesc;
  const BlogDetails(
      {super.key,
      required this.name,
      required this.tag,
      required this.image,
      required this.date,
      required this.title,
      required this.shortDesc,
      required this.longDesc});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl(context) {
      return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    }

    return Scaffold(
      appBar: getSimpleAppBar(getTranslated(context, name)!, context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : Colors.blueGrey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill, image: NetworkImage(image)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: isRtl(context) ? 5 : null,
                            left: isRtl(context) ? null : 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Text(
                                    tag,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date),
                          const SizedBox(height: 5),
                          Text(
                            getTranslated(context, 'short_desc')!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(shortDesc),
                          const SizedBox(height: 5),
                          Text(
                            getTranslated(context, 'long_desc')!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          HtmlWidget(longDesc),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
