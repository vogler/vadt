type time = number
type distance = number
type position = { lat: number, lon: number }
type location = position & { name: string }

// can use type or interface (only difference is reporting (interface: name, type: content), see https://www.typescriptlang.org/docs/handbook/advanced-types.html#interfaces-vs-type-aliases)
type ActivityT = { start: time, stop: time }
interface Activity {
  start: time
  stop: time
}

// approach 1
abstract class ActivityExt implements Activity { // ActivityT also works here
  start: time
  stop: time
  duration = this.stop - this.start
}

// approach 2
const duration = (x: Activity) => x.stop - x.start

// approach 3
const add_duration = <T extends Activity>(x: T) => ({...x, duration: x.stop - x.start})

enum Sport_kind { Run, Swim }
interface Sport extends Activity {
  kind: "run" | "swim"
  kind_enum: Sport_kind
  distance: distance
}

interface Run extends Sport {
  track: position[]
}

const a: Activity = { start: 1, stop: 2 }
const s: Sport = { ...a, kind: "run", kind_enum: Sport_kind.Run, distance: 0 }
const r: Run = { ...s, track: [] }
const x1 = add_duration(a);
const x2 = add_duration(s);
const x3 = add_duration(r);
