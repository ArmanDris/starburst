import argv
import gleam.{Error}
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{map_error, try}
import gleam/string
import internal/draw_map
import internal/send_request

fn get_arg_as_int(args: List(String)) -> Result(Int, String) {
  use arg <- try(case args {
    [] -> Ok("5")
    [a] -> Ok(a)
    _ -> Error("Usage: starburst <num_requests>")
  })

  int.parse(arg)
  |> map_error(fn(_) { "Could not parse " <> arg <> " as an int" })
}

fn helper_spawn_n_processes(
  results: List(String),
  count: Int,
  num_processes_to_spawn: Int,
  subject,
) -> List(String) {
  case count >= num_processes_to_spawn {
    True -> {
      case list.length(results) >= num_processes_to_spawn {
        True -> results
        False -> {
          let msg = process.receive(subject, 1000)
          let new_item = case msg {
            Ok(s) -> s
            Error(_) -> "Did not receive message"
          }
          helper_spawn_n_processes(
            [new_item, ..results],
            count,
            num_processes_to_spawn,
            subject,
          )
        }
      }
    }
    False -> {
      process.start(fn() { send_request.ping_interview_api(subject) }, False)
      helper_spawn_n_processes(
        results,
        count + 1,
        num_processes_to_spawn,
        subject,
      )
    }
  }
}

fn spawn_n_processes(n: Int) -> List(String) {
  helper_spawn_n_processes([], 0, n, process.new_subject())
}

pub fn main() -> Result(Nil, String) {
  use num <- try(get_arg_as_int(argv.load().arguments))

  let result = "[" <> string.join(spawn_n_processes(num), " ") <> "]"
  io.println(result)

  draw_map.draw_ascii_map("drismir.ca")

  Ok(Nil)
}
