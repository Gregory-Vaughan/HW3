import 'package:flutter/material.dart';

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class CardModel {
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.image, this.isFaceUp = false, this.isMatched = false});
}

List<CardModel> generateCards() {
  List<String> images = [
    'assets/Jack.png', 'assets/8.png', 'assets/10.png', 'assets/Queen.png',
    'assets/Joker.png', 'assets/9.png', 'assets/King.png', 'assets/Ace.png',
  ];

  List<CardModel> cards = images.expand((image) => [CardModel(image: image), CardModel(image: image)]).toList();
  cards.shuffle();

  return cards;
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardModel> cards;
  int score = 0;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void onCardTap(int index) {
    setState(() {
      if (!cards[index].isFaceUp && !cards[index].isMatched) {
        cards[index].isFaceUp = true;
      }
    });

    checkMatch();
  }

  void checkMatch() {
    List<int> flippedIndexes = [];

    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isFaceUp && !cards[i].isMatched) {
        flippedIndexes.add(i);
      }
    }

    if (flippedIndexes.length == 2) {
      if (cards[flippedIndexes[0]].image == cards[flippedIndexes[1]].image) {
        setState(() {
          cards[flippedIndexes[0]].isMatched = true;
          cards[flippedIndexes[1]].isMatched = true;
          score += 10;
        });
      } else {
        Future.delayed(Duration(milliseconds: 800), () {
          setState(() {
            cards[flippedIndexes[0]].isFaceUp = false;
            cards[flippedIndexes[1]].isFaceUp = false;
          });
        });
      }
    }
  }

  void resetGame() {
    setState(() {
      cards = generateCards();
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: \$score', style: TextStyle(fontSize: 18)),
                Text('Time: 00:00', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    card: cards[index],
                    onTap: () => onCardTap(index),
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: resetGame,
            child: Text('Reset Game'),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CardWidget({Key? key, required this.card, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.isMatched ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue,
          image: DecorationImage(
            image: AssetImage(card.isFaceUp ? card.image : 'assets/card_back.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
