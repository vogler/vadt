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
  let a = object method start = 1; method stop = 2; end
  let s = object method start = 1; method stop = 2; method kind = Run; method distance = 0; end
  let r = object method start = 1; method stop = 2; method kind = Run; method distance = 0; method track = [] end
  
  let duration a = a#stop - a#start (* yay! < start: int; stop: int; .. > -> int *)
  let _ = duration a, duration s, duration r
end
