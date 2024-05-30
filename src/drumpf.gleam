import gleam/io
import resp

pub fn main() {
  resp.get_quote()
  |> io.debug
}
