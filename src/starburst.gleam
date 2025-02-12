import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleeunit/should

fn format_response(resp: response.Response(String)) -> String {
  string.join([int.to_string(resp.status), resp.body], " ")
}

fn ping_interview_api() {
  let assert Ok(base_req) = request.to("https://interview-api.skillsync.site")

  let req =
    request.prepend_header(base_req, "accept", "application/vnd.hmrc.1.0+json")

  use resp <- result.try(httpc.send(req))

  resp.status |> should.equal(404)

  resp
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  resp.body
  |> should.equal("{\"detail\":\"Not Found\"}")

  io.println(format_response(resp))
  Ok(resp)
}

pub fn main() {
  ping_interview_api()
}
