import gleam/dynamic
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string_builder.{type StringBuilder}
import quote.{type Quote}

const tronalddump_url = "https://www.tronalddump.io"

pub fn get_quote() -> Result(Quote, String) {
  use resp <- result.try(make_request("/random/quote"))

  case json.decode(from: resp.body, using: quote.deserialize()) {
    Ok(quote) -> Ok(quote)
    Error(error) ->
      case error {
        json.UnexpectedFormat(errors) -> handle_unexpected_error(errors)
        _ -> Error("Failed to deccode quote")
      }
  }
}

fn make_request(path: String) -> Result(Response(String), String) {
  let assert Ok(req) = request.to(tronalddump_url <> path)
  let resp_result =
    req
    |> request.prepend_header("accept", "application/json")
    |> httpc.send
    |> result.replace_error(
      "Failed to make request to Tronalddump API: " <> path,
    )

  use resp <- result.try(resp_result)

  case resp.status {
    200 -> Ok(resp)
    _ ->
      Error(
        "Got status "
        <> int.to_string(resp.status)
        <> " from Tronalddump API: "
        <> path,
      )
  }
}

fn handle_unexpected_error(
  errors: List(dynamic.DecodeError),
) -> Result(_, String) {
  hue(errors, string_builder.new())
}

fn hue(
  errors: List(dynamic.DecodeError),
  message: StringBuilder,
) -> Result(_, String) {
  case errors {
    [] -> Error(string_builder.to_string(message))
    [first, ..rest] -> hue(rest, join_error(message, first))
  }
}

fn join_error(
  string: StringBuilder,
  error: dynamic.DecodeError,
) -> StringBuilder {
  let assert Ok(field) = list.first(error.path)
  string
  |> string_builder.append("\n")
  |> string_builder.append(
    "Failed to decode quote for field '"
    <> field
    <> "'. Found: '"
    <> error.found
    <> "' Expected: '"
    <> error.expected
    <> "'",
  )
}
