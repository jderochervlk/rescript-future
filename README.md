# @jvlk/rescript-future
## Installation

```sh
npm install @vlk/rescript-future
```

Update `rescript.json`.
```json
{
    "bs-dependencies": [
        "@jvlk/rescript-future"
        ]
}
```

## Basic Example
```rescript
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
  ->Future.fold(Console.error, Console.log)
```
More examples can be found in the `examples` directory.

###
```rescript
@react.component
let make = () => {
  let request = Future.fetch("http://httpstat.us/200?sleep=1000")
  <div>
    <button
      onClick={_ => {
        request->Future.reset // reset the future to make sure the Abort Controller is new
        Console.log("clicked!")
        let _ = request->Future.fold(Console.error, Console.log)
      }}>
      {"Start"->React.string}
    </button>
    <button
      onClick={_ => {
        let _ = request->Future.cancel // Aborts the fetch request and stops any processing of the response
      }}>
      {"Cancel"->React.string}
    </button>
  </div>
}
```
