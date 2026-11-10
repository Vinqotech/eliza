// bridge.ts: two accepted credentials share one unchanged Redis connection.
// One request, three credential classes. Provider completion and deployment
// atomicity are outside this authentication model.
module RedisBridgeCredentials {
  var s: { primary: bool, secondary: bool, credential: str, phase: str, forwards: int, containerCredential: str }
  action init = {
    nondet primary = Set(false, true).oneOf()
    nondet secondary = Set(false, true).oneOf()
    all { s' = { primary: primary, secondary: secondary, credential: "", phase: "ready", forwards: 0, containerCredential: "" } }
  }
  action submit = {
    nondet credential = Set("primary", "secondary", "invalid").oneOf()
    all { s.phase == "ready", s' = { ...s, credential: credential, phase: "checking" } }
  }
  val authorized = s.primary and (s.credential == "primary" or (s.secondary and s.credential == "secondary"))
  action check = all {
    s.phase == "checking",
    s' = { ...s, phase: "finished", forwards: if (authorized) 1 else 0, containerCredential: if (authorized) "primary" else "" }
  }
  action idle = s' = s
  action step = any { submit, check, idle }
  val safety = all {
    s.forwards <= 1,
    s.forwards == 1 implies (authorized and s.containerCredential == "primary"),
    not(s.primary) implies s.forwards == 0,
    s.credential == "invalid" implies s.forwards == 0
  }
}
