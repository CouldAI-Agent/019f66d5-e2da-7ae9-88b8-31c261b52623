import 'package:flutter/material.dart';

void main() {
  runApp(const PresentationApp());
}

class PresentationApp extends StatelessWidget {
  const PresentationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerPoint Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class SlideElement {
  String id = UniqueKey().toString();
  String type; // 'text', 'rectangle', 'circle'
  String? text;
  Rect rect;
  Color color;

  SlideElement({
    required this.type,
    required this.rect,
    this.text,
    this.color = Colors.black,
  });
}

class Slide {
  String id = UniqueKey().toString();
  List<SlideElement> elements = [];
  Color backgroundColor = Colors.white;
}

class Presentation {
  String id = UniqueKey().toString();
  String title;
  List<Slide> slides = [];

  Presentation({required this.title}) {
    if (slides.isEmpty) {
      slides.add(Slide());
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Presentation> _presentations = [
    Presentation(title: 'My First Presentation'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presentations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _presentations.length,
            itemBuilder: (context, index) {
              final pres = _presentations[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditorScreen(presentation: pres),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.slideshow, size: 48, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pres.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _presentations.add(Presentation(title: 'New Presentation ${_presentations.length + 1}'));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _currentSlideIndex = 0;
  SlideElement? _selectedElement;

  void _addSlide() {
    setState(() {
      widget.presentation.slides.add(Slide());
      _currentSlideIndex = widget.presentation.slides.length - 1;
      _selectedElement = null;
    });
  }

  void _addElement(String type) {
    setState(() {
      final currentSlide = widget.presentation.slides[_currentSlideIndex];
      final newElement = SlideElement(
        type: type,
        rect: const Rect.fromLTWH(50, 50, 150, 100),
        text: type == 'text' ? 'Double tap to edit' : null,
        color: type == 'text' ? Colors.black : Colors.blueAccent,
      );
      currentSlide.elements.add(newElement);
      _selectedElement = newElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.presentation.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Present',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PresentationScreen(
                    presentation: widget.presentation,
                    initialSlide: _currentSlideIndex,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            height: 50,
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.title), tooltip: 'Add Text', onPressed: () => _addElement('text')),
                IconButton(icon: const Icon(Icons.rectangle_outlined), tooltip: 'Add Rectangle', onPressed: () => _addElement('rectangle')),
                IconButton(icon: const Icon(Icons.circle_outlined), tooltip: 'Add Circle', onPressed: () => _addElement('circle')),
                const Spacer(),
                if (_selectedElement != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Selected',
                    onPressed: () {
                      setState(() {
                        widget.presentation.slides[_currentSlideIndex].elements.remove(_selectedElement);
                        _selectedElement = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Slide Thumbnails (Sidebar)
                if (isDesktop)
                  Container(
                    width: 200,
                    color: Colors.grey[50],
                    child: ListView.builder(
                      itemCount: widget.presentation.slides.length + 1,
                      itemBuilder: (context, index) {
                        if (index == widget.presentation.slides.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: _addSlide,
                              icon: const Icon(Icons.add),
                              label: const Text('New Slide'),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentSlideIndex = index;
                              _selectedElement = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentSlideIndex == index ? Colors.blue : Colors.grey,
                                width: _currentSlideIndex == index ? 2 : 1,
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: widget.presentation.slides[index].backgroundColor,
                                child: Center(child: Text('${index + 1}')),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Main Canvas
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final currentSlide = widget.presentation.slides[_currentSlideIndex];
                            return Container(
                              color: currentSlide.backgroundColor,
                              child: Stack(
                                children: [
                                  for (var element in currentSlide.elements)
                                    Positioned.fromRect(
                                      rect: element.rect,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedElement = element;
                                          });
                                        },
                                        onPanUpdate: (details) {
                                          if (_selectedElement == element) {
                                            setState(() {
                                              element.rect = element.rect.translate(details.delta.dx, details.delta.dy);
                                            });
                                          }
                                        },
                                        onDoubleTap: () {
                                          if (element.type == 'text') {
                                            _editTextElement(element);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _selectedElement == element ? Colors.blue : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: _buildElementWidget(element),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _currentSlideIndex > 0 ? () {
                setState(() {
                  _currentSlideIndex--;
                  _selectedElement = null;
                });
              } : null,
            ),
            Text('Slide ${_currentSlideIndex + 1} / ${widget.presentation.slides.length}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _currentSlideIndex < widget.presentation.slides.length - 1 ? () {
                setState(() {
                  _currentSlideIndex++;
                  _selectedElement = null;
                });
              } : null,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addSlide,
            ),
          ],
        ),
      ),
    );
  }

  void _editTextElement(SlideElement element) {
    TextEditingController controller = TextEditingController(text: element.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  element.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildElementWidget(SlideElement element) {
    switch (element.type) {
      case 'text':
        return Center(
          child: Text(
            element.text ?? '',
            style: TextStyle(color: element.color, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        );
      case 'rectangle':
        return Container(color: element.color);
      case 'circle':
        return Container(
          decoration: BoxDecoration(
            color: element.color,
            shape: BoxShape.circle,
          ),
        );
      default:
        return const SizedBox();
    }
  }
}

class PresentationScreen extends StatefulWidget {
  final Presentation presentation;
  final int initialSlide;

  const PresentationScreen({super.key, required this.presentation, this.initialSlide = 0});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  late int _currentSlide;

  @override
  void initState() {
    super.initState();
    _currentSlide = widget.initialSlide;
  }

  void _nextSlide() {
    if (_currentSlide < widget.presentation.slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
    } else {
      Navigator.pop(context); // End presentation
    }
  }

  void _previousSlide() {
    if (_currentSlide > 0) {
      setState(() {
        _currentSlide--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.presentation.slides[_currentSlide];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx > width / 2) {
            _nextSlide();
          } else {
            _previousSlide();
          }
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: slide.backgroundColor,
              child: Stack(
                children: slide.elements.map((element) {
                  return Positioned.fromRect(
                    rect: element.rect,
                    child: _buildElementWidget(element),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementWidget(SlideElement element) {
    switch (element.type) {
      case 'text':
        return Center(
          child: Text(
            element.text ?? '',
            style: TextStyle(color: element.color, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        );
      case 'rectangle':
        return Container(color: element.color);
      case 'circle':
        return Container(
          decoration: BoxDecoration(
            color: element.color,
            shape: BoxShape.circle,
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
