import gleam/dynamic

pub type Quote {
  Quote(value: String, subjects: List(String))
}

pub fn deserialize() {
  dynamic.decode2(
    Quote,
    dynamic.field("value", of: dynamic.string),
    dynamic.field("tags", of: dynamic.list(of: dynamic.string)),
  )
}
