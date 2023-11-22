import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  bool isAnswerCorrect = false;
  bool quizCompleted = false;
  bool showError = false;

  final List<Question> questions = [
    Question(
      'Qual é a capital do Brasil?',
      ['São Paulo', 'Rio de Janeiro', 'Brasília'],
      2,
    ),
    Question(
      'Quantos planetas existem no sistema solar?',
      ['7', '8', '9'],
      1,
    ),
    Question(
      'Qual é a cor do céu em um dia claro?',
      ['Azul', 'Verde', 'Vermelho'],
      0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(_controller);
  }

  void checkAnswer(int answerIndex) {
    if (!showError) {
      setState(() {
        selectedAnswerIndex = answerIndex;
        if (questions[currentQuestionIndex].correctAnswerIndex == answerIndex) {
          _controller.forward();
          isAnswerCorrect = true;
        } else {
          isAnswerCorrect = false;
          showError = true;
          showErrorToast('Resposta incorreta');
        }
      });
    }
  }

  void nextQuestion() {
    if (!showError && isAnswerCorrect) {
      setState(() {
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          selectedAnswerIndex = -1;
          _controller.reset();
          isAnswerCorrect = false;
          showError = false;
        } else {
          quizCompleted = true;
        }
      });
    }
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswerIndex = -1;
      isAnswerCorrect = false;
      showError = false;
      // Reiniciar o AnimatedBuilder
      _controller.reset();
    });
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(109, 244, 67, 54),
      textColor: Colors.white,
      fontSize: 14.0,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showError = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Quiz App',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0.0, 0.4),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  if (_scaleAnimation.value > 0) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Lottie.asset(
                          'assets/images/check_animado.json.zip',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    );
                  } else {
                    return Container(); // Ocultar o AnimatedBuilder
                  }
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              left: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        questions[currentQuestionIndex].question,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: questions[currentQuestionIndex]
                        .options
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: index == selectedAnswerIndex
                            ? const Color.fromARGB(255, 30, 136, 85)
                            : Colors.white,
                        child: InkWell(
                          onTap: () => checkAnswer(index),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: index == selectedAnswerIndex
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              restartQuiz();
            },
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.replay,
              size: 50.0,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              nextQuestion();
            },
            backgroundColor:
                selectedAnswerIndex != -1 && !showError && !quizCompleted
                    ? Colors.green
                    : const Color.fromARGB(255, 148, 23, 14),
            child: const Icon(
              Icons.arrow_right,
              size: 50.0,
            ),
          ),
        ],
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question(this.question, this.options, this.correctAnswerIndex);
}
