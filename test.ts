type time = number
type distance = number
type position = { lat: number, lon: number }
type location = position & { name: string }

interface Activity {
  start: time
  stop: time
}

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
