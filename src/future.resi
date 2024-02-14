/**
 Similar to the existing result type with with a Cancelled variant
 */
type result<'a, 'e> = Ok('a) | Error('e) | Cancelled

/**
 lazy value that holds an asynchronous action that might result in failure.
 */
type future<'a, 'e> = {
  value: unit => promise<result<'a, 'e>>,
  cancelled: ref<bool>,
  controller: option<Webapi.Fetch.AbortController.t>,
}

/**
 Create a `future` from a lazy function that returns a `promise`.
 
 ```rescript
  let request = Future.make(() => Webapi.Fetch.fetch("http://httpstat.us/200"))
 ```
 */
let make: (unit => promise<'a>, ~controller: Webapi.Fetch.AbortController.t=?) => future<'a, 'e>

/**
 Apply a function to the `Ok` value in a `future`. 
 If the value is an `Error` the function will not run.

```rescript
let _ =
  Future.make(() => Promise.make((res, _rej) => res(42)))
  ->Future.map(res => res + 1) // value is now 43
```
 */
let map: (future<'a, 'e>, 'a => 'b) => future<'b, 'e>

/**
 Apply a function to the `Error` value in a `future`. 
 If the value is `Ok` the function will not run.

```rescript
let number =
  Future.make(() => Promise.make((_res, rej) => rej({"message": "There was an error"})))
  ->Future.mapError(err => err["message"])
```
 */
let mapError: (future<'a, 'e>, 'e => 'b) => future<'a, 'b>

/**
Apply a function to an `Ok` value that returns a `promise`.

```rescript
Future.mapPromise(res => res->Fetch.Response.json)
```
 */
let mapPromise: (future<'a, 'e>, 'a => promise<'b>) => future<'d, 'e>

/**
Applies a function to an `Ok` value that returns a `result`.
```rescript
Future.flatMap(res => {
  switch res->Fetch.Response.ok {
  | true => Ok(res)
  | false =>
    Error(`${res->Fetch.Response.status->Int.toString}: ${res->Fetch.Response.statusText}`)
  }
})
```
 */
let flatMap: (future<'a, 'f>, 'a => result<'b, 'f>) => future<'b, 'f>

type successFn<'a> = 'a => unit
type errorFn<'a> = 'a => unit

/**
 Run the `future` and then call an error or a success function with the results.
 */
let fold: (future<'t, 'f>, errorFn<'f>, successFn<'t>) => RescriptCore.Promise.t<unit>

/**
 Runs the `future` and returns a promise with the results. Useful for `async`/`await` syntax.
 ```rescript
 let fn = async () =>
  switch await request->Future.run {
  | Ok(data) => Console.log(data)
  | Error(err) => Console.error(err)
  | Cancelled => Console.log("request was cancelled")
  }

 ```
 */
let run: future<'a, 'e> => promise<result<'a, 'e>>

/**
 Cancel a future terminating it early and preventing any other functions to run

```rescript
let _ = request->Future.cancel
```
*/
let cancel: future<'a, 'e> => unit

/**
 Use 2 futures with `Promise.all2`.
 */
let all2: ((future<'a, 'e>, future<'b, 'f>)) => future<('a, 'b), (option<'e>, option<'f>)>

/**
 Use 3 futures with `Promise.all3`.
 */
let all3: ((future<'a, 'e>, future<'b, 'f>, future<'c, 'e>)) => future<
  ('a, 'b, 'c),
  (option<'e>, option<'f>, option<'e>),
>

/**
 Easily make a `future` using `Webapi.Fetch.fetch`.
 Attaches an Abort controller to call when cancelling the future.
 */
let fetch: string => future<Webapi.Fetch.response, 'a>

/**
 Easily make a `future` using `Webapi.Fetch.fetchWithInit`.
 You have to manually pass in the Abort controller to call when cancelling the future.
 */
let fetchWithInit: (
  string,
  Webapi.Fetch.requestInit,
  Webapi.Fetch.AbortController.t,
) => future<Webapi.Fetch.response, 'a>

/**
 Easily make a `future` using `Webapi.Fetch.fetchWithRequest`.
 Attaches an Abort controller to call when cancelling the future.
 */
let fetchWithRequest: Webapi.Fetch.request => future<Webapi.Fetch.response, 'a>

/**
 Easily make a `future` using `Webapi.Fetch.fetchWithRequestInit`.
 You have to manually pass in the Abort controller to call when cancelling the future.
 */
let fetchWithRequestInit: (
  Webapi.Fetch.request,
  Webapi.Fetch.RequestInit.t,
  Webapi.Fetch.AbortController.t,
) => future<Webapi.Fetch.response, 'a>
