type time = int
(* missing F#'s units of measure *)
(* https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure *)
type duration = int (* seconds *)
type location = { name: string option; lat: int; lon: int }
type distance = int (* meter *)


module Modules = struct
  module type Range = functor (X: sig type t end) -> sig
    val a: X.t
    val b: X.t
  end

  module type Activity = sig
    (* should implement Range with time, but we want aliases *)
    val start: time
    val stop: time
    val location: location option
    (* val duration: duration (* should be computed *) *)
  end
  (* computed duration via ugly mixin *)
  module Activity (X: Activity) = struct
    include X
    let duration = stop - start
  end

  module type Sport = sig
    include Activity
    type sport = Run | Swim
    val sport: sport (* to differentiate subtypes *)
    (* elapsed_time should be an alias for computed duration *)
    val distance: distance
    val moving_time: duration
  end
  module Sport (X: Activity) = struct
    type sport = Run | Swim
    include Activity (X)
  end

  module type Run = sig
    include Sport
    val track: location list
  end
  module Run (X: Activity) = struct
    include Sport (X)
    let sport = Run
    let location = None
  end

  module Run1 : Run = struct
    include Run (struct
      let start = 0
      let stop = 0
      let location = None
    end)
    let distance = 0
    let moving_time = 0
    let track = []
  end
  (* works, but this is super verbose and ugly... *)
end


module Records = struct
  type activity = { start: time; stop: time; }
  type sport_kind = Run | Swim
  type sport = {
    start: time; stop: time; (* ugly, but there's no way to extend/include a record *)
    kind: sport_kind; distance: distance;
  }
  type run = {
    (* activity *) start: time; stop: time;
    (* sport *) kind: sport_kind; distance: distance;
    (* run *) track: location list;
  }
  let a = { start = 1; stop = 2; } (* inferred activity *)
  let s = { start = 1; stop = 2; kind = Run; distance = 0; } (* inferred sport *)
  let r = { start = 1; stop = 2; kind = Run; distance = 0; track = []} (* inferred run *)
  
  (* this all works, but we have no row polymorphism, so the following will just work on run since it was defined last :( *)
  let duration a = a.stop - a.start
  (* let _ = duration a, duration s, duration r *)
end


(* objects have row polymorphism! *)
module Objects = struct
  type activity = < start: time; stop: time; >
  type sport_kind = Run | Swim
  type sport = < activity; kind: sport_kind; distance: distance; >
  type run = < sport; track: location list; >
  (* type defs above are nice, but value defs below ugly *)
  let a = object method start = 1 method stop = 2 end
  let s = object method start = 1 method stop = 2 method kind = Run method distance = 0; end
  let r = object method start = 1 method stop = 2 method kind = Run method distance = 0 method track = [] end
  
  let duration a = a#stop - a#start (* yay! < start: int; stop: int; .. > -> int *)
  let _ = duration a, duration s, duration r

  (* there's no way to inherit/extend an object, only a class, but we can make a class based on some object type: *)
  class c_sport (s: sport) = object method start = s#start method stop = s#stop method kind = s#kind method distance = s#distance end
  let add_track (*: sport -> run *) = fun s -> object
    inherit c_sport s (* only inherhits sport, even if s was more *)
    method track = []
  end
  (* so we can't use this polymorphically to extend any `< start: int; stop: int; .. >` by e.g. `duration: int` after it's created since classes are closed: *)
  class c_activity (a: < start: time; stop: time; .. >) = object method start = a#start method stop = a#stop method duration = a#stop - a#start end
  let s' = new c_activity s (* adds duration but loses others *)
  (* could only use class as mixin; the following does not work, though ('The instance variable self cannot be accessed from the definition of another instance variable'): *)
  (* let a' = object (self) method start = 1 method stop = 2 inherit c_activity self end *)
  (* like this, it works (s' is < sport; duration: int >): *)
  let s' = object inherit c_activity (object method start = 1 method stop = 2; end) method kind = Run method distance = 0 end
  (* the result is no longer sport though! ('This expression has type < distance : int; duration : int; kind : sport_kind; start : time; stop : time > but an expression was expected of type sport The second object type has no method duration') *)
  (* let _: sport = s' *)
  type 'a sport_r = < activity; kind: sport_kind; distance: distance; .. > as 'a
  let _: 'a sport_r = s'
  let _: sport = (s' :> sport)

  (* also see https://discuss.ocaml.org/t/extensible-records-in-ocaml/2153 *)
end
