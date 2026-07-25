import 'dart:developer';

class func {
  static int index = 0;
  static void reset() {
    index = 0;
    log("Page index reset to 0");
  }

  static bool unlockpage(int pageindex) {
    if (index == pageindex) {
      index++;
      log("page unlocked to $index");
      return true;
    }
    else if (index > pageindex) {
      log("page already unlocked at $index");
      return true;
    }
    else if (pageindex == index + 1) {
      // This is for when we are unlocking pages during app start
      index = pageindex + 1;
      log("page unlocked to $index");
      return true;
    }
    else {
      return false;
    }
  }
}