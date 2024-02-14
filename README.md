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

## Examples
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