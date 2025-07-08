import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DailyQuoteWidget extends StatelessWidget {
  final String quote;
  final String? author;

  const DailyQuoteWidget({
    Key? key,
    required this.quote,
    this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 35,
            color: Theme.of(context)
                .colorScheme
                .onTertiaryContainer
                .withOpacity(0.7),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.justify,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (author != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "- $author",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiaryContainer
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuoteItem {
  final String title;
  final String quote;
  final String? author;

  QuoteItem({required this.title, required this.quote, this.author});
}

class QuoteCarousel extends StatefulWidget {
  final List<QuoteItem> quotes;

  const QuoteCarousel({Key? key, required this.quotes}) : super(key: key);

  @override
  State<QuoteCarousel> createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<QuoteCarousel> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.quotes.isEmpty) {
      return const SizedBox.shrink();
    }
    return CarouselSlider.builder(
      itemCount: widget.quotes.length,
      itemBuilder: (context, index, realIndex) {
        final quoteItem = widget.quotes[index];
        return DailyQuoteWidget(
          quote: quoteItem.quote,
          author: quoteItem.author,
        );
      },
      options: CarouselOptions(
        height: 200,
        initialPage: _activeIndex,
        enlargeCenterPage: true,
        viewportFraction: 1,
        enableInfiniteScroll: widget.quotes.length > 1,
        enlargeFactor: 0.2,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          if (mounted) {
            setState(() {
              _activeIndex = index;
            });
          }
        },
      ),
    );
  }
}
