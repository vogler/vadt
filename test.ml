(* As an example, we define some types/modules activity < sport < run.
 * We test how to define `duration` for all of them via:
 * 1. include/mixin: extend each data type at definition
 * 2. subtyping: a function defined outside which accepts all of them as parameter
 * 3. generic extension (needs row polymorphism): a function which adds `duration` for any of them without limiting the original type
 * Each module is a different approach; the comment before says what it supports, e.g. [1,2] for mixin and subtyping.
 *)

(* define some units to use *)
type time = int (* seconds *)
type duration = int (* seconds *)
type location = { name: string option; lat: int; lon: int }
type distance = int (* meter *)
(* missing F#'s units of measure https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure *)


(* [1,2] mixin via functor, subtyping via duck typing on first class modules *)
module Modules = struct
  (* module type Range = functor (X: sig type t end) -> sig *)
  (*   val a: X.t *)
  (*   val b: X.t *)
  (* end *)
  module type ActivityBase = sig
    (* should implement Range with time, but we want aliases *)
    val start: time
    val stop: time
    (* val duration: duration (* should be computed *) *)
  end
  module type Activity = sig
    include ActivityBase
    val duration: duration
  end
  (* extend duration via functor *)
  module Activity (X: ActivityBase) = struct
    include X
    let duration = stop - start
  end
  (* The problem is that X is limited to ActivityBase, so we could only use it around the definition of a Activity. *)

  module type Sport = sig
    include Activity
    type sport_kind = Run | Swim
    val kind: sport_kind (* to differentiate subtypes? *)
    (* elapsed_time should be an alias for computed duration *)
    val distance: distance
  end
  module Sport (X: ActivityBase) = struct
    type sport_kind = Run | Swim
    include Activity (X)
  end

  module type Run = sig
    include Sport
    val track: location list
  end
  module Run (X: ActivityBase) = struct
    include Sport (X)
    let kind = Run
  end

  (* test 1: define a Run with functor mixin to add duration *)
  module Run1 : Run = struct
    include Run (struct
      let start = 1
      let stop = 2
    end)
    let distance = 0
    let track = []
  end
  (* works, but this is super verbose and ugly... *)

  (* test 2 (subtyping on modules): define a duration function *)
  let duration (module X: ActivityBase) = X.stop - X.start

  (* test 3 does not work with modules *)
end


(* normal records [1] *)
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

  (* test 1: to add duration we need to define a new extended type for each type and also a function to extend each type: *)
  type c_activity = { start: time; stop: time; duration: time; }
  (* let c_activity (a: activity) = { a with duration = a.stop - a.start } (* does not work *) *)
  let c_activity (a: activity) = { start = a.start; stop = a.stop; duration = a.stop - a.start }
  (* same for c_sport and c_run... *)
  
  (* test 2: we have no polymorphism, so the following will just work on run since it was defined last :( *)
  let duration a = a.stop - a.start
  (* let _ = duration a, duration s, duration r *)

  (* test 3 does not work with records *)
end


(* [1,2] objects have row polymorphism but can't extend objects! *)
module Objects = struct
  type activity = < start: time; stop: time; >
  type sport_kind = Run | Swim
  type sport = < activity; kind: sport_kind; distance: distance; >
  type run = < sport; track: location list; >
  (* type defs above are nice, but value defs below ugly *)
  let a = object method start = 1 method stop = 2 end
  let s = object method start = 1 method stop = 2 method kind = Run method distance = 0; end
  let r = object method start = 1 method stop = 2 method kind = Run method distance = 0 method track = [] end
  
  (* test 2 *)
  let duration a = a#stop - a#start (* yay! < start: int; stop: int; .. > -> int *)
  let _ = duration a, duration s, duration r

  (* test 3: there's no way to inherit/extend an object, only a class, but we can make a class based on some object type: *)
  class c_sport (s: sport) = object method start = s#start method stop = s#stop method kind = s#kind method distance = s#distance end
  let add_track (*: sport -> run *) = fun s -> object
    inherit c_sport s (* only inherhits sport, even if s was more *)
    method track = []
  end
  (* so we can't use this polymorphically to extend any `< start: int; stop: int; .. >` by e.g. `duration: int` after it's created since classes are closed: *)
  class c_activity (a: < start: time; stop: time; .. >) = object method start = a#start method stop = a#stop method duration = a#stop - a#start end
  let s' = new c_activity s (* adds duration but loses others *)

  (* test 1: can only use class as mixin; using self does not work though: *)
  (* let a' = object (self) method start = 1 method stop = 2 inherit c_activity self end (* error 'The instance variable self cannot be accessed from the definition of another instance variable' *) *)
  (* like this, it works (s' is < sport; duration: int >): *)
  let s' = object inherit c_activity (object method start = 1 method stop = 2; end) method kind = Run method distance = 0 end
  (* the result is no longer sport though: *) 
  (* let _: sport = s' (* error 'This expression has type < distance : int; duration : int; kind : sport_kind; start : time; stop : time > but an expression was expected of type sport The second object type has no method duration' *) *)
  type 'a sport_r = < activity; kind: sport_kind; distance: distance; .. > as 'a
  let _: 'a sport_r = s'
  let _: sport = (s' :> sport)

  (* also see https://discuss.ocaml.org/t/extensible-records-in-ocaml/2153 *)
end

(* use lists of polymorphic variants which also have subtyping *)
module PolyVariants = struct
  (* both [`A 1; `B ""] and [`B ""; `A 1] have type [> `A of int | `B of string ] list *)
  type activity = [ `Start of time | `Stop of time ]
  type sport_kind = Run | Swim
  type sport = [ activity | `Kind of sport_kind | `Distance of distance ]
  type run = [ sport | `Track of location list ]
  type 'a t = 'a list
  let a = [`Start 1; `Stop 2]
  let _: activity t = a (* a: [> `Start of int | `Stop of int ] list *)
  let s = a @ [`Kind Run; `Distance 0]
  let r = s @ [`Track []]
  
  let rec start = function `Start x :: xs -> x | x::xs -> start xs | [] -> assert false
  (* val start : [> `Start of 'a ] list -> 'a *)
  (* We could still call `start []` or `start [`Stop 2]` and it would fail at runtime. [] we could eliminate by using non-empty lists. *)

  (* non-empty list *)
  type 'a nel = Nil of 'a | Cons of 'a * 'a nel

  let rec start = function Cons (`Start x, xs) -> x | Cons (x, xs) -> start xs | Nil x -> x
  (* val start : ([> `Start of 'a ] as 'a) nel -> 'a *)
  (* start (Nil (`Stop 2)) = `Stop 2 *)

  let rec start = function Cons (`Start x, xs) -> x | Cons (x, xs) -> start xs | Nil (`Start x) -> x
  (* Warning that second match case is unused. *)
  (* val start : [< `Start of 'a ] nel -> 'a *)
  (* but this allows only `Start and nothing else... *)

  let rec start = function Cons (`Start x, xs) -> x | Cons (x, xs) -> start xs | Nil (`Start x) -> x | Nil x -> assert false
  (* val start : [> `Start of 'a ] nel -> 'a *)
end
