import 'package:flutter/material.dart';

// News Article model
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final String publishedDate;
  final String category;
  final String? imageUrl;
  final int readTime; // in minutes
  final bool isRead;
  final int likes;
  final int comments;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.publishedDate,
    required this.category,
    this.imageUrl,
    required this.readTime,
    this.isRead = false,
    this.likes = 0,
    this.comments = 0,
  });
}

// News Feed Screen
class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  String selectedCategory = 'all';
  String searchQuery = '';

  // Sample news articles
  final List<NewsArticle> allArticles = [
    NewsArticle(
      id: '1',
      title: 'New Fitness Classes Starting Next Month',
      summary: 'The Villages Recreation Department is excited to announce a series of new fitness classes designed specifically for our active senior community.',
      content: 'Starting February 1st, we will be offering a variety of new fitness classes including chair yoga, water aerobics, and low-impact strength training. All classes are led by certified instructors and designed with senior participants in mind. Classes will be held at various recreation centers throughout The Villages. Registration is now open and spaces are limited.',
      author: 'Recreation Department',
      publishedDate: '2024-01-15',
      category: 'fitness',
      readTime: 3,
      likes: 24,
      comments: 8,
    ),
    NewsArticle(
      id: '2',
      title: 'Community Garden Expansion Project',
      summary: 'Plans are underway to expand the popular community garden with new plots and improved facilities.',
      content: 'The Community Garden Committee has announced an exciting expansion project that will add 20 new garden plots and a community tool shed. The expansion will also include raised garden beds for easier access and new irrigation systems. Current gardeners will have priority registration for the new plots. The project is expected to be completed by spring.',
      author: 'Garden Committee',
      publishedDate: '2024-01-14',
      category: 'community',
      readTime: 4,
      likes: 31,
      comments: 12,
    ),
    NewsArticle(
      id: '3',
      title: 'Weather Preparedness Workshop',
      summary: 'Free workshop on preparing for severe weather events, including hurricanes and thunderstorms.',
      content: 'With hurricane season approaching, the Safety Committee is offering a comprehensive workshop on weather preparedness. Topics will include emergency kit preparation, evacuation procedures, and communication plans. The workshop will be held in the main clubhouse and is open to all residents. Light refreshments will be served.',
      author: 'Safety Committee',
      publishedDate: '2024-01-13',
      category: 'safety',
      readTime: 2,
      likes: 18,
      comments: 5,
    ),
    NewsArticle(
      id: '4',
      title: 'Art Show Winners Announced',
      summary: 'Congratulations to all participants in this year\'s annual art show. The winners have been selected!',
      content: 'The Annual Art Show has concluded with record participation this year. Over 200 pieces were submitted across various categories including painting, photography, and sculpture. The winners will have their work displayed in the community gallery for the next month. Certificates and small prizes will be awarded at the closing reception.',
      author: 'Arts Committee',
      publishedDate: '2024-01-12',
      category: 'arts',
      readTime: 3,
      likes: 27,
      comments: 15,
    ),
    NewsArticle(
      id: '5',
      title: 'Technology Help Sessions',
      summary: 'Weekly technology help sessions now available for residents needing assistance with computers and smartphones.',
      content: 'Beginning next week, we will be offering weekly technology help sessions in the computer lab. Sessions are designed to help residents with email, internet browsing, video calling, and other common technology tasks. No appointment necessary - just drop in during session hours. Our volunteer tech assistants are ready to help!',
      author: 'Technology Committee',
      publishedDate: '2024-01-11',
      category: 'technology',
      readTime: 2,
      likes: 22,
      comments: 7,
    ),
    NewsArticle(
      id: '6',
      title: 'Volunteer Opportunities Available',
      summary: 'Several new volunteer positions are available for residents interested in giving back to the community.',
      content: 'The Volunteer Coordinator is looking for enthusiastic residents to fill several new positions. Opportunities include meal delivery drivers, garden mentors, technology helpers, and event assistants. Training is provided for all positions. If you have a few hours a week to share your skills and make a difference, please contact the Volunteer Office.',
      author: 'Volunteer Office',
      publishedDate: '2024-01-10',
      category: 'volunteer',
      readTime: 3,
      likes: 19,
      comments: 9,
    ),
  ];

  List<NewsArticle> get filteredArticles {
    return allArticles.where((article) {
      final matchesCategory = selectedCategory == 'all' || article.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.author.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  final List<String> categories = ['all', 'community', 'fitness', 'arts', 'safety', 'technology', 'volunteer'];

  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'all': return 'All News';
      case 'community': return 'Community';
      case 'fitness': return 'Fitness';
      case 'arts': return 'Arts';
      case 'safety': return 'Safety';
      case 'technology': return 'Technology';
      case 'volunteer': return 'Volunteer';
      default: return category;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'community': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'arts': return Colors.purple;
      case 'safety': return Colors.red;
      case 'technology': return Colors.teal;
      case 'volunteer': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community News'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Show bookmarks
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmarks coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search news articles...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(getCategoryDisplayName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: getCategoryColor(category).withOpacity(0.2),
                          checkmarkColor: getCategoryColor(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Showing ${filteredArticles.length} of ${allArticles.length} articles',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          // News Articles List
          Expanded(
            child: filteredArticles.isEmpty
                ? const Center(
                    child: Text(
                      'No news articles found matching your criteria',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      return NewsArticleCard(
                        article: article,
                        onTap: () {
                          // Navigate to full article
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// News Article Card Widget
class NewsArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(article.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryDisplayName(article.category),
                      style: TextStyle(
                        color: _getCategoryColor(article.category),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(article.publishedDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              // Summary
              Text(
                article.summary,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Footer with author and stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readTime} min read',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.likes.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.comments.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'community': return 'Community';
      case 'fitness': return 'Fitness';
      case 'arts': return 'Arts';
      case 'safety': return 'Safety';
      case 'technology': return 'Technology';
      case 'volunteer': return 'Volunteer';
      default: return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'community': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'arts': return Colors.purple;
      case 'safety': return Colors.red;
      case 'technology': return Colors.teal;
      case 'volunteer': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

// Article Detail Screen
class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(article.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryDisplayName(article.category),
                    style: TextStyle(
                      color: _getCategoryColor(article.category),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDate(article.publishedDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            // Author and Read Time
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'By ${article.author}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${article.readTime} min read',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // Engagement Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${article.likes} likes',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${article.comments} comments',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Like article
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Article liked!')),
                      );
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Like'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share article
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share options coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'community': return 'Community';
      case 'fitness': return 'Fitness';
      case 'arts': return 'Arts';
      case 'safety': return 'Safety';
      case 'technology': return 'Technology';
      case 'volunteer': return 'Volunteer';
      default: return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'community': return Colors.blue;
      case 'fitness': return Colors.green;
      case 'arts': return Colors.purple;
      case 'safety': return Colors.red;
      case 'technology': return Colors.teal;
      case 'volunteer': return Colors.orange;
      default: return Colors.grey;
    }
  }
}