// this has to come first so that we can run it with just `java test.java`
class Test {
  public static void main(String[] args) {
    // approach 1
    var a = new Activity() {
      int start(){ return 1; }
      int stop(){ return 3; }
    };
    System.out.println(a.duration());
    var r = new Run() {
      // can't include a here?
      int start(){ return 1; }
      int stop(){ return 3; }
      int distance(){ return 4; }
      Location[] track() { return new Location[] { new Location(1, 2) }; }
    };
    System.out.println(r.duration() + ", " + r.distance()); // no vararg overload?

    // approach 2
    // System.out.println(ActivityI.duration(a));
    // above does not work because Activity is not a supertype of ActvityI without `implements ActivityI` (nominal instead of structural typing)
    // instead we could define the static method in Activity and call it on a or pass it a new object of ActivityI:
    var ai = new ActivityI() {
      // interface methods are implicitly public, class methods are not; so we need to add public to be able to create an anonymous class from the interface
      public int start(){ return 1; }
      public int stop(){ return 3; }
    };
    System.out.println(ActivityI.duration(ai));
  }
}

// base types
class Location { // so much code for a record...
  int lat;
  int lon;
  Location(int lat, int lon) {
    this.lat = lat;
    this.lon = lon;
  }
}

// approach 1 by extending abstract classes
abstract class Activity {
  // int start;
  // fields can't be made abstract 
  // they are zeroed by default and we are not forced to define them in children
  // so we have to rely on functions:
  abstract int start();
  abstract int stop();
  int duration() {
    return stop() - start();
  }
}

abstract class Sport extends Activity {
  enum sport_kind { Run, Swim };
  abstract sport_kind kind();
  abstract int distance();
}

abstract class Run extends Sport {
  sport_kind kind(){
    return sport_kind.Run;
  }
  abstract Location[] track();
}

// approach 2
interface ActivityI {
  // interface methods are implicitly public!
  int start();
  int stop();
  static int duration(ActivityI x) {
    return x.stop() - x.start();
  }
}
