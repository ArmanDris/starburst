import gleam/httpc

pub fn connect_err_to_str(conn_err: httpc.ConnectError) -> String {
  case conn_err {
    httpc.Posix(code) -> "Posix err " <> code
    httpc.TlsAlert(code, detail) ->
      "Tls Alert code " <> code <> ", detail: " <> detail
  }
}

pub fn httpc_err_to_str(httpc_err: httpc.HttpError) -> String {
  case httpc_err {
    httpc.InvalidUtf8Response -> "Invalid Utf8 response"
    httpc.FailedToConnect(a, b) ->
      connect_err_to_str(a) <> ", " <> connect_err_to_str(b)
  }
}
