import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../demos.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Rough example')),
      body: DemoList(),
    );
  }
}

class DemoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        separatorBuilder: (context, position) => Container(
          color: Theme.of(context).cardColor,
          child: const Divider(
            indent: 64,
            thickness: 1,
            height: 4,
          ),
        ),
        itemCount: demos.length,
        itemBuilder: (context, position) => DemoRow(demo: demos[position]),
      ),
    );
  }
}

class DemoRow extends StatelessWidget {
  final Demo demo;

  const DemoRow({Key key, this.demo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(demo.name),
        dense: false,
        subtitle: Text(demo.description),
        leading: Container(
          child: demo.icon,
          width: 42,
          height: 42,
        ),
        onTap: () => Navigator.push<MaterialPageRoute>(
          context,
          MaterialPageRoute(
            builder: demo.buildPage,
          ),
        ),
      ),
    );
  }
}
