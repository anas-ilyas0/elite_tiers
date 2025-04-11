import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Models/blogs_model.dart';
import 'package:elite_tiers/Screens/blog_details.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:elite_tiers/UI/widgets/SimpleAppBar.dart';
import 'package:flutter/material.dart';

class ShowMoreBlogs extends StatefulWidget {
  final String name;
  final List<Blogs> blogsList;
  const ShowMoreBlogs({super.key, required this.name, required this.blogsList});

  @override
  State<ShowMoreBlogs> createState() => _ShowMoreBlogsState();
}

class _ShowMoreBlogsState extends State<ShowMoreBlogs> {
  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl(context) {
      return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    }

    return Scaffold(
      appBar: getSimpleAppBar(widget.name, context),
      body: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.blogsList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white),
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? null
                                    : Colors.blueGrey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => BlogDetails(
                                                  name: locale.languageCode ==
                                                          'ar'
                                                      ? widget.blogsList[index]
                                                          .frTitle
                                                      : widget.blogsList[index]
                                                          .enTitle,
                                                  tag: 'Hot Collection',
                                                  image: widget.blogsList[index]
                                                      .smallImage,
                                                  date: formatDate(widget
                                                      .blogsList[index]
                                                      .createdAt),
                                                  title: capitalize(
                                                    locale.languageCode == 'ar'
                                                        ? widget
                                                            .blogsList[index]
                                                            .frTitle
                                                        : widget
                                                            .blogsList[index]
                                                            .enTitle,
                                                  ),
                                                  shortDesc: capitalize(
                                                    locale.languageCode == 'ar'
                                                        ? capitalize(widget
                                                            .blogsList[index]
                                                            .frDescriptionOne
                                                            .toLowerCase())
                                                        : widget
                                                            .blogsList[index]
                                                            .enDescriptionOne
                                                            .toLowerCase(),
                                                  ),
                                                  longDesc: capitalize(
                                                    locale.languageCode == 'ar'
                                                        ? capitalize(widget
                                                            .blogsList[index]
                                                            .frDescriptionTwo
                                                            .toLowerCase())
                                                        : widget
                                                            .blogsList[index]
                                                            .enDescriptionTwo
                                                            .toLowerCase(),
                                                  ),
                                                )),
                                      );
                                    },
                                    child: Container(
                                      height: 200,
                                      width: 340,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(widget
                                                .blogsList[index].smallImage)),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: isRtl(context) ? 5 : null,
                                    left: isRtl(context) ? null : 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            'Hot Collection',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(formatDate(
                                        widget.blogsList[index].createdAt)),
                                    const SizedBox(height: 5),
                                    Text(capitalize(locale.languageCode == 'ar'
                                        ? widget.blogsList[index].frTitle
                                        : widget.blogsList[index].enTitle)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
            )
          ],
        ),
      ),
    );
  }
}
