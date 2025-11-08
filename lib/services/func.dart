
import 'dart:developer';

class func {
  static int index = 0;
  static bool  unlockpage(int pageindex ){
    if(index == pageindex){
      index++;
      log("page unlocked to $index");
      return true;
    }
    else if(index > pageindex){
      log("page unlocked to $index");
      return  true;
    }
    else{
      return false;
    }
    
      
    
  }
}