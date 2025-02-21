import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/result.{map}
import internal/misc_helpers

pub fn ping_interview_api(sub) {
  let req =
    request.to("https://xn--rl8hlm.tk/thank")
    |> map(fn(req) {
      request.prepend_header(req, "accept", "application/vnd.hmrc.1.0+json")
      |> request.set_method(http.Post)
    })

  case req {
    Error(_) -> process.send(sub, "Error creating request body")
    Ok(req) -> {
      let resp = httpc.send(req)
      case resp {
        Error(a) -> process.send(sub, misc_helpers.httpc_err_to_str(a))
        Ok(b) -> process.send(sub, int.to_string(b.status) <> " " <> b.body)
      }
    }
  }
}
