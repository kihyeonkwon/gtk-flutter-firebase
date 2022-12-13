import 'package:flutter/material.dart';
import 'package:gtk_flutter/models.dart';

class YesNoSelection extends StatelessWidget {
  final Attending state;
  final void Function(Attending attending) onSelection;

  const YesNoSelection(
      {required this.state, required this.onSelection, super.key});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TextButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
      case Attending.unknown:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TextButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
    }
  }
}
