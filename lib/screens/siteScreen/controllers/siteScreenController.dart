import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SiteScreenController extends GetxController {
  final RxString displayedText = ''.obs;
  final String fullText = '''"MAOWL - The Abode of Manufacturing Tech" ''';
  
  late Timer timer;
  int currentIndex = 0;
  bool isAnimating = false;
  
  // ScrollController for auto-scrolling images
  final ScrollController scrollController = ScrollController();
  Timer? autoScrollTimer;
  
  @override
  void onInit() {
    super.onInit();
    startAutoScroll();
  }
  
  @override
  void onClose() {
    if (autoScrollTimer != null) {
      autoScrollTimer!.cancel();
    }
    scrollController.dispose();
    super.onClose();
  }
  
  // Auto-scroll images from left to right continuously
  void startAutoScroll() {
    // Wait for the widget to be built and laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoScrollTimer = Timer.periodic(Duration(milliseconds: 20), (timer) {
        if (scrollController.hasClients) {
          // Get the current scroll position
          double currentPosition = scrollController.position.pixels;
          
          // Get the maximum scroll extent
          double maxScrollExtent = scrollController.position.maxScrollExtent;
          
          // Increment the scroll position - increased for faster scrolling
          double newPosition = currentPosition + 4.0;
          
          // If we've reached the end, jump back to start for continuous loop effect
          if (newPosition >= maxScrollExtent) {
            // Jump to the beginning without animation
            scrollController.jumpTo(0);
          } else {
            // Smooth scroll to the new position
            scrollController.jumpTo(newPosition); // Using jumpTo for smoother continuous scrolling
          }
        }
      });
    });
  }
  
  // No pause function as images should always scroll automatically
}