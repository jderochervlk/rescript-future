open Webapi

let _ =
  Future.fetch("http://httpstat.us/200")
  ->Future.flatMap(res => {
    switch res->Fetch.Response.ok {
    | true => Ok(res)
    | false =>
      Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
    }
  })
  ->Future.map(res => res->Fetch.Response.statusText)
  ->Future.fold(Console.error, Console.log) // logs OK

/** fetch request with an invalid response */
let _ =
  Future.fetch("http://httpstat.us/500")
  ->Future.flatMap(res => {
    switch res->Fetch.Response.ok {
    | true => Ok(res)
    | false =>
      Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
    }
  })
  ->Future.map(res => res->Fetch.Response.statusText)
  ->Future.fold(Console.error, Console.log)

// you can cancel a future
let request = Future.fetch("http://httpstat.us/404?sleep=1000")->Future.flatMap(res => {
  Console.log("doing things with response") // this will never log if we cancel before the response comes back
  switch res->Fetch.Response.ok {
  | true => Ok(res)
  | false => Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
  }
})

// call slow request
let _ = request->Future.fold(Console.error, Console.log)

// cancel before it's done and nothing will be logged to the console
let _ = request->Future.cancel
