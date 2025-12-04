import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white10,
              Colors.yellow.shade300
            ],
          ),
        ),
        child: ListView(
          children: [
            EventBanner(),
            EventTitle(),
            SizedBox(width: 5, height: 5,),
            EventDescription(),
            EventDetailsRow(),
            EventCategorySection(),
            EventCategorySection()
          ],
        ),
      ),
    );
  }
}

class EventBanner extends StatelessWidget {
  const EventBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Image.asset('assets/banner_jifce.jpg'),
    );
  }
}

class EventTitle extends StatelessWidget {
  const EventTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        'JIFCE',
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class EventDescription extends StatelessWidget{
  const EventDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: const SingleChildScrollView(
          child: Text(
            'JIFCE é a sigla para os Jogos do Instituto Federal do Ceará. Trata-se de uma competição esportiva anual que reúne estudantes de diversos campi do Instituto Federal de Educação, Ciência e Tecnologia do Ceará (IFCE). ',
            style: TextStyle(color: Colors.black45, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class EventDetailsRow extends StatelessWidget{
  const EventDetailsRow ({super.key});

  Widget detailItem(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 18)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        detailItem(const IconData(0xf06bb, fontFamily: 'MaterialIcons'), "02/12/2025"),
        detailItem(const IconData(0xe3ac, fontFamily: 'MaterialIcons'), 'IFCE - Campus Fortaleza'),
      ],
    );
  }
}

class EventCategorySection extends StatelessWidget {
  const EventCategorySection ({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Categoria',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ),
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Scrollbar(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryCard(),
                CategoryCard(),
                CategoryCard(),
                CategoryCard(),
                CategoryCard(),
                ],
              ),
          ),
        )
      ],
    );
  }
}

class CategoryCard extends StatelessWidget{
  const CategoryCard ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      width: 200,
      height: 100,
      child: Image.asset('assets/jif_card.png'),
    );
  }
}
