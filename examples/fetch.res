open Webapi

/** fetch request with a valid response */
let _ =
  Future.make(() => Fetch.fetch("http://httpstat.us/200"))
  ->Future.flatMap(res => {
    switch res->Fetch.Response.ok {
    | true => Ok(res)
    | false =>
      Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
    }
  })
  ->Future.map(res => res->Fetch.Response.statusText)
  ->Future.fold(Console.error, Console.log)

/** fetch request with an invalid response */
let _ =
  Future.make(() => Fetch.fetch("http://httpstat.us/500"))
  ->Future.flatMap(res => {
    switch res->Fetch.Response.ok {
    | true => Ok(res)
    | false =>
      Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
    }
  })
  ->Future.map(res => res->Fetch.Response.statusText)
  ->Future.fold(Console.error, Console.log)
