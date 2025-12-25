import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

Widget LikuFAB(listeningStatus, textCommand,
    {VoidCallback? toBantuan, VoidCallback? toggleAction}) {
  SpeechToText speech = SpeechToText();
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.blue,
          heroTag: 'mic-button',
          onPressed: toggleAction,
          child: listeningStatus
              ? const Icon(
                  Icons.mic,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.mic_off_rounded,
                  color: Colors.white,
                ),
        ),
        widthSpace(12),
        Expanded(
          child: Hero(
            tag: 'text-container',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  textCommand,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        widthSpace(12),
        FloatingActionButton(
          splashColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.blue,
          heroTag: 'help-button',
          onPressed: toBantuan,
          child: const Icon(
            Icons.help_center_outlined,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
